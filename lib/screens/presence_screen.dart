import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../models/attendance_model.dart';

class PresenceScreen extends StatefulWidget {
  const PresenceScreen({Key? key}) : super(key: key);

  @override
  State<PresenceScreen> createState() => _PresenceScreenState();
}

class _PresenceScreenState extends State<PresenceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AttendanceProvider>(context, listen: false).loadMySummary();
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
        title: const Text('Presence', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.summary.isEmpty) {
            return const Center(
              child: Text('No enrolled courses found', style: TextStyle(color: Colors.black54)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.summary.length,
            itemBuilder: (context, index) {
              final s = provider.summary[index];
              return _buildCourseCard(s);
            },
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(AttendanceSummaryModel s) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CoursePresenceDetailScreen(summary: s)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.courseName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('${s.courseCode} - ${s.classCode}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
                _buildPercentageBadge(s.attendancePercentage),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: s.totalSessions > 0 ? s.totalPresent / s.totalSessions : 0,
                backgroundColor: const Color(0xFFE0E0E0),
                color: _getProgressColor(s.attendancePercentage),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(Icons.check_circle, '${s.totalPresent}', Colors.green, 'Present'),
                _buildStatItem(Icons.cancel, '${s.totalAbsent}', Colors.red, 'Absent'),
                _buildStatItem(Icons.sick, '${s.totalSick}', Colors.orange, 'Sick'),
                _buildStatItem(Icons.event_busy, '${s.totalExcused}', Colors.blue, 'Excused'),
                _buildStatItem(Icons.calendar_today, '${s.totalSessions}', Colors.grey, 'Total'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentageBadge(double percentage) {
    final color = _getProgressColor(percentage);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        '${percentage.toStringAsFixed(0)}%',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, Color color, String label) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black45)),
      ],
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}

// ===================================================================
// DETAIL SCREEN (REACTIVE REAL-TIME UPDATE)
// ===================================================================

class CoursePresenceDetailScreen extends StatefulWidget {
  final AttendanceSummaryModel summary;
  const CoursePresenceDetailScreen({Key? key, required this.summary}) : super(key: key);

  @override
  State<CoursePresenceDetailScreen> createState() => _CoursePresenceDetailScreenState();
}

class _CoursePresenceDetailScreenState extends State<CoursePresenceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AttendanceProvider>(context, listen: false);
      provider.loadMyRecordsByOffering(widget.summary.offeringId);
      provider.loadMySummary(); // Pastikan summary juga ter-fetch
    });
  }

  void _showCheckInDialog() async {
    final pinController = TextEditingController();
    final provider = Provider.of<AttendanceProvider>(context, listen: false);

    // 1. Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // 2. Fetch list sesi aktif
    final activeSessions = await provider.getActiveSessionsByOffering(widget.summary.offeringId);

    if (!mounted) return;
    Navigator.pop(context); // Close loading

    AttendanceSessionModel? selectedSession = activeSessions.isNotEmpty ? activeSessions.first : null;

    // 3. Tampilkan Dialog
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            widget.summary.courseName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (activeSessions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.red, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No open session available. Please wait for your lecturer to open attendance.',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                // Dropdown untuk milih sesi (kalau >1 sesi buka)
                DropdownButtonFormField<AttendanceSessionModel>(
                  value: selectedSession,
                  decoration: InputDecoration(
                    labelText: 'Select Session',
                    prefixIcon: const Icon(Icons.event_available, color: Color(0xFF4097FC), size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: activeSessions.map((session) {
                    return DropdownMenuItem<AttendanceSessionModel>(
                      value: session,
                      child: Text(
                        'Week ${session.weekNumber}${session.topic != null ? ' - ${session.topic}' : ''}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setDialogState(() {
                      selectedSession = val;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Enter PIN',
                    hintText: '6-digit PIN from lecturer',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    counterText: '',
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            if (activeSessions.isNotEmpty)
              Consumer<AttendanceProvider>(
                builder: (context, prov, _) => ElevatedButton(
                  onPressed: prov.isChecking
                      ? null
                      : () async {
                    if (selectedSession == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a session')),
                      );
                      return;
                    }
                    if (pinController.text.length != 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PIN must be 6 digits')),
                      );
                      return;
                    }

                    Navigator.pop(ctx);

                    final success = await prov.checkInWithPin(
                      selectedSession!.id,
                      pinController.text,
                    );

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Check-in successful! ✓'
                            : prov.errorMessage ?? 'Check-in failed'),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );

                    // Trigger re-fetch otomatis agar data real-time ter-update
                    if (success) {
                      await prov.loadMyRecordsByOffering(widget.summary.offeringId);
                      await prov.loadMySummary();
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4097FC)),
                  child: prov.isChecking
                      ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text('Present', style: TextStyle(color: Colors.white)),
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
            Text(
              widget.summary.courseName,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            Text(
              '${widget.summary.courseCode} - ${widget.summary.classCode}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 💡 AMBIL SUMMARY SECARA DINAMIS DARI PROVIDER BIAR LANGSUNG BERUBAH REAL-TIME
          final currentSummary = provider.summary.firstWhere(
                (s) => s.offeringId == widget.summary.offeringId,
            orElse: () => widget.summary,
          );

          return Column(
            children: [
              // Dynamic Header Summary Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4097FC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem('${currentSummary.totalSessions}', 'Sessions', Icons.calendar_today),
                    _buildSummaryItem('${currentSummary.totalPresent}', 'Present', Icons.check_circle),
                    _buildSummaryItem('${currentSummary.totalAbsent}', 'Absent', Icons.cancel),
                    _buildSummaryItem('${currentSummary.attendancePercentage.toStringAsFixed(0)}%', 'Rate', Icons.percent),
                  ],
                ),
              ),
              Expanded(
                child: provider.records.isEmpty
                    ? const Center(
                  child: Text('No attendance records', style: TextStyle(color: Colors.black54)),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.records.length,
                  itemBuilder: (context, index) {
                    final r = provider.records[index];
                    return _buildRecordItem(r);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCheckInDialog,
        backgroundColor: const Color(0xFF4097FC),
        icon: const Icon(Icons.fingerprint, color: Colors.white),
        label: const Text('Check In', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ],
    );
  }

  Widget _buildRecordItem(AttendanceRecordModel r) {
    Color statusColor;
    IconData statusIcon;
    switch (r.status) {
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

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Week ${r.weekNumber}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                if (r.checkedAt != null)
                  Text(
                    'Checked at: ${r.checkedAt!.length >= 16 ? r.checkedAt!.substring(11, 16) : r.checkedAt!}',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                if (r.note != null && r.note!.isNotEmpty)
                  Text(r.note!, style: const TextStyle(fontSize: 11, color: Colors.black45)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              r.status,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }
}