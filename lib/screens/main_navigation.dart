import 'package:flutter/material.dart';
import 'today_menu_screen.dart';
import 'feed_screen.dart';
import 'calendar_screen.dart';
import 'my_profile_screen.dart';
import '../services/localization.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // We will create the screens dynamically in build() so they rebuild on language change.

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LocalizationService.currentLanguage,
      builder: (context, lang, child) {
        final currentScreen = [
          TodayMenuScreen(),
          FeedScreen(),
          CalendarScreen(),
          MyProfileScreen(),
        ][_selectedIndex];

        return Scaffold(
          body: currentScreen,
          bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.restaurant_menu),
            label: LocalizationService.tr('nav_today'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.play_circle_outline),
            label: LocalizationService.tr('nav_feed'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today),
            label: LocalizationService.tr('nav_calendar'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: LocalizationService.tr('nav_my'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.redAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}