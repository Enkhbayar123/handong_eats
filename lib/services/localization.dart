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
    'todays_podium': {'en': "Today's Podium", 'ko': '오늘의 우수 식단'},
    'hot': {'en': 'HOT', 'ko': '인기'},
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

    // Campus Archive
    'campus_archive': {'en': 'Campus Menu Archive', 'ko': '캠퍼스 메뉴 기록'},

    // Dish Detail extra
    'reviews_summary': {'en': 'Reviews Summary', 'ko': '리뷰 요약'},
    'no_reviews_yet': {'en': 'No reviews yet. Be the first to share your thoughts!', 'ko': '아직 리뷰가 없습니다. 첫 번째 리뷰를 남겨보세요!'},
    'generate_ai': {'en': 'Generate AI Description', 'ko': 'AI 설명 생성'},
    'no_photos_yet': {'en': 'No photos yet', 'ko': '아직 사진이 없습니다'},

    // Dietary & Allergies screens
    'dietary_labels_title': {'en': 'Dietary Labels', 'ko': '식단 선호도 설정'},
    'dietary_labels_subtitle': {'en': 'Select your dietary preferences to personalize your food filters.', 'ko': '메뉴 필터를 개인화하기 위한 식단 선호도를 선택해 주세요.'},
    'allergies_title': {'en': 'Allergies', 'ko': '알레르기 설정'},
    'allergies_subtitle': {'en': 'Select ingredients you are allergic to for safety warnings.', 'ko': '안전한 식사를 위해 알레르기가 있는 성분을 선택해 주세요.'},
    'save_changes': {'en': 'Save Changes', 'ko': '설정 저장'},
    'saving': {'en': 'Saving...', 'ko': '저장 중...'},
    'save_success': {'en': 'Preferences updated successfully!', 'ko': '선호 설정이 성공적으로 업데이트되었습니다!'},
    'save_failed': {'en': 'Failed to save changes. Please try again.', 'ko': '설정 저장에 실패했습니다. 다시 시도해 주세요.'},
  };

  // Shared registry to synchronize review translation toggle states
  static final Map<String, ValueNotifier<bool>> _reviewTranslationStates = {};

  static ValueNotifier<bool> getReviewTranslationNotifier(String reviewId, {bool initial = false}) {
    return _reviewTranslationStates.putIfAbsent(
      reviewId,
      () => ValueNotifier<bool>(initial),
    );
  }
}
