import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/localization.dart';
import '../models/models.dart';
import '../widgets/tier_badge.dart';
import '../widgets/app_image.dart';

class ReviewDetailScreen extends StatefulWidget {
  final String menuItemId;
  final String initialReviewId;

  const ReviewDetailScreen({
    super.key,
    required this.menuItemId,
    required this.initialReviewId,
  });

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  late final Future<List<ReviewModel>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = FirebaseFirestore.instance
        .collection('reviews')
        .where('menuItemId', isEqualTo: widget.menuItemId)
        .get()
        .then((snapshot) {
      final list = snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
      // Sort reviews descending by date (newest first)
      list.sort((a, b) => b.datePosted.compareTo(a.datePosted));
      return list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<List<ReviewModel>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No reviews found",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          final reviews = snapshot.data!;
          final initialIndex = reviews.indexWhere((r) => r.id == widget.initialReviewId);
          final PageController controller = PageController(
            initialPage: initialIndex != -1 ? initialIndex : 0,
          );

          return Stack(
            children: [
              PageView.builder(
                controller: controller,
                scrollDirection: Axis.vertical,
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  return _ReviewDetailCard(review: reviews[index]);
                },
              ),

              // Fixed Back Button at the top left
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReviewDetailCard extends StatefulWidget {
  final ReviewModel review;
  const _ReviewDetailCard({required this.review});

  @override
  State<_ReviewDetailCard> createState() => _ReviewDetailCardState();
}

class _ReviewDetailCardState extends State<_ReviewDetailCard> {
  UserModel? _user;
  late final ValueNotifier<bool> _translationNotifier;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _translationNotifier = LocalizationService.getReviewTranslationNotifier(widget.review.id);
  }

  Future<void> _loadUser() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.review.userId)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _user = UserModel.fromFirestore(doc);
        });
      }
    } catch (e) {
      debugPrint("Error loading user in review detail: $e");
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return "${(diff.inDays / 30).floor()}mo ago";
    if (diff.inDays > 0) return "${diff.inDays}d ago";
    if (diff.inHours > 0) return "${diff.inHours}h ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes}m ago";
    return "Just now";
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final bgImage = review.backgroundImageUrl;

    return Stack(
      fit: StackFit.expand,
      children: [
        // --- LAYER 1: Background Wallpaper ---
        if (bgImage.isNotEmpty)
          AppImage(
            imageUrl: bgImage,
            fit: BoxFit.cover,
            errorWidget: Container(
              color: Colors.grey[900],
              child: const Icon(
                Icons.broken_image,
                color: Colors.white24,
                size: 50,
              ),
            ),
          )
        else
          Container(color: Colors.grey[900]),

        // --- LAYER 2: Dark Gradient Overlay ---
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.6),
                Colors.black.withOpacity(0.95),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // --- LAYER 3: Content (Profile, Rating, Text, Buttons) ---
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(), // Pushes content to the bottom

                // User Profile Row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: _user != null && _user!.profileImageUrl.isNotEmpty
                          ? (_user!.profileImageUrl.startsWith('http')
                              ? NetworkImage(_user!.profileImageUrl)
                              : FileImage(File(_user!.profileImageUrl)) as ImageProvider)
                          : null,
                      backgroundColor: Colors.grey[800],
                      child: (_user == null || _user!.profileImageUrl.isEmpty)
                          ? const Icon(Icons.person, color: Colors.white54, size: 24)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _user?.name ?? "...",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_user != null) ...[
                                const SizedBox(width: 8),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    iconTheme: const IconThemeData(
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: TierBadge(
                                    reviewCount: _user!.reviewCount,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            _timeAgo(review.datePosted),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Rating Stars
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star_rounded,
                      color: index < review.rating
                          ? Colors.amber
                          : Colors.grey[600],
                      size: 20,
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Review Text (Toggles between Original and Translated)
                ValueListenableBuilder<bool>(
                  valueListenable: _translationNotifier,
                  builder: (context, isTranslated, _) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        isTranslated
                            ? review.translatedReview
                            : review.originalReview,
                        key: ValueKey<bool>(isTranslated),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    // Translate Button
                    ValueListenableBuilder<bool>(
                      valueListenable: _translationNotifier,
                      builder: (context, isTranslated, _) {
                        return OutlinedButton.icon(
                          onPressed: () {
                            _translationNotifier.value = !isTranslated;
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          icon: Icon(
                            isTranslated ? Icons.check : Icons.g_translate,
                            size: 18,
                          ),
                          label: Text(
                            isTranslated ? "Show Original" : "Translate to English",
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    // Like Button
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('reviews')
                          .doc(review.id)
                          .snapshots(),
                      builder: (context, snap) {
                        int likes = review.likesCount;
                        List<String> likedBy = [];
                        if (snap.hasData && snap.data!.exists) {
                          final data = snap.data!.data() as Map<String, dynamic>? ?? {};
                          likes = data['likesCount'] ?? 0;
                          likedBy = List<String>.from(data['likedBy'] ?? []);
                        }
                        final uid = AuthService.currentUser?.uid ?? 'user_1';
                        final isLiked = likedBy.contains(uid);

                        return ElevatedButton.icon(
                          onPressed: () async {
                            final ref = FirebaseFirestore.instance
                                .collection('reviews')
                                .doc(review.id);
                            if (isLiked) {
                              await ref.update({
                                'likedBy': FieldValue.arrayRemove([uid]),
                                'likesCount': FieldValue.increment(-1),
                              });
                            } else {
                              await ref.update({
                                'likedBy': FieldValue.arrayUnion([uid]),
                                'likesCount': FieldValue.increment(1),
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLiked ? Colors.redAccent : Colors.white12,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                          ),
                          label: Text("$likes Likes"),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
