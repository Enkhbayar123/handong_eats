import 'package:flutter/material.dart';
import 'today_menu_screen.dart'; // Imports your MenuItem and Restaurant classes

class SelectMealScreen extends StatefulWidget {
  const SelectMealScreen({super.key});

  @override
  State<SelectMealScreen> createState() => _SelectMealScreenState();
}

class _SelectMealScreenState extends State<SelectMealScreen> {
  // Track the selected time of day
  String _selectedMealType = "Lunch";
  final List<String> _mealTypes = ["Breakfast", "Lunch", "Dinner"];

  // Track which specific food items are checked
  final Set<String> _checkedItems = {};

  // A focused mock list based on your Figma prototype
  final List<Restaurant> _campusDining = [
    Restaurant(
      name: "Student Cafeteria (학생식당)",
      openTime: "", closeTime: "",
      menu: [
        MenuItem(name: "Lemon Herb Chicken", rating: 4.5, reviewCount: 0),
        MenuItem(name: "Classic Caesar", rating: 4.2, reviewCount: 0),
        MenuItem(name: "Beef Bulgogi", rating: 4.8, reviewCount: 0),
      ],
    ),
    Restaurant(
      name: "Mom's Kitchen (맘스키친)",
      openTime: "", closeTime: "",
      menu: [
        MenuItem(name: "Artisan Margherita", rating: 4.7, reviewCount: 0),
        MenuItem(name: "Pepperoni Feast", rating: 4.6, reviewCount: 0),
        MenuItem(name: "Veggie Delight", rating: 4.4, reviewCount: 0),
      ],
    ),
    Restaurant(
      name: "Handong Lounge (한동라운지)",
      openTime: "", closeTime: "",
      menu: [
        MenuItem(name: "Spicy Miso Ramen", rating: 4.8, reviewCount: 0),
        MenuItem(name: "Shoyu Ramen", rating: 4.5, reviewCount: 0),
        MenuItem(name: "Tonkotsu Ramen", rating: 4.7, reviewCount: 0),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Select Meal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- 1. Top Filters (Breakfast / Lunch / Dinner) ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("CAMPUS DINING", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                // Custom Segmented Control for Meal Type
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: _mealTypes.map((type) {
                      bool isSelected = _selectedMealType == type;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMealType = type;
                            _checkedItems.clear(); // Clear checks when changing meal time
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isSelected 
                                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                                : [],
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.black : Colors.grey[600],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // --- 2. Restaurant and Menu List ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 100), // Padding so the bottom button doesn't cover items
              itemCount: _campusDining.length,
              itemBuilder: (context, index) {
                final restaurant = _campusDining[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.grey[50],
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Text(
                        restaurant.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.black87),
                      ),
                    ),
                    ...restaurant.menu.map((item) {
                      bool isChecked = _checkedItems.contains(item.name);
                      return CheckboxListTile(
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                        value: isChecked,
                        activeColor: Colors.redAccent,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _checkedItems.add(item.name);
                            } else {
                              _checkedItems.remove(item.name);
                            }
                          });
                        },
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      
      // --- 3. Fixed Bottom Button ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _checkedItems.isNotEmpty 
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  print("Added ${_checkedItems.length} items to $_selectedMealType!");
                  Navigator.pop(context); // Go back to calendar
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                child: Text(
                  "Add to $_selectedMealType", 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          )
        : null, // Only show the button if they actually selected something
    );
  }
}