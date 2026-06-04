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
        name: 'Jiwon Kim',
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
        name: 'Alex Chan',
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
      'Soondubu Jjigae',
      'Pork Cutlet',
      'Tteokbbugi',
      'Tansuyuk',
      'GunamulHejangug',
      'Jjanbbun',
      'Pork Cutlet',
      'Tteokbbugi',
      'Tansuyuk',
      'GunamulHejangug',
      'Soondubu Jjigae',
      'Dakkalguksu',
      'Cutlet',
      'Cutlet',
      'Jjimdak',
      'Jjimdak',
      'Ramen',
      'DakKanjon',
      'Ramen',
      'Malatang',
      'Yugkaejang',
      '흰쌀밥, 콩나물국, 김치, 제육김치볶음, 미역줄기볶음, 순두부',
      'Tansuyuk',
      'BudaeJjigae',
      'TuejiGukbab',
      'Fried Rice',
      'Kimchi Jjigae',
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
    // Clear existing reviews first to avoid duplicates
    var existing = await collection.get();
    for (var doc in existing.docs) {
      await doc.reference.delete();
    }

    final newDishNames = [
      'Soondubu Jjigae',
      'Pork Cutlet',
      'Tteokbbugi',
      'Tansuyuk',
      'GunamulHejangug',
      'Jjanbbun',
      'Pork Cutlet',
      'Tteokbbugi',
      'Tansuyuk',
      'GunamulHejangug',
      'Soondubu Jjigae',
      'Dakkalguksu',
      'Cutlet',
      'Cutlet',
      'Jjimdak',
      'Jjimdak',
      'Ramen',
      'DakKanjon',
      'Ramen',
      'Malatang',
      'Yugkaejang',
      '흰쌀밥, 콩나물국, 김치, 제육김치볶음, 미역줄기볶음, 순두부',
      'Tansuyuk',
      'BudaeJjigae',
      'TuejiGukbab',
      'Fried Rice',
      'Kimchi Jjigae',
    ];

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

    final templates = {
      'stew': [
        ['국물이 아주 깊고 맛있어요! 따뜻해서 온몸이 녹네요.', 'The soup is very deep and delicious! Warm and soothing.'],
        ['얼큰하고 시원해서 해장용으로 딱입니다.', 'Spicy and refreshing, perfect for hangover cure.'],
        ['두부와 채소가 듬뿍 들어있어서 든든해요.', 'Full of tofu and vegetables, very filling.'],
        ['기대 이상으로 진하고 정성이 가득한 찌개입니다.', 'Beyond expectations, rich and full of sincerity stew.'],
        ['엄마가 해준 집밥 같은 따뜻함이 느껴집니다.', 'Warmth like mom\'s home-cooked food.'],
      ],
      'cutlet': [
        ['겉은 바삭하고 속은 촉촉해서 정말 맛있어요!', 'Crispy outside and juicy inside, absolutely delicious!'],
        ['고기가 두툼하고 잡내가 전혀 없어서 만족스럽습니다.', 'The meat is thick and completely odorless, very satisfying.'],
        ['소스가 너무 달지 않고 고기랑 아주 잘 어울려요.', 'The sauce is not too sweet and goes extremely well with the meat.'],
        ['바삭바삭한 식감이 끝까지 유지되어 훌륭합니다.', 'The crispy texture stays until the very end, excellent.'],
        ['학식 퀄리티를 뛰어넘는 훌륭한 갓 튀긴 돈까스!', 'Excellent freshly-fried cutlet exceeding school meal quality!'],
      ],
      'spicy': [
        ['매콤하고 쫄깃해서 스트레스가 다 풀립니다!', 'Spicy and chewy, blows all stress away!'],
        ['양념이 중독성 있어서 계속 손이 가요.', 'The seasoning is addictive, keeps me reaching for more.'],
        ['자극적이지 않으면서 맛있게 매운맛이라 강추합니다.', 'Deliciously spicy without being overly irritating, highly recommend.'],
        ['떡과 어묵의 조화가 예술이에요.', 'The harmony of rice cakes and fish cakes is art.'],
        ['매운맛 좋아하는 분들이라면 무조건 좋아할 맛!', 'A flavor anyone who loves spicy food will definitely love!'],
      ],
      'noodles': [
        ['면발이 쫄깃쫄깃하고 국물이 깔끔해요.', 'The noodles are chewy and the broth is clean.'],
        ['비오는 날 먹기에 이보다 완벽할 순 없어요.', 'Nothing could be more perfect than having this on a rainy day.'],
        ['차오르는 불맛과 신선한 해산물이 가득하네요.', 'Full of smoky flavor and fresh seafood.'],
        ['가성비 최고이고 한 그릇 다 비웠어요.', 'Best value for money, cleared the whole bowl.'],
        ['뜨끈한 면 요리가 땡길 때 최선의 선택입니다.', 'Best choice when craving hot noodle dishes.'],
      ],
      'rice': [
        ['밥알이 고슬고슬하게 잘 볶아졌고 정말 고소해요.', 'The rice is fried fluffy and is extremely savory.'],
        ['제육볶음과 반찬 구성이 매우 조화롭습니다.', 'The pork stir-fry and side dishes are highly harmonious.'],
        ['든든한 한 끼 식사로 영양 밸런스가 참 좋네요.', 'Great nutritional balance for a filling meal.'],
        ['엄청 친절하게 많이 주셔서 감동받았습니다.', 'Moved by the friendly and generous portion.'],
        ['매일 먹어도 질리지 않을 담백한 집밥 스타일!', 'Light home-meal style that you won\'t get tired of daily!'],
      ],
    };

    final random = Random();
    final List<ReviewModel> reviews = [];

    for (int i = 0; i < 100; i++) {
      // Pick random dish
      final dishIndex = random.nextInt(newDishNames.length);
      final dishName = newDishNames[dishIndex];
      final menuItemId = 'rest_new_dish_${dishIndex + 1}';

      // Pick category
      String cat = 'stew';
      if (dishName.contains('Cutlet') || dishName.contains('Cutlet') || dishName.contains('Tansuyuk') || dishName.contains('Jjimdak')) {
        cat = 'cutlet';
      } else if (dishName.contains('Tteok') || dishName.contains('Malatang')) {
        cat = 'spicy';
      } else if (dishName.contains('Ramen') || dishName.contains('Dakkalguksu') || dishName.contains('Jjanbbun')) {
        cat = 'noodles';
      } else if (dishName.contains('Rice') || dishName.contains('흰쌀밥') || dishName.contains('Gukbab')) {
        cat = 'rice';
      }

      // Pick random template
      final options = templates[cat]!;
      final template = options[random.nextInt(options.length)];

      // Pick random user
      final userIndex = random.nextInt(7) + 1;
      final userId = 'user_$userIndex';

      // Pick random rating (3 to 5)
      final rating = random.nextInt(3) + 3;

      // Pick random likes count (0 to 7)
      final likesCount = random.nextInt(8); // 0 to 7
      final List<String> likedBy = [];
      final List<int> userPool = [1, 2, 3, 4, 5, 6, 7];
      userPool.shuffle(random);
      for (int k = 0; k < likesCount; k++) {
        likedBy.add('user_${userPool[k]}');
      }

      // 40% chance of background image, 60% chance empty
      final hasImage = random.nextDouble() < 0.4;
      final backgroundImageUrl = hasImage ? 'lib/images/${newImageFiles[dishIndex]}' : '';

      // Random date in the last 30 days
      final daysAgo = random.nextInt(30);
      final hoursAgo = random.nextInt(24);
      final datePosted = DateTime.now().subtract(Duration(days: daysAgo, hours: hoursAgo));

      reviews.add(
        ReviewModel(
          id: 'seeded_review_${i + 1}',
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
