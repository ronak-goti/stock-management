import 'package:flutter/material.dart';

import 'model/signup_screen.dart';
  // Import the sign-up screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stock Management App',
      theme: ThemeData(
        primaryColor: const Color(0xFF0D47A1),  // Deep blue for stock theme
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade700),  // Fixed: Use shade700 for non-nullable Color
        useMaterial3: true,
      ),
      home: SignUpScreen(),  // Start with sign-up screen
    );
  }
}