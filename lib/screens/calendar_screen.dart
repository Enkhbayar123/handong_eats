import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_log_screen.dart';
import 'select_meal_screen.dart';
import 'menu_archive_screen.dart';
import '../models/models.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/localization.dart';
import '../services/auth_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  late final Stream<QuerySnapshot> _restaurantsStream;
  late final Stream<QuerySnapshot> _menuItemsStream;
  late final Stream<QuerySnapshot> _mealLogsStream;

  @override
  void initState() {
    super.initState();
    _restaurantsStream = FirebaseFirestore.instance
        .collection('restaurants')
        .snapshots();
    _menuItemsStream = FirebaseFirestore.instance
        .collection('menu_items')
        .snapshots();
    final uid = AuthService.currentUser?.uid ?? 'user_1';
    _mealLogsStream = FirebaseFirestore.instance
        .collection('meal_logs')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }

  bool _hasLunch(DateTime date, List<MealLogModel> logs) {
    return logs.any(
      (log) => log.mealType == "Lunch" && isSameDay(log.date, date),
    );
  }

  bool _hasDinner(DateTime date, List<MealLogModel> logs) {
    return logs.any(
      (log) => log.mealType == "Dinner" && isSameDay(log.date, date),
    );
  }

  bool _hasBreakfast(DateTime date, List<MealLogModel> logs) {
    return logs.any(
      (log) => log.mealType == "Breakfast" && isSameDay(log.date, date),
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getMonthYear(DateTime date) {
    const List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return "${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _restaurantsStream,
      builder: (context, snapshotR) {
        if (snapshotR.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final restaurants =
            snapshotR.data?.docs
                .map((doc) => RestaurantModel.fromFirestore(doc))
                .toList() ??
            [];

        return StreamBuilder<QuerySnapshot>(
          stream: _menuItemsStream,
          builder: (context, snapshotM) {
            if (snapshotM.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final allMeals =
                snapshotM.data?.docs
                    .map((doc) => MenuItemModel.fromFirestore(doc))
                    .toList() ??
                [];

            return StreamBuilder<QuerySnapshot>(
              stream: _mealLogsStream,
              builder: (context, snapshotL) {
                if (snapshotL.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                final logs =
                    snapshotL.data?.docs
                        .map((doc) => MealLogModel.fromFirestore(doc))
                        .toList() ??
                    [];
                final todaysLogs = logs
                    .where((log) => isSameDay(log.date, _selectedDate))
                    .toList();

                return Scaffold(
                  backgroundColor: const Color(0xFFF8F9FB),
                  appBar: AppBar(
                    title: Text(
                      LocalizationService.tr('calendar_title'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        letterSpacing: -0.5,
                      ),
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
                        _buildTableCalendar(logs),
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

  // --- COMPONENT 1: Full Monthly Calendar ---
  Widget _buildTableCalendar(List<MealLogModel> logs) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDate = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarFormat: CalendarFormat.month,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Color(0x40E94E5D), // Light red for today
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Color(0xFFE94E5D), // Dark/primary red for selected
            shape: BoxShape.circle,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            // Build the meal dots under the date
            bool hasB = _hasBreakfast(date, logs);
            bool hasL = _hasLunch(date, logs);
            bool hasD = _hasDinner(date, logs);

            if (!hasB && !hasL && !hasD) return null;

            return Positioned(
              bottom: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasB) _buildDot(Colors.orangeAccent),
                  if (hasL) _buildDot(Colors.green),
                  if (hasD) _buildDot(Colors.blue),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1.0),
      width: 5,
      height: 5,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // --- COMPONENT 2: My Plate (User's Logs) ---
  Widget _buildMyPlateSection(
    List<MealLogModel> todaysLogs,
    List<MenuItemModel> allMeals,
    List<RestaurantModel> restaurants,
  ) {
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
                  Text(
                    LocalizationService.tr('my_plate'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${todaysLogs.length} ENTRIES",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ),
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
                icon: const Icon(
                  Icons.add_circle_rounded,
                  color: Color(0xFFE94E5D),
                  size: 30,
                ),
              ),
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
                    Icon(
                      Icons.restaurant_outlined,
                      color: Colors.grey[300],
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No meals logged on this date.",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...todaysLogs.map(
              (log) => _buildLogCard(log, allMeals, restaurants),
            ),
        ],
      ),
    );
  }

  Widget _buildLogCard(
    MealLogModel log,
    List<MenuItemModel> allMeals,
    List<RestaurantModel> restaurants,
  ) {
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
    final timeStr =
        "${log.date.hour > 12 ? log.date.hour - 12 : log.date.hour}:${log.date.minute.toString().padLeft(2, '0')} ${log.date.hour >= 12 ? 'PM' : 'AM'}";

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
          ),
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
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rest.name,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (log.personalNote.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      "Note: ${log.personalNote}",
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.grey,
                size: 20,
              ),
              splashRadius: 20,
            ),
          ],
        ),
      ),
    );
  }

  // --- COMPONENT 3: Campus Menu Archive (Live Firebase) ---
  Widget _buildCampusArchiveSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocalizationService.tr('campus_archive'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "${_selectedDate.month}/${_selectedDate.day} 제공 메뉴",
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              final restaurants = snapshot.data!.docs;
              return Column(
                children: restaurants.map((doc) {
                  final name = doc['name'] as String? ?? '';
                  return _buildArchiveRestaurantCard(name);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveRestaurantCard(String name) {
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ),
    );
  }
}
