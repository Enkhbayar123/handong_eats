import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/app_image.dart';

class EditLogScreen extends StatefulWidget {
  final String logId;
  final String foodName;
  final String restaurant;
  final DateTime date;
  final String imageUrl;
  final int initialRating;
  final String initialNote;

  const EditLogScreen({
    super.key,
    required this.logId,
    required this.foodName,
    required this.restaurant,
    required this.date,
    required this.imageUrl,
    required this.initialRating,
    required this.initialNote,
  });

  @override
  State<EditLogScreen> createState() => _EditLogScreenState();
}

class _EditLogScreenState extends State<EditLogScreen> {
  late int _currentRating;
  late TextEditingController _noteController;

  final Map<int, String> _ratingLabels = {
    1: "Terrible",
    2: "Bad",
    3: "Okay",
    4: "Good",
    5: "Excellent!",
  };

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
    _noteController = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
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
        title: const Text(
          "Edit Log",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ),
        leadingWidth: 80,
        actions: [
          TextButton(
            onPressed: () async {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Updating log...')));
              await FirebaseFirestore.instance
                  .collection('meal_logs')
                  .doc(widget.logId)
                  .update({
                    'rating': _currentRating,
                    'personalNote': _noteController.text,
                  });
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text(
              "Post",
              style: TextStyle(
                color: Color(0xFFE94E5D),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Food Info Header ---
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AppImage(
                      imageUrl: widget.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorWidget: Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.restaurant, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.foodName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.restaurant,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(widget.date),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFE94E5D),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              const SizedBox(height: 24),

              // --- 2. Interactive Star Rating ---
              const Text(
                "Rate this meal",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
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
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Icon(
                            starValue <= _currentRating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: starValue <= _currentRating
                                ? Colors.amber
                                : Colors.grey[300],
                            size: 40,
                          ),
                        ),
                      );
                    }),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _ratingLabels[_currentRating] ?? "Okay",
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- 3. Personal Note Text Area ---
              const Text(
                "Personal Note",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "How was it? What made it good or bad? (Optional)",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 32),

              // --- 4. Delete Log Entry Action ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // Confirm delete action
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          "Delete Log Entry",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: const Text(
                          "Are you sure you want to remove this log from your plate? This cannot be undone.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                            ),
                            child: const Text(
                              "Delete",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Deleting log...')),
                        );
                      }
                      await FirebaseFirestore.instance
                          .collection('meal_logs')
                          .doc(widget.logId)
                          .delete();
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE94E5D),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: const Text(
                    "Delete Log Entry",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
