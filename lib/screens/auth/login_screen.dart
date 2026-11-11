import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as auth_provider;
import '../../core/theme.dart';
import 'register_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<auth_provider.AuthProvider>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primary, AppTheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.confirmation_number, size: 56, color: AppTheme.primary),
                    const SizedBox(height: 8),
                    Text('Ticket Master', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text('Sign in to continue', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 24),
                    TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
                    const SizedBox(height: 12),
                    TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outlined)), obscureText: true),
                    const SizedBox(height: 16),
                    if (auth.error != null) ...[
                      Text(auth.error!, style: TextStyle(color: Colors.red.shade700)),
                      const SizedBox(height: 8),
                    ],
                    ElevatedButton(
                      onPressed: auth.loading ? null : () async {
                        final ok = await context.read<auth_provider.AuthProvider>().login(_email.text.trim(), _password.text.trim());
                        if (ok && context.mounted) {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
                        }
                      },
                      child: auth.loading
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Login'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: const Text('Create account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
