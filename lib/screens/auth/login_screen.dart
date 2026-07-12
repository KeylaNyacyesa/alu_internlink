import 'package:flutter/material.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.roleLabel, required this.onComplete});

  final String roleLabel;
  final Future<void> Function() onComplete;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _continueAsRole() async {
    final navigator = Navigator.of(context);
    setState(() => _loading = true);
    await widget.onComplete();
    if (!mounted) {
      return;
    }

    navigator.popUntil((route) => route.isFirst);
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RegisterScreen(roleLabel: widget.roleLabel, onComplete: widget.onComplete)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign in - ${widget.roleLabel}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email (optional)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password (optional)'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loading ? null : _continueAsRole,
              child: _loading ? const CircularProgressIndicator() : const Text('Continue'),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _openRegister, child: const Text('Create an account')),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      final navigator = Navigator.of(context);
                      await widget.onComplete();
                      if (!mounted) {
                        return;
                      }

                      navigator.popUntil((route) => route.isFirst);
                    },
              child: const Text('Continue without account'),
            ),
          ],
        ),
      ),
    );
  }
}
