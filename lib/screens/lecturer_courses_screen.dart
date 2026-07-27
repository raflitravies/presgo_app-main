import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/network/api_client.dart';
import '../providers/lecturer_attendance_provider.dart';
import '../providers/schedule_provider.dart';
import '../models/course_offering_model.dart';
import '../models/schedule_model.dart';
import '../services/schedule_service.dart';

class LecturerCoursesScreen extends StatefulWidget {
  const LecturerCoursesScreen({Key? key}) : super(key: key);

  @override
  State<LecturerCoursesScreen> createState() => _LecturerCoursesScreenState();
}

class _LecturerCoursesScreenState extends State<LecturerCoursesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LecturerAttendanceProvider>(context, listen: false).loadMyOfferings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Courses',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<LecturerAttendanceProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.offerings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.offerings.isEmpty) {
            return const Center(
              child: Text('No courses found', style: TextStyle(color: Colors.black54)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.offerings.length,
            itemBuilder: (context, index) {
              final offering = provider.offerings[index];
              return _buildCourseCard(offering);
            },
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(CourseOfferingModel offering) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LecturerCourseDetailScreen(offering: offering),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05))],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF4097FC).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu_book, color: Color(0xFF4097FC), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offering.courseName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${offering.courseCode} - ${offering.classCode}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.people_outline, size: 13, color: Colors.black45),
                      const SizedBox(width: 4),
                      Text(
                        '${offering.currentEnrolled}/${offering.maxStudents} students',
                        style: const TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.school_outlined, size: 13, color: Colors.black45),
                      const SizedBox(width: 4),
                      Text(
                        '${offering.credits} SKS',
                        style: const TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// COURSE DETAIL SCREEN
// ===================================================================

class LecturerCourseDetailScreen extends StatefulWidget {
  final CourseOfferingModel offering;
  const LecturerCourseDetailScreen({Key? key, required this.offering}) : super(key: key);

  @override
  State<LecturerCourseDetailScreen> createState() => _LecturerCourseDetailScreenState();
}

class _LecturerCourseDetailScreenState extends State<LecturerCourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScheduleService _scheduleService = ScheduleService();
  List<ScheduleModel> _schedules = [];
  bool _loadingSchedules = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSchedules();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSchedules() async {
    setState(() => _loadingSchedules = true);
    try {
      final schedules = await _scheduleService.getOfferingSchedules(widget.offering.id);
      setState(() => _schedules = schedules);
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loadingSchedules = false);
    }
  }

  void _showSetExamDialog() {
    DateTime? selectedDate;
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    final roomController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Set Exam Schedule',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date Picker
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 180)),
                    );
                    if (date != null) setDialogState(() => selectedDate = date);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
                        const SizedBox(width: 8),
                        Text(
                          selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : 'Select Exam Date',
                          style: TextStyle(
                            fontSize: 14,
                            color: selectedDate != null ? Colors.black : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Start time
                GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: ctx,
                      initialTime: const TimeOfDay(hour: 9, minute: 0),
                    );
                    if (time != null) setDialogState(() => startTime = time);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 18, color: Colors.black54),
                        const SizedBox(width: 8),
                        Text(
                          startTime != null
                              ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'
                              : 'Start Time',
                          style: TextStyle(
                            fontSize: 14,
                            color: startTime != null ? Colors.black : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // End time
                GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: ctx,
                      initialTime: const TimeOfDay(hour: 11, minute: 0),
                    );
                    if (time != null) setDialogState(() => endTime = time);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_filled, size: 18, color: Colors.black54),
                        const SizedBox(width: 8),
                        Text(
                          endTime != null
                              ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}'
                              : 'End Time',
                          style: TextStyle(
                            fontSize: 14,
                            color: endTime != null ? Colors.black : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Room
                TextField(
                  controller: roomController,
                  decoration: InputDecoration(
                    labelText: 'Room (optional)',
                    prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedDate == null || startTime == null || endTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill date and time')),
                  );
                  return;
                }

                Navigator.pop(ctx);

                try {
                  final dateStr =
                      '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
                  final startStr =
                      '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00';
                  final endStr =
                      '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00';

                  await _scheduleService.createExamSchedule(
                    widget.offering.id,
                    dateStr,
                    startStr,
                    endStr,
                    roomController.text.trim().isEmpty ? null : roomController.text.trim(),
                  );

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Exam schedule set successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadSchedules();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4097FC)),
              child: const Text('Set Exam', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final examSchedules = _schedules.where((s) => s.type == 'EXAM').toList();
    final classSchedules = _schedules.where((s) => s.type != 'EXAM').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.offering.courseName,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            Text(
              '${widget.offering.courseCode} - ${widget.offering.classCode}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _showSetExamDialog,
            icon: const Icon(Icons.add, size: 16, color: Color(0xFF4097FC)),
            label: const Text('Set Exam', style: TextStyle(color: Color(0xFF4097FC), fontSize: 13)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [Tab(text: 'Schedule'), Tab(text: 'Students')],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Schedule
          _loadingSchedules
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (classSchedules.isNotEmpty) ...[
                  const Text('Class Schedule',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
                  const SizedBox(height: 8),
                  ...classSchedules.map((s) => _buildScheduleCard(s, isExam: false)),
                  const SizedBox(height: 16),
                ],
                if (examSchedules.isNotEmpty) ...[
                  const Text('Exam Schedule',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
                  const SizedBox(height: 8),
                  ...examSchedules.map((s) => _buildScheduleCard(s, isExam: true)),
                ],
                if (_schedules.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No schedules set yet', style: TextStyle(color: Colors.black38)),
                    ),
                  ),
              ],
            ),
          ),
          // Tab 2: Students
          _buildStudentsList(),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleModel s, {required bool isExam}) {
    final color = isExam ? Colors.red : const Color(0xFF4097FC);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(isExam ? Icons.assignment : Icons.class_, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isExam ? _formatDate(s.examDate ?? '') : (s.dayName ?? '-'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 13, color: Colors.black45),
                    const SizedBox(width: 4),
                    Text(
                      '${s.startTime.substring(0, 5)} - ${s.endTime.substring(0, 5)}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    if (s.room != null) ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.location_on_outlined, size: 13, color: Colors.black45),
                      const SizedBox(width: 4),
                      Text(s.room!, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isExam ? 'EXAM' : s.type,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
    return FutureBuilder(
      future: _loadEnrolledStudents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final students = snapshot.data as List<Map<String, dynamic>>? ?? [];

        if (students.isEmpty) {
          return const Center(
            child: Text('No students enrolled', style: TextStyle(color: Colors.black54)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF4097FC).withOpacity(0.1),
                    child: Text(
                      (student['studentName'] as String? ?? '?')[0].toUpperCase(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4097FC)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student['studentName'] ?? '-',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          student['studentNimNip'] ?? '-',
                          style: const TextStyle(fontSize: 12, color: Colors.black45),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.5)),
                    ),
                    child: const Text(
                      'ENROLLED',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.green),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _loadEnrolledStudents() async {
    try {
      final api = ApiClient();
      final response = await api.get('/enrollments/offering/${widget.offering.id}');
      return (response['data'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (e) {
      return [];
    }
  }

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return date;
    }
  }
}