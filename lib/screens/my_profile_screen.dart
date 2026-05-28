import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'nutrition_dashboard_screen.dart';
import 'login_screen.dart';
import 'dish_detail_screen.dart';
import '../models/models.dart';
import '../services/database_seeder.dart';
import '../services/auth_service.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // Get the dynamic user from AuthService
    final user = AuthService.currentUser;
    final name = user?.name ?? "Jack (Enkhbayar)";
    final studentId = user?.studentId ?? "22000123";
    final country = user?.country ?? "Mongolia";
    final spiceTolerance = user?.spiceTolerance ?? "Hot";
    final dietaryLabels = user?.dietaryLabels.isNotEmpty == true 
        ? user!.dietaryLabels.join(", ") 
        : "None";
    final allergies = user?.allergies.isNotEmpty == true 
        ? user!.allergies.join(", ") 
        : "None";
    final preferredTastes = user?.preferredTastes.isNotEmpty == true 
        ? user!.preferredTastes.join(", ") 
        : "None";

    final activeUserId = AuthService.currentUser?.uid ?? 'user_1';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.5),
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
  }

  // --- UI BUILDERS ---

  Widget _buildPremiumHeaderCard(UserModel user, int logCount, int reviewCount) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE94E5D), Color(0xFFFF7B87)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE94E5D).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: NetworkImage(
                      user.profileImageUrl.isNotEmpty
                          ? user.profileImageUrl
                          : "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80",
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Student ID: ${user.studentId}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildHeaderStatColumn("$logCount", "Meal Logs"),
                  Container(
                    height: 32,
                    width: 1,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  _buildHeaderStatColumn("$reviewCount", "Reviews"),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 12,
            fontWeight: FontWeight.w500,
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
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flag,
                color: Colors.blueAccent,
                size: 20,
              ),
            ),
            title: const Text(
              "Home Country",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(
              user.country,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
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
                Icons.whatshot,
                color: Colors.redAccent,
                size: 20,
              ),
            ),
            title: const Text(
              "Spice Tolerance",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(
              user.spiceTolerance,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          const Divider(height: 1, indent: 60),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                color: Colors.purpleAccent,
                size: 20,
              ),
            ),
            title: const Text(
              "Preferred Flavors",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(
              user.preferredTastes.isNotEmpty ? user.preferredTastes.join(", ") : "None",
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          const Divider(height: 1, indent: 60),
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
              final activeUserId = AuthService.currentUser?.uid ?? 'user_1';
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(activeUserId)
                  .set({'pushNotificationsEnabled': value}, SetOptions(merge: true));
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
              AuthService.logout();
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
