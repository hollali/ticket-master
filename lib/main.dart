import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/auth_provider.dart' as auth_provider;
import 'core/theme.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://rwxzojhvnlnskgodrqqh.supabase.co',
    publishableKey: 'sb_publishable_ykrkZB5QvVBYso3I_r-N1Q_7V5jm5Vq',
  );
  runApp(const TicketMasterApp());
}

class TicketMasterApp extends StatelessWidget {
  const TicketMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => auth_provider.AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Ticket Master',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
