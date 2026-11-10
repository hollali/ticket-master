import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart' as auth_provider;
import 'core/theme.dart';
import 'screens/splash_screen.dart';

bool firebaseReady = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    firebaseReady = true;
  } catch (e) {
    firebaseReady = false;
  }
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
        home: firebaseReady ? const SplashScreen() : const _ConfigMissingScreen(),
      ),
    );
  }
}

class _ConfigMissingScreen extends StatelessWidget {
  const _ConfigMissingScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text('Firebase not configured', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Run `flutterfire configure` and replace lib/firebase_options.dart with your project values.', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
