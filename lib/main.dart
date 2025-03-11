import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/heart_rate_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    // Wrap the entire app with ProviderScope for Riverpod
    const ProviderScope(
      child: HeartRateApp(),
    ),
  );
}

/// The main application widget
class HeartRateApp extends StatelessWidget {
  const HeartRateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heart Rate Monitor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const HeartRateScreen(),
    );
  }
}
