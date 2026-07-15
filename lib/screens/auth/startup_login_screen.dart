import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'startup_register_screen.dart';

class StartupLoginScreen extends StatelessWidget {
  const StartupLoginScreen({super.key, required this.onLogin, required this.onRegister});

  final Future<void> Function(String email, String password, String displayName) onLogin;
  final Future<void> Function(String email, String password, String displayName) onRegister;

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      roleLabel: 'Startup',
      onComplete: onLogin,
      registerPageBuilder: (_) => StartupRegisterScreen(onComplete: onRegister),
    );
  }
}

