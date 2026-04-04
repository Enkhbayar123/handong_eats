import 'package:flutter/material.dart';

class EditLogScreen extends StatefulWidget {
  final String foodName;
  final String restaurant;
  final String date; 
  // We will use a mock image for the prototype
  final String imageUrl = "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=80"; 

  const EditLogScreen({
    super.key,
    required this.foodName,
    required this.restaurant,
    required this.date,
  });

  @override
  State<EditLogScreen> createState() => _EditLogScreenState();
}

class _EditLogScreenState extends State<EditLogScreen> {
  int _currentRating = 4; // Default to 4 stars
  final TextEditingController _noteController = TextEditingController();

  // Map to easily translate star counts into text labels
  final Map<int, String> _ratingLabels = {
    1: "Terrible",
    2: "Bad",
    3: "Okay",
    4: "Good",
    5: "Excellent!",
  };

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text("Edit Log", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.black54, fontSize: 16)),
        ),
        leadingWidth: 80, // Gives the text button enough room
        actions: [
          TextButton(
            onPressed: () {
              // Future API call to save data goes here
              print("Saved rating: $_currentRating, Note: ${_noteController.text}");
              Navigator.pop(context);
            },
            child: const Text("Post", style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      // Using GestureDetector to dismiss keyboard when tapping outside the text box
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Food Info Header ---
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.foodName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(widget.restaurant, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        const SizedBox(height: 4),
                        Text(widget.date, style: const TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 32),
              const Divider(height: 1, color: Colors.black12),
              const SizedBox(height: 24),

              // --- 2. Interactive Star Rating ---
              const Text("Rate this meal", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      int starValue = index + 1;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentRating = starValue;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            starValue <= _currentRating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: starValue <= _currentRating ? Colors.amber : Colors.grey[400],
                            size: 40,
                          ),
                        ),
                      );
                    }),
                  ),
                  // Dynamic Text Label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _ratingLabels[_currentRating]!,
                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 32),

              // --- 3. Personal Note Text Area ---
              const Text("Personal Note", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                maxLines: 6, // Makes it a nice big text box
                decoration: InputDecoration(
                  hintText: "How was it? What made it good or bad? (Optional)",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 32),

              // --- 4. Add Photos Section (From your Figma!) ---
              const Text("Add Photos", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      print("Open camera or gallery");
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, color: Colors.redAccent),
                          SizedBox(height: 4),
                          Text("Add", style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text("Optional", style: TextStyle(color: Colors.grey[400])),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}