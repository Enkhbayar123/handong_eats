import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import 'dish_detail_screen.dart';

class MenuArchiveScreen extends StatelessWidget {
  final DateTime archiveDate;

  const MenuArchiveScreen({super.key, required this.archiveDate});

  // A quick helper to format the date nicely without needing extra packages
  String _formatDate(DateTime date) {
    const List<String> months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    const List<String> weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
    
    // Quick suffix logic (st, nd, rd, th)
    String suffix = "th";
    if (date.day % 10 == 1 && date.day != 11) suffix = "st";
    if (date.day % 10 == 2 && date.day != 12) suffix = "nd";
    if (date.day % 10 == 3 && date.day != 13) suffix = "rd";

    return "${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}$suffix";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Menu Archive", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Date Header ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "HISTORICAL MENU", 
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Viewing menu records for\n${_formatDate(archiveDate)}.",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- 2. Live Firebase Food List ---
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
              builder: (context, restSnapshot) {
                if (restSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ));
                }
                
                if (!restSnapshot.hasData || restSnapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No data available."));
                }

                final restaurants = restSnapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    final restDoc = restaurants[index];
                    final restName = restDoc['name'] as String? ?? 'Unknown Restaurant';
                    final restId = restDoc.id;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Restaurant Name
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              restName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Food Items for this restaurant
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('menu_items')
                                .where('restaurantId', isEqualTo: restId)
                                .snapshots(),
                            builder: (context, menuSnapshot) {
                              if (!menuSnapshot.hasData) {
                                return const SizedBox();
                              }
                              final menuDocs = menuSnapshot.data!.docs;
                              if (menuDocs.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Text("No items today", style: TextStyle(color: Colors.grey)),
                                );
                              }
                              
                              return Column(
                                children: menuDocs.map((doc) {
                                  final dish = MenuItemModel.fromFirestore(doc);
                                  return _buildArchiveFoodCard(context, dish);
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER: Archive Food Card ---
  Widget _buildArchiveFoodCard(BuildContext context, MenuItemModel dish) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DishDetailScreen(dish: dish),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))
          ]
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Food Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  dish.imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[200],
                    child: const Icon(Icons.fastfood, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Food Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dish.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("${dish.reviewCount} reviews", style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                  ],
                ),
              ),
              
              // Price Tag
              Text(
                "₩${dish.price}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}