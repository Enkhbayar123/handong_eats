import 'package:flutter/material.dart';

class ReviewDetailScreen extends StatefulWidget {
  final String username;
  final String userImage;
  final int rating;
  final String date;
  final String originalReview;
  final String translatedReview;
  final String? backgroundImageUrl; // Optional, in case they didn't upload a photo

  const ReviewDetailScreen({
    super.key,
    required this.username,
    required this.userImage,
    required this.rating,
    required this.date,
    required this.originalReview,
    required this.translatedReview,
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
            Image.network(
              widget.backgroundImageUrl!,
              fit: BoxFit.cover,
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
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.username,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.date,
                            style: TextStyle(color: Colors.grey[400], fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Rating Stars
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star_rounded,
                        color: index < widget.rating ? Colors.amber : Colors.grey[600],
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Review Text (Toggles between Original and Translated)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300), // Smooth fade transition
                    child: Text(
                      _isTranslated ? widget.translatedReview : widget.originalReview,
                      key: ValueKey<bool>(_isTranslated), // Tells Flutter to animate the change
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

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
                    label: Text(_isTranslated ? "Show Original" : "Translate to English"),
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