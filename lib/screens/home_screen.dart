import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/schedule_model.dart';
import '../providers/auth_provider.dart';
import '../providers/home_provider.dart';
import 'advisor_screen.dart';
import 'announcement_screen.dart';
import 'assignment_screen.dart';
import 'chat_screen.dart';
import 'evaluation_screen.dart';
import 'event_screen.dart';
import 'library_screen.dart';
import 'presence_screen.dart';
import 'profile_screen.dart';
import 'schedule_screen.dart';
import 'support_screen.dart';
import 'transcript_screen.dart';
import 'tuition_screen.dart';

class MenuItemData {
  final IconData icon;
  final String label;
  final Color color;

  MenuItemData({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  DateTime _selectedDate = DateTime.now();

  List<MenuItemData> _favouriteMenus = [
    MenuItemData(icon: Icons.check_circle_outline, label: 'Presence', color: Colors.blue),
    MenuItemData(icon: Icons.event_note, label: 'Events', color: Colors.indigo),
    MenuItemData(icon: Icons.hourglass_empty, label: 'Advisor', color: Colors.orange),
    MenuItemData(icon: Icons.star_rate, label: 'Evaluation', color: Colors.amber),
    MenuItemData(icon: Icons.support_agent, label: 'Support', color: Colors.blue),
    MenuItemData(icon: Icons.receipt_long, label: 'Tuition', color: Colors.purple),
    MenuItemData(icon: Icons.assignment, label: 'Assignment', color: Colors.green),
  ];

  List<MenuItemData> _moreMenus = [
    MenuItemData(icon: Icons.school, label: 'eCampus', color: Colors.orange),
    MenuItemData(icon: Icons.local_library, label: 'Library', color: Colors.blue),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      if (authProvider.isStudent) {
        homeProvider.loadHomeData();
      } else if (authProvider.isLecturer) {
        homeProvider.loadLecturerHomeData();
      }
    });
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => screen,
      ),
    );
  }

  void _openAllMenus() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AllMenusSheet(
        favouriteMenus: List.from(_favouriteMenus),
        moreMenus: List.from(_moreMenus),
        onSave: (favs, mores) {
          setState(() {
            _favouriteMenus = favs;
            _moreMenus = mores;
          });
        },
      ),
    );
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
                SizedBox(height: 72, child: _buildCalendar()),
                const SizedBox(height: 20),
                _buildScheduleSection(),
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
    final transcript = homeProvider.transcript;
    final isStudent = authProvider.isStudent;

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
            onTap: () => _navigateToScreen(const ProfileScreen()),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFD9D9D9),
                  child: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                      ? ClipOval(
                    child: Image.network(
                      user.photoUrl!,
                      fit: BoxFit.cover,
                      width: 56,
                      height: 56,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person, size: 28, color: Colors.black54),
                    ),
                  )
                      : const Icon(Icons.person, size: 28, color: Colors.black54),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'Loading...',
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
          child: isStudent
              ? GestureDetector(
            onTap: () => _navigateToScreen(const TranscriptScreen()),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF5B9BE6),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                    color: Colors.black.withOpacity(0.18),
                  )
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Grade Point Average", style: TextStyle(color: Colors.black87, fontSize: 12)),
                      const SizedBox(height: 8),
                      homeProvider.isLoading
                          ? const SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : Text(
                        transcript != null ? transcript.cumulativeGpa.toStringAsFixed(2) : '0.00',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 14),
                      const Text("Credits Earned", style: TextStyle(fontSize: 12, color: Colors.black87)),
                      Text(
                        transcript != null ? '${transcript.totalCredits}' : '0',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      const Text("Active Semester", style: TextStyle(fontSize: 12, color: Colors.black87)),
                      Text(
                        transcript != null ? '${transcript.semesters.length}' : '0',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          )
              : Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF5B9BE6),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                  color: Colors.black.withOpacity(0.18),
                )
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Today's Teaching Schedule", style: TextStyle(color: Colors.black87, fontSize: 12)),
                    const SizedBox(height: 4),
                    homeProvider.isLoading
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : Text(
                      '${homeProvider.todaySchedule.length} class(es) today',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    final displayed = _favouriteMenus.take(7).toList();
    final allItems = [...displayed, MenuItemData(icon: Icons.more_horiz, label: 'More', color: Colors.grey)];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF4F4F4), borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: allItems.sublist(0, 4).map((m) => _buildMenuItem(m, onTap: _menuTap(m.label))).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: allItems.sublist(4).map((m) => _buildMenuItem(m, onTap: _menuTap(m.label))).toList(),
            ),
          ],
        ),
      ),
    );
  }

  VoidCallback _menuTap(String label) {
    switch (label) {
      case 'Presence':
        return () => _navigateToScreen(const PresenceScreen());
      case 'Events':
        return () => _navigateToScreen(const EventScreen());
      case 'Advisor':
        return () => _navigateToScreen(const AdvisorScreen());
      case 'Evaluation':
        return () => _navigateToScreen(const EvaluationScreen());
      case 'Support':
        return () => _navigateToScreen(const SupportScreen());
      case 'Tuition':
        return () => _navigateToScreen(const TuitionScreen());
      case 'Assignment':
        return () => _navigateToScreen(const AssignmentScreen());
      case 'Library':
        return () => _navigateToScreen(const LibraryScreen());
      case 'More':
        return _openAllMenus;
      default:
        return () {};
    }
  }

  Widget _buildMenuItem(MenuItemData m, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
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
            child: Icon(m.icon, color: m.color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(m.label, style: const TextStyle(fontSize: 11, color: Colors.black87), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: PageView.builder(
        controller: PageController(initialPage: 1),
        itemCount: 3,
        itemBuilder: (context, page) {
          final offset = page - 1;
          final monday = now.subtract(Duration(days: now.weekday - 1));
          final weekStart = monday.add(Duration(days: offset * 7));
          final pageDates = List.generate(7, (i) => weekStart.add(Duration(days: i)));

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final currentDate = pageDates[index];

              final isSelected = currentDate.year == _selectedDate.year &&
                  currentDate.month == _selectedDate.month &&
                  currentDate.day == _selectedDate.day;

              final isToday = currentDate.year == now.year &&
                  currentDate.month == now.month &&
                  currentDate.day == now.day;

              return GestureDetector(
                onTap: () => setState(() {
                  _selectedDate = currentDate;
                }),
                child: SizedBox(
                  width: 40,
                  child: Column(
                    children: [
                      Text(days[index], style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 6),
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF4097FC) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: isToday && !isSelected
                              ? Border.all(color: const Color(0xFF4097FC), width: 1.5)
                              : null,
                        ),
                        child: Text(
                          "${currentDate.day}",
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isToday ? const Color(0xFF4097FC) : Colors.black),
                            fontSize: 13,
                            fontWeight: (isSelected || isToday) ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildScheduleSection() {
    final homeProvider = Provider.of<HomeProvider>(context);
    final allSchedules = homeProvider.todaySchedule;

    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final formattedDate = "${_selectedDate.day} ${monthNames[_selectedDate.month - 1]}";
    final titleText = "Schedule on $formattedDate";

    final selectedYear = _selectedDate.year.toString();
    final selectedMonth = _selectedDate.month.toString().padLeft(2, '0');
    final selectedDay = _selectedDate.day.toString().padLeft(2, '0');
    final formattedSelectedDateStr = "$selectedYear-$selectedMonth-$selectedDay";

    final filteredSchedules = allSchedules.where((s) {
      if (s.type == ScheduleType.EXAM && s.examDate != null && s.examDate!.isNotEmpty) {
        return s.examDate!.startsWith(formattedSelectedDateStr);
      }

      if (s.type == ScheduleType.RESCHEDULE && s.specificDate != null && s.specificDate!.isNotEmpty) {
        return s.specificDate!.startsWith(formattedSelectedDateStr);
      }

      if (s.dayOfWeek != null) {
        return s.dayOfWeek == _selectedDate.weekday;
      }

      if (s.dayName != null && s.dayName!.isNotEmpty) {
        final daysEng = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
        final daysIndo = ['senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu', 'minggu'];

        final currentDayEng = daysEng[_selectedDate.weekday - 1];
        final currentDayIndo = daysIndo[_selectedDate.weekday - 1];
        final targetDay = s.dayName!.toLowerCase();

        return targetDay == currentDayEng || targetDay == currentDayIndo;
      }

      return false;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titleText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (homeProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (filteredSchedules.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No classes today', style: TextStyle(color: Colors.black54)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredSchedules.length,
              itemBuilder: (context, index) {
                final s = filteredSchedules[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildScheduleRow(
                    startTime: s.startTime.length >= 5 ? s.startTime.substring(0, 5) : s.startTime,
                    endTime: s.endTime.length >= 5 ? s.endTime.substring(0, 5) : s.endTime,
                    title: s.courseName,
                    room: s.room.isEmpty ? '-' : s.room,
                    type: s.type,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleRow({
    required String startTime,
    required String endTime,
    required String title,
    required String room,
    required ScheduleType type,
  }) {
    final Color color;
    switch (type) {
      case ScheduleType.RESCHEDULE:
        color = Colors.orange;
        break;
      case ScheduleType.EXAM:
        color = const Color(0xFFF44336);
        break;
      case ScheduleType.PRACTICUM:
        color = Colors.teal;
        break;
      case ScheduleType.CLASS:
      default:
        color = const Color(0xFF4097FC);
        break;
    }

    final String displayType = type == ScheduleType.EXAM ? 'Exam' : type.name;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(startTime, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
                Text(endTime, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      displayType,
                      style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(room, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
          final selected = _selectedIndex == index;
          return GestureDetector(
            onTap: () {
              if (index == 1) {
                _navigateToScreen(const ScheduleScreen());
              } else if (index == 3) {
                _navigateToScreen(const ChatScreen());
              } else if (index == 4) {
                _navigateToScreen(const AnnouncementScreen());
              } else {
                setState(() => _selectedIndex = index);
              }
            },
            child: Icon(icons[index], color: selected ? const Color(0xFF4097FC) : Colors.black54),
          );
        }),
      ),
    );
  }
}

class _AllMenusSheet extends StatefulWidget {
  final List<MenuItemData> favouriteMenus;
  final List<MenuItemData> moreMenus;
  final void Function(List<MenuItemData> favs, List<MenuItemData> mores) onSave;

  const _AllMenusSheet({
    required this.favouriteMenus,
    required this.moreMenus,
    required this.onSave,
  });

  @override
  State<_AllMenusSheet> createState() => _AllMenusSheetState();
}

class _AllMenusSheetState extends State<_AllMenusSheet> {
  bool _isEditing = false;
  late List<MenuItemData> _favs;
  late List<MenuItemData> _mores;

  String? _hovering;
  int _hoverIndex = -1;

  @override
  void initState() {
    super.initState();
    _favs = List.from(widget.favouriteMenus);
    _mores = List.from(widget.moreMenus);
  }

  void _onSave() {
    setState(() => _isEditing = false);
    widget.onSave(_favs, _mores);
  }

  void _navigateToScreen(Widget screen) {
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                const Text('All Menus', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 16, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Favourite', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      GestureDetector(
                        onTap: () => _isEditing ? _onSave() : setState(() => _isEditing = true),
                        child: Text(
                          _isEditing ? 'Selesai' : 'Edit',
                          style: const TextStyle(fontSize: 14, color: Color(0xFF4097FC), fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDragGrid(_favs, 'fav'),
                  const SizedBox(height: 24),
                  const Text('More', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  _buildDragGrid(_mores, 'more'),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragGrid(List<MenuItemData> items, String section) {
    final screenWidth = MediaQuery.of(context).size.width - 40;
    final itemWidth = screenWidth / 4;

    return Wrap(
      spacing: 0,
      runSpacing: 16,
      children: List.generate(items.length, (index) {
        final item = items[index];
        final isHoverTarget = _hovering == section && _hoverIndex == index;
        final menuWidget = _menuItemWidget(item, editing: _isEditing, highlighted: isHoverTarget);

        if (!_isEditing) {
          return GestureDetector(
            onTap: () {
              switch (item.label) {
                case 'Presence':
                  _navigateToScreen(const PresenceScreen());
                  break;
                case 'Events':
                  _navigateToScreen(const EventScreen());
                  break;
                case 'Support':
                  _navigateToScreen(const SupportScreen());
                  break;
                case 'Tuition':
                  _navigateToScreen(const TuitionScreen());
                  break;
                case 'Assignment':
                  _navigateToScreen(const AssignmentScreen());
                  break;
                case 'Library':
                  _navigateToScreen(const LibraryScreen());
                  break;
                case 'Evaluation':
                  _navigateToScreen(const EvaluationScreen());
                  break;
                case 'Advisor':
                  _navigateToScreen(const AdvisorScreen());
                  break;
              }
            },
            child: SizedBox(width: itemWidth, child: menuWidget),
          );
        }

        return SizedBox(
          width: itemWidth,
          child: DragTarget<Map<String, dynamic>>(
            onWillAcceptWithDetails: (details) {
              final data = details.data;
              if (data['from'] == section && data['fromIndex'] == index) return false;
              setState(() {
                _hovering = section;
                _hoverIndex = index;
              });
              return true;
            },
            onLeave: (_) => setState(() {
              _hovering = null;
              _hoverIndex = -1;
            }),
            onAcceptWithDetails: (details) {
              final data = details.data;
              final fromSection = data['from'] as String;
              final fromIndex = data['fromIndex'] as int;
              final draggedItem = data['item'] as MenuItemData;

              setState(() {
                if (fromSection == section) {
                  final list = section == 'fav' ? _favs : _mores;
                  final temp = list[index];
                  list[index] = draggedItem;
                  list[fromIndex] = temp;
                } else {
                  final fromList = fromSection == 'fav' ? _favs : _mores;
                  final toList = section == 'fav' ? _favs : _mores;
                  final targetItem = toList[index];
                  toList[index] = draggedItem;
                  fromList[fromIndex] = targetItem;
                }
                _hovering = null;
                _hoverIndex = -1;
              });
            },
            builder: (context, candidateData, rejectedData) {
              final highlight = candidateData.isNotEmpty;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: highlight
                    ? BoxDecoration(
                  color: const Color(0xFF4097FC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                )
                    : null,
                child: Draggable<Map<String, dynamic>>(
                  data: {'item': item, 'from': section, 'fromIndex': index},
                  onDragStarted: () => setState(() {
                    _hovering = section;
                  }),
                  onDragEnd: (_) => setState(() {
                    _hovering = null;
                    _hoverIndex = -1;
                  }),
                  feedback: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: itemWidth,
                      child: Transform.scale(
                        scale: 1.1,
                        child: _menuItemWidget(item, editing: false, highlighted: false),
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.25,
                    child: _menuItemWidget(item, editing: true, highlighted: false),
                  ),
                  child: _menuItemWidget(item, editing: true, highlighted: highlight),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _menuItemWidget(MenuItemData m, {required bool editing, required bool highlighted}) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: editing ? const Color(0xFF4097FC) : Colors.grey.shade300,
                  width: 1.5,
                ),
                color: Colors.white,
              ),
              child: Icon(m.icon, color: m.color, size: 24),
            ),
            if (editing)
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                child: const Icon(Icons.drag_indicator, size: 10, color: Colors.white),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(m.label, style: const TextStyle(fontSize: 11, color: Colors.black87), textAlign: TextAlign.center),
      ],
    );
  }
}