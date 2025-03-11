import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/heart_rate_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    // Wrap the entire app with ProviderScope for Riverpod
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// The main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heart Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF6B9AC4),
          secondary: const Color(0xFFEF959C),
          tertiary: const Color(0xFF97C1A9),
          background: const Color(0xFFF8F9FA),
          surface: Colors.white,
          error: const Color(0xFFE57373),
          onBackground: const Color(0xFF495057),
          onSurface: const Color(0xFF495057),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        textTheme: TextTheme(
          headlineMedium: TextStyle(
            color: const Color(0xFF495057),
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            color: const Color(0xFF495057),
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: const Color(0xFF495057),
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(
            color: const Color(0xFF495057),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.black12,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 2,
          ),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF495057),
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: const Color(0xFF495057),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const HeartRateScreen(),
    );
  }
}
