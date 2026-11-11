import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as auth_provider;
import '../../core/theme.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['name']?.toString() ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : (user?.email?.isNotEmpty == true ? user!.email![0].toUpperCase() : '?');
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(radius: 44, backgroundColor: AppTheme.primary, child: Text(initial, style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold))),
            const SizedBox(height: 16),
            Text(name.isNotEmpty ? name : 'User', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)),
            Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  ListTile(leading: const Icon(Icons.email_outlined), title: Text(user?.email ?? '')),
                  ListTile(leading: const Icon(Icons.badge_outlined), title: Text('Role: user')),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              onPressed: () async {
                await context.read<auth_provider.AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
