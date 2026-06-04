import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'services/database_seeder.dart';
import 'services/localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Failed to load .env file: $e");
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Force clean database refresh on this launch to remove all old menus
  try {
    debugPrint("Forcing database seeder refresh to remove old menus...");
    await DatabaseSeeder.runAllSeeds();
    debugPrint("Database seeder refresh complete.");
  } catch (e) {
    debugPrint("Database seeding failed: $e");
  }

  runApp(const HandongEatsApp());
}

class HandongEatsApp extends StatelessWidget {
  const HandongEatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LocalizationService.currentLanguage,
      builder: (context, currentLang, child) {
        return MaterialApp(
          title: 'Handong Eats',
          debugShowCheckedModeBanner:
              false, // Turn off that little "DEBUG" banner in the corner!
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
            useMaterial3: true,
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}

// change
