import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'schedule_screen.dart';
import 'chat_screen.dart';
import 'announcement_screen.dart';
import 'transcript_screen.dart';
import 'profile_screen.dart';
import 'presence_screen.dart';
import 'event_screen.dart';
import 'support_screen.dart';
import 'tuition_screen.dart';
import 'assignment_screen.dart';
import 'library_screen.dart';
import 'evaluation_screen.dart';
import 'advisor_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/home_provider.dart';

class MenuItemData {
  final IconData icon;
  final String label;
  final Color color;
  MenuItemData({required this.icon, required this.label, required this.color});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _selectedDay = 3;
  int _weekOffset = 0;

  DateTime get _weekStart {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return monday.add(Duration(days: _weekOffset * 7));
  }

  List<int> get _weekDates {
    return List.generate(7, (i) => _weekStart.add(Duration(days: i)).day);
  }

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
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
                pageBuilder: (_, __, ___) => const TranscriptScreen(),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF5B9BE6),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(blurRadius: 25, offset: const Offset(0, 12), color: Colors.black.withOpacity(0.18))],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Grade Point Average", style: TextStyle(color: Colors.black87, fontSize: 12)),
                      const SizedBox(height: 8),
                      homeProvider.isLoading
                          ? const SizedBox(height: 28, width: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(12)),
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
              boxShadow: [BoxShadow(blurRadius: 25, offset: const Offset(0, 12), color: Colors.black.withOpacity(0.18))],
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
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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
        return () => Navigator.push(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const PresenceScreen()));
      case 'Events':
        return () => Navigator.push(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const EventScreen()));
      case 'Advisor':
        return () => Navigator.push(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const AdvisorScreen()));
      case 'Evaluation':
        return () => Navigator.push(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const EvaluationScreen()));
      case 'Support':
        return () => Navigator.push(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const SupportScreen()));
      case 'Tuition':
        return () => Navigator.push(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const TuitionScreen()));
      case 'Assignment':
        return () => Navigator.push(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const AssignmentScreen()));
      case 'Library':
        return () => Navigator.push(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const LibraryScreen()));
      case 'More':
        return _openAllMenus;
      default:
        return () {};
    }
  }

  Widget _buildMenuItem(MenuItemData m, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300, width: 1.5), color: Colors.white),
          child: Icon(m.icon, color: m.color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(m.label, style: const TextStyle(fontSize: 11, color: Colors.black87), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildCalendar() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: PageView.builder(
        controller: PageController(initialPage: 1),
        onPageChanged: (page) {
          final newOffset = page - 1;
          if (newOffset != _weekOffset) {
            setState(() {
              _weekOffset = newOffset;
              _selectedDay = 0;
            });
          }
        },
        itemCount: 3,
        itemBuilder: (context, page) {
          final offset = page - 1;
          final now = DateTime.now();
          final monday = now.subtract(Duration(days: now.weekday - 1));
          final weekStart = monday.add(Duration(days: offset * 7));
          final pageDates = List.generate(7, (i) => weekStart.add(Duration(days: i)).day);

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final selected = offset == _weekOffset && index == _selectedDay;
              return GestureDetector(
                onTap: () => setState(() {
                  _weekOffset = offset;
                  _selectedDay = index;
                }),
                child: SizedBox(
                  width: 40,
                  child: Column(children: [
                    Text(days[index], style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 6),
                    Container(
                      width: 32, height: 32, alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF4097FC) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "${pageDates[index]}",
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black,
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ]),
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
    final schedules = homeProvider.todaySchedule;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Schedule on today", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
              child: _buildScheduleRow(
                startTime: s.startTime.substring(0, 5),
                endTime: s.endTime.substring(0, 5),
                title: s.courseName,
                room: s.room ?? '-',
                type: s.type,
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildScheduleRow({required String startTime, required String endTime, required String title, required String room, required String type}) {
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(width: 48, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(startTime, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
          Text(endTime, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
        ])),
        Expanded(child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF4097FC), width: 1.5)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFF4097FC), borderRadius: BorderRadius.circular(20)),
              child: Text(type, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Colors.black54),
              const SizedBox(width: 4),
              Text(room, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ]),
          ]),
        )),
      ]),
    );
  }

  Widget _buildBottomNav() {
    final icons = [Icons.home, Icons.calendar_month, Icons.qr_code_scanner, Icons.chat_bubble, Icons.campaign];
    return Container(
      height: 65,
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          final selected = _selectedIndex == index;
          return GestureDetector(
            onTap: () {
              if (index == 1) Navigator.push(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const ScheduleScreen()));
              else if (index == 3) Navigator.push(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const ChatScreen()));
              else if (index == 4) Navigator.push(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const AnnouncementScreen()));
              else setState(() => _selectedIndex = index);
            },
            child: Icon(icons[index], color: selected ? const Color(0xFF4097FC) : Colors.black54),
          );
        }),
      ),
    );
  }
}

// ===================================================================
// ALL MENUS BOTTOM SHEET
// ===================================================================

class _AllMenusSheet extends StatefulWidget {
  final List<MenuItemData> favouriteMenus;
  final List<MenuItemData> moreMenus;
  final void Function(List<MenuItemData> favs, List<MenuItemData> mores) onSave;

  const _AllMenusSheet({required this.favouriteMenus, required this.moreMenus, required this.onSave});

  @override
  State<_AllMenusSheet> createState() => _AllMenusSheetState();
}

class _AllMenusSheetState extends State<_AllMenusSheet> {
  bool _isEditing = false;
  late List<MenuItemData> _favs;
  late List<MenuItemData> _mores;

  MenuItemData? _draggingItem;
  String? _draggingFrom;
  int? _draggingFromIndex;
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(children: [
        Container(margin: const EdgeInsets.only(top: 12, bottom: 4), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const SizedBox(width: 40),
            const Text('All Menus', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(width: 30, height: 30, decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle), child: const Icon(Icons.close, size: 16, color: Colors.black54)),
            ),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Favourite', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                GestureDetector(
                  onTap: () => _isEditing ? _onSave() : setState(() => _isEditing = true),
                  child: Text(_isEditing ? 'Selesai' : 'Edit', style: const TextStyle(fontSize: 14, color: Color(0xFF4097FC), fontWeight: FontWeight.w500)),
                ),
              ]),
              const SizedBox(height: 16),
              _buildDragGrid(_favs, 'fav'),
              const SizedBox(height: 24),
              const Text('More', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              _buildDragGrid(_mores, 'more'),
              const SizedBox(height: 30),
            ]),
          ),
        ),
      ]),
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
              Navigator.pop(context);
              switch (item.label) {
                case 'Presence': Navigator.push(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const PresenceScreen())); break;
                case 'Events': Navigator.push(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const EventScreen())); break;
                case 'Support': Navigator.push(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const SupportScreen())); break;
                case 'Tuition': Navigator.push(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const TuitionScreen())); break;
                case 'Assignment': Navigator.push(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const AssignmentScreen())); break;
                case 'Library': Navigator.push(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const LibraryScreen())); break;
                case 'Evaluation': Navigator.push(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const EvaluationScreen())); break;
                case 'Advisor': Navigator.push(context, PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const AdvisorScreen())); break;
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
              setState(() { _hovering = section; _hoverIndex = index; });
              return true;
            },
            onLeave: (_) => setState(() { _hovering = null; _hoverIndex = -1; }),
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
                decoration: highlight ? BoxDecoration(color: const Color(0xFF4097FC).withOpacity(0.1), borderRadius: BorderRadius.circular(12)) : null,
                child: Draggable<Map<String, dynamic>>(
                  data: {'item': item, 'from': section, 'fromIndex': index},
                  onDragStarted: () => setState(() { _draggingItem = item; _draggingFrom = section; _draggingFromIndex = index; }),
                  onDragEnd: (_) => setState(() { _draggingItem = null; _draggingFrom = null; _draggingFromIndex = null; _hovering = null; _hoverIndex = -1; }),
                  feedback: Material(color: Colors.transparent, child: SizedBox(width: itemWidth, child: Transform.scale(scale: 1.1, child: _menuItemWidget(item, editing: false, highlighted: false)))),
                  childWhenDragging: Opacity(opacity: 0.25, child: _menuItemWidget(item, editing: true, highlighted: false)),
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
    return Column(children: [
      Stack(alignment: Alignment.topRight, children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: editing ? const Color(0xFF4097FC) : Colors.grey.shade300, width: 1.5), color: Colors.white),
          child: Icon(m.icon, color: m.color, size: 24),
        ),
        if (editing) Container(width: 16, height: 16, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle), child: const Icon(Icons.drag_indicator, size: 10, color: Colors.white)),
      ]),
      const SizedBox(height: 6),
      Text(m.label, style: const TextStyle(fontSize: 11, color: Colors.black87), textAlign: TextAlign.center),
    ]);
  }
}