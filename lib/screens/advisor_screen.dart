import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ===== DATA MODELS =====

enum ConsultationStatus { pending, approved, rejected }

class ConsultationLog {
  final String id;
  final String title;
  final DateTime date;
  final String semesterCode;
  final String? notes;
  ConsultationStatus status;

  ConsultationLog({
    required this.id,
    required this.title,
    required this.date,
    required this.semesterCode,
    this.notes,
    this.status = ConsultationStatus.pending,
  });
}

class AdvisorData {
  final String name;
  final String title;
  final String email;
  final String room;

  AdvisorData({
    required this.name,
    required this.title,
    required this.email,
    required this.room,
  });
}

// ===== SCREEN =====

class AdvisorScreen extends StatefulWidget {
  const AdvisorScreen({Key? key}) : super(key: key);

  @override
  State<AdvisorScreen> createState() => _AdvisorScreenState();
}

class _AdvisorScreenState extends State<AdvisorScreen> {
  // Dynamic — nanti dari API berdasarkan data user
  final AdvisorData _advisor = AdvisorData(
    name: 'Setyanto Kusmaryono',
    title: 'M.Si.',
    email: 'setyanto@university.ac.id',
    room: 'FMIPA Building, Room 204',
  );

  // Nanti dari API
  final List<ConsultationLog> _logs = [
    ConsultationLog(
      id: 'C001',
      title: 'Internship recommendation discussion',
      date: DateTime(2024, 9, 15),
      semesterCode: '20225',
      notes: 'Discussed internship placement at BRIN and recommendation letter requirements.',
      status: ConsultationStatus.approved,
    ),
    ConsultationLog(
      id: 'C002',
      title: 'Taking cross major course for semester 5',
      date: DateTime(2024, 7, 30),
      semesterCode: '20225',
      notes: 'Requested approval to take statistics elective from FMIPA department.',
      status: ConsultationStatus.approved,
    ),
  ];

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Column(
          children: [
            // ===== HEADER =====
            _buildHeader(context),

            // ===== CONSULTATION LOG =====
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Row(
                        children: [
                          const Text('Consultation Log',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
                          const SizedBox(width: 10),
                          // Add button
                          GestureDetector(
                            onTap: () => _showAddLogSheet(context),
                            child: Container(
                              width: 28, height: 28,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4097FC),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 18),
                            ),
                          ),
                          const Spacer(),
                          Text('${_logs.length} logs',
                              style: const TextStyle(fontSize: 12, color: Colors.black45)),
                        ],
                      ),
                    ),

                    Expanded(
                      child: _logs.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.note_alt_outlined, size: 56, color: Colors.grey.shade300),
                                  const SizedBox(height: 12),
                                  Text('No consultation logs yet',
                                      style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                                  const SizedBox(height: 6),
                                  Text('Tap + to add a new log',
                                      style: TextStyle(color: Colors.grey.shade300, fontSize: 12)),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              itemCount: _logs.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) => _LogCard(
                                log: _logs[index],
                                formatDate: _formatDate,
                                onTap: () => _showLogDetail(context, _logs[index]),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4097FC), Color(0xFF90CAF9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('Advisor',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Avatar
            CircleAvatar(
              radius: 42,
              backgroundColor: Colors.white.withOpacity(0.3),
              child: const CircleAvatar(
                radius: 38,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 44, color: Colors.black38),
              ),
            ),

            const SizedBox(height: 10),

            // Name
            Text(_advisor.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 2),
            Text(_advisor.title,
                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8))),

            const SizedBox(height: 14),

            // Chat button
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4097FC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text('Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ===== ADD LOG SHEET =====
  void _showAddLogSheet(BuildContext context) {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    final semesterController = TextEditingController(text: '20225');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
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

              const Text('New Consultation Log',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 20),

              _inputField('Title', 'e.g. Internship recommendation discussion', titleController),
              const SizedBox(height: 14),
              _inputField('Semester Code', 'e.g. 20225', semesterController),
              const SizedBox(height: 14),
              _inputField('Notes (optional)', 'Add details about this consultation...', notesController, maxLines: 3),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: StatefulBuilder(
                  builder: (context, setLocalState) => ElevatedButton(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) return;
                      setState(() {
                        _logs.insert(0, ConsultationLog(
                          id: 'C${_logs.length + 1}',
                          title: titleController.text.trim(),
                          date: DateTime.now(),
                          semesterCode: semesterController.text.trim(),
                          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                          status: ConsultationStatus.pending,
                        ));
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4097FC),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text('Submit for Approval',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, String hint, TextEditingController ctrl, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4097FC), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  // ===== LOG DETAIL SHEET =====
  void _showLogDetail(BuildContext context, ConsultationLog log) {
    final statusColor = _statusColor(log.status);
    final statusLabel = _statusLabel(log.status);
    final statusIcon = _statusIcon(log.status);

    showModalBottomSheet(
      context: context,
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

            // Status badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 6),
                      Text(statusLabel, style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const Spacer(),
                Text(log.id, style: const TextStyle(fontSize: 12, color: Colors.black38)),
              ],
            ),

            const SizedBox(height: 14),

            Text(log.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),

            const SizedBox(height: 14),

            _detailRow(Icons.calendar_today_outlined, 'Date', _formatDate(log.date)),
            const SizedBox(height: 8),
            _detailRow(Icons.school_outlined, 'Semester', log.semesterCode),

            if (log.notes != null) ...[
              const SizedBox(height: 16),
              const Text('Notes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black54)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(log.notes!,
                    style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5)),
              ),
            ],

            const SizedBox(height: 24),

            if (log.status == ConsultationStatus.pending)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Waiting for advisor approval',
                          style: TextStyle(fontSize: 12, color: Colors.orange)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.black38),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 13, color: Colors.black45)),
        Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Color _statusColor(ConsultationStatus s) {
    switch (s) {
      case ConsultationStatus.approved: return Colors.green;
      case ConsultationStatus.pending: return Colors.orange;
      case ConsultationStatus.rejected: return Colors.red;
    }
  }

  String _statusLabel(ConsultationStatus s) {
    switch (s) {
      case ConsultationStatus.approved: return 'Approved';
      case ConsultationStatus.pending: return 'Pending';
      case ConsultationStatus.rejected: return 'Rejected';
    }
  }

  IconData _statusIcon(ConsultationStatus s) {
    switch (s) {
      case ConsultationStatus.approved: return Icons.check_circle_outline;
      case ConsultationStatus.pending: return Icons.schedule;
      case ConsultationStatus.rejected: return Icons.cancel_outlined;
    }
  }
}

// ===== LOG CARD =====

class _LogCard extends StatelessWidget {
  final ConsultationLog log;
  final String Function(DateTime) formatDate;
  final VoidCallback onTap;

  const _LogCard({required this.log, required this.formatDate, required this.onTap});

  Color get _statusColor {
    switch (log.status) {
      case ConsultationStatus.approved: return Colors.green;
      case ConsultationStatus.pending: return Colors.orange;
      case ConsultationStatus.rejected: return Colors.red;
    }
  }

  IconData get _statusIcon {
    switch (log.status) {
      case ConsultationStatus.approved: return Icons.check_circle;
      case ConsultationStatus.pending: return Icons.schedule;
      case ConsultationStatus.rejected: return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text('Date: ${formatDate(log.date)}',
                      style: const TextStyle(fontSize: 12, color: Colors.black45)),
                  Text('Semester code: ${log.semesterCode}',
                      style: const TextStyle(fontSize: 12, color: Colors.black45)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(_statusIcon, color: _statusColor, size: 22),
          ],
        ),
      ),
    );
  }
}