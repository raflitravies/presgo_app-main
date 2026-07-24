import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../providers/schedule_provider.dart';
import 'profile_screen.dart';
import 'schedule_screen.dart';
import 'lecturer_courses_screen.dart';
import 'lecturer_attendance_screen.dart';
import 'lecturer_advisees_screen.dart';
import 'announcement_screen.dart';
import 'chat_screen.dart';

class LecturerHomeScreen extends StatefulWidget {
  const LecturerHomeScreen({Key? key}) : super(key: key);

  @override
  State<LecturerHomeScreen> createState() => _LecturerHomeScreenState();
}

class _LecturerHomeScreenState extends State<LecturerHomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).loadLecturerHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTopSection(),
                const SizedBox(height: 110),
                _buildMenuSection(),
                const SizedBox(height: 20),
                _buildTodayScheduleSection(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopSection() {
    final authProvider = Provider.of<AuthProvider>(context);
    final homeProvider = Provider.of<HomeProvider>(context);
    final user = authProvider.user;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 150),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB7D7F5), Color(0xFF8EC5FC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
                pageBuilder: (_, __, ___) => const ProfileScreen(),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFD9D9D9),
                  child: user?.photoUrl != null
                      ? ClipOval(child: Image.network(user!.photoUrl!, fit: BoxFit.cover))
                      : Text(
                    user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'Lecturer',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.nimNip ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -75,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF5B9BE6),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(blurRadius: 25, offset: const Offset(0, 12), color: Colors.black.withOpacity(0.18))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.calendar_today,
                  homeProvider.todaySchedule.length.toString(),
                  "Today's Classes",
                ),
                Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                _buildStatItem(
                  Icons.people_outline,
                  '-',
                  'Students',
                ),
                Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                _buildStatItem(
                  Icons.assignment_outlined,
                  '-',
                  'Courses',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ],
    );
  }

  Widget _buildMenuSection() {
    final menus = [
      {'icon': Icons.menu_book, 'label': 'My Courses', 'color': Colors.blue},
      {'icon': Icons.fact_check, 'label': 'Attendance', 'color': Colors.green},
      {'icon': Icons.grade, 'label': 'Grades', 'color': Colors.orange},
      {'icon': Icons.supervisor_account, 'label': 'Advisees', 'color': Colors.purple},
      {'icon': Icons.campaign, 'label': 'Announcement', 'color': Colors.red},
      {'icon': Icons.support_agent, 'label': 'Support', 'color': Colors.teal},
      {'icon': Icons.chat_bubble_outline, 'label': 'Chat', 'color': Colors.indigo},
      {'icon': Icons.more_horiz, 'label': 'More', 'color': Colors.grey},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: menus.sublist(0, 4).map((m) => _buildMenuItem(m)).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: menus.sublist(4).map((m) => _buildMenuItem(m)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> m) {
    return GestureDetector(
      onTap: () => _handleMenuTap(m['label'] as String),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
              color: Colors.white,
            ),
            child: Icon(m['icon'] as IconData, color: m['color'] as Color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(m['label'] as String,
              style: const TextStyle(fontSize: 11, color: Colors.black87),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  void _handleMenuTap(String label) {
    switch (label) {
      case 'My Courses':
        Navigator.push(context, PageRouteBuilder(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (_, __, ___) => const LecturerCoursesScreen(),
        ));
        break;
      case 'Attendance':
        Navigator.push(context, PageRouteBuilder(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (_, __, ___) => const LecturerAttendanceScreen(),
        ));
        break;
      case 'Advisees':
        Navigator.push(context, PageRouteBuilder(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (_, __, ___) => const LecturerAdviseesScreen(),
        ));
        break;
      case 'Announcement':
        Navigator.push(context, PageRouteBuilder(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (_, __, ___) => const AnnouncementScreen(),
        ));
        break;
      case 'Chat':
        Navigator.push(context, PageRouteBuilder(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (_, __, ___) => const ChatScreen(),
        ));
        break;
    }
  }

  Widget _buildTodayScheduleSection() {
    final homeProvider = Provider.of<HomeProvider>(context);
    final schedules = homeProvider.todaySchedule;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Today's Teaching Schedule",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (homeProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (schedules.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No classes today', style: TextStyle(color: Colors.black54)),
              ),
            )
          else
            ...schedules.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildScheduleCard(s),
            )),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(dynamic s) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4097FC), width: 1.5),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.startTime.substring(0, 5),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Text(s.endTime.substring(0, 5),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54)),
            ],
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 36, color: const Color(0xFF4097FC).withOpacity(0.3)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.courseName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4097FC),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(s.classCode,
                          style: const TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.location_on_outlined, size: 12, color: Colors.black45),
                    Text(s.room ?? '-',
                        style: const TextStyle(fontSize: 12, color: Colors.black45)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
              if (index == 1) {
                Navigator.push(context, PageRouteBuilder(
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                  pageBuilder: (_, __, ___) => const ScheduleScreen(),
                ));
              } else if (index == 2) {
                Navigator.push(context, PageRouteBuilder(
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                  pageBuilder: (_, __, ___) => const ChatScreen(),
                ));
              } else if (index == 3) {
                Navigator.push(context, PageRouteBuilder(
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                  pageBuilder: (_, __, ___) => const AnnouncementScreen(),
                ));
              } else {
                setState(() => _selectedIndex = index);
              }
            },
            child: Icon(icons[index],
                color: selected ? const Color(0xFF4097FC) : Colors.black54),
          );
        }),
      ),
    );
  }
}