import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class SelectMealScreen extends StatefulWidget {
  const SelectMealScreen({super.key});

  @override
  State<SelectMealScreen> createState() => _SelectMealScreenState();
}

class _SelectMealScreenState extends State<SelectMealScreen> {
  String _selectedMealType = "Lunch";
  final List<String> _mealTypes = ["Breakfast", "Lunch", "Dinner"];
  final Set<String> _checkedItemIds = {}; // Storing IDs instead of names for Firebase

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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
        builder: (context, snapshotR) {
          if (snapshotR.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshotR.hasData || snapshotR.data!.docs.isEmpty) {
            return const Center(child: Text("No restaurants found."));
          }

          List<RestaurantModel> restaurants = snapshotR.data!.docs
              .map((doc) => RestaurantModel.fromFirestore(doc))
              .toList();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('menu_items').snapshots(),
            builder: (context, snapshotM) {
              if (snapshotM.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              List<MenuItemModel> allMeals = snapshotM.data?.docs
                  .map((doc) => MenuItemModel.fromFirestore(doc))
                  .toList() ?? [];

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("CAMPUS DINING", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
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
                                    _checkedItemIds.clear();
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

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: restaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = restaurants[index];
                        final restaurantMenu = allMeals.where((m) => m.restaurantId == restaurant.id).toList();

                        if (restaurantMenu.isEmpty) return const SizedBox.shrink();

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
                            ...restaurantMenu.map((item) {
                              bool isChecked = _checkedItemIds.contains(item.id);
                              return CheckboxListTile(
                                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                value: isChecked,
                                activeColor: Colors.redAccent,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      _checkedItemIds.add(item.id);
                                    } else {
                                      _checkedItemIds.remove(item.id);
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
              );
            },
          );
        },
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _checkedItemIds.isNotEmpty 
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saving meal...')));
                  
                  // Save all selected items as Meal Logs
                  for (String itemId in _checkedItemIds) {
                    final newLog = MealLogModel(
                      id: '',
                      userId: 'user_1', // Mocked user
                      menuItemId: itemId,
                      date: DateTime.now(),
                      mealType: _selectedMealType,
                      rating: 0,
                      personalNote: '',
                      photoUrl: '',
                    );
                    await FirebaseFirestore.instance.collection('meal_logs').add(newLog.toMap());
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ${_checkedItemIds.length} items to $_selectedMealType!')));
                    Navigator.pop(context);
                  }
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
        : null,
    );
  }
}