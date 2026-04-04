import 'package:flutter/material.dart';
import 'edit_log_screen.dart';
import 'select_meal_screen.dart';
import 'menu_archive_screen.dart';

// --- MOCK DATA MODELS ---
class MealLog {
  final DateTime date;
  final String mealType; // "Lunch" or "Dinner"
  final String foodName;
  final String restaurant;
  final String time;

  MealLog(this.date, this.mealType, this.foodName, this.restaurant, this.time);
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  // Mocking some user logs for the dot indicators and My Plate list
  final List<MealLog> _userLogs = [
    MealLog(DateTime.now(), "Lunch", "Grilled Chicken Quinoa Bowl", "Grace Table", "12:45 PM"),
    MealLog(DateTime.now().subtract(const Duration(days: 1)), "Lunch", "Spicy Pork Bowl", "Sola Fide", "1:15 PM"),
    MealLog(DateTime.now().subtract(const Duration(days: 1)), "Dinner", "Ramyeon", "Korean Table 1", "7:00 PM"),
    MealLog(DateTime.now().subtract(const Duration(days: 2)), "Dinner", "Cheese Tonkatsu", "Goshen", "6:30 PM"),
  ];

  // Helper to check if a specific date has a lunch or dinner logged
  bool _hasLunch(DateTime date) {
    return _userLogs.any((log) => log.mealType == "Lunch" && isSameDay(log.date, date));
  }

  bool _hasDinner(DateTime date) {
    return _userLogs.any((log) => log.mealType == "Dinner" && isSameDay(log.date, date));
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    // Filter logs for the currently selected date
    final todaysLogs = _userLogs.where((log) => isSameDay(log.date, _selectedDate)).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Calendar", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendarStrip(),
            const SizedBox(height: 24),
            _buildMyPlateSection(todaysLogs),
            const SizedBox(height: 32),
            _buildCampusArchiveSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- COMPONENT 1: Horizontal Date Picker with Dots ---
  Widget _buildCalendarStrip() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month/Year Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "October 2025", // Hardcoded for prototype, make dynamic later
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          // Horizontal Date Scroller
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              // Start the list a few days in the past to simulate history
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
                      color: isSelected ? Colors.black87 : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Day of week (Mon, Tue)
                        Text(
                          _getWeekday(date.weekday),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white70 : Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Date number (15, 16)
                        Text(
                          "${date.day}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Dots Indicator Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_hasLunch(date))
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                              ),
                            if (_hasDinner(date))
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
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
  Widget _buildMyPlateSection(List<MealLog> todaysLogs) {
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                    child: Text("${todaysLogs.length} ENTRIES", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                  )
                ],
              ),
              // Manual Add Button
              IconButton(
                onPressed: () {
                  // Open the Select Meal screen as a full-screen modal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SelectMealScreen(),
                      fullscreenDialog: true, // This makes it slide up from the bottom like a true modal!
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle, color: Colors.redAccent, size: 28),
              )
            ],
          ),
          const SizedBox(height: 16),
          
          if (todaysLogs.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Center(
                child: Text("No meals logged on this date.", style: TextStyle(color: Colors.grey[500])),
              ),
            )
          else
            ...todaysLogs.map((log) => _buildLogCard(log)),
        ],
      ),
    );
  }

  Widget _buildLogCard(MealLog log) {
    bool isLunch = log.mealType == "Lunch";
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Colored stripe indicator
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: isLunch ? Colors.green : Colors.blue,
                borderRadius: BorderRadius.circular(4)
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
                      Text(log.mealType.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isLunch ? Colors.green : Colors.blue)),
                      Text(log.time, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(log.foodName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(log.restaurant, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
            // --- NEW: Edit Button ---
            IconButton(
              onPressed: () {
                // Navigate to the Edit Log Screen, passing the specific log data
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditLogScreen(
                      foodName: log.foodName,
                      restaurant: log.restaurant,
                      date: "Oct ${log.date.day}", // A simple formatted date
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
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
          const SizedBox(height: 16),
          
          // Reusing a simplified card style for the historical menus
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: ListTile(
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          subtitle: Text(menuPreview, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ),
    );
  }
}