import 'package:flutter/material.dart';
import 'today_menu_screen.dart'; 
import 'photo_gallery_screen.dart'; 
import 'review_detail_screen.dart'; 
import '../models/models.dart';

class DishDetailScreen extends StatelessWidget {
  final MenuItemModel dish;

  const DishDetailScreen({super.key, required this.dish});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // --- HERO IMAGE APP BAR ---
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                dish.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                  Container(color: Colors.grey[200], child: const Icon(Icons.fastfood, size: 50, color: Colors.grey)),
              ),
            ),
          ),

          // --- PAGE CONTENT ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Title and Basic Info
                  Text(
                    dish.name,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                      const SizedBox(width: 4),
                      Text(
                        dish.averageRating.toString(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${dish.reviewCount} Reviews",
                        style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 2. AI Smart Description Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple[50], 
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.purple[100]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.purple[400], size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "SMART MENU DESCRIPTION",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.purple[700]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "A savory soy-based stir-fry with sweet potato glass noodles, colorful vegetables, and toasted sesame.",
                          style: TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. "I Ate This!" Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Will trigger the camera/review flow later
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text("I ate this!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 4. Reviews Summary (Bars)
                  const Text("Reviews", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(dish.averageRating.toString(), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, height: 1)),
                          Row(
                            children: List.generate(5, (index) => const Icon(Icons.star_rounded, color: Colors.amber, size: 16)),
                          )
                        ],
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          children: [
                            _buildRatingBar("5", 0.85),
                            _buildRatingBar("4", 0.10),
                            _buildRatingBar("3", 0.03),
                            _buildRatingBar("2", 0.02),
                            _buildRatingBar("1", 0.00),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 5. Photos Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Photos", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhotoGalleryScreen(dish: dish),
                            ),
                          );
                        },
                        child: Text("See all", style: TextStyle(color: Colors.redAccent[400], fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[300],
                            image: const DecorationImage(
                              image: NetworkImage("https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&q=80"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 6. User Reviews List
                  _buildUserReview(
                    context: context, 
                    name: "Alex Chan",
                    date: "3 days ago",
                    rating: 5,
                    review: "Best I've had on campus so far. The noodles are perfectly chewy and not too oily. Love the amount of wood ear mushrooms they included!",
                  ),
                  _buildUserReview(
                    context: context, 
                    name: "Ji-won Kim",
                    date: "Yesterday",
                    rating: 4,
                    review: "면이 아주 쫄깃하고 간이 딱 맞아요. 고향의 맛이 느껴지네요. 야채도 신선해서 좋았습니다.",
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- HELPER: Rating Bar ---
  Widget _buildRatingBar(String star, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(star, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[200],
              color: Colors.redAccent,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text("${(percentage * 100).toInt()}%", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          )
        ],
      ),
    );
  }

  // --- HELPER: User Review Card ---
  Widget _buildUserReview({required BuildContext context, required String name, required String date, required int rating, required String review}) {
    final String mockTranslation = "The noodles are very chewy and the seasoning is just right. It tastes like home. It was nice that the vegetables were fresh.";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewDetailScreen(
              username: name,
              userImage: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80", 
              rating: rating,
              date: date,
              originalReview: review,
              translatedReview: mockTranslation, 
              backgroundImageUrl: "https://images.unsplash.com/photo-1552611052-33e04de081de?w=800&q=80", 
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Container(
          color: Colors.transparent, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: Text(name[0], style: const TextStyle(color: Colors.black)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Row(
                            children: List.generate(5, (index) => Icon(
                              Icons.star_rounded, 
                              color: index < rating ? Colors.amber : Colors.grey[300], 
                              size: 14
                            )),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                review, 
                style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
                maxLines: 3, 
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}