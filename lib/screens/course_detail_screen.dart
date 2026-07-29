import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schedule_model.dart';
import '../models/attendance_model.dart';
import '../providers/attendance_provider.dart';

class CourseDetailScreen extends StatefulWidget {
  final ScheduleModel schedule;

  const CourseDetailScreen({Key? key, required this.schedule}) : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
      attendanceProvider.loadMySummary();
      attendanceProvider.loadMyRecordsByOffering(widget.schedule.offeringId);
    });
  }

  void _showRecapSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return Consumer<AttendanceProvider>(
              builder: (context, provider, _) {
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Icon(Icons.receipt_long, color: Color(0xFF3352C4)),
                          const SizedBox(width: 8),
                          Text(
                            'Attendance Recap - ${widget.schedule.courseName}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    Expanded(
                      child: provider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : provider.records.isEmpty
                          ? const Center(
                        child: Text('No attendance records found', style: TextStyle(color: Colors.black54)),
                      )
                          : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
            );
          },
        );
      },
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
      margin: const EdgeInsets.only(bottom: 10),
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

  void _showCheckInDialog(AttendanceSummaryModel currentSummary) async {
    final pinController = TextEditingController();
    final provider = Provider.of<AttendanceProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final activeSessions = await provider.getActiveSessionsByOffering(widget.schedule.offeringId);

    if (!mounted) return;
    Navigator.pop(context);

    AttendanceSessionModel? selectedSession = activeSessions.isNotEmpty ? activeSessions.first : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            widget.schedule.courseName,
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
                DropdownButtonFormField<AttendanceSessionModel>(
                  value: selectedSession,
                  decoration: InputDecoration(
                    labelText: 'Select Session',
                    prefixIcon: const Icon(Icons.event_available, color: Color(0xFF3352C4), size: 20),
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
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
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

                    if (success) {
                      await prov.loadMyRecordsByOffering(widget.schedule.offeringId);
                      await prov.loadMySummary();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3352C4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
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
    final s = widget.schedule;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFBCE6F8),
                  Color(0xFF8EC5FC),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 10),
                  _buildCourseHeaderCard(s),
                  const SizedBox(height: 20),
                  Consumer<AttendanceProvider>(
                    builder: (context, attendanceProv, _) {
                      final currentSummary = attendanceProv.summary.firstWhere(
                            (item) => item.offeringId == s.offeringId,
                        orElse: () => AttendanceSummaryModel(
                          offeringId: s.offeringId,
                          courseCode: s.courseCode,
                          courseName: s.courseName,
                          classCode: s.classCode,
                          totalSessions: 0,
                          totalPresent: 0,
                          totalAbsent: 0,
                          totalSick: 0,
                          totalExcused: 0,
                          attendancePercentage: 0.0,
                        ),
                      );

                      final percentageInt = currentSummary.attendancePercentage.toInt();

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Lecture', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Color(0xFFE0E0E0),
                                  child: Icon(Icons.person, size: 18, color: Colors.grey),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    s.lecturerName.isNotEmpty ? s.lecturerName : 'Lecturer Name',
                                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('Assistant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            const Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Color(0xFFE0E0E0),
                                  child: Icon(Icons.person, size: 18, color: Colors.grey),
                                ),
                                SizedBox(width: 10),
                                Text('N/A', style: TextStyle(fontSize: 14, color: Colors.black87)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text('Attendance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 12),

                            // KARTU PANEL REKAP KELAS (KLIKABLE)
                            GestureDetector(
                              onTap: _showRecapSheet,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(width: 50),
                                        Icon(Icons.calendar_month, size: 20, color: Colors.blueAccent),
                                        Icon(Icons.check_circle, size: 20, color: Colors.green),
                                        Icon(Icons.cancel, size: 20, color: Colors.redAccent),
                                        Text('%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        SizedBox(width: 20),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Class', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                        Text('${currentSummary.totalSessions}', style: const TextStyle(fontSize: 13)),
                                        Text('${currentSummary.totalPresent}', style: const TextStyle(fontSize: 13)),
                                        Text('${currentSummary.totalAbsent}', style: const TextStyle(fontSize: 13)),
                                        Text('$percentageInt', style: const TextStyle(fontSize: 13)),
                                        const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3352C4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                onPressed: () => _showCheckInDialog(currentSummary),
                                child: const Text(
                                  'Presence',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseHeaderCard(ScheduleModel s) {
    final classCode = s.classCode.isNotEmpty ? s.classCode : 'K1';
    final dayName = _getDayName(s.dayOfWeek);
    final timeStr = '${s.startTime} - ${s.endTime}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$classCode - ${s.courseName}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8EC5FC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      s.type.name,
                      style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.circle, size: 5, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Credits : ${s.credit}  |  $dayName ($timeStr)',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(
                    s.room.isEmpty ? '-' : s.room,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chat_outlined, size: 22, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int? dayOfWeek) {
    if (dayOfWeek == null) return 'Thursday';
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[(dayOfWeek - 1).clamp(0, 6)];
  }
}