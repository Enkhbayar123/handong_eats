import 'package:flutter/material.dart';
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
                widget.dish.imageUrl,
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
                    widget.dish.name,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                      const SizedBox(width: 4),
                      Text(
                        widget.dish.averageRating.toString(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${widget.dish.reviewCount} Reviews",
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
                        
                        // Handles conditional visibility states seamlessly
                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: CircularProgressIndicator(color: Colors.purple),
                            ),
                          )
                        else if (_aiDescription != null)
                          Text(
                            _aiDescription!,
                            style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
                          )
                        else
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: ElevatedButton.icon(
                                onPressed: _generateAIDescription,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple[400],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.auto_awesome, size: 18),
                                label: const Text("Generate AI Description", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
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
                          Text(widget.dish.averageRating.toString(), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, height: 1)),
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
                              builder: (context) => PhotoGalleryScreen(dish: widget.dish),
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