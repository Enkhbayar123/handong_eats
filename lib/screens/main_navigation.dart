import 'package:flutter/material.dart';
import 'today_menu_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // These are the three main screens of your app
  final List<Widget> _screens = [
    const TodayMenuScreen(),
    const Center(child: Text('Calendar / Archive')), // Placeholder for later
    const Center(child: Text('My Page')), // Placeholder for later
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Today', // 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar', // 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My', // 
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.redAccent, 
        onTap: _onItemTapped,
      ),
    );
  }
}