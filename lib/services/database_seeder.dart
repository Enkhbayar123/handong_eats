import 'dart:math';
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
        name: '김지원',
        profileImageUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80',
        dietaryLabels: ['Halal', 'Lactose-Free'],
        allergies: ['Peanuts'],
        pushNotificationsEnabled: true,
        favoriteMenuIds: ['rest_new_dish_1', 'rest_new_dish_2'],
        country: 'South Korea',
        spiceTolerance: 'Hot',
        preferredTastes: ['Spicy', 'Savory'],
      ),
      UserModel(
        uid: 'user_2',
        email: 'student2@handong.ac.kr',
        studentId: '22000002',
        name: '이민우',
        profileImageUrl:
            'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=200&q=80',
        dietaryLabels: ['Vegetarian'],
        allergies: [],
        pushNotificationsEnabled: false,
        favoriteMenuIds: ['rest_new_dish_3', 'rest_new_dish_4'],
        country: 'United States',
        spiceTolerance: 'Mild',
        preferredTastes: ['Sweet', 'Savory'],
        reviewCount: 0, // Iron
      ),
      UserModel(
        uid: 'user_3',
        email: 'michael@handong.ac.kr',
        studentId: '22000003',
        name: '박지현',
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
        name: '최수빈',
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
        name: '김동현',
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
        name: '정우성',
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
        email: 'jieun@handong.ac.kr',
        studentId: '22000007',
        name: '이지은',
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
      final userData = user.toMap();
      userData['password'] = '123456'; // Default password for seeded users
      await collection.doc(user.uid).set(userData);
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
        imageUrl: "https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=200&q=80",
      ),
      RestaurantModel(
        id: 'rest_2',
        name: "Student Lounge (Sola Fide)",
        openTime: "11:00",
        closeTime: "20:00",
        currentStatus: CrowdedStatus.unknown,
        imageUrl: "https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=200&q=80",
      ),
      RestaurantModel(
        id: 'rest_3',
        name: "Student Lounge (Goshen)",
        openTime: "11:30",
        closeTime: "19:00",
        currentStatus: CrowdedStatus.unknown,
        imageUrl: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=200&q=80",
      ),
      RestaurantModel(
        id: 'rest_4',
        name: "Myeongsong",
        openTime: "11:00",
        closeTime: "19:00",
        currentStatus: CrowdedStatus.unknown,
        imageUrl: "https://images.unsplash.com/photo-1552566626-52f8b828add9?w=200&q=80",
      ),
      RestaurantModel(
        id: 'rest_5',
        name: "Grace Table",
        openTime: "11:30",
        closeTime: "19:30",
        currentStatus: CrowdedStatus.unknown,
        imageUrl: "https://images.unsplash.com/photo-1544025162-d76694265947?w=200&q=80",
      ),
      RestaurantModel(
        id: 'rest_6',
        name: "Dasu Handong",
        openTime: "11:00",
        closeTime: "18:00",
        currentStatus: CrowdedStatus.unknown,
        imageUrl: "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=200&q=80",
      ),
      RestaurantModel(
        id: 'rest_7',
        name: "Deun Deun (Student Bento)",
        openTime: "08:00",
        closeTime: "15:00",
        currentStatus: CrowdedStatus.unknown,
        imageUrl: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&q=80",
      ),
      RestaurantModel(
        id: 'rest_8',
        name: "Korean Table",
        openTime: "11:00",
        closeTime: "19:30",
        currentStatus: CrowdedStatus.unknown,
        imageUrl: "https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=200&q=80",
      ),
    ];
    for (var r in restaurants) {
      await collection.doc(r.id).set(r.toMap());
    }
  }

  static Future<void> seedMenuItems() async {
    final collection = _firestore.collection('menu_items');
    final items = <MenuItemModel>[];

    final newImageFiles = [
      'KakaoTalk_Photo_2026-05-30-22-04-17 001.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-18 002.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-18 003.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-19 004.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-19 005.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-50 001.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-51 002.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-51 003.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-51 004.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-51 005.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-51 006.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-51 007.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-51 008.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-52 009.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-52 010.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-52 011.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-53 012.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-53 013.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-53 014.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-54 015.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-54 016.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-55 017.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-55 018.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-56 019.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-56 020.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-56 021.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-57 022.jpeg',
    ];

    final newDishNames = [
      '순두부찌개',
      '돈까스',
      '떡볶이',
      '탕수육',
      '콩나물해장국',
      '짬뽕',
      '돈까스',
      '떡볶이',
      '탕수육',
      '콩나물해장국',
      '순두부찌개',
      '닭칼국수',
      '돈까스',
      '돈까스',
      '찜닭',
      '찜닭',
      '라면',
      '닭강정',
      '라면',
      '마라탕',
      '육개장',
      '흰쌀밥, 콩나물국, 김치, 제육김치볶음, 미역줄기볶음, 순두부',
      '탕수육',
      '부대찌개',
      '돼지국밥',
      '볶음밥',
      '김치찌개',
    ];

    for (int i = 0; i < newImageFiles.length; i++) {
      final restNum = (i % 8) + 1;
      items.add(
        MenuItemModel(
          id: 'rest_new_dish_${i + 1}',
          restaurantId: 'rest_$restNum',
          name: newDishNames[i],
          price: 5500 + (i * 150),
          imageUrl: 'lib/images/${newImageFiles[i]}',
          description: 'A newly seeded delicious ${newDishNames[i]} served fresh at our campus cafeteria.',
          averageRating: double.parse((4.0 + (i % 10) * 0.1).toStringAsFixed(1)),
          reviewCount: 15 + (i * 2),
          calories: 480 + (i * 8),
          protein: 12 + (i % 5),
          carbs: 65 + (i % 8),
          fat: 10 + (i % 4),
        ),
      );
    }

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
        menuItemId: 'rest_new_dish_1',
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
        menuItemId: 'rest_new_dish_2',
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
    var existing = await collection.get();
    for (var doc in existing.docs) {
      await doc.reference.delete();
    }

    final newDishNames = [
      '순두부찌개', '돈까스', '떡볶이', '탕수육', '콩나물해장국', '짬뽕', '돈까스', '떡볶이',
      '탕수육', '콩나물해장국', '순두부찌개', '닭칼국수', '돈까스', '돈까스', '찜닭', '찜닭',
      '라면', '닭강정', '라면', '마라탕', '육개장', '흰쌀밥, 콩나물국, 김치, 제육김치볶음, 미역줄기볶음, 순두부',
      '탕수육', '부대찌개', '돼지국밥', '볶음밥', '김치찌개',
    ];

    final newImageFiles = [
      'KakaoTalk_Photo_2026-05-30-22-04-17 001.jpeg', 'KakaoTalk_Photo_2026-05-30-22-04-18 002.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-18 003.jpeg', 'KakaoTalk_Photo_2026-05-30-22-04-19 004.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-19 005.jpeg', 'KakaoTalk_Photo_2026-05-30-22-04-50 001.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-51 002.jpeg', 'KakaoTalk_Photo_2026-05-30-22-04-51 003.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-51 004.jpeg', 'KakaoTalk_Photo_2026-05-30-22-04-51 005.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-51 006.jpeg', 'KakaoTalk_Photo_2026-05-30-22-04-51 007.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-51 008.jpeg', 'KakaoTalk_Photo_2026-05-30-22-04-52 009.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-52 010.jpeg', 'KakaoTalk_Photo_2026-05-30-22-04-52 011.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-53 012.jpeg', 'KakaoTalk_Photo_2026-05-30-22-04-53 013.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-53 014.jpeg', 'KakaoTalk_Photo_2026-05-30-22-04-54 015.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-54 016.jpeg', 'KakaoTalk_Photo_2026-05-30-22-04-55 017.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-55 018.jpeg', 'KakaoTalk_Photo_2026-05-30-22-04-56 019.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-56 020.jpeg', 'KakaoTalk_Photo_2026-05-30-22-04-56 021.jpeg',
      'KakaoTalk_Photo_2026-05-30-22-04-57 022.jpeg',
    ];

    final templates = {
      'stew': [['국물이 아주 깊고 맛있어요!', 'Deep and delicious broth.'], ['얼큰하고 시원해요.', 'Spicy and refreshing.']],
      'cutlet': [['겉은 바삭하고 속은 촉촉해요!', 'Crispy outside, juicy inside!'], ['고기가 두툼해서 좋아요.', 'Thick meat is good.']],
      'spicy': [['매콤하고 쫄깃해요!', 'Spicy and chewy!'], ['중독성 있는 맛.', 'Addictive flavor.']],
      'noodles': [['면발이 쫄깃해요.', 'Chewy noodles.'], ['국물이 깔끔해요.', 'Clean broth.']],
      'rice': [['밥알이 고슬고슬해요.', 'Fluffy rice.'], ['집밥 스타일이에요.', 'Home-cooked style.']],
    };

    final random = Random();
    int reviewIdCounter = 1;
    final List<ReviewModel> reviews = [];

    for (int j = 0; j < newDishNames.length; j++) {
      final dishName = newDishNames[j];
      final menuItemId = 'rest_new_dish_${j + 1}';
      String cat = 'stew';
      if (dishName.contains('돈까스') || dishName.contains('탕수육') || dishName.contains('찜닭')) {
        cat = 'cutlet';
      } else if (dishName.contains('떡볶이') || dishName.contains('마라탕')) {
        cat = 'spicy';
      } else if (dishName.contains('라면') || dishName.contains('닭칼국수') || dishName.contains('짬뽕')) {
        cat = 'noodles';
      } else if (dishName.contains('볶음밥') || dishName.contains('흰쌀밥') || dishName.contains('국밥')) {
        cat = 'rice';
      }

      final options = templates[cat]!;

      for (int i = 0; i < 30; i++) {
        final template = options[random.nextInt(options.length)];
        final userId = 'user_${random.nextInt(7) + 1}';
        final rating = random.nextInt(3) + 3;
        final hasImage = random.nextDouble() < 0.4;
        final backgroundImageUrl = hasImage ? 'lib/images/${newImageFiles[j]}' : '';

        // Random date in the last 30 days
        final daysAgo = random.nextInt(30);
        final hoursAgo = random.nextInt(24);
        final datePosted = DateTime.now().subtract(Duration(days: daysAgo, hours: hoursAgo));

        // Random likes count
        final likesCount = random.nextInt(8); // 0 to 7
        final List<String> likedBy = [];
        final List<int> userPool = [1, 2, 3, 4, 5, 6, 7];
        userPool.shuffle(random);
        for (int k = 0; k < likesCount; k++) {
          likedBy.add('user_${userPool[k]}');
        }

        reviews.add(
          ReviewModel(
            id: 'seeded_review_${reviewIdCounter++}',
            userId: userId,
            menuItemId: menuItemId,
            rating: rating,
            originalReview: template[0],
            translatedReview: template[1],
            datePosted: datePosted,
            backgroundImageUrl: backgroundImageUrl,
            likesCount: likesCount,
            likedBy: likedBy,
          ),
        );
      }
    }

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
