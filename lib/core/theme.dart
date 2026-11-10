import 'package:flutter/material.dart';

class AppTheme {
  static final light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}
