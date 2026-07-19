import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ===== DATA MODEL =====

enum AssignmentStatus { upcoming, dueSoon, overdue, submitted }

class AssignmentData {
  final String courseCode;
  final String courseName;
  final String taskTitle;
  final DateTime openedAt;
  final DateTime dueAt;
  final AssignmentStatus status;

  AssignmentData({
    required this.courseCode,
    required this.courseName,
    required this.taskTitle,
    required this.openedAt,
    required this.dueAt,
    required this.status,
  });

  int get daysUntilDue => dueAt.difference(DateTime.now()).inDays;
  int get hoursUntilDue => dueAt.difference(DateTime.now()).inHours;
  bool get isOverdue => DateTime.now().isAfter(dueAt);
}

// ===== SCREEN =====

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({Key? key}) : super(key: key);

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  String _sortBy = 'deadline'; // 'deadline' | 'course'
  String _filterStatus = 'all'; // 'all' | 'upcoming' | 'dueSoon' | 'submitted'

  // Simulated dynamic data — nanti dari API berdasarkan user
  final List<AssignmentData> _allAssignments = [
    AssignmentData(
      courseCode: 'K1',
      courseName: 'Fluid Mechanics',
      taskTitle: 'Task 5: Viscous Effect and Fluid Resistance',
      openedAt: DateTime(2024, 10, 4, 19, 0),
      dueAt: DateTime.now().add(const Duration(hours: 6)),
      status: AssignmentStatus.dueSoon,
    ),
    AssignmentData(
      courseCode: 'K2',
      courseName: 'Human Computer Interaction',
      taskTitle: 'Task 2: Figma Submission',
      openedAt: DateTime(2024, 10, 10, 20, 0),
      dueAt: DateTime.now().add(const Duration(days: 1, hours: 3)),
      status: AssignmentStatus.dueSoon,
    ),
    AssignmentData(
      courseCode: 'K3',
      courseName: 'Optics and Photonics',
      taskTitle: 'Task 3: Lab Report – Diffraction',
      openedAt: DateTime(2024, 10, 8, 10, 0),
      dueAt: DateTime.now().add(const Duration(days: 3)),
      status: AssignmentStatus.upcoming,
    ),
    AssignmentData(
      courseCode: 'K4',
      courseName: 'Atmospheric Thermodynamics',
      taskTitle: 'Task 4: Pressure Analysis Essay',
      openedAt: DateTime(2024, 10, 9, 8, 0),
      dueAt: DateTime.now().add(const Duration(days: 5)),
      status: AssignmentStatus.upcoming,
    ),
    AssignmentData(
      courseCode: 'K5',
      courseName: 'Ordinary Differential Equations',
      taskTitle: 'Task 2: Problem Set Week 6',
      openedAt: DateTime(2024, 10, 1, 10, 0),
      dueAt: DateTime.now().subtract(const Duration(days: 2)),
      status: AssignmentStatus.overdue,
    ),
    AssignmentData(
      courseCode: 'K6',
      courseName: 'Electrostatic',
      taskTitle: 'Task 1: Coulomb\'s Law Worksheet',
      openedAt: DateTime(2024, 9, 25, 9, 0),
      dueAt: DateTime.now().subtract(const Duration(days: 5)),
      status: AssignmentStatus.submitted,
    ),
  ];

  List<AssignmentData> get _filtered {
    List<AssignmentData> list = _allAssignments
        .where((a) => a.status != AssignmentStatus.overdue)
        .toList();

    // Filter
    if (_filterStatus != 'all') {
      final map = {
        'upcoming': AssignmentStatus.upcoming,
        'dueSoon': AssignmentStatus.dueSoon,
        'submitted': AssignmentStatus.submitted,
      };
      list = list.where((a) => a.status == map[_filterStatus]).toList();
    }

    // Sort
    if (_sortBy == 'deadline') {
      list.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    } else {
      list.sort((a, b) => a.courseName.compareTo(b.courseName));
    }

    return list;
  }

  Map<String, int> get _counts => {
    'all': _allAssignments.length,
    'dueSoon': _allAssignments.where((a) => a.status == AssignmentStatus.dueSoon).length,
    'upcoming': _allAssignments.where((a) => a.status == AssignmentStatus.upcoming).length,
    'overdue': _allAssignments.where((a) => a.status == AssignmentStatus.overdue).length,
    'submitted': _allAssignments.where((a) => a.status == AssignmentStatus.submitted).length,
  };

  @override
  Widget build(BuildContext context) {
    final assignments = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Column(
            children: [
              // ===== HEADER =====
              Container(
                color: const Color(0xFFD6E9F8),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text('Assignment',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                          const Spacer(),
                          // Sort button
                          GestureDetector(
                            onTap: () => _showSortSheet(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.sort, size: 16, color: Colors.black54),
                                  const SizedBox(width: 4),
                                  Text(
                                    _sortBy == 'deadline' ? 'Deadline' : 'Course',
                                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),

                    // Filter chips
                    SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        children: [
                          _filterChip('all', 'All', _counts['all']!),
                          _filterChip('dueSoon', 'Due Soon', _counts['dueSoon']!, color: Colors.orange),
                          _filterChip('upcoming', 'Upcoming', _counts['upcoming']!, color: const Color(0xFF4097FC)),
                                        _filterChip('submitted', 'Submitted', _counts['submitted']!, color: Colors.green),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ===== LIST =====
              Expanded(
                child: assignments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text('No assignments found',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: assignments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => _AssignmentCard(
                          data: assignments[index],
                          onTap: () => _showDetail(context, assignments[index]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String value, String label, int count, {Color color = Colors.grey}) {
    final selected = _filterStatus == value;
    final chipColor = value == 'all' ? const Color(0xFF4097FC) : color;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? chipColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? chipColor : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Text(label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : Colors.black54,
                )),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: selected ? Colors.white.withOpacity(0.3) : chipColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : chipColor,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Sort by', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _sortOption('deadline', 'Deadline (Nearest First)', Icons.schedule),
            _sortOption('course', 'Course Name (A–Z)', Icons.sort_by_alpha),
          ],
        ),
      ),
    );
  }

  Widget _sortOption(String value, String label, IconData icon) {
    final selected = _sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() => _sortBy = value);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4097FC).withOpacity(0.08) : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? const Color(0xFF4097FC) : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: selected ? const Color(0xFF4097FC) : Colors.black45),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? const Color(0xFF4097FC) : Colors.black87,
                )),
            const Spacer(),
            if (selected) const Icon(Icons.check, size: 18, color: Color(0xFF4097FC)),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, AssignmentData data) {
    final color = _statusColor(data.status);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),

            // Course badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4097FC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(data.courseCode,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF4097FC), fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_statusLabel(data.status),
                      style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(data.courseName,
                style: const TextStyle(fontSize: 13, color: Colors.black45)),
            const SizedBox(height: 4),
            Text(data.taskTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),

            const SizedBox(height: 20),

            // Countdown (if not submitted/overdue)
            if (data.status == AssignmentStatus.dueSoon || data.status == AssignmentStatus.upcoming)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_outlined, color: color, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _timeRemaining(data),
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),

            _detailRow(Icons.open_in_new, 'Opened', _formatDate(data.openedAt)),
            const SizedBox(height: 8),
            _detailRow(Icons.event, 'Due', _formatDate(data.dueAt), color: data.isOverdue ? Colors.red : null),

            const SizedBox(height: 24),

            if (data.status != AssignmentStatus.submitted && data.status != AssignmentStatus.overdue)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text('Submit Assignment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4097FC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              )
            else if (data.status == AssignmentStatus.submitted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Text('Submitted', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black38),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 13, color: Colors.black45)),
        Text(value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color ?? Colors.black87,
            )),
      ],
    );
  }

  String _timeRemaining(AssignmentData data) {
    final h = data.hoursUntilDue;
    if (h < 24) return 'Due in $h hour${h == 1 ? '' : 's'}';
    final d = data.daysUntilDue;
    return 'Due in $d day${d == 1 ? '' : 's'}';
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $h:$m';
  }

  Color _statusColor(AssignmentStatus s) {
    switch (s) {
      case AssignmentStatus.dueSoon: return Colors.orange;
      case AssignmentStatus.upcoming: return const Color(0xFF4097FC);
      case AssignmentStatus.overdue: return Colors.red;
      case AssignmentStatus.submitted: return Colors.green;
    }
  }

  String _statusLabel(AssignmentStatus s) {
    switch (s) {
      case AssignmentStatus.dueSoon: return 'Due Soon';
      case AssignmentStatus.upcoming: return 'Upcoming';
      case AssignmentStatus.overdue: return 'Overdue';
      case AssignmentStatus.submitted: return 'Submitted';
    }
  }
}

// ===== ASSIGNMENT CARD =====

class _AssignmentCard extends StatelessWidget {
  final AssignmentData data;
  final VoidCallback onTap;
  const _AssignmentCard({required this.data, required this.onTap});

  Color get _color {
    switch (data.status) {
      case AssignmentStatus.dueSoon: return Colors.orange;
      case AssignmentStatus.upcoming: return const Color(0xFF4097FC);
      case AssignmentStatus.overdue: return Colors.red;
      case AssignmentStatus.submitted: return Colors.green;
    }
  }

  String get _statusLabel {
    switch (data.status) {
      case AssignmentStatus.dueSoon: return 'Due Soon';
      case AssignmentStatus.upcoming: return 'Upcoming';
      case AssignmentStatus.overdue: return 'Overdue';
      case AssignmentStatus.submitted: return 'Submitted';
    }
  }

  String get _timeTag {
    if (data.status == AssignmentStatus.submitted) return 'Submitted';
    if (data.status == AssignmentStatus.overdue) return 'Overdue';
    final h = data.hoursUntilDue;
    if (h < 24) return '$h hr left';
    return '${data.daysUntilDue}d left';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: _color, width: 4)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: course code + status + time tag
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4097FC).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(data.courseCode,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF4097FC), fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 6),
                  Text(data.courseName,
                      style: const TextStyle(fontSize: 12, color: Colors.black45),
                      overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(_timeTag,
                        style: TextStyle(fontSize: 11, color: _color, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Task title
              Text(data.taskTitle,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),

              const SizedBox(height: 10),

              // Bottom row: due date + status badge
              Row(
                children: [
                  Icon(Icons.event_outlined, size: 13, color: _color),
                  const SizedBox(width: 4),
                  Text(
                    _shortDate(data.dueAt),
                    style: TextStyle(fontSize: 12, color: _color, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_statusLabel,
                        style: TextStyle(fontSize: 11, color: _color, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _shortDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $h:$m';
  }
}
