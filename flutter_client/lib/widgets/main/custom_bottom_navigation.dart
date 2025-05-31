import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Categories',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
      ],
      selectedItemColor: Colors.green,
      onTap: (index) {
        // Handle navigation
        switch (index) {
          case 0:
            // Already on home
            break;
          case 1:
            // Navigate to categories
            break;
          case 2:
            // Navigate to settings
            break;
        }
      },
    );
  }
}