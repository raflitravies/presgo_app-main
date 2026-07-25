import 'package:flutter/material.dart';
import 'lecturer_home_screen.dart';
import 'lecturer_schedule_screen.dart';
import 'lecturer_chat_screen.dart';
import 'lecturer_announcement_screen.dart';

class LecturerMainNavigation extends StatefulWidget {
  const LecturerMainNavigation({Key? key}) : super(key: key);

  @override
  State<LecturerMainNavigation> createState() => _LecturerMainNavigationState();
}

class _LecturerMainNavigationState extends State<LecturerMainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    LecturerHomeScreen(),
    LecturerScheduleScreen(),
    LecturerChatScreen(),
    LecturerAnnouncementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: _screens.asMap().entries.map((entry) {
          final index = entry.key;
          final screen = entry.value;
          return Offstage(
            offstage: _currentIndex != index,
            child: TickerMode(
              enabled: _currentIndex == index,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 65),
                child: screen,
              ),
            ),
          );
        }).toList(),
      ),
      bottomNavigationBar: Container(
        height: 65,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
            _buildNavItem(Icons.calendar_month_outlined, Icons.calendar_month, 'Schedule', 1),
            _buildNavItem(Icons.chat_bubble_outline, Icons.chat_bubble, 'Chat', 2),
            _buildNavItem(Icons.campaign_outlined, Icons.campaign, 'Announcement', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData unselectedIcon, IconData selectedIcon, String label, int index) {
    final selected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selected ? selectedIcon : unselectedIcon,
            color: selected ? const Color(0xFF4097FC) : Colors.black54,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: selected ? const Color(0xFF4097FC) : Colors.black54,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}