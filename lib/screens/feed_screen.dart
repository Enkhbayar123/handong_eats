import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../widgets/tier_badge.dart';
import '../services/localization.dart';
import '../widgets/app_image.dart';
import '../services/auth_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late final Stream<QuerySnapshot> _reviewsStream;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _reviewsStream = FirebaseFirestore.instance
        .collection('reviews')
        .orderBy('datePosted', descending: true)
        .snapshots();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Feed",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _reviewsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final reviews = snapshot.data?.docs
                  .map((doc) => ReviewModel.fromFirestore(doc))
                  .toList() ??
              [];

          if (reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.restaurant, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    LocalizationService.tr('no_reviews'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: reviews.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _FeedCard(review: reviews[index]);
            },
          );
        },
      ),
    );
  }
}

// --- Individual full-screen review card ---
class _FeedCard extends StatefulWidget {
  final ReviewModel review;
  const _FeedCard({required this.review});

  @override
  State<_FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<_FeedCard> {
  bool _isTranslated = false;
  bool _isLiked = false;

  // Cache for user & menu data
  UserModel? _user;
  MenuItemModel? _menuItem;
  RestaurantModel? _restaurant;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    final uid = AuthService.currentUser?.uid ?? 'user_1';
    _isLiked = widget.review.likedBy.contains(uid);
  }

  Future<void> _loadData() async {
    final firestore = FirebaseFirestore.instance;

    // Fetch user
    final userDoc =
        await firestore.collection('users').doc(widget.review.userId).get();
    if (userDoc.exists) {
      _user = UserModel.fromFirestore(userDoc);
    }

    // Fetch menu item
    final menuDoc = await firestore
        .collection('menu_items')
        .doc(widget.review.menuItemId)
        .get();
    if (menuDoc.exists) {
      _menuItem = MenuItemModel.fromFirestore(menuDoc);

      // Fetch restaurant
      if (_menuItem != null) {
        final restDoc = await firestore
            .collection('restaurants')
            .doc(_menuItem!.restaurantId)
            .get();
        if (restDoc.exists) {
          _restaurant = RestaurantModel.fromFirestore(restDoc);
        }
      }
    }

    if (mounted) {
      setState(() {
        _loaded = true;
      });
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
    // Use the review's background image, or the menu item's image, or a fallback
    final bgImage = review.backgroundImageUrl.isNotEmpty
        ? review.backgroundImageUrl
        : (_menuItem?.imageUrl ?? '');

    return Stack(
      fit: StackFit.expand,
      children: [
        // --- LAYER 1: Full-bleed background image ---
        AppImage(
          imageUrl: bgImage,
          fit: BoxFit.cover,
          errorWidget: Container(color: Colors.grey[900]),
        ),

        // --- LAYER 2: Gradient overlay for readability ---
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.15),
                Colors.black.withOpacity(0.75),
                Colors.black.withOpacity(0.95),
              ],
              stops: const [0.0, 0.3, 0.65, 1.0],
            ),
          ),
        ),

        // --- LAYER 3: Content ---
        SafeArea(
          child: Column(
            children: [
              const Spacer(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Left side: review info
                    Expanded(child: _buildReviewContent(review)),

                    // Right side: action buttons (like, translate, etc.)
                    const SizedBox(width: 12),
                    _buildActionButtons(review),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewContent(ReviewModel review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dish name & Restaurant
        if (_loaded && _menuItem != null) ...[
          Text(
            _menuItem!.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          if (_restaurant != null)
            Text(
              _restaurant!.name,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 16),
        ],

        // User profile row
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[800],
              backgroundImage: _user != null && _user!.profileImageUrl.isNotEmpty
                  ? (_user!.profileImageUrl.startsWith('http')
                      ? NetworkImage(_user!.profileImageUrl)
                      : FileImage(File(_user!.profileImageUrl)) as ImageProvider)
                  : null,
              child: (_user == null || _user!.profileImageUrl.isEmpty)
                  ? const Icon(Icons.person, color: Colors.white54, size: 18)
                  : null,
            ),
            const SizedBox(width: 10),
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
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_user != null) ...[
                        const SizedBox(width: 6),
                        TierBadge(reviewCount: _user!.reviewCount),
                      ],
                    ],
                  ),
                  Text(
                    _timeAgo(review.datePosted),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Rating stars
        Row(
          children: List.generate(5, (index) {
            return Icon(
              Icons.star_rounded,
              color: index < review.rating ? Colors.amber : Colors.grey[700],
              size: 18,
            );
          }),
        ),
        const SizedBox(height: 10),

        // Review text
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _isTranslated ? review.translatedReview : review.originalReview,
            key: ValueKey<bool>(_isTranslated),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildActionButtons(ReviewModel review) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Like button
        _ActionButton(
          icon: _isLiked ? Icons.favorite : Icons.favorite_border,
          color: _isLiked ? Colors.redAccent : Colors.white,
          onTap: () async {
            final uid = AuthService.currentUser?.uid ?? 'user_1';
            final ref = FirebaseFirestore.instance.collection('reviews').doc(widget.review.id);
            if (_isLiked) {
              setState(() {
                _isLiked = false;
              });
              await ref.update({
                'likedBy': FieldValue.arrayRemove([uid]),
                'likesCount': FieldValue.increment(-1),
              });
            } else {
              setState(() {
                _isLiked = true;
              });
              await ref.update({
                'likedBy': FieldValue.arrayUnion([uid]),
                'likesCount': FieldValue.increment(1),
              });
            }
          },
        ),
        const SizedBox(height: 4),
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('reviews').doc(widget.review.id).snapshots(),
          builder: (context, snap) {
            int likes = widget.review.likesCount;
            if (snap.hasData && snap.data!.exists) {
              final data = snap.data!.data() as Map<String, dynamic>? ?? {};
              likes = data['likesCount'] ?? 0;
            }
            return Text(
              "$likes",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Translate button
        _ActionButton(
          icon: Icons.g_translate,
          color: _isTranslated ? Colors.lightBlueAccent : Colors.white,
          onTap: () {
            setState(() {
              _isTranslated = !_isTranslated;
            });
          },
        ),
        const SizedBox(height: 20),

        // Share button (placeholder)
        _ActionButton(
          icon: Icons.share_outlined,
          color: Colors.white,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Share coming soon!"),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }
}

// Reusable circular action button (like IG Reels sidebar)
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }
}
