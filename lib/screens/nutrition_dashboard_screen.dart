import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class NutritionDashboardScreen extends StatelessWidget {
  const NutritionDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Nutrition & Diet", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('menu_items').snapshots(),
        builder: (context, snapshotM) {
          if (snapshotM.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshotM.hasError) {
            return Center(child: Text("Error: ${snapshotM.error}"));
          }
          
          // Map of menuItemId -> MenuItemModel for easy lookup
          final menuItemsMap = {
            for (var doc in snapshotM.data!.docs)
              doc.id: MenuItemModel.fromFirestore(doc)
          };

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('meal_logs')
                .where('userId', isEqualTo: 'user_1')
                .snapshots(),
            builder: (context, snapshotL) {
              if (snapshotL.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshotL.hasError) {
                return Center(child: Text("Error: ${snapshotL.error}"));
              }

              final logs = snapshotL.data?.docs.map((doc) => MealLogModel.fromFirestore(doc)).toList() ?? [];

              // Process Data
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              
              int todayCalories = 0;
              int todayProtein = 0;
              int todayCarbs = 0;
              int todayFat = 0;
              
              Map<int, int> weeklyCalories = {}; // 1-7 for Mon-Sun

              for (var log in logs) {
                final logDate = DateTime(log.date.year, log.date.month, log.date.day);
                final menuItem = menuItemsMap[log.menuItemId];
                
                // If the menu item exists, add its macros
                if (menuItem != null) {
                  if (logDate == today) {
                    todayCalories += menuItem.calories;
                    todayProtein += menuItem.protein;
                    todayCarbs += menuItem.carbs;
                    todayFat += menuItem.fat;
                  }
                  final diff = today.difference(logDate).inDays;
                  if (diff >= 0 && diff < 7) {
                    weeklyCalories[log.date.weekday] = (weeklyCalories[log.date.weekday] ?? 0) + menuItem.calories;
                  }
                }
              }

              int goalCalories = 2200;
              int remaining = goalCalories - todayCalories;
              if (remaining < 0) remaining = 0;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDateSelector(),
                      const SizedBox(height: 24),
                      _buildCalorieCard(todayCalories, goalCalories, remaining),
                      const SizedBox(height: 20),
                      _buildMacrosRow(todayProtein, todayCarbs, todayFat),
                      const SizedBox(height: 32),
                      const Text("Weekly Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildWeeklyChart(weeklyCalories, goalCalories),
                      const SizedBox(height: 32),
                      _buildInsightsCard(todayCalories <= goalCalories),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDateSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
        const Text("Today", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
      ],
    );
  }

  Widget _buildCalorieCard(int eaten, int goal, int remaining) {
    double progress = eaten / goal;
    if (progress > 1.0) progress = 1.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Left side stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Eaten", style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text("$eaten", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const Text(" kcal", style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: remaining == 0 ? Colors.red[50] : Colors.green[50], 
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Text(
                  remaining == 0 ? "Goal Exceeded" : "$remaining kcal remaining", 
                  style: TextStyle(
                    color: remaining == 0 ? Colors.red[700] : Colors.green[700], 
                    fontSize: 12, 
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
            ],
          ),
          
          // Right side circular progress
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(remaining == 0 ? Colors.red : Colors.redAccent),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_fire_department, color: Colors.orange[400], size: 28),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMacrosRow(int protein, int carbs, int fat) {
    return Row(
      children: [
        Expanded(child: _buildMacroCard("Protein", protein.toDouble(), 120, Colors.blue, "${protein}g")),
        const SizedBox(width: 12),
        Expanded(child: _buildMacroCard("Carbs", carbs.toDouble(), 250, Colors.orange, "${carbs}g")),
        const SizedBox(width: 12),
        Expanded(child: _buildMacroCard("Fats", fat.toDouble(), 65, Colors.purple, "${fat}g")),
      ],
    );
  }

  Widget _buildMacroCard(String label, double current, double max, MaterialColor color, String amount) {
    double progress = current / max;
    if (progress > 1.0) progress = 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Text(amount, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(Map<int, int> weeklyCalories, int goal) {
    // Generate data for Mon-Sun
    final today = DateTime.now().weekday;
    
    return Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildBar("Mon", (weeklyCalories[1] ?? 0) / goal, isToday: today == 1),
          _buildBar("Tue", (weeklyCalories[2] ?? 0) / goal, isToday: today == 2),
          _buildBar("Wed", (weeklyCalories[3] ?? 0) / goal, isToday: today == 3),
          _buildBar("Thu", (weeklyCalories[4] ?? 0) / goal, isToday: today == 4),
          _buildBar("Fri", (weeklyCalories[5] ?? 0) / goal, isToday: today == 5),
          _buildBar("Sat", (weeklyCalories[6] ?? 0) / goal, isToday: today == 6),
          _buildBar("Sun", (weeklyCalories[7] ?? 0) / goal, isToday: today == 7),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double percentage, {bool isToday = false}) {
    bool isWarning = percentage > 1.0;
    double visualPercentage = percentage > 1.0 ? 1.0 : percentage;
    
    Color barColor = isWarning ? Colors.orangeAccent : (isToday ? Colors.redAccent : Colors.grey.shade300);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 24,
              height: 80 * visualPercentage,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: TextStyle(fontSize: 12, color: isToday ? Colors.black : Colors.grey, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildInsightsCard(bool underGoal) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: underGoal ? Colors.blue.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: underGoal ? Colors.blueAccent : Colors.orangeAccent, 
              shape: BoxShape.circle
            ),
            child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  underGoal ? "Great job today!" : "Watch out!", 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16, 
                    color: underGoal ? Colors.blueAccent : Colors.orangeAccent
                  )
                ),
                const SizedBox(height: 4),
                Text(
                  underGoal 
                    ? "You are staying on track with your calories. Keep it up!"
                    : "You've exceeded your daily calorie goal. Try a lighter meal tomorrow!",
                  style: const TextStyle(height: 1.4, color: Colors.black87),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
