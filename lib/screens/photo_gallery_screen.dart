import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../widgets/add_review_bottom_sheet.dart';
import '../widgets/app_image.dart';
import 'package:image_picker/image_picker.dart';

class PhotoGalleryScreen extends StatelessWidget {
  final MenuItemModel dish;

  const PhotoGalleryScreen({super.key, required this.dish});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('reviews')
              .where('menuItemId', isEqualTo: dish.id)
              .snapshots(),
          builder: (context, snapshot) {
            final count = snapshot.data?.docs
                    .where((doc) =>
                        (doc['backgroundImageUrl'] as String?)?.isNotEmpty ==
                        true)
                    .length ??
                0;
            return Text(
              "${dish.name} • $count Photos",
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reviews')
            .where('menuItemId', isEqualTo: dish.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reviews = snapshot.data?.docs
                  .map((doc) => ReviewModel.fromFirestore(doc))
                  .toList() ??
              [];
          
          // Sort chronologically: newest (most recent) photos first
          reviews.sort((a, b) => b.datePosted.compareTo(a.datePosted));
          
          final photos = reviews
                  .map((r) => r.backgroundImageUrl)
                  .where((url) => url.isNotEmpty)
                  .toList();

          if (photos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined,
                      color: Colors.grey[300], size: 64),
                  const SizedBox(height: 16),
                  Text(
                    "아직 사진이 없습니다",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.only(top: 2.0, bottom: 80.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Full-screen photo view
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.black,
                      insetPadding: EdgeInsets.zero,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          InteractiveViewer(
                            child: AppImage(
                              imageUrl: photos[index],
                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned(
                            top: 40,
                            right: 16,
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close,
                                  color: Colors.white, size: 28),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: AppImage(
                  imageUrl: photos[index],
                  fit: BoxFit.cover,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ImagePicker picker = ImagePicker();
          final XFile? photo = await picker.pickImage(
            source: ImageSource.gallery,
          );

          if (photo != null && context.mounted) {
            showAddReviewBottomSheet(context, dish, imagePath: photo.path);
          }
        },
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.camera_alt_rounded, size: 28),
      ),
    );
  }
}
