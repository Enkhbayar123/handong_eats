import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; // Import for Gemini API
import 'photo_gallery_screen.dart';
import 'review_detail_screen.dart';
import '../models/models.dart';
import '../services/auth_service.dart';

class DishDetailScreen extends StatefulWidget {
  final MenuItemModel dish;

  const DishDetailScreen({super.key, required this.dish});

  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen> {
  // We can track the current average rating and count locally or stream them from Firestore
  late double _averageRating;
  late int _reviewCount;

  @override
  void initState() {
    super.initState();
    _averageRating = widget.dish.averageRating.toDouble();
    _reviewCount = widget.dish.reviewCount;
  }

  bool _isLoading = false;
  String? _aiDescription;

  Future<void> _generateAIDescription() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Secure API Key: allows overriding using --dart-define=GEMINI_API_KEY=YOUR_KEY
      const apiKey = String.fromEnvironment(
        'GEMINI_API_KEY',
        defaultValue: 'AIzaSyDSiGXcpR7jAhIU8OUyeX67dob19Z99RmY',
      );
      
      // Using gemini-flash-latest for rapid text generations
      final model = GenerativeModel(model: 'gemini-flash-latest', apiKey: apiKey);

      final user = AuthService.currentUser;
      final userCountry = user?.country ?? 'South Korea';
      final spiceTolerance = user?.spiceTolerance ?? 'Medium';
      final dietaryLabels = user?.dietaryLabels ?? [];
      final allergies = user?.allergies ?? [];
      final preferredTastes = user?.preferredTastes ?? [];
      
      final dishName = widget.dish.name;

      // Prompt template explicitly handling country-specific food matching
      var prompt = 'Provide a short, highly appetizing description for a dish named "$dishName". '
          'Additionally, since the user is from $userCountry, recommend a similar food or equivalent option '
          'that exists in $userCountry cuisine to help them understand what it tastes like.';

      // Add spice tolerance custom logic
      prompt += ' The user has a spice tolerance of "$spiceTolerance". '
          'Identify if the dish is spicy. If it is spicier than their tolerance, warn them clearly; '
          'otherwise, let them know it fits their spice preference.';

      // Add allergy/dietary custom logic
      if (dietaryLabels.isNotEmpty || allergies.isNotEmpty) {
        prompt += ' IMPORTANT: The user has the following dietary guidelines: '
            'Dietary labels: ${dietaryLabels.join(", ")}, Allergies: ${allergies.join(", ")}. '
            'If the dish "$dishName" violates these (e.g., contains peanuts if they are allergic, or is non-halal if they require halal), '
            'prominently place a clear caution/warning at the very beginning of the response. Otherwise, note that it conforms to their restrictions.';
      }

      // Add flavor preference custom logic
      if (preferredTastes.isNotEmpty) {
        prompt += ' The user prefers these flavor notes: ${preferredTastes.join(", ")}. '
            'Highlight how this dish matches or fits these favorite flavor profiles.';
      }

      // Instruct Gemini to output raw, clean, highly readable plain text paragraphs only without any markdown formatting
      prompt += ' CRITICAL FORMATTING REQUIREMENT: Do NOT use any Markdown formatting, bold symbols (like asterisks like **), bullet points (- or *), headings (#), or list symbols. Return the response as raw, clean, highly readable plain text paragraphs only. Ensure no special formatting characters appear in the output.';
      
      final response = await model.generateContent([Content.text(prompt)]);

      // Double-layered protection: strip any stray markdown formatting characters
      String? cleanText = response.text;
      if (cleanText != null) {
        cleanText = cleanText
            .replaceAll(RegExp(r'\*\*'), '') // Remove bold marks
            .replaceAll(RegExp(r'\*'), '')   // Remove italic marks
            .replaceAll(RegExp(r'###? '), '') // Remove headings
            .replaceAll(RegExp(r'`'), '')     // Remove code backticks
            .replaceAll(RegExp(r'^\s*-\s+', multiLine: true), '') // Remove leading list dashes
            .trim();
      }

      setState(() {
        _aiDescription = cleanText;
      });
    } catch (e) {
      debugPrint('Gemini API Error: $e');
      final errorStr = e.toString();
      setState(() {
        if (errorStr.contains('API key expired')) {
          _aiDescription = 'Failed to generate AI description because the API key is expired.\n\n'
              'To fix this, please run your app with a valid key:\n'
              'flutter run --dart-define=GEMINI_API_KEY=YOUR_NEW_KEY\n\n'
              'Or replace the expired apiKey variable in dish_detail_screen.dart.';
        } else if (errorStr.contains('blocked') || errorStr.contains('API key not valid')) {
          _aiDescription = 'Failed to generate AI description because the API key is restricted or invalid.\n\n'
              'Please verify that your Google AI Studio API key has permission for the Generative Language API, '
              'or run with a valid key:\n'
              'flutter run --dart-define=GEMINI_API_KEY=YOUR_NEW_KEY';
        } else {
          _aiDescription = 'Failed to generate smart description. Please try again.\nError: $e';
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

    final userId = AuthService.currentUser?.uid ?? 'user_1';
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
      builder: (context, userSnapshot) {
        final userData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
        final favoriteMenuIds = List<String>.from(userData['favoriteMenuIds'] ?? []);
        final isFavorited = favoriteMenuIds.contains(widget.dish.id);

        return Scaffold(
          backgroundColor: Colors.white,
          body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('menu_items').doc(widget.dish.id).snapshots(),
            builder: (context, dishSnapshot) {
              if (dishSnapshot.hasData && dishSnapshot.data!.exists) {
                final freshDish = MenuItemModel.fromFirestore(dishSnapshot.data!);
                _averageRating = freshDish.averageRating.toDouble();
                _reviewCount = freshDish.reviewCount;
              }

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // --- HERO IMAGE APP BAR ---
                  SliverAppBar(
                    expandedHeight: 280.0,
                    pinned: true,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            widget.dish.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.fastfood, size: 50, color: Colors.grey),
                            ),
                          ),
                            ),
                          ),
                          // Subtle overlay at the top for back/heart buttons
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isFavorited ? Icons.favorite : Icons.favorite_border_rounded,
                            color: isFavorited ? const Color(0xFFE94E5D) : Colors.black87,
                            size: 24,
                          ),
                          onPressed: () async {
                            final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
                            await userRef.set({
                              'favoriteMenuIds': isFavorited
                                  ? FieldValue.arrayRemove([widget.dish.id])
                                  : FieldValue.arrayUnion([widget.dish.id])
                            }, SetOptions(merge: true));
                          },
                        ),
                      ),
                    ],
                  ),

                  // --- PAGE CONTENT ---
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Title and Basic Info
                          Text(
                            widget.dish.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
                              const SizedBox(width: 4),
                              Text(
                                _averageRating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "$_reviewCount Reviews",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "₩${widget.dish.price}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFE94E5D),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 2. Nutrition Macros Breakdown (Visual First & Elegant)
                          _buildNutritionMacrosWidget(),
                          const SizedBox(height: 20),

                          // 3. AI Smart Description Box
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [const Color(0xFF6B4EFF).withOpacity(0.06), const Color(0xFF8B5CF6).withOpacity(0.06)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFF6B4EFF).withOpacity(0.12)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.auto_awesome, color: const Color(0xFF6B4EFF), size: 18),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "SMART MENU DESCRIPTION",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF6B4EFF),
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  widget.dish.description.isNotEmpty
                                      ? widget.dish.description
                                      : "A savory, freshly-prepared selection crafted with healthy and seasonal ingredients.",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 4. "I Ate This!" Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () => _showAddReviewBottomSheet(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE94E5D),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 4,
                                shadowColor: const Color(0xFFE94E5D).withOpacity(0.3),
                              ),
                              icon: const Icon(Icons.add_a_photo_outlined),
                              label: const Text("I ate this!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 5. Reviews Summary (Live calculations)
                          const Text("Reviews Summary", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _buildLiveReviewsSummarySection(),
                          const SizedBox(height: 32),

                          // 6. User Reviews List (Live stream)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("User Reviews", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PhotoGalleryScreen(dish: widget.dish),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Photos",
                                  style: TextStyle(
                                    color: Color(0xFFE94E5D),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildLiveReviewsList(),
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }

  // --- MACROS COMPONENT ---
  Widget _buildNutritionMacrosWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMacroLabel("Calories", "${widget.dish.calories} kcal"),
          _buildMacroLabel("Protein", "${widget.dish.protein}g"),
          _buildMacroLabel("Carbs", "${widget.dish.carbs}g"),
          _buildMacroLabel("Fat", "${widget.dish.fat}g"),
        ],
      ),
    );
  }

  Widget _buildMacroLabel(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // --- LIVE REVIEWS SUMMARY COMPONENT ---
  Widget _buildLiveReviewsSummarySection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('menuItemId', isEqualTo: widget.dish.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final reviews = snapshot.data!.docs;
        final total = reviews.length;

        // Calculate distribution
        Map<int, int> ratingCounts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
        for (var doc in reviews) {
          final r = doc['rating'] as int? ?? 0;
          if (ratingCounts.containsKey(r)) {
            ratingCounts[r] = ratingCounts[r]! + 1;
          }
        }

        return Row(
          children: [
            Column(
              children: [
                Text(
                  _averageRating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, height: 1),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.star_rounded,
                      color: index < _averageRating.round() ? Colors.amber : Colors.grey[300],
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$total Reviews",
                  style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Column(
                children: List.generate(5, (index) {
                  final star = 5 - index;
                  final count = ratingCounts[star] ?? 0;
                  final pct = total > 0 ? count / total : 0.0;
                  return _buildRatingBar(star.toString(), pct);
                }),
              ),
            )
          ],
        );
      },
    );
  }

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
              backgroundColor: const Color(0xFFF3F4F6),
              color: const Color(0xFFE94E5D),
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              "${(percentage * 100).toInt()}%",
              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  // --- LIVE REVIEWS LIST COMPONENT ---
  Widget _buildLiveReviewsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('menuItemId', isEqualTo: widget.dish.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                "No reviews yet. Be the first to share your thoughts!",
                style: TextStyle(color: Colors.grey[400], fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          );
        }

        final reviews = snapshot.data!.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(review.userId).get(),
              builder: (context, userSnap) {
                String name = "Alex Chan";
                String userImage = "https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=200&q=80";

                if (userSnap.hasData && userSnap.data!.exists) {
                  name = userSnap.data!.get('name') ?? name;
                  userImage = userSnap.data!.get('profileImageUrl') ?? userImage;
                }

                // Format time difference
                final diff = DateTime.now().difference(review.datePosted);
                String dateStr = "Just now";
                if (diff.inDays > 0) {
                  dateStr = "${diff.inDays} days ago";
                } else if (diff.inHours > 0) {
                  dateStr = "${diff.inHours} hours ago";
                } else if (diff.inMinutes > 0) {
                  dateStr = "${diff.inMinutes} mins ago";
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewDetailScreen(
                          username: name,
                          userImage: userImage,
                          rating: review.rating,
                          date: dateStr,
                          originalReview: review.originalReview,
                          translatedReview: review.translatedReview,
                          backgroundImageUrl: review.backgroundImageUrl.isNotEmpty
                              ? review.backgroundImageUrl
                              : "https://images.unsplash.com/photo-1552611052-33e04de081de?w=800&q=80",
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: NetworkImage(userImage),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      Row(
                                        children: List.generate(
                                          5,
                                          (idx) => Icon(
                                            Icons.star_rounded,
                                            color: idx < review.rating ? Colors.amber : Colors.grey[300],
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            review.originalReview,
                            style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // --- REVIEW SUBMISSION BOTTOM SHEET ---
  void _showAddReviewBottomSheet(BuildContext context) {
    int localRating = 5;
    String selectedMealType = "Lunch";
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Add Meal Log & Review",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Record your plate and share your feedback on ${widget.dish.name}.",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 20),

                    // Meal Type
                    const Text("Meal Type", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: ["Breakfast", "Lunch", "Dinner"].map((type) {
                        bool isSel = selectedMealType == type;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(type),
                            selected: isSel,
                            selectedColor: const Color(0xFFE94E5D),
                            onSelected: (selected) {
                              if (selected) {
                                setModalState(() {
                                  selectedMealType = type;
                                });
                              }
                            },
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Rating
                    const Text("Rating", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              localRating = star;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(
                              star <= localRating ? Icons.star_rounded : Icons.star_border_rounded,
                              color: star <= localRating ? Colors.amber : Colors.grey[300],
                              size: 40,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // Review text
                    const Text("Write a Review", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: noteController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "How was the taste, portions, and freshness?",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(bc);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Saving your meal log & review...")),
                          );

                          final String userReviewText = noteController.text.trim();
                          final String originalText = userReviewText.isNotEmpty ? userReviewText : "Delicious!";

                          // Generate mock translation for bilingual users
                          final String translatedText = originalText == "Delicious!"
                              ? "Delicious!"
                              : "Translation: $originalText";
                          
                          final activeUserId = AuthService.currentUser?.uid ?? 'user_1';

                          // 1. Add review
                          final reviewDocRef = FirebaseFirestore.instance.collection('reviews').doc();
                          final newReview = ReviewModel(
                            id: reviewDocRef.id,
                            userId: activeUserId,
                            menuItemId: widget.dish.id,
                            rating: localRating,
                            originalReview: originalText,
                            translatedReview: translatedText,
                            datePosted: DateTime.now(),
                            backgroundImageUrl: widget.dish.imageUrl,
                          );
                          await reviewDocRef.set(newReview.toMap());

                          // 2. Add meal log
                          final logDocRef = FirebaseFirestore.instance.collection('meal_logs').doc();
                          final newLog = MealLogModel(
                            id: logDocRef.id,
                            userId: activeUserId,
                            menuItemId: widget.dish.id,
                            date: DateTime.now(),
                            mealType: selectedMealType,
                            rating: localRating,
                            personalNote: originalText,
                            photoUrl: widget.dish.imageUrl,
                          );
                          await logDocRef.set(newLog.toMap());

                          // 3. Update restaurant and menu item stats in Transaction
                          final dishRef = FirebaseFirestore.instance.collection('menu_items').doc(widget.dish.id);
                          await FirebaseFirestore.instance.runTransaction((transaction) async {
                            final freshSnap = await transaction.get(dishRef);
                            if (freshSnap.exists) {
                              final currentRating = freshSnap.get('averageRating') ?? 0.0;
                              final currentCount = freshSnap.get('reviewCount') ?? 0;

                              final newCount = currentCount + 1;
                              final newRating = ((currentRating * currentCount) + localRating) / newCount;

                              transaction.update(dishRef, {
                                'averageRating': double.parse(newRating.toStringAsFixed(1)),
                                'reviewCount': newCount,
                              });
                            }
                          });

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Successfully logged meal and posted review! 🎉"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE94E5D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text("Post Review & Log", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}