import 'package:flutter/material.dart';
import 'dish_detail_screen.dart';
// ==========================================
// 1. DATA MODELS (Prep for API Integration)
// ==========================================
class MenuItem {
  final String name;
  final double rating;
  final int reviewCount;
  final String imageUrl; 
  final String price; 

  MenuItem({
    required this.name,
    required this.rating,
    required this.reviewCount,
    // Setting default values so your existing list doesn't break!
    this.imageUrl = '', 
    this.price = '₩6,500', 
  });
}

class Restaurant {
  final String name;
  final String openTime;
  final String closeTime;
  final List<MenuItem> menu;

  Restaurant({
    required this.name,
    required this.openTime,
    required this.closeTime,
    required this.menu,
  });
}

class TodayMenuScreen extends StatefulWidget {
  const TodayMenuScreen({super.key});

  @override
  State<TodayMenuScreen> createState() => _TodayMenuScreenState();
}

class _TodayMenuScreenState extends State<TodayMenuScreen> {
  // ==========================================
  // 2. MOCK DATA (Simulating the future API)
  // ==========================================
  
  // A combined list of all today's meals to calculate the podium
  // Update this list to include real image URLs
  final List<MenuItem> _allMealsToday = [
    MenuItem(
      name: "Grilled Salmon", 
      rating: 4.9, 
      reviewCount: 215,
      imageUrl: "https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=500&q=80", 
    ),
    MenuItem(
      name: "Beef Stir Fry", 
      rating: 4.8, 
      reviewCount: 180,
      imageUrl: "https://images.unsplash.com/photo-1544025162-d76694265947?w=500&q=80",
    ),
    MenuItem(
      name: "Vegan Bowl", 
      rating: 4.7, 
      reviewCount: 124,
      imageUrl: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&q=80",
    ),
  ];

  final List<Restaurant> _restaurants = [
    Restaurant(
      name: "Mom's Kitchen",
      openTime: "08:00",
      closeTime: "19:00",
      menu: [
        MenuItem(name: "Today's Special (Changes Daily)", rating: 4.8, reviewCount: 156),
      ],
    ),
    Restaurant(
      name: "Student Lounge (Sola Fide)",
      openTime: "11:00",
      closeTime: "20:00",
      menu: [
        MenuItem(name: "Sola Fide Static 1", rating: 4.5, reviewCount: 312),
        MenuItem(name: "Sola Fide Static 2", rating: 4.3, reviewCount: 201),
        MenuItem(name: "Sola Fide Static 3", rating: 4.6, reviewCount: 405),
      ],
    ),
    Restaurant(
      name: "Student Lounge (Goshen)",
      openTime: "11:00",
      closeTime: "20:00",
      menu: [
        MenuItem(name: "Goshen Menu 1", rating: 4.7, reviewCount: 288),
        MenuItem(name: "Goshen Menu 2", rating: 4.1, reviewCount: 95),
        MenuItem(name: "Goshen Menu 3", rating: 4.4, reviewCount: 120),
        MenuItem(name: "Goshen Menu 4", rating: 4.2, reviewCount: 80),
        MenuItem(name: "Goshen Menu 5", rating: 4.8, reviewCount: 210),
      ],
    ),
    Restaurant(
      name: "Myeongsong",
      openTime: "11:00",
      closeTime: "19:00",
      menu: [
        MenuItem(name: "Myeongsong Meal A", rating: 4.5, reviewCount: 150),
        MenuItem(name: "Myeongsong Meal B", rating: 4.3, reviewCount: 110),
      ],
    ),
    Restaurant(
      name: "Grace Table",
      openTime: "11:30",
      closeTime: "19:30",
      menu: [
        MenuItem(name: "Grace Table Set A", rating: 4.6, reviewCount: 90),
        MenuItem(name: "Grace Table Set B", rating: 4.8, reviewCount: 140),
      ],
    ),
    Restaurant(
      name: "Dasu Handong",
      openTime: "07:30",
      closeTime: "19:30",
      menu: [
        MenuItem(name: "Daily Changing Menu", rating: 4.5, reviewCount: 128),
      ],
    ),
    Restaurant(
      name: "Deun Deun (Student Bento)",
      openTime: "10:00",
      closeTime: "18:00",
      menu: [
        MenuItem(name: "Bento Box 1", rating: 4.2, reviewCount: 65),
        MenuItem(name: "Bento Box 2", rating: 4.4, reviewCount: 88),
      ],
    ),
    Restaurant(
      name: "Korean Table",
      openTime: "11:00",
      closeTime: "19:00",
      menu: [
        MenuItem(name: "Daily Korean Meal", rating: 4.6, reviewCount: 200),
      ],
    ),
    Restaurant(
      name: "Korean Table 1",
      openTime: "11:00",
      closeTime: "19:00",
      menu: [
        MenuItem(name: "Ramyeon", rating: 4.7, reviewCount: 340),
        MenuItem(name: "Fried Rice", rating: 4.5, reviewCount: 280),
      ],
    ),
  ];

  // State variable to track which restaurant category is clicked
  int _selectedRestaurantIndex = 0; 

  // ==========================================
  // 3. UI BUILDER
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Menu", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50], // Slightly off-white background
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPodiumSection(),
            const SizedBox(height: 16),
            _buildRestaurantFilter(),
            const SizedBox(height: 16),
            _buildMenuListing(),
          ],
        ),
      ),
    );
  }

  // --- WIDGET: TOP 3 PODIUM (UPGRADED) ---
  Widget _buildPodiumSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
          child: Row(
            children: [
              const Text(
                "Today's Podium", 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
              ),
              const SizedBox(width: 8),
              Icon(Icons.local_fire_department, color: Colors.orange[400], size: 24),
            ],
          ),
        ),
        SizedBox(
          height: 190, // Increased height to accommodate the drop shadow and text
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _allMealsToday.length,
            itemBuilder: (context, index) {
              final meal = _allMealsToday[index];
              final isFirstPlace = index == 0; // Check if it's the #1 item

              return Container(
                width: 130, // Slightly wider
                margin: const EdgeInsets.only(right: 20.0),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none, // Allows the badge to hang slightly outside the circle
                      alignment: Alignment.bottomRight,
                      children: [
                        // The Food Image with Shadow
                        Container(
                          height: 110,
                          width: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            border: isFirstPlace 
                                ? Border.all(color: Colors.redAccent, width: 3) // Thicker border for #1
                                : Border.all(color: Colors.white, width: 3),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              meal.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                Container(color: Colors.grey[300], child: const Icon(Icons.restaurant)),
                            ),
                          ),
                        ),
                        
                        // The Rank Badge
                        Positioned(
                          bottom: 0,
                          right: -5,
                          child: Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                              color: isFirstPlace ? Colors.redAccent : Colors.grey[800],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            ),
                            child: Center(
                              child: Text(
                                "${index + 1}", 
                                style: const TextStyle(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 16
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Typography Polish
                    Text(
                      meal.name, 
                      overflow: TextOverflow.ellipsis, 
                      style: const TextStyle(
                        fontWeight: FontWeight.w700, 
                        fontSize: 15,
                        color: Colors.black87,
                      )
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        const SizedBox(width: 2),
                        Text(
                          meal.rating.toString(), 
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- WIDGET: HORIZONTAL RESTAURANT SCROLL ---
  Widget _buildRestaurantFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = _restaurants[index];
          final isSelected = _selectedRestaurantIndex == index;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(restaurant.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedRestaurantIndex = index;
                });
              },
              selectedColor: Colors.black87,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET: THE MENU ITEMS FOR SELECTED RESTAURANT (UPGRADED) ---
  Widget _buildMenuListing() {
    final activeRestaurant = _restaurants[_selectedRestaurantIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Header (Styled)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                activeRestaurant.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${activeRestaurant.openTime} - ${activeRestaurant.closeTime}",
                  style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Menu Items List
          ListView.separated(
            shrinkWrap: true, 
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeRestaurant.menu.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16), // Better spacing between cards
            itemBuilder: (context, index) {
              final item = activeRestaurant.menu[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DishDetailScreen(dish: item),
                    ),
                  );
                },
                child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04), // Very soft shadow
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Food Image with rounded corners
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          item.imageUrl, 
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                            Container(width: 90, height: 90, color: Colors.grey[200], child: const Icon(Icons.fastfood, color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Text Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name, 
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)
                            ),
                            const SizedBox(height: 4),
                            // Price tag
                            Text(
                              item.price, 
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.redAccent)
                            ),
                            const SizedBox(height: 8),
                            // Rating and Reviews Row
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.15), // Tinted background for the star
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                      const SizedBox(width: 2),
                                      Text(item.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text("${item.reviewCount} reviews", style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                              ],
                            )
                          ],
                        ),
                      ),
                      
                      // Trailing Arrow to show it's clickable (for future dish details page)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chevron_right_rounded, color: Colors.black54),
                      )
                    ],
                  ),
                ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}