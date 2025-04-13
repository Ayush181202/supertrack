import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const SupertrackApp());
}

class SupertrackApp extends StatelessWidget {
  const SupertrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supertrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF007BFF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007BFF),
          secondary: const Color(0xFF28A745),
          error: const Color(0xFFDC3545),
          background: const Color(0xFFF5F5F5),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Color(0xFF333333),
          ),
        ),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
} 