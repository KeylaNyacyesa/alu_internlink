import 'package:flutter/material.dart';

import 'register_screen.dart';


class StartupRegisterScreen extends StatelessWidget {
  const StartupRegisterScreen({super.key, required this.onComplete});

  final Future<void> Function(String email, String password, String displayName)
      onComplete;

  @override
  Widget build(BuildContext context) {
    return RegisterScreen(roleLabel: 'Startup', onComplete: onComplete);
  }
}

