import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; // Import for Gemini API
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'photo_gallery_screen.dart';
import 'review_detail_screen.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/localization.dart';
import '../widgets/add_review_bottom_sheet.dart';
import '../widgets/tier_badge.dart';
import '../widgets/app_image.dart';

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

  int? _aiCalories;
  int? _aiProtein;
  int? _aiCarbs;
  int? _aiFat;
  bool _isMacrosLoading = false;
  String? _macrosError;
  bool _isLocalEstimation = false;

  @override
  void initState() {
    super.initState();
    _averageRating = widget.dish.averageRating.toDouble();
    _reviewCount = widget.dish.reviewCount;
    _estimateAIMacros();
  }

  bool _isLoading = false;
  String? _aiDescription;

  Future<void> _generateAIDescription() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final dishName = widget.dish.name;
    final dishDesc = widget.dish.description;

    Future<String?> tryQueryDescription(String modelName) async {
      try {
        final apiKey =
            (dotenv.isInitialized ? dotenv.env['GEMINI_API_KEY'] : null) ??
            const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
        if (apiKey.isEmpty) return null;

        final model = GenerativeModel(
          model: modelName,
          apiKey: apiKey,
        );

        final user = AuthService.currentUser;
        final allergies = user?.allergies ?? [];

        var prompt =
            '"$dishName" 음식에 대해 2~3문장으로 설명해줘. '
            '백과사전이나 네이버 검색 결과처럼 건조하고 사실적으로만 써. '
            '절대 맛있다, 풍미가 일품이다, 입안에서 녹는다 같은 오글거리는 표현 쓰지 마. '
            '그냥 어떤 재료로 만들고 어떤 종류의 음식인지만 알려줘. 한국어로 써.';

        if (allergies.isNotEmpty) {
          prompt +=
              ' 알레르기 주의: 사용자가 ${allergies.join(", ")}에 알레르기가 있음. 해당 성분이 포함될 수 있으면 맨 앞에 경고해줘.';
        }

        prompt += ' 마크다운 기호 쓰지 마.';

        final response = await model.generateContent([Content.text(prompt)]);
        String? cleanText = response.text;
        if (cleanText != null) {
          cleanText = cleanText
              .replaceAll(RegExp(r'\*\*'), '')
              .replaceAll(RegExp(r'\*'), '')
              .replaceAll(RegExp(r'###? '), '')
              .replaceAll(RegExp(r'`'), '')
              .replaceAll(RegExp(r'^\s*-\s+', multiLine: true), '')
              .trim();
        }
        return cleanText;
      } catch (e) {
        final errStr = e.toString().toLowerCase();
        if (errStr.contains('quota') || errStr.contains('limit') || errStr.contains('exhausted') || errStr.contains('429')) {
          debugPrint('Gemini Description failed: API quota exceeded or rate limit hit. Aborting descriptions query.');
          throw Exception('QUOTA_EXCEEDED');
        }
        debugPrint('Gemini Description tryQueryDescription ($modelName) failed: $e');
        return null;
      }
    }

    final modelNames = [
      'gemini-2.0-flash',
      'gemini-1.5-flash-latest',
      'gemini-1.5-flash',
      'gemini-flash-latest',
      'gemini-2.0-flash-exp',
      'gemini-1.5-pro',
      'gemini-1.5-pro-latest',
      'gemini-pro-latest',
    ];

    String? cleanText;
    try {
      // Secure API Key loaded dynamically from .env to prevent leakage on GitHub
      final apiKey =
          (dotenv.isInitialized ? dotenv.env['GEMINI_API_KEY'] : null) ??
          const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

      // Using gemini-flash-latest for rapid text generations
      final model = GenerativeModel(
        model: 'gemini-flash-latest',
        apiKey: apiKey,
      );

      final user = AuthService.currentUser;
      final userCountry = user?.country ?? 'South Korea';
      final spiceTolerance = user?.spiceTolerance ?? 'Medium';
      final dietaryLabels = user?.dietaryLabels ?? [];
      final allergies = user?.allergies ?? [];
      final preferredTastes = user?.preferredTastes ?? [];
      final preferredLanguage = user?.preferredLanguage ?? 'English';

      final dishName = widget.dish.name;

      // Prompt: dry, factual, no fluff, with nationality-based comparison
      var prompt =
          '"$dishName" 음식에 대해 2~3문장으로 설명해줘. '
          '백과사전이나 검색 결과처럼 건조하고 사실적으로만 써. '
          '절대 맛있다, 풍미가 일품이다, 입안에서 녹는다 같은 오글거리는 표현 쓰지 마. '
          '그냥 어떤 재료로 만들고 어떤 종류의 음식인지 설명해줘. 한국어로 써. '
          '또한, 사용자의 출신 국가는 "$userCountry"입니다. '
          '만약 "$userCountry"에 이 음식("$dishName")과 조리법, 재료, 컨셉 등이 유사한 대표적인 현지 음식이 있다면, '
          '"이 음식은 $userCountry의 [유사 음식 이름]과 유사합니다." 형태로 비슷한 점을 비교하여 쉽게 이해할 수 있게 설명하는 한 문장을 꼭 덧붙여줘. '
          '(만약 사용자의 국가가 South Korea인 경우에는 한국의 다른 대중적인 음식과 비교해줘.)';

      // Allergy warning only
      if (allergies.isNotEmpty) {
        prompt +=
            ' 알레르기 주의: 사용자가 ${allergies.join(", ")}에 알레르기가 있음. 해당 성분이 포함될 수 있으면 맨 앞에 경고해줘.';
      }
    } catch (e) {
      if (e.toString().contains('QUOTA_EXCEEDED')) {
        cleanText = null;
      }
    }

    if (cleanText != null) {
      if (mounted) {
        setState(() {
          _aiDescription = cleanText;
          _isLoading = false;
        });
      }
    } else {
      // Fallback: clean local description
      debugPrint('Gemini Description failed for both models. Using local description fallback.');
      final localText = dishDesc.isNotEmpty
          ? dishDesc
          : "신선한 재료로 준비한 정성스러운 음식입니다. 학생 및 교직원을 위해 균형 잡힌 영양소로 구성되어 맛과 건강을 동시에 챙길 수 있습니다.";
      if (mounted) {
        setState(() {
          _aiDescription = localText;
          _isLoading = false;
        });
      }
    }
  }

  Map<String, int> _calculateLocalHeuristicMacros(String name, String description) {
    final text = "$name $description".toLowerCase();
    
    int calories = 350;
    int protein = 12;
    int carbs = 45;
    int fat = 10;

    if (text.contains("fried") || text.contains("fry") || text.contains("deep-fried") || text.contains("katsu") || text.contains("nugget")) {
      calories += 220;
      fat += 12;
    }
    if (text.contains("beef") || text.contains("pork") || text.contains("steak") || text.contains("burger") || text.contains("meat")) {
      calories += 250;
      protein += 22;
      fat += 15;
    } else if (text.contains("chicken") || text.contains("turkey") || text.contains("tuna") || text.contains("salmon") || text.contains("shrimp") || text.contains("fish")) {
      calories += 180;
      protein += 24;
      fat += 6;
    } else if (text.contains("tofu") || text.contains("egg") || text.contains("cheese")) {
      calories += 110;
      protein += 12;
      fat += 7;
    }

    if (text.contains("rice") || text.contains("noodle") || text.contains("pasta") || text.contains("bread") || text.contains("spaghetti") || text.contains("carb")) {
      calories += 150;
      carbs += 35;
    }

    if (text.contains("salad") || text.contains("vegetable") || text.contains("cabbage") || text.contains("soup") || text.contains("diet")) {
      calories -= 90;
      carbs -= 18;
      fat -= 4;
    }

    if (calories < 120) calories = 120;
    if (protein < 5) protein = 5;
    if (carbs < 8) carbs = 8;
    if (fat < 2) fat = 2;

    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  Future<void> _estimateAIMacros() async {
    if (!mounted) return;
    setState(() {
      _isMacrosLoading = true;
      _macrosError = null;
      _isLocalEstimation = false;
    });

    final dishName = widget.dish.name;
    final dishDesc = widget.dish.description.isNotEmpty
        ? widget.dish.description
        : "Fresh and savory selection crafted with seasonal ingredients.";

    String? responseText;
    bool apiSuccess = false;

    Future<String?> tryQueryModel(String modelName) async {
      try {
        final apiKey =
            (dotenv.isInitialized ? dotenv.env['GEMINI_API_KEY'] : null) ??
            const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
        if (apiKey.isEmpty) return null;

        final model = GenerativeModel(
          model: modelName,
          apiKey: apiKey,
        );

        final prompt =
            "You are an expert nutritionist. Estimate the nutritional macros for a dish named '$dishName' with description: '$dishDesc'. "
            "Provide your estimate in EXACTLY the following format, with nothing else, no explanation, no markdown: "
            "calories: [number], protein: [number], carbs: [number], fat: [number]. "
            "Use only integers for the numbers, representing kcal for calories and grams for protein, carbs, and fat.";

        final response = await model.generateContent([Content.text(prompt)]);
        return response.text;
      } catch (e) {
        final errStr = e.toString().toLowerCase();
        if (errStr.contains('quota') || errStr.contains('limit') || errStr.contains('exhausted') || errStr.contains('429')) {
          debugPrint('Gemini Macros failed: API quota exceeded or rate limit hit. Aborting macros query.');
          throw Exception('QUOTA_EXCEEDED');
        }
        debugPrint('Gemini Macros tryQueryModel ($modelName) failed: $e');
        return null;
      }
    }

    final modelNames = [
      'gemini-2.0-flash',
      'gemini-1.5-flash-latest',
      'gemini-1.5-flash',
      'gemini-flash-latest',
      'gemini-2.0-flash-exp',
      'gemini-1.5-pro',
      'gemini-1.5-pro-latest',
      'gemini-pro-latest',
    ];

    try {
      for (final modelName in modelNames) {
        responseText = await tryQueryModel(modelName);
        if (responseText != null) {
          apiSuccess = true;
          break;
        }
      }
    } catch (e) {
      if (e.toString().contains('QUOTA_EXCEEDED')) {
        responseText = null;
        apiSuccess = false;
      }
    }

    if (apiSuccess && responseText != null) {
      final calReg = RegExp(r'calories:\s*(\d+)');
      final protReg = RegExp(r'protein:\s*(\d+)');
      final carbReg = RegExp(r'carbs:\s*(\d+)');
      final fatReg = RegExp(r'fat:\s*(\d+)');

      final calMatch = calReg.firstMatch(responseText);
      final protMatch = protReg.firstMatch(responseText);
      final carbMatch = carbReg.firstMatch(responseText);
      final fatMatch = fatReg.firstMatch(responseText);

      final parsedCal = calMatch != null ? int.tryParse(calMatch.group(1)!) : null;
      final parsedProt = protMatch != null ? int.tryParse(protMatch.group(1)!) : null;
      final parsedCarb = carbMatch != null ? int.tryParse(carbMatch.group(1)!) : null;
      final parsedFat = fatMatch != null ? int.tryParse(fatMatch.group(1)!) : null;

      if (parsedCal != null && parsedProt != null && parsedCarb != null && parsedFat != null) {
        if (mounted) {
          setState(() {
            _aiCalories = parsedCal;
            _aiProtein = parsedProt;
            _aiCarbs = parsedCarb;
            _aiFat = parsedFat;
            _isMacrosLoading = false;
          });
        }
        return;
      }
    }

    debugPrint('Gemini Macros both models failed or parsing failed. Utilizing high-fidelity local heuristic fallback.');
    final localMacros = _calculateLocalHeuristicMacros(dishName, dishDesc);
    if (mounted) {
      setState(() {
        _aiCalories = localMacros['calories'];
        _aiProtein = localMacros['protein'];
        _aiCarbs = localMacros['carbs'];
        _aiFat = localMacros['fat'];
        _isLocalEstimation = true;
        _isMacrosLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = AuthService.currentUser?.uid ?? 'user_1';
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, userSnapshot) {
        final userData =
            userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
        final favoriteMenuIds = List<String>.from(
          userData['favoriteMenuIds'] ?? [],
        );
        final isFavorited = favoriteMenuIds.contains(widget.dish.id);

        return Scaffold(
          backgroundColor: Colors.white,
          body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('menu_items')
                .doc(widget.dish.id)
                .snapshots(),
            builder: (context, dishSnapshot) {
              if (dishSnapshot.hasData && dishSnapshot.data!.exists) {
                final freshDish = MenuItemModel.fromFirestore(
                  dishSnapshot.data!,
                );
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
                          AppImage(
                            imageUrl: widget.dish.imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.fastfood, size: 50, color: Colors.grey),
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
                            isFavorited
                                ? Icons.favorite
                                : Icons.favorite_border_rounded,
                            color: isFavorited
                                ? const Color(0xFFE94E5D)
                                : Colors.black87,
                            size: 24,
                          ),
                          onPressed: () async {
                            final userRef = FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId);
                            await userRef.set({
                              'favoriteMenuIds': isFavorited
                                  ? FieldValue.arrayRemove([widget.dish.id])
                                  : FieldValue.arrayUnion([widget.dish.id]),
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
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 24,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _averageRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
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
                                colors: [
                                  const Color(0xFF6B4EFF).withOpacity(0.06),
                                  const Color(0xFF8B5CF6).withOpacity(0.06),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(
                                  0xFF6B4EFF,
                                ).withOpacity(0.12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.auto_awesome,
                                          color: const Color(0xFF6B4EFF),
                                          size: 18,
                                        ),
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
                                    if (_aiDescription != null)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.green[600],
                                        size: 16,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (_isLoading)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.0,
                                      ),
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF6B4EFF),
                                      ),
                                    ),
                                  )
                                else if (_aiDescription != null)
                                  Text(
                                    _aiDescription!,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      height: 1.5,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                else
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
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
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: ElevatedButton.icon(
                                          onPressed: _generateAIDescription,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF6B4EFF,
                                            ),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            elevation: 0,
                                          ),
                                          icon: const Icon(
                                            Icons.auto_awesome,
                                            size: 18,
                                          ),
                                          label: Text(
                                            LocalizationService.tr(
                                              'generate_ai',
                                            ),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
                              onPressed: () => showAddReviewBottomSheet(
                                context,
                                widget.dish,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE94E5D),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 4,
                                shadowColor: const Color(
                                  0xFFE94E5D,
                                ).withOpacity(0.3),
                              ),
                              icon: const Icon(Icons.edit_note_rounded),
                              label: Text(
                                LocalizationService.tr('write_review'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 5. Reviews Summary (Live calculations)
                          Text(
                            LocalizationService.tr('reviews_summary'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildLiveReviewsSummarySection(),
                          const SizedBox(height: 32),

                          // 6. User Reviews List (Live stream)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                LocalizationService.tr('dish_reviews'),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PhotoGalleryScreen(dish: widget.dish),
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
                  ),
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
    if (_isMacrosLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF6B4EFF),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Estimating nutrition with AI...",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_macrosError != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFDC2626), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _macrosError!,
                      style: const TextStyle(
                        color: Color(0xFF991B1B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: _estimateAIMacros,
              icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFFDC2626)),
              label: const Text(
                "Retry",
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      );
    }

    final cal = _aiCalories ?? widget.dish.calories;
    final protein = _aiProtein ?? widget.dish.protein;
    final carbs = _aiCarbs ?? widget.dish.carbs;
    final fat = _aiFat ?? widget.dish.fat;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroLabel("Calories", "$cal kcal"),
              _buildMacroLabel("Protein", "${protein}g"),
              _buildMacroLabel("Carbs", "${carbs}g"),
              _buildMacroLabel("Fat", "${fat}g"),
            ],
          ),
          if (_isLocalEstimation) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, color: Colors.deepPurple[400], size: 12),
                const SizedBox(width: 4),
                Text(
                  "AI Local Heuristic Estimate Profile",
                  style: TextStyle(
                    color: Colors.deepPurple[400],
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMacroLabel(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
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
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.star_rounded,
                      color: index < _averageRating.round()
                          ? Colors.amber
                          : Colors.grey[300],
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$total Reviews",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.bold,
                  ),
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
            ),
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
          Text(
            star,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
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
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
                LocalizationService.tr('no_reviews_yet'),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }

        final reviews = snapshot.data!.docs
            .map((doc) => ReviewModel.fromFirestore(doc))
            .toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(review.userId)
                  .get(),
              builder: (context, userSnap) {
                String name = "사용자";
                String userImage = "";
                int userReviewCount = 0;

                if (userSnap.hasData && userSnap.data!.exists) {
                  final data =
                      userSnap.data!.data() as Map<String, dynamic>? ?? {};
                  name = data['name'] ?? name;
                  userImage = data['profileImageUrl'] ?? userImage;
                  userReviewCount = data['reviewCount'] ?? 0;
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
                          userReviewCount: userReviewCount,
                          reviewId: review.id,
                          likesCount: review.likesCount,
                          backgroundImageUrl:
                              review.backgroundImageUrl.isNotEmpty
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
                                    backgroundImage: userImage.isNotEmpty
                                        ? (userImage.startsWith('http')
                                            ? NetworkImage(userImage)
                                            : FileImage(File(userImage)) as ImageProvider)
                                        : null,
                                    child: userImage.isEmpty
                                        ? const Icon(
                                            Icons.person,
                                            color: Colors.grey,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                       Row(
                                         children: [
                                           Flexible(
                                             child: Text(
                                               name,
                                               style: const TextStyle(
                                                 fontWeight: FontWeight.bold,
                                                 fontSize: 14,
                                               ),
                                               overflow: TextOverflow.ellipsis,
                                             ),
                                           ),
                                           const SizedBox(width: 8),
                                           TierBadge(
                                             reviewCount: userReviewCount,
                                           ),
                                         ],
                                       ),
                                       const SizedBox(height: 4),
                                       Row(
                                         children: List.generate(
                                           5,
                                           (idx) => Icon(
                                             Icons.star_rounded,
                                             color: idx < review.rating
                                                 ? Colors.amber
                                                 : Colors.grey[300],
                                             size: 14,
                                           ),
                                         ),
                                       ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                dateStr,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  review.originalReview,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (review.backgroundImageUrl.isNotEmpty) ...[
                                const SizedBox(width: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: AppImage(
                                    imageUrl: review.backgroundImageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ],
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
}
