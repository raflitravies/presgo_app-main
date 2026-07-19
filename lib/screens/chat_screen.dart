import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import 'schedule_screen.dart';
import 'announcement_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _selectedNavIndex = 3;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _chats = [
    {'name': 'K1 - Fluid Mechanics', 'lastSender': 'Hannan Radefa Putra', 'lastMessage': 'Thank you for...', 'time': '14:41', 'isGroup': true},
    {'name': 'K2 - Human Computer Interaction', 'lastSender': 'Dean Apriana (Lecturer)', 'lastMessage': 'Dear all st...', 'time': '07:21', 'isGroup': true},
    {'name': 'K2 - Optics and Photonics', 'lastSender': 'Bambang Kartono (Lecturer)', 'lastMessage': 'Please...', 'time': '7/10', 'isGroup': true},
    {'name': 'K2 - Ordinary Differential Equations', 'lastSender': 'Donny Fahrizal Anhar (Lecturer)', 'lastMessage': 'Good...', 'time': '7/10', 'isGroup': true},
    {'name': 'K3 - Atmospheric Thermodynamics', 'lastSender': 'Rama Azhari Putra', 'lastMessage': 'Thank you for the i...', 'time': '2/10', 'isGroup': true},
    {'name': 'K1 - Electrostatic', 'lastSender': 'Alika Zaviera', 'lastMessage': 'Thank you for the info, Sir.', 'time': '1/10', 'isGroup': true},
    {'name': 'Setyanto Kusmaryono', 'lastSender': '', 'lastMessage': 'Thank you, Sir.', 'time': '14/09', 'isGroup': false, 'isRead': true},
    {'name': 'P1 - Integrated Practicum II', 'lastSender': 'Clara Aurelia Setiady (Assistant)', 'lastMessage': 'These...', 'time': '2/09', 'isGroup': true},
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
                child: Text('Chat', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Colors.black38, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: _chats.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 76, endIndent: 20, color: Color(0xFFEEEEEE)),
                    itemBuilder: (context, index) => _buildChatTile(_chats[index]),
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

  Widget _buildChatTile(Map<String, dynamic> chat) {
    final isGroup = chat['isGroup'] as bool;
    final isRead = chat['isRead'] as bool? ?? false;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(color: Color(0xFFE8E8E8), shape: BoxShape.circle),
        child: Icon(isGroup ? Icons.group : Icons.person, color: Colors.black54, size: 24),
      ),
      title: Text(chat['name'],
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
      subtitle: Row(
        children: [
          if (isRead)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.done_all, size: 14, color: Colors.blue),
            ),
          Expanded(
            child: Text(
              chat['lastSender'] != '' ? '${chat['lastSender']}: ${chat['lastMessage']}' : chat['lastMessage'],
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Text(chat['time'], style: const TextStyle(fontSize: 12, color: Colors.black45)),
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
                setState(() => _selectedNavIndex = 3);
              } else if (index == 4) {
                Navigator.pushReplacement(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const AnnouncementScreen()));
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
