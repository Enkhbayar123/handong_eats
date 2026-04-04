import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // <--- Import the login screen instead

void main() {
  runApp(const HandongEatsApp());
}

class HandongEatsApp extends StatelessWidget {
  const HandongEatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Handong Eats',
      debugShowCheckedModeBanner: false, // Turn off that little "DEBUG" banner in the corner!
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      home: const LoginScreen(), // <--- Set this as the initial route
    );
  }
}