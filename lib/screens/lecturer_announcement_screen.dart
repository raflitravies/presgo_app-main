import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/announcement_provider.dart'; // Sesuaikan jika ada provider announcement
import 'lecturer_home_screen.dart';
import 'lecturer_schedule_screen.dart';
import 'lecturer_chat_screen.dart';

class LecturerAnnouncementScreen extends StatefulWidget {
  const LecturerAnnouncementScreen({Key? key}) : super(key: key);

  @override
  State<LecturerAnnouncementScreen> createState() => _LecturerAnnouncementScreenState();
}

class _LecturerAnnouncementScreenState extends State<LecturerAnnouncementScreen> {
  final int _selectedIndex = 3; // Index 3 untuk tab Announcement di Lecturer Bottom Nav

  @override
  void initState() {
    super.initState();
    // Inisialisasi data pengumuman jika menggunakan provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Provider.of<AnnouncementProvider>(context, listen: false).loadAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FA),
      body: Stack(
        children: [
          // Background Gradient khas PresGO
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffD4F2FE), Color(0xffF8F9FA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title
                const Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 12),
                  child: Text(
                    'Announcement',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                // List Announcement
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: 3, // Disesuaikan dengan data dari API/Provider nantinya
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildAnnouncementCard(
                        title: 'Academic Notice',
                        date: '24 Jul 2026',
                        content: 'Reminder for submission of mid-term evaluation scores.',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // BOTTOM NAVIGATION BAR KHUSUS LECTURER
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAnnouncementCard({
    required String title,
    required String date,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
          ),
        ],
      ),
    );
  }

  // BOTTOM NAV LECTURER (Home, Schedule, Chat, Announcement)
  Widget _buildBottomNav() {
    final icons = [Icons.home, Icons.calendar_month, Icons.chat_bubble, Icons.campaign];
    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          final selected = _selectedIndex == index;
          return GestureDetector(
            onTap: () {
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                    pageBuilder: (_, __, ___) => const LecturerHomeScreen(),
                  ),
                );
              } else if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                    pageBuilder: (_, __, ___) => const LecturerScheduleScreen(),
                  ),
                );
              } else if (index == 2) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                    pageBuilder: (_, __, ___) => const LecturerChatScreen(),
                  ),
                );
              } else if (index == 3) {
                setState(() {});
              }
            },
            child: Icon(icons[index], color: selected ? const Color(0xFF4097FC) : Colors.black54),
          );
        }),
      ),
    );
  }
}