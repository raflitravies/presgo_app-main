import 'package:flutter/material.dart';
import 'package:presgo/screens/lecturer_chat_screen.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../models/schedule_model.dart';
import 'lecturer_home_screen.dart';
import 'lecturer_announcement_screen.dart';

class LecturerScheduleScreen extends StatefulWidget {
  const LecturerScheduleScreen({Key? key}) : super(key: key);

  @override
  State<LecturerScheduleScreen> createState() => _LecturerScheduleScreenState();
}

class _LecturerScheduleScreenState extends State<LecturerScheduleScreen> {
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScheduleProvider>(context, listen: false).loadLecturerSchedule();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 💡 WARNA BACKGROUND BIRU MUDA SESUAI GAMBAR
      backgroundColor: const Color(0xFFD6F0F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomHeader(),
            Expanded(
              child: Consumer<ScheduleProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final schedules = provider.classSchedule;

                  if (schedules.isEmpty) {
                    return const Center(
                      child: Text(
                        'No teaching schedule found',
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  final Map<int, List<ScheduleModel>> grouped = {};
                  for (final s in schedules) {
                    if (s.dayOfWeek != null) {
                      grouped.putIfAbsent(s.dayOfWeek!, () => []).add(s);
                    }
                  }
                  final sortedDays = grouped.keys.toList()..sort();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: sortedDays.length,
                    itemBuilder: (context, index) {
                      final day = sortedDays[index];
                      final daySchedules = grouped[day]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index > 0) const SizedBox(height: 16),
                          // Header Hari Soft Grey Pill
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD3D3D3).withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _days[(day - 1).clamp(0, 6)],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          ...daySchedules.map((s) => _buildLecturerClassCard(s)),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCustomHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 20, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          const Text(
            'Teaching Schedule',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLecturerClassCard(ScheduleModel s) {
    final start = s.startTime.length >= 5 ? s.startTime.substring(0, 5) : s.startTime;
    final end = s.endTime.length >= 5 ? s.endTime.substring(0, 5) : s.endTime;

    // Warna border & tag sesuai tipe kelas
    final isPracticum = s.type.toLowerCase().contains('practicum');
    final borderColor = isPracticum ? const Color(0xFFF5A623) : const Color(0xFF2551E0);
    final tagBgColor = isPracticum ? const Color(0xFFF5A623) : const Color(0xFF7CA6FC);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    start,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                  Text(
                    end,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 2), // 💡 Border Kontras Berwarna
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.courseName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: tagBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        s.type,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text(
                          s.room ?? '-',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
              if (index == 0) {
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                    pageBuilder: (_, __, ___) => const LecturerHomeScreen(),
                  ),
                      (route) => false,
                );
              } else if (index == 1) {
                setState(() => _selectedIndex = 1);
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
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                    pageBuilder: (_, __, ___) => const LecturerAnnouncementScreen(),
                  ),
                );
              }
            },
            child: Icon(
              icons[index],
              color: selected ? const Color(0xFF2551E0) : Colors.black54,
            ),
          );
        }),
      ),
    );
  }
}