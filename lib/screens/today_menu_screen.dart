import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dish_detail_screen.dart';
import '../models/models.dart';

class TodayMenuScreen extends StatefulWidget {
  const TodayMenuScreen({super.key});

  @override
  State<TodayMenuScreen> createState() => _TodayMenuScreenState();
}

class _TodayMenuScreenState extends State<TodayMenuScreen> {
  int _selectedRestaurantIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Menu", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      // Outer Stream: Restaurants
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
        builder: (context, snapshotR) {
          if (snapshotR.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshotR.hasData || snapshotR.data!.docs.isEmpty) {
            return const Center(
              child: Text("No restaurants found.\nGo to My Profile and tap 'Seed Database'.", textAlign: TextAlign.center),
            );
          }

          List<RestaurantModel> restaurants = snapshotR.data!.docs
              .map((doc) => RestaurantModel.fromFirestore(doc))
              .toList();

          if (_selectedRestaurantIndex >= restaurants.length) {
            _selectedRestaurantIndex = 0;
          }

          // Inner Stream: Menu Items
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('menu_items').snapshots(),
            builder: (context, snapshotM) {
              if (snapshotM.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              List<MenuItemModel> allMeals = snapshotM.data?.docs
                  .map((doc) => MenuItemModel.fromFirestore(doc))
                  .toList() ?? [];

              // Compute podium
              List<MenuItemModel> sortedMeals = List.from(allMeals);
              sortedMeals.sort((a, b) => b.averageRating.compareTo(a.averageRating));
              List<MenuItemModel> podiumMeals = sortedMeals.take(3).toList();

              // Get active restaurant's meals
              RestaurantModel activeRestaurant = restaurants[_selectedRestaurantIndex];
              List<MenuItemModel> activeMenu = allMeals
                  .where((m) => m.restaurantId == activeRestaurant.id)
                  .toList();

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (podiumMeals.isNotEmpty) _buildPodiumSection(podiumMeals),
                    if (podiumMeals.isNotEmpty) const SizedBox(height: 16),
                    _buildRestaurantFilter(restaurants),
                    const SizedBox(height: 16),
                    _buildMenuListing(activeRestaurant, activeMenu),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPodiumSection(List<MenuItemModel> meals) {
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
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final meal = meals[index];
              final isFirstPlace = index == 0;

              return Container(
                width: 130,
                margin: const EdgeInsets.only(right: 20.0),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomRight,
                      children: [
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
                                ? Border.all(color: Colors.redAccent, width: 3)
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
                                ]),
                            child: Center(
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(meal.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.black87,
                        )),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        const SizedBox(width: 2),
                        Text(
                          meal.averageRating.toString(),
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

  Widget _buildRestaurantFilter(List<RestaurantModel> restaurants) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];
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

  Widget _buildMenuListing(RestaurantModel activeRestaurant, List<MenuItemModel> activeMenu) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeRestaurant.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusBadge(activeRestaurant),
                  ],
                ),
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
          if (activeMenu.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text("No items available today.", style: TextStyle(color: Colors.grey)),
            ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeMenu.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = activeMenu[index];
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
                        color: Colors.black.withOpacity(0.04),
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            item.imageUrl,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                                width: 90,
                                height: 90,
                                color: Colors.grey[200],
                                child: const Icon(Icons.fastfood, color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  style: const TextStyle(
                                      fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
                              const SizedBox(height: 4),
                              Text("₩${item.price}",
                                  style: const TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w600, color: Colors.redAccent)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                        const SizedBox(width: 2),
                                        Text(item.averageRating.toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.orange)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text("${item.reviewCount} reviews",
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                                ],
                              )
                            ],
                          ),
                        ),
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

  Widget _buildStatusBadge(RestaurantModel restaurant) {
    Color badgeColor;
    Color textColor;
    String statusText;
    IconData statusIcon;

    switch (restaurant.currentStatus) {
      case CrowdedStatus.empty:
        badgeColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        statusText = "Line: Empty";
        statusIcon = Icons.sentiment_very_satisfied;
        break;
      case CrowdedStatus.moderate:
        badgeColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        statusText = "Line: Moderate";
        statusIcon = Icons.sentiment_neutral;
        break;
      case CrowdedStatus.busy:
        badgeColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        statusText = "Line: Busy";
        statusIcon = Icons.sentiment_dissatisfied;
        break;
      case CrowdedStatus.unknown:
      default:
        badgeColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
        statusText = "Line: Unknown";
        statusIcon = Icons.help_outline;
        break;
    }

    return GestureDetector(
      onTap: () => _showReportStatusBottomSheet(restaurant),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: textColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              statusText,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit, size: 12, color: textColor.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }

  void _showReportStatusBottomSheet(RestaurantModel restaurant) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "How is the line at ${restaurant.name}?",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Help other students by reporting the current status.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildReportOption(
                context,
                restaurant,
                "Empty (0-5 mins)",
                Icons.sentiment_very_satisfied,
                Colors.green,
                CrowdedStatus.empty,
              ),
              const SizedBox(height: 12),
              _buildReportOption(
                context,
                restaurant,
                "Moderate (5-15 mins)",
                Icons.sentiment_neutral,
                Colors.orange,
                CrowdedStatus.moderate,
              ),
              const SizedBox(height: 12),
              _buildReportOption(
                context,
                restaurant,
                "Very Busy (15+ mins)",
                Icons.sentiment_dissatisfied,
                Colors.red,
                CrowdedStatus.busy,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportOption(BuildContext context, RestaurantModel restaurant, String label, IconData icon,
      MaterialColor color, CrowdedStatus status) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        await FirebaseFirestore.instance.collection('restaurants').doc(restaurant.id).update({
          'currentStatus': status.name,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Thank you for updating the line status! 👏"),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: color.shade200),
          borderRadius: BorderRadius.circular(12),
          color: color.shade50,
        ),
        child: Row(
          children: [
            Icon(icon, color: color.shade700, size: 28),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}