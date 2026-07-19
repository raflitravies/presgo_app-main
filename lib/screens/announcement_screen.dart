import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import 'schedule_screen.dart';
import 'chat_screen.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({Key? key}) : super(key: key);

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  int _selectedNavIndex = 4;

  final List<Map<String, dynamic>> _announcements = [
    {'title': 'Evaluation of Teaching and Learning Activities...', 'date': '7 October 2024'},
    {'title': 'Open Registration Youth Today X Join AIESEC', 'date': '1 October 2024'},
    {'title': 'Webinar: Becoming Generation that Shapes Cy...', 'date': '30 September 2024'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6E9F8),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Text('Announcement', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: _announcements.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFE0E0E0)),
                    itemBuilder: (context, index) => _buildAnnouncementTile(_announcements[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAnnouncementTile(Map<String, dynamic> item) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 10),
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(color: Color(0xFF4097FC), shape: BoxShape.circle),
                child: const Center(
                  child: Text('!', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title'],
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(item['date'], style: const TextStyle(fontSize: 12, color: Colors.black45)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.chevron_right, color: Colors.black45, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final icons = [Icons.home, Icons.calendar_month, Icons.qr_code_scanner, Icons.chat_bubble, Icons.campaign];

    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          final selected = _selectedNavIndex == index;
          return GestureDetector(
            onTap: () {
              if (index == 0) {
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const HomeScreen()),
                  (route) => false,
                );
              } else if (index == 1) {
                Navigator.pushReplacement(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const ScheduleScreen()));
              } else if (index == 3) {
                Navigator.pushReplacement(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const ChatScreen()));
              } else if (index == 4) {
                setState(() => _selectedNavIndex = 4);
              } else {
                setState(() => _selectedNavIndex = index);
              }
            },
            child: Icon(icons[index], color: selected ? const Color(0xFF4097FC) : Colors.black54),
          );
        }),
      ),
    );
  }
}
