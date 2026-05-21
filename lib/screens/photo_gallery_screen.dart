import 'package:flutter/material.dart';
import '../models/models.dart';

class PhotoGalleryScreen extends StatelessWidget {
  final MenuItemModel dish;

  // Mocking 24 photos for the grid layout
  final List<String> mockPhotos = List.generate(
    24, 
    (index) => "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=80"
  );

  PhotoGalleryScreen({super.key, required this.dish});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "${dish.name} • ${mockPhotos.length} Photos", 
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      // The GridView remains exactly the same
      body: GridView.builder(
        padding: const EdgeInsets.only(top: 2.0, bottom: 80.0), // Added bottom padding so the FAB doesn't cover the last images
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: mockPhotos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Future feature: Tap a grid photo to view it full-screen!
            },
            child: Image.network(
              mockPhotos[index],
              fit: BoxFit.cover, 
              errorBuilder: (context, error, stackTrace) => 
                Container(color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
            ),
          );
        },
      ),
      
      // --- NEW: Floating Camera Button ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // This will eventually push to your new Camera Screen!
          print("Camera button tapped! Ready to snap a pic of ${dish.name}.");
        },
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        elevation: 4, // Gives it a nice pop off the screen
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Modern "squircle" shape instead of a perfect circle
        ),
        child: const Icon(Icons.camera_alt_rounded, size: 28),
      ),
    );
  }
}