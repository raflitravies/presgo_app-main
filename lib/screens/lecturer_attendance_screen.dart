import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lecturer_attendance_provider.dart';
import '../models/attendance_model.dart';
import '../models/course_offering_model.dart';

class LecturerAttendanceScreen extends StatefulWidget {
  const LecturerAttendanceScreen({Key? key}) : super(key: key);

  @override
  State<LecturerAttendanceScreen> createState() => _LecturerAttendanceScreenState();
}

class _LecturerAttendanceScreenState extends State<LecturerAttendanceScreen> {
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
        title: const Text('Attendance Management',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
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
              return _buildOfferingCard(offering);
            },
          );
        },
      ),
    );
  }

  Widget _buildOfferingCard(CourseOfferingModel offering) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LecturerSessionsScreen(offering: offering),
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
              child: const Icon(Icons.fact_check, color: Color(0xFF4097FC), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(offering.courseName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${offering.courseCode} - ${offering.classCode}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text('${offering.currentEnrolled} students enrolled',
                      style: const TextStyle(fontSize: 12, color: Colors.black45)),
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
// SESSIONS SCREEN
// ===================================================================

class LecturerSessionsScreen extends StatefulWidget {
  final CourseOfferingModel offering;
  const LecturerSessionsScreen({Key? key, required this.offering}) : super(key: key);

  @override
  State<LecturerSessionsScreen> createState() => _LecturerSessionsScreenState();
}

class _LecturerSessionsScreenState extends State<LecturerSessionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LecturerAttendanceProvider>(context, listen: false)
          .loadSessionsByOffering(widget.offering.id);
    });
  }

  void _showCreateSessionDialog() {
    final topicController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    int weekNumber = 1;

    final provider = Provider.of<LecturerAttendanceProvider>(context, listen: false);
    // Auto set week number
    weekNumber = provider.sessions.length + 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Open Attendance Session',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Week number
              Row(
                children: [
                  const Text('Week: ', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text('$weekNumber', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4097FC))),
                ],
              ),
              const SizedBox(height: 12),
              // Date picker
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 7)),
                    lastDate: DateTime.now().add(const Duration(days: 7)),
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
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Topic
              TextField(
                controller: topicController,
                decoration: InputDecoration(
                  labelText: 'Topic (optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            Consumer<LecturerAttendanceProvider>(
              builder: (context, prov, _) => ElevatedButton(
                onPressed: prov.isCreating
                    ? null
                    : () async {
                  Navigator.pop(ctx);
                  final dateStr =
                      '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                  final success = await prov.createSession(
                    widget.offering.id,
                    dateStr,
                    weekNumber,
                    topicController.text.trim().isEmpty
                        ? null
                        : topicController.text.trim(),
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Session opened! PIN: ${prov.sessions.first.pin}'
                          : prov.errorMessage ?? 'Failed'),
                      backgroundColor: success ? Colors.green : Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4097FC)),
                child: prov.isCreating
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Open Session', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.offering.courseName,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
            Text('${widget.offering.courseCode} - ${widget.offering.classCode}',
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateSessionDialog,
        backgroundColor: const Color(0xFF4097FC),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Open Session', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<LecturerAttendanceProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.fact_check_outlined, size: 64, color: Colors.black26),
                  SizedBox(height: 16),
                  Text('No sessions yet', style: TextStyle(color: Colors.black54)),
                  SizedBox(height: 8),
                  Text('Tap + to open a new attendance session',
                      style: TextStyle(color: Colors.black38, fontSize: 13)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: provider.sessions.length,
            itemBuilder: (context, index) {
              final session = provider.sessions[index];
              return _buildSessionCard(session);
            },
          );
        },
      ),
    );
  }

  Widget _buildSessionCard(AttendanceSessionModel session) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LecturerSessionDetailScreen(
            session: session,
            offering: widget.offering,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: session.isOpen
                ? Colors.green.withOpacity(0.5)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: session.isOpen
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${session.weekNumber}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: session.isOpen ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Week ${session.weekNumber}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  if (session.topic != null)
                    Text(session.topic!,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  Text(session.sessionDate,
                      style: const TextStyle(fontSize: 11, color: Colors.black45)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: session.isOpen
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: session.isOpen ? Colors.green : Colors.grey,
                    ),
                  ),
                  child: Text(
                    session.isOpen ? 'OPEN' : 'CLOSED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: session.isOpen ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '✓ ${session.totalPresent}  ✗ ${session.totalAbsent}',
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// SESSION DETAIL SCREEN
// ===================================================================

class LecturerSessionDetailScreen extends StatefulWidget {
  final AttendanceSessionModel session;
  final CourseOfferingModel offering;

  const LecturerSessionDetailScreen({
    Key? key,
    required this.session,
    required this.offering,
  }) : super(key: key);

  @override
  State<LecturerSessionDetailScreen> createState() =>
      _LecturerSessionDetailScreenState();
}

class _LecturerSessionDetailScreenState
    extends State<LecturerSessionDetailScreen> {
  late AttendanceSessionModel _session;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LecturerAttendanceProvider>(context, listen: false)
          .loadRecordsBySession(widget.session.id);
    });
  }

  void _showPinDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Session PIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share this PIN with your students:',
                style: TextStyle(color: Colors.black54, fontSize: 13)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF4097FC).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF4097FC)),
              ),
              child: Text(
                _session.pin ?? '-',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4097FC),
                  letterSpacing: 8,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Week', style: TextStyle(color: Colors.black45, fontSize: 12)),
            Text('${_session.weekNumber}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4097FC)),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(AttendanceRecordModel record) {
    final statuses = ['PRESENT', 'ABSENT', 'SICK', 'EXCUSED'];
    String selectedStatus = record.status;
    final noteController = TextEditingController(text: record.note ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(record.studentName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status selector
              ...statuses.map((status) => RadioListTile<String>(
                title: Text(status),
                value: status,
                groupValue: selectedStatus,
                activeColor: const Color(0xFF4097FC),
                onChanged: (v) => setDialogState(() => selectedStatus = v!),
                dense: true,
              )),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final provider = Provider.of<LecturerAttendanceProvider>(
                    context, listen: false);
                final success = await provider.updateAttendanceManual(
                  widget.session.id,
                  record.studentId,
                  selectedStatus,
                  noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Status updated!' : provider.errorMessage ?? 'Failed'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4097FC)),
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Week ${_session.weekNumber}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
            Text(widget.offering.courseName,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
        actions: [
          if (_session.isOpen)
            IconButton(
              icon: const Icon(Icons.pin, color: Color(0xFF4097FC)),
              onPressed: _showPinDialog,
              tooltip: 'Show PIN',
            ),
        ],
      ),
      body: Consumer<LecturerAttendanceProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Session info card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _session.isOpen ? const Color(0xFF4097FC) : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSessionStat('${provider.records.where((r) => r.status == 'PRESENT').length}', 'Present', Icons.check_circle),
                    _buildSessionStat('${provider.records.where((r) => r.status == 'ABSENT').length}', 'Absent', Icons.cancel),
                    _buildSessionStat('${provider.records.where((r) => r.status == 'SICK').length}', 'Sick', Icons.sick),
                    _buildSessionStat('${provider.records.length}', 'Total', Icons.people),
                  ],
                ),
              ),
              // Close session button
              if (_session.isOpen)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Close Session'),
                            content: const Text('Are you sure you want to close this attendance session?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Close Session', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          final success = await provider.closeSession(widget.session.id);
                          if (success && mounted) {
                            setState(() => _session = provider.sessions
                                .firstWhere((s) => s.id == widget.session.id,
                                orElse: () => _session));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Session closed'), backgroundColor: Colors.orange),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.lock, color: Colors.red),
                      label: const Text('Close Session', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              // Records list
              Expanded(
                child: provider.records.isEmpty
                    ? const Center(child: Text('No students found', style: TextStyle(color: Colors.black54)))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.records.length,
                  itemBuilder: (context, index) {
                    final record = provider.records[index];
                    return _buildRecordCard(record);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSessionStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
      ],
    );
  }

  Widget _buildRecordCard(AttendanceRecordModel record) {
    Color statusColor;
    IconData statusIcon;
    switch (record.status) {
      case 'PRESENT':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'SICK':
        statusColor = Colors.orange;
        statusIcon = Icons.sick;
        break;
      case 'EXCUSED':
        statusColor = Colors.blue;
        statusIcon = Icons.event_busy;
        break;
      default:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
    }

    return GestureDetector(
      onTap: () => _showUpdateStatusDialog(record),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: statusColor.withOpacity(0.1),
              child: Icon(statusIcon, color: statusColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.studentName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(record.studentNimNip,
                      style: const TextStyle(fontSize: 12, color: Colors.black45)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor),
              ),
              child: Text(record.status,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.edit_outlined, size: 16, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}