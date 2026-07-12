import 'enums.dart';

class AuthState {
  const AuthState({
    required this.onboardingComplete,
    required this.role,
    required this.displayName,
    required this.verifiedStartup,
  });

  factory AuthState.initial() => const AuthState(
        onboardingComplete: false,
        role: null,
        displayName: 'Amina Hassan',
        verifiedStartup: false,
      );

  final bool onboardingComplete;
  final UserRole? role;
  final String displayName;
  final bool verifiedStartup;

  AuthState copyWith({
    bool? onboardingComplete,
    UserRole? role,
    String? displayName,
    bool? verifiedStartup,
  }) {
    return AuthState(
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      verifiedStartup: verifiedStartup ?? this.verifiedStartup,
    );
  }
}
