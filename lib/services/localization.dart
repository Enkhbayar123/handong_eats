import 'package:flutter/material.dart';

class LocalizationService {
  // Global ValueNotifier to trigger app-wide rebuilds on language change
  static final ValueNotifier<String> currentLanguage = ValueNotifier<String>('en');

  // Toggle between 'en' and 'ko'
  static void toggleLanguage() {
    currentLanguage.value = currentLanguage.value == 'en' ? 'ko' : 'en';
  }

  // Translation helper function
  static String tr(String key) {
    final lang = currentLanguage.value;
    if (_dictionary.containsKey(key) && _dictionary[key]!.containsKey(lang)) {
      return _dictionary[key]![lang]!;
    }
    // Fallback to English if translation is missing
    return _dictionary[key]?['en'] ?? key;
  }

  // Dictionary containing UI translations
  static final Map<String, Map<String, String>> _dictionary = {
    // Nav Bar
    'nav_today': {'en': 'Today', 'ko': '오늘'},
    'nav_feed': {'en': 'Feed', 'ko': '피드'},
    'nav_calendar': {'en': 'Calendar', 'ko': '달력'},
    'nav_my': {'en': 'My', 'ko': '내 정보'},

    // Settings & Profile
    'profile_title': {'en': 'My Profile', 'ko': '내 프로필'},
    'language_setting': {'en': 'Language', 'ko': '언어 설정'},
    'language_toggle': {'en': 'English', 'ko': '한국어'},
    'student_id': {'en': 'Student ID', 'ko': '학번'},
    'review_count': {'en': 'Reviews', 'ko': '리뷰 수'},
    'dietary_preferences': {'en': 'Dietary Preferences', 'ko': '식단 선호도'},
    'allergies': {'en': 'Allergies', 'ko': '알레르기'},

    // Today Menu
    'today_title': {'en': 'Handong Eats', 'ko': '한동 이츠'},
    'breakfast': {'en': 'Breakfast', 'ko': '조식'},
    'lunch': {'en': 'Lunch', 'ko': '중식'},
    'dinner': {'en': 'Dinner', 'ko': '석식'},
    'crowded_busy': {'en': 'Busy', 'ko': '혼잡'},
    'crowded_moderate': {'en': 'Moderate', 'ko': '보통'},
    'crowded_empty': {'en': 'Empty', 'ko': '여유'},
    'crowded_unknown': {'en': 'Unknown', 'ko': '정보없음'},
    'view_menu': {'en': 'View Menu', 'ko': '메뉴 보기'},

    // Feed
    'feed_title': {'en': 'Feed', 'ko': '피드'},
    'no_reviews': {'en': 'No reviews yet.\nBe the first to share!', 'ko': '아직 리뷰가 없습니다.\n첫 리뷰를 남겨보세요!'},

    // Calendar & Log
    'calendar_title': {'en': 'Calendar', 'ko': '식단 달력'},
    'my_plate': {'en': 'My Plate', 'ko': '내 식판'},
    'weekly_summary': {'en': 'Weekly Summary', 'ko': '주간 요약'},

    // Dish Detail
    'dish_reviews': {'en': 'Reviews', 'ko': '리뷰'},
    'write_review': {'en': 'Write Review', 'ko': '리뷰 작성'},
    
    // Add Review Form
    'add_log_title': {'en': 'Add Meal Log & Review', 'ko': '식사 기록 및 리뷰 추가'},
    'add_log_subtitle': {'en': 'Record your plate and share your feedback.', 'ko': '식판을 기록하고 피드백을 공유하세요.'},
    'add_photo': {'en': 'Add a Photo', 'ko': '사진 추가'},
    'change_photo': {'en': 'Change Photo', 'ko': '사진 변경'},
    'meal_type': {'en': 'Meal Type', 'ko': '식사 종류'},
    'rating': {'en': 'Rating', 'ko': '평점'},
    'write_a_review': {'en': 'Write a Review', 'ko': '리뷰 작성하기'},
    'review_hint': {'en': 'How was the taste, portions, and freshness?', 'ko': '맛, 양, 그리고 신선도는 어땠나요?'},
    'submit_review': {'en': 'Post Review & Log', 'ko': '리뷰 및 기록 등록'},
  };
}
