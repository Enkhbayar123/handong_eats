import 'package:cloud_firestore/cloud_firestore.dart';

enum CrowdedStatus { empty, moderate, busy, unknown }

class UserModel {
  final String uid;
  final String email;
  final String studentId;
  final String name;
  final String profileImageUrl;
  final List<String> dietaryLabels;
  final List<String> allergies;
  final bool pushNotificationsEnabled;
  final List<String> favoriteMenuIds;
  final String country;
  final String spiceTolerance;
  final List<String> preferredTastes;
  final String preferredLanguage;

  UserModel({
    required this.uid,
    required this.email,
    required this.studentId,
    required this.name,
    required this.profileImageUrl,
    required this.dietaryLabels,
    required this.allergies,
    required this.pushNotificationsEnabled,
    required this.favoriteMenuIds,
    this.country = 'South Korea',
    this.spiceTolerance = 'Medium',
    this.preferredTastes = const [],
    this.preferredLanguage = 'English',
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      studentId: data['studentId'] ?? '',
      name: data['name'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      dietaryLabels: List<String>.from(data['dietaryLabels'] ?? []),
      allergies: List<String>.from(data['allergies'] ?? []),
      pushNotificationsEnabled: data['pushNotificationsEnabled'] ?? false,
      favoriteMenuIds: List<String>.from(data['favoriteMenuIds'] ?? []),
      country: data['country'] ?? 'South Korea',
      spiceTolerance: data['spiceTolerance'] ?? 'Medium',
      preferredTastes: List<String>.from(data['preferredTastes'] ?? []),
      preferredLanguage: data['preferredLanguage'] ?? 'English',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'studentId': studentId,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'dietaryLabels': dietaryLabels,
      'allergies': allergies,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'favoriteMenuIds': favoriteMenuIds,
      'country': country,
      'spiceTolerance': spiceTolerance,
      'preferredTastes': preferredTastes,
      'preferredLanguage': preferredLanguage,
    };
  }
}

class RestaurantModel {
  final String id;
  final String name;
  final String openTime;
  final String closeTime;
  final CrowdedStatus currentStatus;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.openTime,
    required this.closeTime,
    required this.currentStatus,
  });

  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    
    CrowdedStatus status = CrowdedStatus.unknown;
    String statusStr = data['currentStatus'] ?? 'unknown';
    if (statusStr == 'empty') status = CrowdedStatus.empty;
    if (statusStr == 'moderate') status = CrowdedStatus.moderate;
    if (statusStr == 'busy') status = CrowdedStatus.busy;

    return RestaurantModel(
      id: doc.id,
      name: data['name'] ?? '',
      openTime: data['openTime'] ?? '',
      closeTime: data['closeTime'] ?? '',
      currentStatus: status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'openTime': openTime,
      'closeTime': closeTime,
      'currentStatus': currentStatus.name,
    };
  }
}

class MenuItemModel {
  final String id;
  final String restaurantId;
  final String name;
  final num price;
  final String imageUrl;
  final String description;
  final num averageRating;
  final int reviewCount;
  
  // Macros added back for Nutrition Dashboard
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  MenuItemModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.averageRating,
    required this.reviewCount,
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });

  factory MenuItemModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return MenuItemModel(
      id: doc.id,
      restaurantId: data['restaurantId'] ?? '',
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      averageRating: data['averageRating'] ?? 0,
      reviewCount: data['reviewCount'] ?? 0,
      calories: data['calories'] ?? 0,
      protein: data['protein'] ?? 0,
      carbs: data['carbs'] ?? 0,
      fat: data['fat'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'restaurantId': restaurantId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}

class MealLogModel {
  final String id;
  final String userId;
  final String menuItemId;
  final DateTime date;
  final String mealType;
  final int rating;
  final String personalNote;
  final String photoUrl;

  MealLogModel({
    required this.id,
    required this.userId,
    required this.menuItemId,
    required this.date,
    required this.mealType,
    required this.rating,
    required this.personalNote,
    required this.photoUrl,
  });

  factory MealLogModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return MealLogModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      menuItemId: data['menuItemId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      mealType: data['mealType'] ?? '',
      rating: data['rating'] ?? 0,
      personalNote: data['personalNote'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'menuItemId': menuItemId,
      'date': Timestamp.fromDate(date),
      'mealType': mealType,
      'rating': rating,
      'personalNote': personalNote,
      'photoUrl': photoUrl,
    };
  }
}

class ReviewModel {
  final String id;
  final String userId;
  final String menuItemId;
  final int rating;
  final String originalReview;
  final String translatedReview;
  final DateTime datePosted;
  final String backgroundImageUrl;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.menuItemId,
    required this.rating,
    required this.originalReview,
    required this.translatedReview,
    required this.datePosted,
    required this.backgroundImageUrl,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return ReviewModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      menuItemId: data['menuItemId'] ?? '',
      rating: data['rating'] ?? 0,
      originalReview: data['originalReview'] ?? '',
      translatedReview: data['translatedReview'] ?? '',
      datePosted: (data['datePosted'] as Timestamp?)?.toDate() ?? DateTime.now(),
      backgroundImageUrl: data['backgroundImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'menuItemId': menuItemId,
      'rating': rating,
      'originalReview': originalReview,
      'translatedReview': translatedReview,
      'datePosted': Timestamp.fromDate(datePosted),
      'backgroundImageUrl': backgroundImageUrl,
    };
  }
}
