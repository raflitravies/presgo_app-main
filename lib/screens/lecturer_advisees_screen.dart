import 'package:flutter/material.dart';
import '../core/network/api_client.dart';

class Advisee {
  final int? assignmentId;
  final int studentId;
  final String studentName;
  final String studentNim;
  final String? academicYear;

  Advisee({
    this.assignmentId,
    required this.studentId,
    required this.studentName,
    required this.studentNim,
    this.academicYear,
  });

  factory Advisee.fromJson(Map<String, dynamic> json) {
    final studentObj = json['student'] is Map<String, dynamic> ? json['student'] : null;

    return Advisee(
      assignmentId: json['id'],
      studentId: studentObj != null ? (studentObj['id'] ?? 0) : (json['studentId'] ?? 0),
      studentName: studentObj != null
          ? (studentObj['fullName'] ?? studentObj['name'] ?? 'Unknown Student')
          : (json['studentName'] ?? json['fullName'] ?? 'Unknown Student'),
      studentNim: studentObj != null
          ? (studentObj['nimNip'] ?? studentObj['nim'] ?? '-')
          : (json['studentNimNip'] ?? json['studentNim'] ?? json['nimNip'] ?? '-'),
      academicYear: json['academicYear'] ?? '-',
    );
  }
}

class Appointment {
  final int id;
  final int studentId;
  final String date;
  final String time;
  final String topic;
  String status; // PENDING, APPROVED, DONE, CANCELLED

  Appointment({
    required this.id,
    required this.studentId,
    required this.date,
    required this.time,
    required this.topic,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final studentObj = json['student'] is Map<String, dynamic> ? json['student'] : null;

    // Parsing gabungan ISO DateTime dari scheduledAt (contoh: "2026-07-29T15:30:00")
    String dateStr = '-';
    String timeStr = '-';

    final scheduledAt = json['scheduledAt']?.toString();
    if (scheduledAt != null && scheduledAt.contains('T')) {
      final parts = scheduledAt.split('T');
      dateStr = parts[0];
      if (parts.length > 1) {
        final timeParts = parts[1].split(':');
        if (timeParts.length >= 2) {
          timeStr = '${timeParts[0]}:${timeParts[1]}';
        }
      }
    } else {
      dateStr = json['date'] ?? json['appointmentDate'] ?? '-';
      timeStr = json['time'] ?? json['appointmentTime'] ?? '-';
    }

    return Appointment(
      id: json['id'] ?? 0,
      studentId: studentObj != null ? (studentObj['id'] ?? 0) : (json['studentId'] ?? 0),
      date: dateStr,
      time: timeStr,
      topic: json['topic'] ?? json['notes'] ?? '-',
      status: json['status'] ?? 'PENDING',
    );
  }
}

class LecturerAdviseesScreen extends StatefulWidget {
  const LecturerAdviseesScreen({Key? key}) : super(key: key);

  @override
  State<LecturerAdviseesScreen> createState() => _LecturerAdviseesScreenState();
}

class _LecturerAdviseesScreenState extends State<LecturerAdviseesScreen> {
  final ApiClient _api = ApiClient();
  bool _isLoading = true;
  List<Advisee> _advisees = [];
  List<Appointment> _allIncomingAppointments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final adviseesRes = await _api.get('/advisor/advisees');
      final List adviseesData = adviseesRes['data'] ?? [];

      final appointmentsRes = await _api.get('/advisor/appointments/incoming');
      final List appointmentsData = appointmentsRes['data'] ?? [];

      setState(() {
        _advisees = adviseesData.map((e) => Advisee.fromJson(e)).toList();
        _allIncomingAppointments = appointmentsData.map((e) => Appointment.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Failed to load data: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: bg, behavior: SnackBarBehavior.floating),
    );
  }

  int _getPendingCountForStudent(Advisee student) {
    return _allIncomingAppointments.where((app) {
      final matchesStudent = app.studentId == student.studentId ||
          (student.assignmentId != null && app.studentId == student.assignmentId);
      return matchesStudent && app.status.toUpperCase() == 'PENDING';
    }).length;
  }

  void _openStudentDetail(Advisee student) {
    final studentAppointments = _allIncomingAppointments.where((app) {
      return app.studentId == student.studentId ||
          (student.assignmentId != null && app.studentId == student.assignmentId);
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StudentAppointmentsSheet(
        student: student,
        appointments: studentAppointments,
        api: _api,
        onStatusUpdated: () => _loadData(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('My Advisees', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _advisees.isEmpty
          ? const Center(child: Text('No advisees assigned yet.', style: TextStyle(color: Colors.grey)))
          : RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _advisees.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final student = _advisees[index];
            final pendingCount = _getPendingCountForStudent(student);

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF5B9BE6),
                  child: Text(
                    student.studentName.isNotEmpty ? student.studentName[0].toUpperCase() : 'S',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(student.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: Text('NIM: ${student.studentNim}', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (pendingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$pendingCount Request',
                          style: TextStyle(color: Colors.orange.shade900, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                onTap: () => _openStudentDetail(student),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ===================================================================
// BOTTOM SHEET: DETAIL APPOINTMENT & UPDATE STATUS
// ===================================================================

class _StudentAppointmentsSheet extends StatefulWidget {
  final Advisee student;
  final List<Appointment> appointments;
  final ApiClient api;
  final VoidCallback onStatusUpdated;

  const _StudentAppointmentsSheet({
    required this.student,
    required this.appointments,
    required this.api,
    required this.onStatusUpdated,
  });

  @override
  State<_StudentAppointmentsSheet> createState() => _StudentAppointmentsSheetState();
}

class _StudentAppointmentsSheetState extends State<_StudentAppointmentsSheet> {
  late List<Appointment> _list;

  @override
  void initState() {
    super.initState();
    _list = List.from(widget.appointments);
  }

  Future<void> _updateAppointmentStatus(Appointment appointment, String newStatus) async {
    try {
      await widget.api.put(
        '/advisor/appointments/${appointment.id}/status',
        {'status': newStatus},
      );

      setState(() {
        appointment.status = newStatus;
      });

      widget.onStatusUpdated();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment status updated to $newStatus'),
          backgroundColor: newStatus == 'APPROVED' ? Colors.green : Colors.grey,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'DONE':
        return Colors.blue;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF5B9BE6),
                  child: Text(
                    widget.student.studentName.isNotEmpty ? widget.student.studentName[0].toUpperCase() : 'S',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.student.studentName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('NIM: ${widget.student.studentNim}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _list.isEmpty
                ? const Center(child: Text('No appointments found for this student.'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _list.length,
              itemBuilder: (context, index) {
                final item = _list[index];
                final isPending = item.status.toUpperCase() == 'PENDING';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 14, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text('${item.date} • ${item.time}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _getStatusColor(item.status).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.status,
                              style: TextStyle(color: _getStatusColor(item.status), fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Topic:', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      const SizedBox(height: 2),
                      Text(item.topic, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      if (isPending) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _updateAppointmentStatus(item, 'CANCELLED'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _updateAppointmentStatus(item, 'APPROVED'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4097FC),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: const Text('Approve', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}