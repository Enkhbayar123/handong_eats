import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_log_screen.dart';
import 'select_meal_screen.dart';
import 'menu_archive_screen.dart';
import '../models/models.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  bool _hasLunch(DateTime date, List<MealLogModel> logs) {
    return logs.any((log) => log.mealType == "Lunch" && isSameDay(log.date, date));
  }

  bool _hasDinner(DateTime date, List<MealLogModel> logs) {
    return logs.any((log) => log.mealType == "Dinner" && isSameDay(log.date, date));
  }

  bool _hasBreakfast(DateTime date, List<MealLogModel> logs) {
    return logs.any((log) => log.mealType == "Breakfast" && isSameDay(log.date, date));
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  String _getMonthYear(DateTime date) {
    const List<String> months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return "${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
      builder: (context, snapshotR) {
        if (snapshotR.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final restaurants = snapshotR.data?.docs.map((doc) => RestaurantModel.fromFirestore(doc)).toList() ?? [];

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('menu_items').snapshots(),
          builder: (context, snapshotM) {
            if (snapshotM.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            final allMeals = snapshotM.data?.docs.map((doc) => MenuItemModel.fromFirestore(doc)).toList() ?? [];

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('meal_logs')
                  .where('userId', isEqualTo: 'user_1')
                  .snapshots(),
              builder: (context, snapshotL) {
                if (snapshotL.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                final logs = snapshotL.data?.docs.map((doc) => MealLogModel.fromFirestore(doc)).toList() ?? [];
                final todaysLogs = logs.where((log) => isSameDay(log.date, _selectedDate)).toList();

                return Scaffold(
                  backgroundColor: const Color(0xFFF8F9FB),
                  appBar: AppBar(
                    title: const Text(
                      "Calendar",
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.5),
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                  ),
                  body: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCalendarStrip(logs),
                        const SizedBox(height: 24),
                        _buildMyPlateSection(todaysLogs, allMeals, restaurants),
                        const SizedBox(height: 32),
                        _buildCampusArchiveSection(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // --- COMPONENT 1: Horizontal Date Picker with Dots ---
  Widget _buildCalendarStrip(List<MealLogModel> logs) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic Month/Year Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              _getMonthYear(_selectedDate),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
          ),
          const SizedBox(height: 16),
          // Horizontal Date Scroller
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: 14,
              itemBuilder: (context, index) {
                DateTime date = DateTime.now().subtract(Duration(days: 7 - index));
                bool isSelected = isSameDay(date, _selectedDate);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    width: 60,
                    margin: EdgeInsets.only(
                      left: index == 0 ? 16 : 4,
                      right: index == 13 ? 16 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE94E5D) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFE94E5D).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Day of week
                        Text(
                          _getWeekday(date.weekday),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white70 : Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Date number
                        Text(
                          "${date.day}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Dots Indicator Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_hasBreakfast(date, logs))
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : Colors.orangeAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (_hasLunch(date, logs))
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (_hasDinner(date, logs))
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1: return "MON";
      case 2: return "TUE";
      case 3: return "WED";
      case 4: return "THU";
      case 5: return "FRI";
      case 6: return "SAT";
      case 7: return "SUN";
      default: return "";
    }
  }

  // --- COMPONENT 2: My Plate (User's Logs) ---
  Widget _buildMyPlateSection(
      List<MealLogModel> todaysLogs, List<MenuItemModel> allMeals, List<RestaurantModel> restaurants) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text("My Plate", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      "${todaysLogs.length} ENTRIES",
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF4B5563)),
                    ),
                  )
                ],
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SelectMealScreen(),
                      fullscreenDialog: true,
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle_rounded, color: Color(0xFFE94E5D), size: 30),
              )
            ],
          ),
          const SizedBox(height: 16),
          if (todaysLogs.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.restaurant_outlined, color: Colors.grey[300], size: 48),
                    const SizedBox(height: 12),
                    Text(
                      "No meals logged on this date.",
                      style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            )
          else
            ...todaysLogs.map((log) => _buildLogCard(log, allMeals, restaurants)),
        ],
      ),
    );
  }

  Widget _buildLogCard(MealLogModel log, List<MenuItemModel> allMeals, List<RestaurantModel> restaurants) {
    // Resolve dish name & restaurant name
    final meal = allMeals.firstWhere(
      (m) => m.id == log.menuItemId,
      orElse: () => MenuItemModel(
        id: log.menuItemId,
        restaurantId: '',
        name: 'Unknown Dish',
        price: 0,
        imageUrl: '',
        description: '',
        averageRating: 0,
        reviewCount: 0,
      ),
    );

    final rest = restaurants.firstWhere(
      (r) => r.id == meal.restaurantId,
      orElse: () => RestaurantModel(
        id: '',
        name: 'Unknown Cafe',
        openTime: '',
        closeTime: '',
        currentStatus: CrowdedStatus.unknown,
      ),
    );

    Color indicatorColor;
    switch (log.mealType) {
      case "Breakfast":
        indicatorColor = Colors.orangeAccent;
        break;
      case "Lunch":
        indicatorColor = Colors.green;
        break;
      case "Dinner":
      default:
        indicatorColor = Colors.blue;
        break;
    }

    // Format log time (e.g. 12:45 PM)
    final timeStr = "${log.date.hour > 12 ? log.date.hour - 12 : log.date.hour}:${log.date.minute.toString().padLeft(2, '0')} ${log.date.hour >= 12 ? 'PM' : 'AM'}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 48,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        log.mealType.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: indicatorColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meal.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rest.name,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                  if (log.personalNote.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      "Note: ${log.personalNote}",
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditLogScreen(
                      logId: log.id,
                      foodName: meal.name,
                      restaurant: rest.name,
                      date: log.date,
                      imageUrl: meal.imageUrl.isNotEmpty
                          ? meal.imageUrl
                          : "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=80",
                      initialRating: log.rating,
                      initialNote: log.personalNote,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
              splashRadius: 20,
            )
          ],
        ),
      ),
    );
  }

  // --- COMPONENT 3: Campus Menu Archive ---
  Widget _buildCampusArchiveSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Campus Menu Archive", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            "Viewing menus offered on ${_selectedDate.month}/${_selectedDate.day}",
            style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          _buildArchiveRestaurantCard("Mom's Kitchen", "Classic Bibimbap, Handmade Tonkatsu"),
          _buildArchiveRestaurantCard("Student Lounge (Sola Fide)", "Spicy Pork Bowl, Tuna Mayo Rice"),
          _buildArchiveRestaurantCard("Dasu Handong", "Kimchi Jjigae"),
        ],
      ),
    );
  }

  Widget _buildArchiveRestaurantCard(String name, String menuPreview) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuArchiveScreen(archiveDate: _selectedDate),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          subtitle: Text(
            menuPreview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ),
    );
  }
}