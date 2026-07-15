import 'package:flutter/material.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.roleLabel,
    required this.onComplete,
    this.registerPageBuilder,
  });

  final String roleLabel;
  final Future<void> Function(String email, String password, String displayName) onComplete;
  final WidgetBuilder? registerPageBuilder;


  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _continueAsRole() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.onComplete(
        _emailController.text,
        _passwordController.text,
        '',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
      return;
    }

    if (!mounted) {
      return;
    }

    // Login/register screens are pushed on top of AppGate, so a state flip
    // alone doesn't reveal MarketplaceShell underneath — pop back to it.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }


  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: widget.registerPageBuilder ??
            (_) => RegisterScreen(roleLabel: widget.roleLabel, onComplete: widget.onComplete),
      ),
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
              decoration: const InputDecoration(labelText: 'Email'),
            ),

            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loading ? null : _continueAsRole,
              child: _loading ? const CircularProgressIndicator() : const Text('Continue'),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _openRegister, child: const Text('Create an account')),
          ],
        ),
      ),
    );
  }
}
