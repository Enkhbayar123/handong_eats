import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'nutrition_dashboard_screen.dart';
import 'login_screen.dart';
import 'dish_detail_screen.dart';
import '../models/models.dart';
import '../widgets/tier_badge.dart';
import '../services/localization.dart';
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
    _userStream = FirebaseFirestore.instance.collection('users').doc('user_1').snapshots();
    _mealLogsStream = FirebaseFirestore.instance
        .collection('meal_logs')
        .where('userId', isEqualTo: 'user_1')
        .snapshots();
    _reviewsStream = FirebaseFirestore.instance
        .collection('reviews')
        .where('userId', isEqualTo: 'user_1')
        .snapshots();
    _menuItemsStream = FirebaseFirestore.instance.collection('menu_items').snapshots();
  }

  @override
  Widget build(BuildContext context) {
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
        stream: _userStream,
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
            stream: _mealLogsStream,
            builder: (context, logsSnapshot) {
              final logCount = logsSnapshot.data?.docs.length ?? 0;

              return StreamBuilder<QuerySnapshot>(
                stream: _reviewsStream,
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
  }

  // --- UI BUILDERS ---

  Widget _buildPremiumHeaderCard(UserModel user, int logCount, int reviewCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.grey[200],
            backgroundImage: NetworkImage(
              user.profileImageUrl.isNotEmpty
                  ? user.profileImageUrl
                  : "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80",
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
      stream: _menuItemsStream,
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
                  .doc('user_1')
                  .set({'pushNotificationsEnabled': value}, SetOptions(merge: true));
            },
          ),
          const Divider(height: 1, indent: 60),
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.language,
                color: Colors.teal[600],
                size: 20,
              ),
            ),
            title: Text(
              LocalizationService.tr('language_setting'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(LocalizationService.tr('language_toggle')),
            value: LocalizationService.currentLanguage.value == 'ko',
            activeColor: Colors.teal[600],
            onChanged: (bool value) {
              LocalizationService.toggleLanguage();
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
