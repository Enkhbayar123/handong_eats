import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'services/database_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Auto-seed if database is empty to guarantee a working first-launch experience
  try {
    final rests = await FirebaseFirestore.instance.collection('restaurants').limit(1).get();
    if (rests.docs.isEmpty) {
      await DatabaseSeeder.runAllSeeds();
    }
  } catch (e) {
    debugPrint("Auto-seeding check skipped/failed: $e");
  }

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

// change