import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../widgets/tier_badge.dart';

class ReviewDetailScreen extends StatefulWidget {
  final String username;
  final String userImage;
  final int rating;
  final String date;
  final String originalReview;
  final String translatedReview;
  final int userReviewCount;
  final String reviewId;
  final int likesCount;
  final String? backgroundImageUrl; // Optional, in case they didn't upload a photo

  const ReviewDetailScreen({
    super.key,
    required this.username,
    required this.userImage,
    required this.rating,
    required this.date,
    required this.originalReview,
    required this.translatedReview,
    required this.userReviewCount,
    required this.reviewId,
    required this.likesCount,
    this.backgroundImageUrl,
  });

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  bool _isTranslated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fallback color
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- LAYER 1: Background Wallpaper ---
          if (widget.backgroundImageUrl != null)
            widget.backgroundImageUrl!.startsWith('http')
                ? Image.network(
                    widget.backgroundImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[900],
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.white24,
                        size: 50,
                      ),
                    ),
                  )
                : Image.file(
                    File(widget.backgroundImageUrl!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[900],
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.white24,
                        size: 50,
                      ),
                    ),
                  )
          else
            Container(color: Colors.grey[900]), // Dark background if no photo
          // --- LAYER 2: Dark Gradient Overlay ---
          // This ensures the white text is always readable against any photo
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2), // Top is mostly clear
                  Colors.black.withOpacity(0.6), // Middle starts getting dark
                  Colors.black.withOpacity(0.9), // Bottom is very dark for text
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
                  // Back Button at the top
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const Spacer(), // Pushes everything below to the bottom of the screen
                  // User Profile Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(widget.userImage),
                        backgroundColor: Colors.grey[800],
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
                                    widget.username,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    iconTheme: const IconThemeData(
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: TierBadge(
                                    reviewCount: widget.userReviewCount,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              widget.date,
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
                        color: index < widget.rating
                            ? Colors.amber
                            : Colors.grey[600],
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Review Text (Toggles between Original and Translated)
                  AnimatedSwitcher(
                    duration: const Duration(
                      milliseconds: 300,
                    ), // Smooth fade transition
                    child: Text(
                      _isTranslated
                          ? widget.translatedReview
                          : widget.originalReview,
                      key: ValueKey<bool>(
                        _isTranslated,
                      ), // Tells Flutter to animate the change
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      // Translate Button
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isTranslated = !_isTranslated;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: Icon(
                          _isTranslated ? Icons.check : Icons.g_translate,
                          size: 18,
                        ),
                        label: Text(
                          _isTranslated ? "Show Original" : "Translate to English",
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Like Button
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance.collection('reviews').doc(widget.reviewId).snapshots(),
                        builder: (context, snap) {
                          int likes = widget.likesCount;
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
                              final ref = FirebaseFirestore.instance.collection('reviews').doc(widget.reviewId);
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
                  const SizedBox(height: 20), // Extra padding at the bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
