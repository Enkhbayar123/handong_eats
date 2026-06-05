import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../widgets/app_image.dart';
import '../services/auth_service.dart';

class NutritionDashboardScreen extends StatefulWidget {
  const NutritionDashboardScreen({super.key});

  @override
  State<NutritionDashboardScreen> createState() => _NutritionDashboardScreenState();
}

class _NutritionDashboardScreenState extends State<NutritionDashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  String _activeTab = 'muscle'; // 'muscle' or 'weight'

  late final Stream<QuerySnapshot> _menuItemsStream;
  late final Stream<QuerySnapshot> _mealLogsStream;

  @override
  void initState() {
    super.initState();
    _menuItemsStream = FirebaseFirestore.instance.collection('menu_items').snapshots();
    _mealLogsStream = FirebaseFirestore.instance
        .collection('meal_logs')
        .where('userId', isEqualTo: AuthService.currentUser?.uid ?? 'user_1')
        .snapshots();
  }

  String _getDateText(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) {
      return "Today";
    } else if (diff == -1) {
      return "Yesterday";
    } else if (diff == 1) {
      return "Tomorrow";
    } else {
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }
  }

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
        stream: _menuItemsStream,
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

          // Get raw menu items list for recommendations
          final allFoods = snapshotM.data!.docs
              .map((doc) => MenuItemModel.fromFirestore(doc))
              .toList();

          return StreamBuilder<QuerySnapshot>(
            stream: _mealLogsStream,
            builder: (context, snapshotL) {
              if (snapshotL.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshotL.hasError) {
                return Center(child: Text("Error: ${snapshotL.error}"));
              }

              final logs = snapshotL.data?.docs.map((doc) => MealLogModel.fromFirestore(doc)).toList() ?? [];

              // Process Data based on selected date
              final selectedDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
              
              int todayCalories = 0;
              int todayProtein = 0;
              int todayCarbs = 0;
              int todayFat = 0;
              
              Map<int, int> weeklyCalories = {}; // 1-7 for Mon-Sun

              // Calculate start of week containing selectedDay
              final startOfWeek = selectedDay.subtract(Duration(days: selectedDay.weekday - 1));

              for (var log in logs) {
                final logDate = DateTime(log.date.year, log.date.month, log.date.day);
                final menuItem = menuItemsMap[log.menuItemId];
                
                // If the menu item exists, add its macros
                if (menuItem != null) {
                  if (logDate == selectedDay) {
                    todayCalories += menuItem.calories;
                    todayProtein += menuItem.protein;
                    todayCarbs += menuItem.carbs;
                    todayFat += menuItem.fat;
                  }
                  
                  final diff = logDate.difference(startOfWeek).inDays;
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
                      _buildDietRecommendations(allFoods),
                      const SizedBox(height: 32),
                      const Text("Weekly Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildWeeklyChart(weeklyCalories, goalCalories, selectedDay.weekday),
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
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _selectedDate = _selectedDate.subtract(const Duration(days: 1));
            });
          },
        ),
        Text(
          _getDateText(_selectedDate),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _selectedDate = _selectedDate.add(const Duration(days: 1));
            });
          },
        ),
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

  Widget _buildDietRecommendations(List<MenuItemModel> allFoods) {
    if (allFoods.isEmpty) return const SizedBox.shrink();

    // Sort for muscle gain (protein descending, then calories ascending)
    final muscleFoods = List<MenuItemModel>.from(allFoods)
      ..sort((a, b) {
        int comp = b.protein.compareTo(a.protein);
        if (comp != 0) return comp;
        return a.calories.compareTo(b.calories);
      });
    final topMuscle = muscleFoods.take(3).toList();

    // Sort for weight loss (calories ascending, then protein descending)
    final weightLossFoods = List<MenuItemModel>.from(allFoods)
      ..sort((a, b) {
        int comp = a.calories.compareTo(b.calories);
        if (comp != 0) return comp;
        return b.protein.compareTo(a.protein);
      });
    final topWeightLoss = weightLossFoods.take(3).toList();

    final foodsToShow = _activeTab == 'muscle' ? topMuscle : topWeightLoss;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  "Diet Recommendations",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildTabButton("💪 Muscle", 'muscle'),
                    _buildTabButton("🥗 Weight", 'weight'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _activeTab == 'muscle'
                ? "Top high-protein foods to support muscle recovery and growth:"
                : "Top low-calorie options to support a calorie deficit for weight loss:",
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: foodsToShow.length,
            separatorBuilder: (context, index) => const Divider(height: 20),
            itemBuilder: (context, index) {
              final food = foodsToShow[index];
              return Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AppImage(
                      imageUrl: food.imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${food.calories} kcal  •  P: ${food.protein}g  •  C: ${food.carbs}g  •  F: ${food.fat}g",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _activeTab == 'muscle'
                          ? Colors.blue[50]
                          : Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _activeTab == 'muscle'
                          ? "${food.protein}g Protein"
                          : "${food.calories} kcal",
                      style: TextStyle(
                        color: _activeTab == 'muscle'
                            ? Colors.blue[700]
                            : Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String tab) {
    final isActive = _activeTab == tab;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = tab;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(Map<int, int> weeklyCalories, int goal, int selectedWeekday) {
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
          _buildBar("Mon", (weeklyCalories[1] ?? 0) / goal, isSelected: selectedWeekday == 1),
          _buildBar("Tue", (weeklyCalories[2] ?? 0) / goal, isSelected: selectedWeekday == 2),
          _buildBar("Wed", (weeklyCalories[3] ?? 0) / goal, isSelected: selectedWeekday == 3),
          _buildBar("Thu", (weeklyCalories[4] ?? 0) / goal, isSelected: selectedWeekday == 4),
          _buildBar("Fri", (weeklyCalories[5] ?? 0) / goal, isSelected: selectedWeekday == 5),
          _buildBar("Sat", (weeklyCalories[6] ?? 0) / goal, isSelected: selectedWeekday == 6),
          _buildBar("Sun", (weeklyCalories[7] ?? 0) / goal, isSelected: selectedWeekday == 7),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double percentage, {bool isSelected = false}) {
    bool isWarning = percentage > 1.0;
    double visualPercentage = percentage > 1.0 ? 1.0 : percentage;
    
    Color barColor = isWarning ? Colors.orangeAccent : (isSelected ? Colors.redAccent : Colors.grey.shade300);
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
        Text(day, style: TextStyle(fontSize: 12, color: isSelected ? Colors.black : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
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
