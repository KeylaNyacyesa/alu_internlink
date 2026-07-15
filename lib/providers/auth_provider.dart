import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/auth_state.dart';
import '../models/enums.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController(this.ref) : super(AuthState.initial());

  final Ref ref;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSubscription;

  /// Called after a successful signup or login.
  Future<void> completeOnboarding({
    required UserRole role,
    required String displayName,
  }) async {
    // On login the caller passes an empty name, so resolve the best available
    // display name: the one just entered, else the stored profile name, else a
    // readable fallback derived from the email.
    final resolvedName = await _resolveDisplayName(displayName);

    state = state.copyWith(
      onboardingComplete: true,
      role: role,
      displayName: resolvedName,
      verifiedStartup: role == UserRole.startup ? state.verifiedStartup : false,
    );

    await _ensureUserProfile(role: role, displayName: resolvedName);
    _bindProfileListener(role);
  }

  Future<String> _resolveDisplayName(String provided) async {
    final trimmed = provided.trim();
    if (trimmed.isNotEmpty) return trimmed;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return state.displayName;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final stored = doc.data()?['displayName'] as String?;
      if (stored != null && stored.trim().isNotEmpty) return stored.trim();
    } catch (_) {}

    final email = user.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return state.displayName;
  }


  /// Creates a persisted verification request for ALU moderation.
  /// After approval, security rules and UI depend on `users/{uid}.verifiedStartup`.
  Future<void> requestStartupVerification() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // If already verified, no-op.
    if (state.verifiedStartup) return;

    try {
      await FirebaseFirestore.instance
          .collection('startupVerificationRequests')
          .doc(uid)
          .set({
        'userId': uid,
        'requestedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    } catch (_) {}
  }


  Future<void> signOut() async {
    unawaited(_profileSubscription?.cancel());
    _profileSubscription = null;
    state = AuthState.initial();
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
  }


  Future<void> _ensureUserProfile({
    required UserRole role,
    required String displayName,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {
          'userId': uid,
          'role': role.label,
          'displayName': displayName,
          'verifiedStartup': role == UserRole.startup ? state.verifiedStartup : false,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // ignore: avoid_print
      print('[AuthController] Wrote Firestore user profile: $uid (${role.label})');
    } catch (e) {
      // ignore: avoid_print
      print('[AuthController] Failed to write Firestore user profile: $uid -> $e');
      rethrow;
    }
  }




  Future<void> registerWithEmailAndPassword({
    required String roleLabel,
    required String displayName,
    required String email,
    required String password,
  }) async {
    final emailTrimmed = email.trim();
    final passwordValue = password;
    final role = roleLabel == 'Startup' ? UserRole.startup : UserRole.student;

    // Basic sanity to avoid silent failures.
    if (emailTrimmed.isEmpty || passwordValue.isEmpty) {
      throw StateError('Email and password are required');
    }

    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: emailTrimmed, password: passwordValue);

    final uid = userCredential.user?.uid;
    if (uid == null) {
      throw StateError('FirebaseAuth returned a null user');
    }

    await completeOnboarding(role: role, displayName: displayName.trim());
  }

  Future<void> loginWithEmailAndPassword({
    required String roleLabel,
    required String displayName,
    required String email,
    required String password,
  }) async {
    final emailTrimmed = email.trim();
    final passwordValue = password;
    final role = roleLabel == 'Startup' ? UserRole.startup : UserRole.student;

    if (emailTrimmed.isEmpty || passwordValue.isEmpty) {
      throw StateError('Email and password are required');
    }

    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailTrimmed,
      password: passwordValue,
    );

    await completeOnboarding(role: role, displayName: displayName.trim());
  }



  /// Keeps `verifiedStartup` in sync with Firestore in real time, so an ALU
  /// admin approving a request from the console is reflected immediately in
  /// the app — without requiring the user to log out and back in.
  void _bindProfileListener(UserRole role) {
    unawaited(_profileSubscription?.cancel());
    _profileSubscription = null;

    if (role != UserRole.startup) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      _profileSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots()
          .listen((doc) {
        final verified = doc.data()?['verifiedStartup'];
        if (verified is bool) {
          state = state.copyWith(verifiedStartup: verified);
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    unawaited(_profileSubscription?.cancel());
    super.dispose();
  }
}
