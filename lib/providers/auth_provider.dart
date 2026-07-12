import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/auth_state.dart';
import '../models/enums.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController(this.ref) : super(AuthState.initial());

  final Ref ref;

  Future<void> completeOnboarding(UserRole role) async {
    state = state.copyWith(
      onboardingComplete: true,
      role: role,
      displayName: role == UserRole.startup ? 'Startup Founder' : 'Amina Hassan',
    );
    await _tryFirebaseAuth(role);
  }

  void toggleStartupVerification() {
    state = state.copyWith(verifiedStartup: !state.verifiedStartup);
  }

  void signOut() {
    state = AuthState.initial();
  }

  Future<void> _tryFirebaseAuth(UserRole role) async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        return;
      }
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {
          'role': role.label,
          'displayName': state.displayName,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {}
  }
}
