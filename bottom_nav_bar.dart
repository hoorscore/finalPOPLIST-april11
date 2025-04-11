import 'package:flutter/material.dart';
import 'level_selection_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFFFFCC63),
      selectedItemColor: const Color(0xFF4285F4),
      unselectedItemColor: Colors.white,
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LevelSelectionScreen()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.checklist), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: ""),
      ],
    );
  }
}
