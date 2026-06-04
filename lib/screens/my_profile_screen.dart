import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'nutrition_dashboard_screen.dart';
import 'login_screen.dart';
import 'dish_detail_screen.dart';
import '../models/models.dart';
import '../widgets/tier_badge.dart';
import '../services/localization.dart';
import '../services/auth_service.dart';
class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  late final Stream<DocumentSnapshot> _userStream;
  late final Stream<QuerySnapshot> _mealLogsStream;
  late final Stream<QuerySnapshot> _reviewsStream;
  late final Stream<QuerySnapshot> _menuItemsStream;

  @override
  void initState() {
    super.initState();
  }

  void _showAvatarPicker(String activeUserId, String currentAvatarUrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Edit Profile Picture",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: Colors.black87),
                  title: const Text("Choose from Gallery", style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () async {
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    final photo = await picker.pickImage(source: ImageSource.gallery);
                    if (photo != null) {
                      await _updateProfileImage(activeUserId, photo.path);
                    }
                  },
                ),
                if (currentAvatarUrl.isNotEmpty) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    title: const Text("Remove Photo", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    onTap: () async {
                      Navigator.pop(context);
                      await _updateProfileImage(activeUserId, "");
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateProfileImage(String activeUserId, String path) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(activeUserId)
          .update({'profileImageUrl': path});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile picture updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error updating profile image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update profile picture: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeUserId = AuthService.currentUser?.uid ?? 'user_1';

    return ValueListenableBuilder<String>(
      valueListenable: LocalizationService.currentLanguage,
      builder: (context, lang, child) {
        return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Text(
          LocalizationService.tr('profile_title'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(activeUserId).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(
              child: Text(
                "User profile not found.\nPlease check your connection or sign in again.",
                textAlign: TextAlign.center,
              ),
            );
          }

          final user = UserModel.fromFirestore(userSnapshot.data!);

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('meal_logs')
                .where('userId', isEqualTo: activeUserId)
                .snapshots(),
            builder: (context, logsSnapshot) {
              final logCount = logsSnapshot.data?.docs.length ?? 0;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reviews')
                    .where('userId', isEqualTo: activeUserId)
                    .snapshots(),
                builder: (context, reviewsSnapshot) {
                  final reviewCount = reviewsSnapshot.data?.docs.length ?? 0;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- 1. User Header (Premium Gradient Card) ---
                        _buildPremiumHeaderCard(user, logCount, reviewCount),
                        const SizedBox(height: 20),

                        // --- 2. My Favorites ---
                        _buildSectionHeader("My Favorites"),
                        _buildFavoritesSection(user.favoriteMenuIds),
                        const SizedBox(height: 20),

                        // --- 3. Dining Preferences ---
                        _buildSectionHeader("Dining Preferences"),
                        _buildPreferencesSection(user),
                        const SizedBox(height: 20),

                        // --- 4. Health & Diet ---
                        _buildSectionHeader("Health & Diet"),
                        _buildHealthSection(),
                        const SizedBox(height: 20),

                        // --- 5. App Settings & Logout ---
                        _buildSectionHeader("App Settings"),
                        _buildSettingsSection(user),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
      },
    );
  }

  // --- UI BUILDERS ---

  Widget _buildPremiumHeaderCard(UserModel user, int logCount, int reviewCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _showAvatarPicker(user.uid, user.profileImageUrl),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: user.profileImageUrl.isNotEmpty
                      ? (user.profileImageUrl.startsWith('http')
                          ? NetworkImage(user.profileImageUrl)
                          : FileImage(File(user.profileImageUrl)) as ImageProvider)
                      : null,
                  child: user.profileImageUrl.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              TierBadge(reviewCount: user.reviewCount),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "${LocalizationService.tr('student_id')}: ${user.studentId}",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            user.email,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeaderStatColumn("$logCount", "Meal Logs"),
              Container(
                height: 40,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                color: Colors.grey[300],
              ),
              _buildHeaderStatColumn("$reviewCount", LocalizationService.tr('review_count')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6B7280),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildFavoritesSection(List<String> favoriteMenuIds) {
    if (favoriteMenuIds.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: Text(
            "No favorites selected yet.",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('menu_items').snapshots(),
      builder: (context, menuSnapshot) {
        if (menuSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final allMeals = menuSnapshot.data?.docs
                .map((doc) => MenuItemModel.fromFirestore(doc))
                .toList() ??
            [];

        final favoriteMeals =
            allMeals.where((m) => favoriteMenuIds.contains(m.id)).toList();

        if (favoriteMeals.isEmpty) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Text(
                "No favorites found.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: favoriteMeals.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 20, endIndent: 20),
            itemBuilder: (context, index) {
              final meal = favoriteMeals[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                title: Text(
                  meal.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "${meal.averageRating} (${meal.reviewCount} reviews)",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DishDetailScreen(dish: meal),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPreferencesSection(UserModel user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.eco,
                color: Colors.green[600],
                size: 20,
              ),
            ),
            title: const Text(
              "Dietary Labels",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: user.dietaryLabels.map((label) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[100]!),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(color: Colors.green[700], fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {},
          ),
          const Divider(height: 1, indent: 60),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[600],
                size: 20,
              ),
            ),
            title: const Text(
              "Allergies",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: user.allergies.map((allergy) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[100]!),
                    ),
                    child: Text(
                      allergy,
                      style: TextStyle(color: Colors.orange[700], fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHealthSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.pie_chart_rounded,
            color: Colors.blue[600],
            size: 20,
          ),
        ),
        title: const Text(
          "My Nutrition Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: const Text("Track your daily calories and macros"),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NutritionDashboardScreen()),
          );
        },
      ),
    );
  }

  Widget _buildSettingsSection(UserModel user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active,
                color: Colors.purple[600],
                size: 20,
              ),
            ),
            title: const Text(
              "Push Notifications",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            value: user.pushNotificationsEnabled,
            activeColor: const Color(0xFFE94E5D),
            onChanged: (bool value) async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .set({'pushNotificationsEnabled': value}, SetOptions(merge: true));
            },
          ),
          const Divider(height: 1, indent: 60),
          ValueListenableBuilder<String>(
            valueListenable: LocalizationService.currentLanguage,
            builder: (context, lang, child) {
              return SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.language, color: Colors.teal[600]),
                ),
                title: Text(
                  LocalizationService.tr('language_setting'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: Text(LocalizationService.tr('language_toggle')),
                value: lang == 'ko',
                activeColor: Colors.teal[600],
                onChanged: (bool value) {
                  LocalizationService.toggleLanguage();
                },
              );
            },
          ),

          const Divider(height: 1, indent: 60),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout,
                color: Colors.redAccent,
                size: 20,
              ),
            ),
            title: const Text(
              "Logout",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.redAccent,
              ),
            ),
            onTap: () {
              // Reset navigation back to the login screen and clean up stack
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
