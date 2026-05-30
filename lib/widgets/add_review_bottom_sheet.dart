import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../services/localization.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

void showAddReviewBottomSheet(
  BuildContext context,
  MenuItemModel dish, {
  String? imagePath,
}) {
  String? localImagePath = imagePath;
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
        builder: (BuildContext modalContext, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(bc).viewInsets.bottom + 24,
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
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    LocalizationService.tr('add_log_title'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    LocalizationService.tr('add_log_subtitle'),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  if (localImagePath != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(localImagePath!),
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Button to add/change photo
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final photo = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (photo != null) {
                          setModalState(() {
                            localImagePath = photo.path;
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.add_a_photo,
                        color: Color(0xFFE94E5D),
                      ),
                      label: Text(
                        localImagePath == null
                            ? LocalizationService.tr('add_photo')
                            : LocalizationService.tr('change_photo'),
                        style: const TextStyle(
                          color: Color(0xFFE94E5D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Meal Type
                  Text(
                    LocalizationService.tr('meal_type'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                  Text(
                    LocalizationService.tr('rating'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                            star <= localRating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: star <= localRating
                                ? Colors.amber
                                : Colors.grey[300],
                            size: 40,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Review text
                  Text(
                    LocalizationService.tr('write_a_review'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: LocalizationService.tr('review_hint'),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
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
                          const SnackBar(
                            content: Text("Saving your meal log & review..."),
                          ),
                        );

                        final String userReviewText = noteController.text
                            .trim();
                        final String originalText = userReviewText.isNotEmpty
                            ? userReviewText
                            : "Delicious!";

                        String translatedText = originalText;
                        try {
                          final apiKey = const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
                          if (apiKey.isNotEmpty) {
                            final model = GenerativeModel(model: 'gemini-flash-latest', apiKey: apiKey);
                            final prompt = 'Translate the following review to English if it is in Korean, or to Korean if it is in English. Keep the meaning and tone intact. Review: "$originalText"';
                            final response = await model.generateContent([Content.text(prompt)]);
                            if (response.text != null && response.text!.isNotEmpty) {
                              translatedText = response.text!.trim();
                            }
                          }
                        } catch (e) {
                          debugPrint('Gemini Translation Error: $e');
                        }

                        // 1. Add review
                        final reviewDocRef = FirebaseFirestore.instance
                            .collection('reviews')
                            .doc();
                        final newReview = ReviewModel(
                          id: reviewDocRef.id,
                          userId: 'user_1',
                          menuItemId: dish.id,
                          rating: localRating,
                          originalReview: originalText,
                          translatedReview: translatedText,
                          datePosted: DateTime.now(),
                          backgroundImageUrl: localImagePath ?? dish.imageUrl,
                        );
                        await reviewDocRef.set(newReview.toMap());

                        // 2. Add meal log
                        final logDocRef = FirebaseFirestore.instance
                            .collection('meal_logs')
                            .doc();
                        final newLog = MealLogModel(
                          id: logDocRef.id,
                          userId: 'user_1',
                          menuItemId: dish.id,
                          date: DateTime.now(),
                          mealType: selectedMealType,
                          rating: localRating,
                          personalNote: originalText,
                          photoUrl: dish.imageUrl,
                        );
                        await logDocRef.set(newLog.toMap());

                        // 3. Update User's Review Count
                        final userRef = FirebaseFirestore.instance
                            .collection('users')
                            .doc('user_1');
                        await userRef.set({
                          'reviewCount': FieldValue.increment(1),
                        }, SetOptions(merge: true));

                        // 4. Update restaurant and menu item stats in Transaction
                        final dishRef = FirebaseFirestore.instance
                            .collection('menu_items')
                            .doc(dish.id);
                        await FirebaseFirestore.instance.runTransaction((
                          transaction,
                        ) async {
                          final freshSnap = await transaction.get(dishRef);
                          if (freshSnap.exists) {
                            final currentRating =
                                freshSnap.get('averageRating') ?? 0.0;
                            final currentCount =
                                freshSnap.get('reviewCount') ?? 0;

                            final newCount = currentCount + 1;
                            final newRating =
                                ((currentRating * currentCount) + localRating) /
                                newCount;

                            transaction.update(dishRef, {
                              'averageRating': double.parse(
                                newRating.toStringAsFixed(1),
                              ),
                              'reviewCount': newCount,
                            });
                          }
                        });

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Successfully logged meal and posted review! 🎉",
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE94E5D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        LocalizationService.tr('submit_review'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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
