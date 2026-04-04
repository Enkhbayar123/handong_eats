import 'package:flutter/material.dart';

// --- MOCK DATA FOR ARCHIVE ---
class ArchiveItem {
  final String name;
  final int reviews;
  final String price;
  final String imageUrl;

  ArchiveItem(this.name, this.reviews, this.price, this.imageUrl);
}

class ArchiveRestaurant {
  final String name;
  final List<ArchiveItem> items;

  ArchiveRestaurant(this.name, this.items);
}

class MenuArchiveScreen extends StatelessWidget {
  final DateTime archiveDate;

  // Mocking the historical data
  final List<ArchiveRestaurant> _historicalMenus = [
    ArchiveRestaurant("Student Cafeteria (학생식당)", [
      ArchiveItem("Kimchi Jjigae", 128, "₩7,500", "https://images.unsplash.com/photo-1580651315530-69c8e0026377?w=200&q=80"),
      ArchiveItem("Bulgogi Bowl", 94, "₩8,200", "https://images.unsplash.com/photo-1544025162-d76694265947?w=200&q=80"),
    ]),
    ArchiveRestaurant("Mom's Kitchen (맘스키친)", [
      ArchiveItem("Classic Bibimbap", 64, "₩7,000", "https://images.unsplash.com/photo-1553163147-622abc30ffb6?w=200&q=80"),
      ArchiveItem("Handmade Tonkatsu", 112, "₩8,500", "https://images.unsplash.com/photo-1598514982205-f36b96d1e8dd?w=200&q=80"),
    ]),
    ArchiveRestaurant("Handong Lounge (한동라운지)", [
      ArchiveItem("Chef's Special Pasta", 42, "₩12,000", "https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=200&q=80"),
    ]),
  ];

  MenuArchiveScreen({super.key, required this.archiveDate});

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

            // --- 2. Restaurant & Food List ---
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _historicalMenus.length,
              itemBuilder: (context, index) {
                final restaurant = _historicalMenus[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Restaurant Name
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          restaurant.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Food Items for this restaurant
                      ...restaurant.items.map((item) => _buildArchiveFoodCard(item)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER: Archive Food Card ---
  Widget _buildArchiveFoodCard(ArchiveItem item) {
    return Container(
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
                item.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            
            // Food Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("${item.reviews} reviews", style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                ],
              ),
            ),
            
            // Price Tag
            Text(
              item.price,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}