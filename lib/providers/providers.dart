import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import 'marketplace_provider.dart';
import '../models/auth_state.dart';

final firebaseReadyProvider = Provider<bool>((ref) => false);
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) => AuthController(ref));

final marketplaceControllerProvider =
    StateNotifierProvider<MarketplaceController, MarketplaceState>((ref) {
  final controller = MarketplaceController();

  // Rebind the applications stream whenever the authenticated identity changes
  // (login, logout, or role switch) so the pipeline always matches the user.
  ref.listen<AuthState>(
    authControllerProvider,
    (previous, next) {
      final uid = next.onboardingComplete ? FirebaseAuth.instance.currentUser?.uid : null;
      controller.onAuthChanged(next.role, uid, next.displayName);
    },
    fireImmediately: true,
  );

  return controller;
});

final selectedTabProvider = StateProvider<int>((ref) => 0);
