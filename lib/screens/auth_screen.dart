import 'package:flutter/material.dart';
import '../data/auth_repository.dart';

enum _AuthMode { signIn, signUp }

class AuthScreen extends StatefulWidget {
  final AuthRepository authRepository;

  const AuthScreen({super.key, required this.authRepository});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  _AuthMode _mode = _AuthMode.signUp;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter an email and password.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final error = _mode == _AuthMode.signUp
        ? await widget.authRepository.signUp(email, password)
        : await widget.authRepository.signIn(email, password);

    if (!mounted) return;
    setState(() {
      _submitting = false;
      _error = error;
    });

    if (error == null) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email above first, then tap "Forgot password?".');
      return;
    }

    final error = await widget.authRepository.sendPasswordReset(email);
    if (!mounted) return;

    if (error != null) {
      setState(() => _error = error);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent to $email.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final navy = Theme.of(context).colorScheme.primary;
    final isSignUp = _mode == _AuthMode.signUp;

    return Scaffold(
      appBar: AppBar(title: const Text('SLCZ Premium')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isSignUp ? 'Create an ad-free account' : 'Sign in',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Requires internet once, to register. Ad-free access then works fully offline.',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: navy, foregroundColor: Colors.white),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(isSignUp ? 'Create account' : 'Sign in'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _submitting
                  ? null
                  : () => setState(() {
                        _mode = isSignUp ? _AuthMode.signIn : _AuthMode.signUp;
                        _error = null;
                      }),
              child: Text(isSignUp ? 'Already have an account? Sign in' : "Don't have an account? Sign up"),
            ),
            if (!isSignUp)
              TextButton(
                onPressed: _submitting ? null : _forgotPassword,
                child: const Text('Forgot password?'),
              ),
          ],
        ),
      ),
    );
  }
}
