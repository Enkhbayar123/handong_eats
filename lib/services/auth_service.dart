import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

class AuthService {
  static UserModel? currentUser;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Checks if a user is logged in
  static bool get isLoggedIn => currentUser != null;

  /// Logs in the user by matching their email in the Firestore 'users' collection
  static Future<bool> login(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        currentUser = UserModel.fromFirestore(querySnapshot.docs.first);
        debugPrint('Logged in user: ${currentUser?.name}');
        return true;
      }
      
      // Fallback: Check if they are trying to log in with a seed email but Firestore hasn't been seeded yet
      if (email.trim() == 'student1@handong.ac.kr') {
        currentUser = UserModel(
          uid: 'user_1',
          email: 'student1@handong.ac.kr',
          studentId: '22000001',
          name: 'Jiwon Kim',
          profileImageUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80',
          dietaryLabels: ['Halal', 'Lactose-Free'],
          allergies: ['Peanuts'],
          pushNotificationsEnabled: true,
          favoriteMenuIds: ['rest_1_m2', 'rest_8_m3'],
          country: 'South Korea',
          spiceTolerance: 'Hot',
          preferredTastes: ['Spicy', 'Savory'],
        );
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error logging in: $e');
      return false;
    }
  }

  /// Signs up a new user, saves their profile to Firestore, and logs them in
  static Future<bool> signUp({
    required String email,
    required String name,
    required String studentId,
    required String country,
    required String spiceTolerance,
    required List<String> dietaryLabels,
    required List<String> allergies,
    required List<String> preferredTastes,
  }) async {
    try {
      final uid = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final newUser = UserModel(
        uid: uid,
        email: email.trim(),
        studentId: studentId.trim(),
        name: name.trim(),
        profileImageUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80', // Default gorgeous avatar
        dietaryLabels: dietaryLabels,
        allergies: allergies,
        pushNotificationsEnabled: true,
        favoriteMenuIds: [],
        country: country,
        spiceTolerance: spiceTolerance,
        preferredTastes: preferredTastes,
      );

      // Save to Firestore users collection
      await _firestore.collection('users').doc(uid).set(newUser.toMap());
      
      // Update session
      currentUser = newUser;
      debugPrint('Signed up new user: ${newUser.name}');
      return true;
    } catch (e) {
      debugPrint('Error signing up: $e');
      return false;
    }
  }

  /// Log out current session
  static void logout() {
    currentUser = null;
    debugPrint('Logged out current user session');
  }
}
