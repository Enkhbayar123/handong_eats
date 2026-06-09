import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dish_detail_screen.dart';
import '../models/models.dart';
import '../services/localization.dart';
import '../widgets/app_image.dart';
import '../services/auth_service.dart';

class TodayMenuScreen extends StatefulWidget {
  const TodayMenuScreen({super.key});

  @override
  State<TodayMenuScreen> createState() => _TodayMenuScreenState();
}

class _TodayMenuScreenState extends State<TodayMenuScreen> {
  int _selectedRestaurantIndex = 0;
  late final Stream<QuerySnapshot> _restaurantsStream;
  late final Stream<QuerySnapshot> _menuItemsStream;

  @override
  void initState() {
    super.initState();
    _restaurantsStream = FirebaseFirestore.instance
        .collection('restaurants')
        .snapshots();
    _menuItemsStream = FirebaseFirestore.instance
        .collection('menu_items')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Text(
          LocalizationService.tr("today_title"),
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(AuthService.currentUser?.uid ?? 'user_1')
            .snapshots(),
        builder: (context, snapshotU) {
          final user = snapshotU.hasData && snapshotU.data!.exists
              ? UserModel.fromFirestore(snapshotU.data!)
              : AuthService.currentUser;
          final userAllergies = user?.allergies ?? [];

          return StreamBuilder<QuerySnapshot>(
            stream: _restaurantsStream,
            builder: (context, snapshotR) {
              if (snapshotR.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshotR.hasData || snapshotR.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    LocalizationService.tr("no_restaurants"),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                );
              }

              List<RestaurantModel> restaurants = snapshotR.data!.docs
                  .map((doc) => RestaurantModel.fromFirestore(doc))
                  .toList();

              if (_selectedRestaurantIndex >= restaurants.length) {
                _selectedRestaurantIndex = 0;
              }

              return StreamBuilder<QuerySnapshot>(
                stream: _menuItemsStream,
                builder: (context, snapshotM) {
                  if (snapshotM.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<MenuItemModel> allMeals =
                      snapshotM.data?.docs
                          .map((doc) => MenuItemModel.fromFirestore(doc))
                          .toList() ??
                      [];

                  // Compute podium (Top 3 rated items)
                  List<MenuItemModel> sortedMeals = List.from(allMeals);
                  sortedMeals.sort(
                    (a, b) => b.averageRating.compareTo(a.averageRating),
                  );
                  List<MenuItemModel> podiumMeals = sortedMeals.take(3).toList();

                  // Get active restaurant's meals
                  RestaurantModel activeRestaurant =
                      restaurants[_selectedRestaurantIndex];
                  List<MenuItemModel> activeMenu = allMeals
                      .where((m) => m.restaurantId == activeRestaurant.id)
                      .toList();

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (podiumMeals.isNotEmpty)
                          _buildPodiumSection(podiumMeals),
                        if (podiumMeals.isNotEmpty) const SizedBox(height: 24),
                        _buildRestaurantFilter(restaurants),
                        const SizedBox(height: 20),
                        _buildMenuListing(activeRestaurant, activeMenu, userAllergies),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // --- PODIUM SECTION (GORGEOUS Visual First Carousel) ---
  Widget _buildPodiumSection(List<MenuItemModel> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 12.0),
          child: Row(
            children: [
              Text(
                LocalizationService.tr("todays_podium"),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      LocalizationService.tr("hot"),
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 195,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final meal = meals[index];
              final isFirstPlace = index == 0;
              final isSecondPlace = index == 1;

              Color ringColor = Colors.white;
              Color badgeColor = const Color(0xFF6B7280);
              if (isFirstPlace) {
                ringColor = const Color(0xFFFBBF24); // Gold
                badgeColor = const Color(0xFFF59E0B);
              } else if (isSecondPlace) {
                ringColor = const Color(0xFF9CA3AF); // Silver
                badgeColor = const Color(0xFF4B5563);
              } else {
                ringColor = const Color(0xFFD97706); // Bronze
                badgeColor = const Color(0xFF78350F);
              }

              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12.0),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DishDetailScreen(dish: meal),
                              ),
                            );
                          },
                          child: Container(
                            height: 110,
                            width: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              border: Border.all(color: ringColor, width: 3),
                            ),
                            child: ClipOval(
                              child: AppImage(
                                imageUrl: meal.imageUrl,
                                fit: BoxFit.cover,
                                errorWidget: Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.restaurant),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            height: 28,
                            width: 28,
                            decoration: BoxDecoration(
                              color: badgeColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      meal.name,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          meal.averageRating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: Colors.black87,
                          ),
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

  // --- RESTAURANT FILTER (Pill-shaped modern filter bar) ---
  Widget _buildRestaurantFilter(List<RestaurantModel> restaurants) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
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
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF1E293B),
              shadowColor: Colors.black.withOpacity(0.05),
              elevation: isSelected ? 4 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : const Color(0xFFE5E7EB),
                ),
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF4B5563),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          );
        },
      ),
    );
  }

  // --- MENU LISTING (Modern cards with details) ---
  List<String> _getDetectedAllergens(MenuItemModel item, List<String> userAllergies) {
    if (userAllergies.isEmpty) return [];

    final textToSearch = "${item.name} ${item.description}".toLowerCase();
    final List<String> detected = [];

    final Map<String, List<String>> allergyKeywords = {
      'Peanuts': ['peanut', '땅콩', '피넛'],
      'Tree Nuts': ['almond', 'walnut', 'cashew', 'pecan', 'hazelnut', 'nut', 'macadamia', '아몬드', '호두', '캐슈넛', '피칸', '헤이즐넛', '견과류', '넛트'],
      'Shellfish': ['shrimp', 'crab', 'lobster', 'shellfish', 'clam', 'oyster', 'mussel', 'seafood', '새우', '게', '조개', '굴', '홍합', '갑각류', '해산물'],
      'Eggs': ['egg', '계란', '달걀', '난황', '알류'],
      'Wheat': ['wheat', 'flour', 'gluten', 'bread', 'pasta', '밀', '밀가루', '글루텐'],
      'Soy': ['soy', 'tofu', 'edamame', '콩', '두부', '간장', '대두'],
      'Milk': ['milk', 'butter', 'cheese', 'dairy', 'cream', 'yogurt', 'whey', '우유', '버터', '치즈', '크림', '요거트', '유제품'],
    };

    for (var allergy in userAllergies) {
      final keywords = allergyKeywords[allergy];
      if (keywords != null) {
        for (var keyword in keywords) {
          if (textToSearch.contains(keyword)) {
            detected.add(allergy);
            break;
          }
        }
      }
    }

    return detected;
  }

  Widget _buildMenuListing(
    RestaurantModel activeRestaurant,
    List<MenuItemModel> activeMenu,
    List<String> userAllergies,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeRestaurant.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildStatusBadge(activeRestaurant),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Text(
                  "${activeRestaurant.openTime} - ${activeRestaurant.closeTime}",
                  style: const TextStyle(
                    color: Color(0xFF047857),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (activeMenu.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Center(
                child: Text(
                  LocalizationService.tr("no_items_available"),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeMenu.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = activeMenu[index];
              final detectedAllergens = _getDetectedAllergens(item, userAllergies);
              final isKo = LocalizationService.currentLanguage.value == 'ko';

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
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: AppImage(
                            imageUrl: item.imageUrl,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "₩${item.price}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE94E5D),
                                ),
                              ),
                              if (detectedAllergens.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red[100]!),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.redAccent,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          isKo 
                                            ? "알레르기 주의: ${detectedAllergens.join(', ')}"
                                            : "Allergy Warning: ${detectedAllergens.join(', ')}",
                                          style: const TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          color: Colors.amber,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          item.averageRating.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${item.reviewCount} reviews",
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3F4F6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.black54,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- REPORT STATUS BADGE ---
  Widget _buildStatusBadge(RestaurantModel restaurant) {
    Color badgeColor;
    Color textColor;
    String statusText;
    IconData statusIcon;

    switch (restaurant.currentStatus) {
      case CrowdedStatus.empty:
        badgeColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        statusText = "Line: Empty";
        statusIcon = Icons.sentiment_very_satisfied_rounded;
        break;
      case CrowdedStatus.moderate:
        badgeColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        statusText = "Line: Moderate";
        statusIcon = Icons.sentiment_neutral_rounded;
        break;
      case CrowdedStatus.busy:
        badgeColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        statusText = "Line: Busy";
        statusIcon = Icons.sentiment_dissatisfied_rounded;
        break;
      case CrowdedStatus.unknown:
        badgeColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF374151);
        statusText = "Line: Unknown";
        statusIcon = Icons.help_outline_rounded;
        break;
    }

    return GestureDetector(
      onTap: () => _showReportStatusBottomSheet(restaurant),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: textColor.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, size: 14, color: textColor),
            const SizedBox(width: 4),
            Text(
              statusText,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.edit_outlined,
              size: 11,
              color: textColor.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportStatusBottomSheet(RestaurantModel restaurant) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "How is the line at ${restaurant.name}?",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                "Help other students by reporting the current status.",
                style: TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildReportOption(
                context,
                restaurant,
                "Empty (0-5 mins)",
                Icons.sentiment_very_satisfied_rounded,
                Colors.green,
                CrowdedStatus.empty,
              ),
              const SizedBox(height: 10),
              _buildReportOption(
                context,
                restaurant,
                "Moderate (5-15 mins)",
                Icons.sentiment_neutral_rounded,
                Colors.orange,
                CrowdedStatus.moderate,
              ),
              const SizedBox(height: 10),
              _buildReportOption(
                context,
                restaurant,
                "Very Busy (15+ mins)",
                Icons.sentiment_dissatisfied_rounded,
                Colors.red,
                CrowdedStatus.busy,
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportOption(
    BuildContext context,
    RestaurantModel restaurant,
    String label,
    IconData icon,
    MaterialColor color,
    CrowdedStatus status,
  ) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(restaurant.id)
            .update({'currentStatus': status.name});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Thank you for updating the line status! 👏"),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: color.shade200),
          borderRadius: BorderRadius.circular(16),
          color: color.shade50.withOpacity(0.8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color.shade700, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
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
