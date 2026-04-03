import 'package:flutter/material.dart';

class TodayMenuScreen extends StatelessWidget {
  const TodayMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Today's Menu", // 
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      // Use a SingleChildScrollView so the whole page can scroll
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: TODAY'S PODIUM ---
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Today's Podium", // 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            
            // A horizontal scrolling list for the top 3 items
            SizedBox(
              height: 200, // Adjust based on your image sizes
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildPodiumItem("1", "Grilled Salmon", "4.9"), // [cite: 27, 30, 33]
                  _buildPodiumItem("2", "Beef Stir Fry", "4.8"), // [cite: 28, 31, 34]
                  _buildPodiumItem("3", "Vegan Bowl", "4.7"), // [cite: 29, 32, 35]
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- SECTION 2: CAFETERIA LIST ---
            // List of dining halls and their top items
            _buildCafeteriaSection(
              cafeteriaName: "학생식당 (Student Cafeteria)", // 
              menuItem: "김치만두설렁탕", // 
              price: "₩7,500", // 
              rating: "4.5", // [cite: 44]
            ),
            
            _buildCafeteriaSection(
               cafeteriaName: "맘스키친 (Moms Kitchen)", // [cite: 49]
               menuItem: "치킨 케밥", // [cite: 50]
               price: "₩9,000", // [cite: 56]
               rating: "4.8", // [cite: 57]
            )
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---
  
  // Widget for the circular top 3 items
  Widget _buildPodiumItem(String rank, String title, String rating) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          // Placeholder for your circular food images
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300], 
              border: Border.all(color: Colors.redAccent, width: 3),
            ),
            child: Center(child: Text("Rank $rank")),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("★ $rating"),
        ],
      ),
    );
  }

  // Widget for the standard list format below the podium
  Widget _buildCafeteriaSection({
    required String cafeteriaName,
    required String menuItem,
    required String price,
    required String rating,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        child: ListTile(
          // Placeholder for the square food image
          leading: Container(
            width: 60,
            height: 60,
            color: Colors.grey[300],
            child: const Icon(Icons.fastfood),
          ),
          title: Text(cafeteriaName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(menuItem, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              Row(
                children: [
                  Text(price, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text("★ $rating"),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}