import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/models.dart';

class GoogleSignInResult {
  final bool success;
  final bool isNewUser;
  final String? email;
  final String? name;
  final String? errorMessage;

  GoogleSignInResult({
    required this.success,
    this.isNewUser = false,
    this.email,
    this.name,
    this.errorMessage,
  });
}

class AuthService {
  static UserModel? currentUser;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  /// Checks if a user is logged in
  static bool get isLoggedIn => currentUser != null;

  /// Authenticates using Google Sign-In and Firebase Auth
  static Future<GoogleSignInResult> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize();
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: null,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return GoogleSignInResult(success: false, errorMessage: "Firebase sign-in failed.");
      }

      final String email = firebaseUser.email ?? '';
      final String name = firebaseUser.displayName ?? '';

      // Check if user already exists in Firestore by email
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        currentUser = UserModel.fromFirestore(querySnapshot.docs.first);
        debugPrint('Logged in existing Google user: ${currentUser?.name}');
        return GoogleSignInResult(success: true, isNewUser: false, email: email, name: name);
      } else {
        debugPrint('Google user not found in Firestore users collection.');
        return GoogleSignInResult(success: true, isNewUser: true, email: email, name: name);
      }
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      String errorMsg = e.toString();
      if (errorMsg.contains("canceled") || errorMsg.contains("cancelled")) {
        errorMsg = "Google sign-in cancelled by user.";
      }
      return GoogleSignInResult(success: false, errorMessage: errorMsg);
    }
  }

  /// Logs in the user by matching their email and password in the Firestore 'users' collection
  static Future<bool> login(String email, String password) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        final storedPassword = data['password'] as String?;

        if (storedPassword != null) {
          if (storedPassword != password) {
            debugPrint('Password mismatch for user: $email');
            return false;
          }
        } else {
          // Fallback: If no password is saved in DB (e.g. from older seeds), default to '123456'
          if (password != '123456') {
            debugPrint('Default password check failed for user: $email');
            return false;
          }
        }

        currentUser = UserModel.fromFirestore(doc);
        debugPrint('Logged in user: ${currentUser?.name}');
        return true;
      }
      
      // Fallback: Check if they are trying to log in with a seed email but Firestore hasn't been seeded yet
      if (email.trim() == 'student1@handong.ac.kr' && password == '123456') {
        currentUser = UserModel(
          uid: 'user_1',
          email: 'student1@handong.ac.kr',
          studentId: '22000001',
          name: '김지원',
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
    required String password,
    required String name,
    required String studentId,
    required String country,
    required String spiceTolerance,
    required List<String> dietaryLabels,
    required List<String> allergies,
    required List<String> preferredTastes,
    required String preferredLanguage,
    String? profileImageUrl,
  }) async {
    try {
      final uid = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final newUser = UserModel(
        uid: uid,
        email: email.trim(),
        studentId: studentId.trim(),
        name: name.trim(),
        profileImageUrl: profileImageUrl ?? '',
        dietaryLabels: dietaryLabels,
        allergies: allergies,
        pushNotificationsEnabled: true,
        favoriteMenuIds: [],
        country: country,
        spiceTolerance: spiceTolerance,
        preferredTastes: preferredTastes,
        preferredLanguage: preferredLanguage,
      );

      // Save to Firestore users collection along with password
      final userData = newUser.toMap();
      userData['password'] = password;
      await _firestore.collection('users').doc(uid).set(userData);
      
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
    _auth.signOut().catchError((e) => debugPrint('Error firebase sign out: $e'));
    GoogleSignIn.instance.signOut().catchError((e) => debugPrint('Error google sign out: $e'));
    debugPrint('Logged out current user session');
  }
}
