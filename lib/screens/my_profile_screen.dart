import 'package:flutter/material.dart';
import 'nutrition_dashboard_screen.dart';
import '../services/database_seeder.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  // State for the notification toggle
  bool _pushNotificationsEnabled = true;

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
    final preferredLanguage = user?.preferredLanguage ?? "English";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. User Header & Stats ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: const NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80"),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name, 
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                            ),
                            const SizedBox(height: 4),
                            Text("Student ID: $studentId", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                            Text("Handong Eats Member since 2023", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn("124", "Meal Logs"),
                      Container(height: 40, width: 1, color: Colors.grey[300]), // Divider line
                      _buildStatColumn("42", "Reviews"),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- 2. My Favorites ---
            _buildSectionHeader("My Favorites"),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildFavoriteTile(
                    title: "Quinoa Buddha Bowl",
                    subtitle: "★ Favorite Meal",
                    icon: Icons.favorite,
                    iconColor: Colors.redAccent,
                  ),
                  const Divider(height: 1, indent: 20),
                  _buildFavoriteTile(
                    title: "Garden Fresh Salad",
                    subtitle: "★ Saved Review",
                    icon: Icons.bookmark,
                    iconColor: Colors.blueAccent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- 3. Dining Preferences ---
            _buildSectionHeader("Dining & Food Profile"),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                      child: const Icon(Icons.flag, color: Colors.blueAccent, size: 20),
                    ),
                    title: const Text("Home Country", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(country),
                  ),
                  const Divider(height: 1, indent: 60),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.teal[50], shape: BoxShape.circle),
                      child: const Icon(Icons.translate, color: Colors.teal, size: 20),
                    ),
                    title: const Text("Preferred Language", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(preferredLanguage),
                  ),
                  const Divider(height: 1, indent: 60),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
                      child: const Icon(Icons.whatshot, color: Colors.redAccent, size: 20),
                    ),
                    title: const Text("Spice Tolerance", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(spiceTolerance),
                  ),
                  const Divider(height: 1, indent: 60),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                      child: Icon(Icons.eco, color: Colors.green[600], size: 20),
                    ),
                    title: const Text("Dietary Labels", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(dietaryLabels),
                  ),
                  const Divider(height: 1, indent: 60),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.orange[50], shape: BoxShape.circle),
                      child: Icon(Icons.warning_amber_rounded, color: Colors.orange[600], size: 20),
                    ),
                    title: const Text("Allergies", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(allergies),
                  ),
                  const Divider(height: 1, indent: 60),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.purple[50], shape: BoxShape.circle),
                      child: Icon(Icons.favorite_border, color: Colors.purple[600], size: 20),
                    ),
                    title: const Text("Preferred Flavors", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(preferredTastes),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- 4. Health & Diet ---
            _buildSectionHeader("Health & Diet"),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                      child: Icon(Icons.pie_chart_rounded, color: Colors.blue[600], size: 20),
                    ),
                    title: const Text("My Nutrition Dashboard", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text("Track your calories and macros"),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NutritionDashboardScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- 5. App Settings & Logout ---
            _buildSectionHeader("App Settings"),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.purple[50], shape: BoxShape.circle),
                      child: Icon(Icons.notifications_active, color: Colors.purple[600], size: 20),
                    ),
                    title: const Text("Push Notifications", style: TextStyle(fontWeight: FontWeight.w600)),
                    value: _pushNotificationsEnabled,
                    activeColor: Colors.redAccent,
                    onChanged: (bool value) {
                      setState(() {
                        _pushNotificationsEnabled = value;
                      });
                    },
                  ),
                  const Divider(height: 1, indent: 60),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.orange[50], shape: BoxShape.circle),
                      child: Icon(Icons.cloud_upload, color: Colors.orange[600], size: 20),
                    ),
                    title: Text("Seed Database (Debug)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[800])),
                    onTap: () async {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeding Database...')));
                      await DatabaseSeeder.runAllSeeds();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Database seeded successfully!')));
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 60),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
                      child: Icon(Icons.logout, color: Colors.red[600], size: 20),
                    ),
                    title: Text("Logout", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[600])),
                    onTap: () {
                      AuthService.logout();
                      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40), // Bottom padding
          ],
        ),
      ),
    );
  }

  // --- HELPERS ---
  
  Widget _buildStatColumn(String number, String label) {
    return Column(
      children: [
        Text(number, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildFavoriteTile({required String title, required String subtitle, required IconData icon, required Color iconColor}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 14),
            const SizedBox(width: 4),
            Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }
}