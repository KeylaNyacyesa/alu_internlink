import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'student_register_screen.dart';

class StudentLoginScreen extends StatelessWidget {
  const StudentLoginScreen({super.key, required this.onLogin, required this.onRegister});

  final Future<void> Function(String email, String password, String displayName) onLogin;
  final Future<void> Function(String email, String password, String displayName) onRegister;

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      roleLabel: 'Student',
      onComplete: onLogin,
      registerPageBuilder: (_) => StudentRegisterScreen(onComplete: onRegister),
    );
  }
}

