import 'package:flutter/material.dart';
import 'screens/main_navigation.dart';

void main() {
  runApp(const HandongEatsApp());
}

class HandongEatsApp extends StatelessWidget {
  const HandongEatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Handong Eats',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}