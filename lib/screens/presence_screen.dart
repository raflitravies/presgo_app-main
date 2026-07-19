import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ===== DATA MODEL =====

class AttendanceRecord {
  final String week;
  final String date;
  final String status; // 'Present', 'Absent', 'Excused'
  final String lecturer;

  AttendanceRecord({
    required this.week,
    required this.date,
    required this.status,
    required this.lecturer,
  });
}

class PresenceData {
  final String courseName;
  final String type;
  final int total;
  final int present;
  final int absent;
  final List<AttendanceRecord> records;

  PresenceData({
    required this.courseName,
    required this.type,
    required this.total,
    required this.present,
    required this.absent,
    required this.records,
  });
}

// ===== SCREEN =====

class PresenceScreen extends StatelessWidget {
  const PresenceScreen({Key? key}) : super(key: key);

  // Simulated dynamic data — nanti diganti dari API
  List<PresenceData> get _courses => [
    PresenceData(
      courseName: 'Atmospheric Thermodynamics',
      type: 'Class', total: 7, present: 7, absent: 0,
      records: List.generate(7, (i) => AttendanceRecord(
        week: 'Week ${i + 1}',
        date: _weekDate(i, DateTime(2024, 8, 29)),
        status: 'Present',
        lecturer: 'Gunawan Sjahriza',
      )),
    ),
    PresenceData(
      courseName: 'Electrostatic',
      type: 'Class', total: 7, present: 7, absent: 0,
      records: List.generate(7, (i) => AttendanceRecord(
        week: 'Week ${i + 1}',
        date: _weekDate(i, DateTime(2024, 8, 29)),
        status: 'Present',
        lecturer: 'Bambang Kartono',
      )),
    ),
    PresenceData(
      courseName: 'Fluid Mechanics',
      type: 'Class', total: 6, present: 5, absent: 1,
      records: List.generate(6, (i) => AttendanceRecord(
        week: 'Week ${i + 1}',
        date: _weekDate(i, DateTime(2024, 9, 5)),
        status: i == 2 ? 'Absent' : 'Present',
        lecturer: 'Hannan Radefa Putra',
      )),
    ),
    PresenceData(
      courseName: 'Human Computer Interaction',
      type: 'Class', total: 6, present: 6, absent: 0,
      records: List.generate(6, (i) => AttendanceRecord(
        week: 'Week ${i + 1}',
        date: _weekDate(i, DateTime(2024, 9, 5)),
        status: 'Present',
        lecturer: 'Dean Apriana',
      )),
    ),
    PresenceData(
      courseName: 'Integrated Practicum II',
      type: 'Class', total: 7, present: 7, absent: 0,
      records: List.generate(7, (i) => AttendanceRecord(
        week: 'Week ${i + 1}',
        date: _weekDate(i, DateTime(2024, 8, 29)),
        status: 'Present',
        lecturer: 'Clara Aurelia Setiady',
      )),
    ),
    PresenceData(
      courseName: 'Optics and Photonics',
      type: 'Class', total: 7, present: 7, absent: 0,
      records: List.generate(7, (i) => AttendanceRecord(
        week: 'Week ${i + 1}',
        date: _weekDate(i, DateTime(2024, 8, 29)),
        status: 'Present',
        lecturer: 'Bambang Kartono',
      )),
    ),
    PresenceData(
      courseName: 'Ordinary Differential Equations',
      type: 'Class', total: 7, present: 7, absent: 0,
      records: List.generate(7, (i) => AttendanceRecord(
        week: 'Week ${i + 1}',
        date: _weekDate(i, DateTime(2024, 8, 29)),
        status: 'Present',
        lecturer: 'Donny Fahrizal Anhar',
      )),
    ),
  ];

  static String _weekDate(int weekIndex, DateTime start) {
    final d = start.add(Duration(days: weekIndex * 7));
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final courses = _courses;
    final totalSessions = courses.fold<int>(0, (s, c) => s + c.total);
    final totalPresent = courses.fold<int>(0, (s, c) => s + c.present);
    final totalAbsent = courses.fold<int>(0, (s, c) => s + c.absent);
    final avgPct = totalSessions == 0 ? 0 : ((totalPresent / totalSessions) * 100).round();

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
                padding: const EdgeInsets.only(bottom: 16),
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
                          const Text('Presence',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                      child: Row(
                        children: [
                          _summaryChip(Icons.calendar_month, '$totalSessions', 'Total', Colors.blueGrey),
                          const SizedBox(width: 10),
                          _summaryChip(Icons.check_circle, '$totalPresent', 'Present', Colors.green),
                          const SizedBox(width: 10),
                          _summaryChip(Icons.cancel, '$totalAbsent', 'Absent', Colors.red),
                          const SizedBox(width: 10),
                          _summaryChip(Icons.percent, '$avgPct', 'Average', const Color(0xFF4097FC)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ===== LIST =====
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: courses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _CourseTile(
                    data: courses[index],
                    onTap: () => _showAttendanceRecap(context, courses[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryChip(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.black45)),
          ],
        ),
      ),
    );
  }

  void _showAttendanceRecap(BuildContext context, PresenceData data) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Attendance Recap',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Records list (scrollable)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                itemCount: data.records.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final rec = data.records[i];
                  final isPresent = rec.status == 'Present';
                  final isSickOrPermit = rec.status == 'Sick' || rec.status == 'Permit';
                  final color = isPresent
                      ? Colors.green
                      : isSickOrPermit
                          ? const Color(0xFFF59E0B)
                          : Colors.red;
                  final bgColor = isPresent
                      ? const Color(0xFFE8F5E9)
                      : isSickOrPermit
                          ? const Color(0xFFFFF9E6)
                          : const Color(0xFFFFEBEE);

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isPresent
                                  ? Icons.check_circle
                                  : isSickOrPermit
                                      ? Icons.sick
                                      : Icons.cancel,
                              size: 16,
                              color: color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              rec.week,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Date: ${rec.date}',
                            style: const TextStyle(fontSize: 12, color: Colors.black87)),
                        Text('Status: ${rec.status}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
                        Text('Lect: ${rec.lecturer}',
                            style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== COURSE TILE =====

class _CourseTile extends StatelessWidget {
  final PresenceData data;
  final VoidCallback onTap;
  const _CourseTile({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final percentage = data.total == 0 ? 0 : ((data.present / data.total) * 100).round();
    final isWarning = percentage < 80;
    final color = isWarning ? Colors.red : const Color(0xFF4097FC);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(data.courseName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$percentage%',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: data.total == 0 ? 0 : data.present / data.total,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4097FC).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(data.type,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF4097FC), fontWeight: FontWeight.w500)),
                  ),
                  const Spacer(),
                  _stat(Icons.calendar_month, '${data.total}', Colors.blueGrey),
                  const SizedBox(width: 14),
                  _stat(Icons.check_circle, '${data.present}', Colors.green),
                  const SizedBox(width: 14),
                  _stat(Icons.cancel, '${data.absent}', Colors.red),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, size: 18, color: Colors.black26),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}
