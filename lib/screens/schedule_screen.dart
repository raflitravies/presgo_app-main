import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/schedule_provider.dart';
import '../models/schedule_model.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'announcement_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  int _selectedNavIndex = 1;

  // Warna Background dari Gambar Acuan
  final Color _bgColor = const Color(0xFFE2F5FA);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
      if (authProvider.isStudent) {
        scheduleProvider.loadStudentSchedule();
      } else if (authProvider.isLecturer) {
        scheduleProvider.loadLecturerSchedule();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgColor,
      child: Scaffold(
        backgroundColor: _bgColor,
        appBar: null,
        body: SafeArea(
          child: Column(
            children: [
              _buildCustomHeader(),
              _buildTabMenuBar(),
              Expanded(
                child: Consumer<ScheduleProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return TabBarView(
                      controller: _tabController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildClassTab(provider.classSchedule),
                        _buildExamTab(provider.examSchedule),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildCustomHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Text(
            'Class Schedule',
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

  Widget _buildTabMenuBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _buildCapsuleTab(index: 0, label: 'Class')),
          const SizedBox(width: 12),
          Expanded(child: _buildCapsuleTab(index: 1, label: 'Exam')),
        ],
      ),
    );
  }

  Widget _buildCapsuleTab({required int index, required String label}) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3352C4) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF3352C4) : const Color(0xFFD0D0D0),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF3352C4).withAlpha(60),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
          ),
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
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))]
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
                setState(() => _selectedNavIndex = 1);
              } else if (index == 3) {
                Navigator.pushReplacement(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const ChatScreen()));
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

  Widget _buildClassTab(List<ScheduleModel> schedules) {
    if (schedules.isEmpty) {
      return const Center(child: Text('No class schedule found', style: TextStyle(color: Colors.black54)));
    }

    final regularSchedules = schedules.where((s) => s.type == ScheduleType.CLASS || s.type == ScheduleType.PRACTICUM).toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final rescheduleSchedules = schedules.where((s) {
      final isReschedule = s.type == ScheduleType.RESCHEDULE || s.type.toString().contains('RESCHEDULE');
      if (!isReschedule) return false;

      if (s.specificDate != null && s.specificDate!.isNotEmpty) {
        final resDate = DateTime.tryParse(s.specificDate!);
        if (resDate != null) {
          final resDateOnly = DateTime(resDate.year, resDate.month, resDate.day);
          return resDateOnly.isAfter(today) || resDateOnly.isAtSameMomentAs(today);
        }
      }
      return false;
    }).toList();

    final Map<int, List<ScheduleModel>> groupedByDay = {};
    for (final s in regularSchedules) {
      if (s.dayOfWeek != null) {
        groupedByDay.putIfAbsent(s.dayOfWeek!, () => []).add(s);
      }
    }
    final sortedDays = groupedByDay.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (rescheduleSchedules.isNotEmpty) ...[
          const Text(
            'Reschedule / Replacement Classes',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          const SizedBox(height: 10),
          ...rescheduleSchedules.map((s) => _buildRescheduleCard(s)),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
        ],
        ...sortedDays.map((day) {
          final daySchedules = groupedByDay[day]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _days[(day - 1).clamp(0, 6)],
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54),
                ),
              ),
              ...daySchedules.map((s) => _buildClassCard(s)),
              const SizedBox(height: 16),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildExamTab(List<ScheduleModel> schedules) {
    if (schedules.isEmpty) {
      return const Center(child: Text('No exam schedule found', style: TextStyle(color: Colors.black54)));
    }
    final Map<String, List<ScheduleModel>> grouped = {};
    for (final s in schedules) {
      if (s.examDate != null) {
        grouped.putIfAbsent(s.examDate!, () => []).add(s);
      }
    }
    final sortedDates = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dateSchedules = grouped[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _formatDate(date),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54),
              ),
            ),
            ...dateSchedules.map((s) => _buildExamCard(s)),
          ],
        );
      },
    );
  }

  Widget _buildClassCard(ScheduleModel s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 48,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_cleanTime(s.startTime), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  Text(_cleanTime(s.endTime), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4097FC), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.courseName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    _buildTag(s.type.name, const Color(0xFF4097FC)),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(s.room.isEmpty ? '-' : s.room, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRescheduleCard(ScheduleModel s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(s.courseName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                _buildTag('RESCHEDULE', Colors.orange),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'New Date: ${_formatDate(s.specificDate ?? '')}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            if (s.originalDate != null)
              Text(
                'Replaces: ${_formatDate(s.originalDate!)}',
                style: const TextStyle(fontSize: 11, color: Colors.redAccent),
              ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.black54),
                const SizedBox(width: 4),
                Text('${_cleanTime(s.startTime)} - ${_cleanTime(s.endTime)}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(width: 12),
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.black54),
                const SizedBox(width: 4),
                Text(s.room.isEmpty ? '-' : s.room, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamCard(ScheduleModel s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 48,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_cleanTime(s.startTime), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  Text(_cleanTime(s.endTime), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.courseName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    _buildTag('Exam', Colors.red),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(s.room.isEmpty ? '-' : s.room, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
    );
  }

  String _cleanTime(String time) {
    if (time.length >= 5) {
      return time.substring(0, 5);
    }
    return time;
  }

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return '${days[d.weekday - 1]} (${months[d.month - 1]} ${d.day} ${d.year})';
    } catch (_) {
      return date;
    }
  }
}