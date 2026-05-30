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

  // ONE-TIME FIX: Remove fake review counts from database
  try {
    final menuItems = await FirebaseFirestore.instance
        .collection('menu_items')
        .get();
    for (var doc in menuItems.docs) {
      final reviews = await FirebaseFirestore.instance
          .collection('reviews')
          .where('menuItemId', isEqualTo: doc.id)
          .get();
      int count = reviews.docs.length;
      double totalRating = 0.0;
      for (var r in reviews.docs) {
        totalRating += (r['rating'] as num).toDouble();
      }
      double avgRating = count > 0 ? totalRating / count : 0.0;
      avgRating = double.parse(avgRating.toStringAsFixed(1));
      await doc.reference.update({
        'reviewCount': count,
        'averageRating': avgRating,
      });
    }
    debugPrint(
      "✅ Reviews database successfully cleaned and hardcoded numbers removed!",
    );
  } catch (e) {
    debugPrint("Error fixing reviews: $e");
  }

  // Auto-seed if database is empty to guarantee a working first-launch experience
  try {
    final rests = await FirebaseFirestore.instance
        .collection('restaurants')
        .limit(1)
        .get();
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
