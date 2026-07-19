// schedule_screen.dart
import 'package:flutter/material.dart';
// Perhatikan: Kami menghapus AnnotatedRegion karena SafeArea akan menangani System UI
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/schedule_provider.dart';
import '../models/schedule_model.dart';
// Impor layar lain untuk navigasi di BottomNav
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

  // === VARIABEL UNTUK BOTTOM NAV ===
  // Index 1 adalah untuk layar Kalender/Jadwal
  int _selectedNavIndex = 1;

  @override
  void initState() {
    super.initState();
    // Logic TabController tetap sama
    _tabController = TabController(length: 2, vsync: this);

    // Logic pemuatan data tetap sama
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
    // === EDIT: GANTI WIDGET UNTUK MEWADAHI LAYOUT BARU ===
    // Menghapus AnnotatedRegion dan menggunakan Container luar untuk Scaffold
    return Container(
      color: const Color(0xFFEDEDED), // Warna latar belakang keseluruhan (samakan dengan Home)
      child: Scaffold(
        // === EDIT: JANGAN GUNAKAN APPBAR STANDAR ===
        // backgroundColor: Colors.white, // Hapus warna putih standar
        appBar: null, // Matikan AppBar standar

        // === EDIT: GUNAKAN BODY UNTUK SEMUA KONTEN, TERMASUK HEADER ===
        body: SafeArea(
          child: Column(
            children: [
              // 1. === MEMBUAT HEADER KUSTOM (MENGGANTIKAN APPBAR) ===
              _buildCustomHeader(),

              // 2. === MEMBUAT SEGMEN TAB MENU (SAMA DENGAN APPBAR.BOTTOM SEBELUMNYA) ===
              _buildTabMenuBar(),

              // 3. === BAGIAN KONTEN UTAMA (TABVIEW) ===
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

        // === 4. === EDIT: MENAMBAHKAN BOTTOM NAV PANEL ===
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // === WIDGET HEADER KUSTOM ===
  Widget _buildCustomHeader() {
    return Padding(
      // Padding serasi dengan Home
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          IconButton(
            // Gunakan ikon 'arrow_back' atau 'chevron_left'
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Class Schedule',
            style: TextStyle(
              fontSize: 22, // Ukuran serasi dengan Home
              fontWeight: FontWeight.bold, // Bold serasi dengan Home
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // === WIDGET TAB MENU BAR (DIPINDAH DARI APPBAR) ===
  Widget _buildTabMenuBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF4097FC),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black54,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        tabs: const [Tab(text: 'Class'), Tab(text: 'Exam')],
      ),
    );
  }

  // === WIDGET BOTTOM NAV PANEL (SAMA DENGAN HOME/CHAT) ===
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
              // Navigasi serasi dengan layar lain
              if (index == 0) {
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const HomeScreen()),
                      (route) => false,
                );
              } else if (index == 1) {
                // Jangan lakukan apa-apa, sudah di layar Jadwal
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

  // ===================================================================
  // WIDGET & LOGIC KONTEN JADWAL (TETAP SAMA, HANYA DIPINDAH POSISI)
  // ===================================================================

  Widget _buildClassTab(List<ScheduleModel> schedules) {
    if (schedules.isEmpty) {
      return const Center(child: Text('No class schedule found', style: TextStyle(color: Colors.black54)));
    }
    // Group by dayOfWeek
    final Map<int, List<ScheduleModel>> grouped = {};
    for (final s in schedules) {
      if (s.dayOfWeek != null) {
        grouped.putIfAbsent(s.dayOfWeek!, () => []).add(s);
      }
    }
    final sortedDays = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sortedDays.length,
      itemBuilder: (context, index) {
        final day = sortedDays[index];
        final daySchedules = grouped[day]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _days[(day - 1).clamp(0, 6)],
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54),
              ),
            ),
            ...daySchedules.map((s) => _buildClassCard(s)),
          ],
        );
      },
    );
  }

  Widget _buildExamTab(List<ScheduleModel> schedules) {
    if (schedules.isEmpty) {
      return const Center(child: Text('No exam schedule found', style: TextStyle(color: Colors.black54)));
    }
    // Group by examDate
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
                color: const Color(0xFFF0F0F0),
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
                  Text(s.startTime.substring(0, 5), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  Text(s.endTime.substring(0, 5), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
                    _buildTag(s.type, const Color(0xFF4097FC)),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(s.room ?? '-', style: const TextStyle(fontSize: 12, color: Colors.black54)),
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
                  Text(s.startTime.substring(0, 5), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  Text(s.endTime.substring(0, 5), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
                      Text(s.room ?? '-', style: const TextStyle(fontSize: 12, color: Colors.black54)),
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