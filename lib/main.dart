import 'package:flutter/material.dart';
import 'data/dictionary_repository.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const ZambiaSignHubApp());
}

class ZambiaSignHubApp extends StatelessWidget {
  const ZambiaSignHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Single shared repository instance, loaded once and reused
    // across every screen in the app.
    final repository = DictionaryRepository();

    const navy = Color(0xFF1E3A5C);

    return MaterialApp(
      title: 'SLCZ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: navy,
          primary: navy,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        scaffoldBackgroundColor: const Color(0xFFF2F2F0),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.bold, color: navy),
          headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: navy),
          titleLarge: TextStyle(fontWeight: FontWeight.bold, color: navy),
        ),
        // Large, clear tap targets throughout — important for an
        // accessibility-first app.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: navy,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: WelcomeScreen(repository: repository),
    );
  }
}
