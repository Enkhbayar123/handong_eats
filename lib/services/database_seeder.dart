import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class DatabaseSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedUsers() async {
    final collection = _firestore.collection('users');
    final users = [
      UserModel(
        uid: 'user_1',
        email: 'student1@handong.ac.kr',
        studentId: '22000001',
        name: 'Jiwon Kim',
        profileImageUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80',
        dietaryLabels: ['Halal', 'Lactose-Free'],
        allergies: ['Peanuts'],
        pushNotificationsEnabled: true,
        favoriteMenuIds: ['rest_1_m2', 'rest_8_m3'],
        country: 'South Korea',
        spiceTolerance: 'Hot',
        preferredTastes: ['Spicy', 'Savory'],
      ),
      UserModel(
        uid: 'user_2',
        email: 'student2@handong.ac.kr',
        studentId: '22000002',
        name: 'Alex Chan',
        profileImageUrl:
            'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=200&q=80',
        dietaryLabels: ['Vegetarian'],
        allergies: [],
        pushNotificationsEnabled: false,
        favoriteMenuIds: ['rest_5_m1', 'rest_3_m1'],
        country: 'United States',
        spiceTolerance: 'Mild',
        preferredTastes: ['Sweet', 'Savory'],
        reviewCount: 0, // Iron
      ),
      UserModel(
        uid: 'user_3',
        email: 'michael@handong.ac.kr',
        studentId: '22000003',
        name: 'Michael Scott',
        profileImageUrl:
            'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=200&q=80',
        dietaryLabels: [],
        allergies: [],
        pushNotificationsEnabled: true,
        favoriteMenuIds: [],
        reviewCount: 0, // Diamond
      ),
      UserModel(
        uid: 'user_4',
        email: 'sarah@handong.ac.kr',
        studentId: '22000004',
        name: 'Sarah Jenkins',
        profileImageUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
        dietaryLabels: ['Vegan'],
        allergies: ['Gluten'],
        pushNotificationsEnabled: true,
        favoriteMenuIds: [],
        reviewCount: 0, // Platinum
      ),
      UserModel(
        uid: 'user_5',
        email: 'david@handong.ac.kr',
        studentId: '22000005',
        name: 'David Lee',
        profileImageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
        dietaryLabels: [],
        allergies: [],
        pushNotificationsEnabled: false,
        favoriteMenuIds: [],
        reviewCount: 0, // Gold
      ),
      UserModel(
        uid: 'user_6',
        email: 'emma@handong.ac.kr',
        studentId: '22000006',
        name: 'Emma Watson',
        profileImageUrl:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&q=80',
        dietaryLabels: [],
        allergies: [],
        pushNotificationsEnabled: true,
        favoriteMenuIds: [],
        reviewCount: 0, // Silver
      ),
      UserModel(
        uid: 'user_7',
        email: 'john@handong.ac.kr',
        studentId: '22000007',
        name: 'John Doe',
        profileImageUrl:
            'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=200&q=80',
        dietaryLabels: [],
        allergies: [],
        pushNotificationsEnabled: false,
        favoriteMenuIds: [],
        reviewCount: 0, // Bronze

      ),
    ];
    for (var user in users) {
      await collection.doc(user.uid).set(user.toMap());
    }
  }

  static Future<void> seedRestaurants() async {
    final collection = _firestore.collection('restaurants');
    final restaurants = [
      RestaurantModel(
        id: 'rest_1',
        name: "Mom's Kitchen (맘스키친)",
        openTime: "08:00",
        closeTime: "19:00",
        currentStatus: CrowdedStatus.unknown,
      ),
      RestaurantModel(
        id: 'rest_2',
        name: "Student Lounge (Sola Fide)",
        openTime: "11:00",
        closeTime: "20:00",
        currentStatus: CrowdedStatus.unknown,
      ),
      RestaurantModel(
        id: 'rest_3',
        name: "Student Lounge (Goshen)",
        openTime: "11:30",
        closeTime: "19:00",
        currentStatus: CrowdedStatus.unknown,
      ),
      RestaurantModel(
        id: 'rest_4',
        name: "Myeongsong",
        openTime: "11:00",
        closeTime: "19:00",
        currentStatus: CrowdedStatus.unknown,
      ),
      RestaurantModel(
        id: 'rest_5',
        name: "Grace Table",
        openTime: "11:30",
        closeTime: "19:30",
        currentStatus: CrowdedStatus.unknown,
      ),
      RestaurantModel(
        id: 'rest_6',
        name: "Dasu Handong",
        openTime: "11:00",
        closeTime: "18:00",
        currentStatus: CrowdedStatus.unknown,
      ),
      RestaurantModel(
        id: 'rest_7',
        name: "Deun Deun (Student Bento)",
        openTime: "08:00",
        closeTime: "15:00",
        currentStatus: CrowdedStatus.unknown,
      ),
      RestaurantModel(
        id: 'rest_8',
        name: "Korean Table",
        openTime: "11:00",
        closeTime: "19:30",
        currentStatus: CrowdedStatus.unknown,
      ),
    ];
    for (var r in restaurants) {
      await collection.doc(r.id).set(r.toMap());
    }
  }

  static Future<void> seedMenuItems() async {
    final collection = _firestore.collection('menu_items');
    final items = [
      // Mom's Kitchen
      MenuItemModel(
        id: 'rest_1_m1',
        restaurantId: 'rest_1',
        name: "Today's Special (Changes Daily)",
        price: 6000,
        imageUrl:
            'https://images.unsplash.com/photo-1544025162-d76694265947?w=500&q=80',
        description: 'Freshly prepared daily special.',
        averageRating: 0.0,
        reviewCount: 0,
        calories: 600,
        protein: 30,
        carbs: 65,
        fat: 20,
      ),
      MenuItemModel(
        id: 'rest_1_m2',
        restaurantId: 'rest_1',
        name: "Classic Bibimbap",
        price: 5500,
        imageUrl:
            'https://images.unsplash.com/photo-1553163147-622ab57be1c7?w=500&q=80',
        description: 'Healthy and traditional bibimbap with fresh vegetables.',
        averageRating: 0.0,
        reviewCount: 0,
        calories: 500,
        protein: 15,
        carbs: 80,
        fat: 12,
      ),
      MenuItemModel(
        id: 'rest_1_m3',
        restaurantId: 'rest_1',
        name: "Handmade Tonkatsu",
        price: 6500,
        imageUrl:
            'https://images.unsplash.com/photo-1598514982205-f36b96d1e8d4?w=500&q=80',
        description: 'Crispy fried pork cutlet with savory sauce.',
        averageRating: 0.0,
        reviewCount: 0,
        calories: 800,
        protein: 35,
        carbs: 70,
        fat: 40,
      ),

      // Sola Fide
      MenuItemModel(
        id: 'rest_2_m1',
        restaurantId: 'rest_2',
        name: "Sola Fide Static 1",
        price: 5000,
        imageUrl:
            'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=500&q=80',
        description: 'Standard static meal.',
        averageRating: 0.0,
        reviewCount: 0,
        calories: 450,
        protein: 20,
        carbs: 60,
        fat: 15,
      ),
      MenuItemModel(
        id: 'rest_2_m2',
        restaurantId: 'rest_2',
        name: "Sola Fide Static 2",
        price: 5000,
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&q=80',
        description: 'Standard static meal.',
        averageRating: 0.0,
        reviewCount: 0,
        calories: 480,
        protein: 25,
        carbs: 55,
        fat: 18,
      ),
      MenuItemModel(
        id: 'rest_2_m3',
        restaurantId: 'rest_2',
        name: "Sola Fide Static 3",
        price: 5000,
        imageUrl:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80',
        description: 'Standard static meal.',
        averageRating: 0.0,
        reviewCount: 0,
        calories: 500,
        protein: 22,
        carbs: 65,
        fat: 16,
      ),

      // Goshen
      MenuItemModel(
        id: 'rest_3_m1',
        restaurantId: 'rest_3',
        name: "Goshen Menu 1",
        price: 4500,
        imageUrl:
            'https://images.unsplash.com/photo-1544025162-d76694265947?w=500&q=80',
        description: 'Goshen standard meal.',
        averageRating: 0.0,
        reviewCount: 0,
        calories: 400,
        protein: 18,
        carbs: 50,
        fat: 12,
      ),
      MenuItemModel(
        id: 'rest_3_m2',
        restaurantId: 'rest_3',
        name: "Goshen Menu 2",
        price: 4500,
        imageUrl:
            'https://images.unsplash.com/photo-1553163147-622ab57be1c7?w=500&q=80',
        description: 'Goshen standard meal.',
        averageRating: 0.0,
        reviewCount: 0,
        calories: 420,
        protein: 20,
        carbs: 55,
        fat: 14,
      ),
      MenuItemModel(
        id: 'rest_3_m3',
        restaurantId: 'rest_3',
        name: "Goshen Menu 3",
        price: 4500,
        imageUrl:
            'https://images.unsplash.com/photo-1598514982205-f36b96d1e8d4?w=500&q=80',
        description: 'Goshen standard meal.',
        averageRating: 0.0,
        reviewCount: 0,
        calories: 440,
        protein: 22,
        carbs: 60,
        fat: 16,
      ),
      MenuItemModel(
        id: 'rest_3_m4',
        restaurantId: 'rest_3',
        name: "Goshen Menu 4",
        price: 4500,
        imageUrl:
            'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=500&q=80',
        description: 'Goshen standard meal.',
        averageRating: 0.0,
        reviewCount: 0,
        calories: 410,
        protein: 19,
        carbs: 52,
        fat: 13,
      ),
      MenuItemModel(
        id: 'rest_3_m5',
        restaurantId: 'rest_3',
        name: "Goshen Menu 5",
        price: 4500,
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&q=80',
        description: 'Goshen standard meal.',
        averageRating: 0.0,
        reviewCount: 0,
        calories: 460,
        protein: 24,
        carbs: 58,
        fat: 15,
      ),

      // Myeongsong
      MenuItemModel(
        id: 'rest_4_m1',
        restaurantId: 'rest_4',
        name: "Myeongsong Meal A",
        price: 5500,
        imageUrl:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80',
        description: 'Traditional Korean soup and sides.',
        averageRating: 0.0,
        reviewCount: 0,
        calories: 550,
        protein: 25,
        carbs: 65,
        fat: 18,
      ),
      MenuItemModel(
        id: 'rest_4_m2',
        restaurantId: 'rest_4',
        name: "Myeongsong Meal B",
        price: 6000,
        imageUrl:
            'https://images.unsplash.com/photo-1544025162-d76694265947?w=500&q=80',
        description: 'Stir-fry with rice and sides.',
        averageRating: 0.0,
        reviewCount: 0,
        calories: 600,
        protein: 30,
        carbs: 70,
        fat: 22,
      ),

      // Grace Table
      MenuItemModel(
        id: 'rest_5_m1',
        restaurantId: 'rest_5',
        name: "Grace Table Set A",
        price: 7000,
        imageUrl:
            'https://images.unsplash.com/photo-1553163147-622ab57be1c7?w=500&q=80',
        description: 'Premium balanced meal.',
        averageRating: 0.0,
        reviewCount: 0,
        calories: 550,
        protein: 40,
        carbs: 50,
        fat: 15,
      ),
      MenuItemModel(
        id: 'rest_5_m2',
        restaurantId: 'rest_5',
        name: "Grace Table Set B",
        price: 7500,
        imageUrl:
            'https://images.unsplash.com/photo-1598514982205-f36b96d1e8d4?w=500&q=80',
        description: 'Premium hearty meal.',
        averageRating: 0.0,
        reviewCount: 0,
        calories: 650,
        protein: 45,
        carbs: 60,
        fat: 20,
      ),

      // Dasu Handong
      MenuItemModel(
        id: 'rest_6_m1',
        restaurantId: 'rest_6',
        name: "Daily Changing Menu",
        price: 5000,
        imageUrl:
            'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=500&q=80',
        description: 'A surprise every day.',
        averageRating: 0.0,
        reviewCount: 0,
        calories: 500,
        protein: 25,
        carbs: 60,
        fat: 15,
      ),

      // Deun Deun
      MenuItemModel(
        id: 'rest_7_m1',
        restaurantId: 'rest_7',
        name: "Bento Box 1",
        price: 4500,
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&q=80',
        description: 'Convenient and filling student bento.',
        averageRating: 0.0,
        reviewCount: 0,
        calories: 550,
        protein: 20,
        carbs: 75,
        fat: 18,
      ),
      MenuItemModel(
        id: 'rest_7_m2',
        restaurantId: 'rest_7',
        name: "Bento Box 2",
        price: 5000,
        imageUrl:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80',
        description: 'Premium bento with extra sides.',
        averageRating: 0.0,
        reviewCount: 0,
        calories: 650,
        protein: 25,
        carbs: 80,
        fat: 22,
      ),

      // Korean Table
      MenuItemModel(
        id: 'rest_8_m1',
        restaurantId: 'rest_8',
        name: "Daily Korean Meal",
        price: 5500,
        imageUrl:
            'https://images.unsplash.com/photo-1544025162-d76694265947?w=500&q=80',
        description: 'Authentic daily Korean food.',
        averageRating: 0.0,
        reviewCount: 0,
        calories: 550,
        protein: 25,
        carbs: 70,
        fat: 15,
      ),
      MenuItemModel(
        id: 'rest_8_m2',
        restaurantId: 'rest_8',
        name: "Korean Table 1",
        price: 6000,
        imageUrl:
            'https://images.unsplash.com/photo-1553163147-622ab57be1c7?w=500&q=80',
        description: 'Classic stew and rice.',
        averageRating: 0.0,
        reviewCount: 0,
        calories: 600,
        protein: 30,
        carbs: 65,
        fat: 18,
      ),
      MenuItemModel(
        id: 'rest_8_m3',
        restaurantId: 'rest_8',
        name: "Ramyeon",
        price: 3500,
        imageUrl:
            'https://images.unsplash.com/photo-1598514982205-f36b96d1e8d4?w=500&q=80',
        description: 'Spicy and hot ramen.',
        averageRating: 0.0,
        reviewCount: 0,
        calories: 450,
        protein: 10,
        carbs: 70,
        fat: 15,
      ),
      MenuItemModel(
        id: 'rest_8_m4',
        restaurantId: 'rest_8',
        name: "Fried Rice",
        price: 5000,
        imageUrl:
            'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=500&q=80',
        description: 'Savory fried rice with egg.',
        averageRating: 0.0,
        reviewCount: 0,
        calories: 580,
        protein: 15,
        carbs: 85,
        fat: 20,
      ),
    ];
    for (var item in items) {
      await collection.doc(item.id).set(item.toMap());
    }
  }

  static Future<void> seedMealLogs() async {
    final collection = _firestore.collection('meal_logs');
    // Clear old logs for student_1
    var existing = await collection.where('userId', isEqualTo: 'user_1').get();
    for (var doc in existing.docs) {
      await doc.reference.delete();
    }

    final logs = [
      MealLogModel(
        id: 'log_1',
        userId: 'user_1',
        menuItemId: 'rest_1_m2',
        date: DateTime.now(),
        mealType: 'Lunch',
        rating: 5,
        personalNote: 'Classic bibimbap never fails!',
        photoUrl:
            'https://images.unsplash.com/photo-1553163147-622ab57be1c7?w=500&q=80',
      ),
      MealLogModel(
        id: 'log_2',
        userId: 'user_1',
        menuItemId: 'rest_8_m3',
        date: DateTime.now().subtract(const Duration(days: 1)),
        mealType: 'Dinner',
        rating: 4,
        personalNote: 'Spicy ramen hit the spot.',
        photoUrl:
            'https://images.unsplash.com/photo-1598514982205-f36b96d1e8d4?w=500&q=80',
      ),
    ];
    for (var log in logs) {
      await collection.doc(log.id).set(log.toMap());
    }
  }

  static Future<void> seedReviews() async {
    final collection = _firestore.collection('reviews');
    // Clear existing reviews first to avoid duplicates
    var existing = await collection.get();
    for (var doc in existing.docs) {
      await doc.reference.delete();
    }

    final reviews = [
      ReviewModel(
        id: 'review_1',
        userId: 'user_1',
        menuItemId: 'rest_1_m2',
        rating: 5,
        originalReview: '비빔밥 최고에요!',
        translatedReview: 'Bibimbap is the best!',
        datePosted: DateTime.now().subtract(const Duration(days: 1)),
        backgroundImageUrl:
            'https://images.unsplash.com/photo-1553163147-622ab57be1c7?w=800&q=80',
      ),
      ReviewModel(
        id: 'review_2',
        userId: 'user_2',
        menuItemId: 'rest_5_m1',
        rating: 5,
        originalReview: 'The best meal on campus.',
        translatedReview: '캠퍼스 내 최고의 식사.',
        datePosted: DateTime.now().subtract(const Duration(days: 2)),
        backgroundImageUrl:
            'https://images.unsplash.com/photo-1553163147-622ab57be1c7?w=800&q=80',
      ),
      ReviewModel(
        id: 'review_3',
        userId: 'user_3',
        menuItemId: 'rest_1_m2',
        rating: 4,
        originalReview: 'This is my 100th time eating here, still good.',
        translatedReview: '이곳에서 100번째 먹는 건데 여전히 맛있네요.',
        datePosted: DateTime.now().subtract(const Duration(days: 3)),
        backgroundImageUrl:
            'https://images.unsplash.com/photo-1553163147-622ab57be1c7?w=800&q=80',
      ),
      ReviewModel(
        id: 'review_4',
        userId: 'user_4',
        menuItemId: 'rest_1_m2',
        rating: 5,
        originalReview: 'Very healthy and filling.',
        translatedReview: '매우 건강하고 든든합니다.',
        datePosted: DateTime.now().subtract(const Duration(days: 4)),
        backgroundImageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&q=80',
      ),
      ReviewModel(
        id: 'review_5',
        userId: 'user_5',
        menuItemId: 'rest_1_m2',
        rating: 3,
        originalReview: 'A bit too spicy today.',
        translatedReview: '오늘은 조금 맵네요.',
        datePosted: DateTime.now().subtract(const Duration(days: 5)),
        backgroundImageUrl:
            'https://images.unsplash.com/photo-1553163147-622ab57be1c7?w=800&q=80',
      ),
      ReviewModel(
        id: 'review_6',
        userId: 'user_6',
        menuItemId: 'rest_1_m2',
        rating: 4,
        originalReview: 'Loved the fresh veggies.',
        translatedReview: '신선한 채소가 좋았어요.',
        datePosted: DateTime.now().subtract(const Duration(days: 6)),
        backgroundImageUrl:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&q=80',
      ),
      ReviewModel(
        id: 'review_7',
        userId: 'user_7',
        menuItemId: 'rest_1_m2',
        rating: 5,
        originalReview: 'Highly recommended for lunch!',
        translatedReview: '점심 식사로 강력 추천합니다!',
        datePosted: DateTime.now().subtract(const Duration(days: 7)),
        backgroundImageUrl:
            'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=800&q=80',
      ),
    ];
    for (var r in reviews) {
      await collection.doc(r.id).set(r.toMap());
    }
  }

  static Future<void> runAllSeeds() async {
    // Clear the restaurants and menu_items collections to prevent leftover old dummy data
    var existingRests = await _firestore.collection('restaurants').get();
    for (var doc in existingRests.docs) {
      await doc.reference.delete();
    }

    var existingMenus = await _firestore.collection('menu_items').get();
    for (var doc in existingMenus.docs) {
      await doc.reference.delete();
    }

    await seedUsers();
    await seedRestaurants();
    await seedMenuItems();
    await seedMealLogs();
    await seedReviews();
  }
}
