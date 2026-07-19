import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ===== DATA MODELS =====

enum PaymentStatus { paid, pending, overdue }

class TuitionPayment {
  final String semester;
  final String academicYear;
  final int amount;
  final String dueDate;
  final String? paidDate;
  final PaymentStatus status;
  final String? receiptNumber;

  TuitionPayment({
    required this.semester,
    required this.academicYear,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.receiptNumber,
  });
}

// ===== SCREEN =====

class TuitionScreen extends StatefulWidget {
  const TuitionScreen({Key? key}) : super(key: key);

  @override
  State<TuitionScreen> createState() => _TuitionScreenState();
}

class _TuitionScreenState extends State<TuitionScreen> {
  // Simulated dynamic data — nanti dari API berdasarkan user
  final List<TuitionPayment> _payments = [
    TuitionPayment(
      semester: 'Semester 5',
      academicYear: '2024/2025',
      amount: 7500000,
      dueDate: '15 Aug 2024',
      paidDate: '10 Aug 2024',
      status: PaymentStatus.paid,
      receiptNumber: 'RCP-2024-0812-005',
    ),
    TuitionPayment(
      semester: 'Semester 4',
      academicYear: '2023/2024',
      amount: 7500000,
      dueDate: '15 Feb 2024',
      paidDate: '12 Feb 2024',
      status: PaymentStatus.paid,
      receiptNumber: 'RCP-2024-0212-004',
    ),
    TuitionPayment(
      semester: 'Semester 3',
      academicYear: '2023/2024',
      amount: 7500000,
      dueDate: '15 Aug 2023',
      paidDate: '14 Aug 2023',
      status: PaymentStatus.paid,
      receiptNumber: 'RCP-2023-0814-003',
    ),
    TuitionPayment(
      semester: 'Semester 2',
      academicYear: '2022/2023',
      amount: 7000000,
      dueDate: '15 Feb 2023',
      paidDate: '11 Feb 2023',
      status: PaymentStatus.paid,
      receiptNumber: 'RCP-2023-0211-002',
    ),
    TuitionPayment(
      semester: 'Semester 1',
      academicYear: '2022/2023',
      amount: 7000000,
      dueDate: '15 Aug 2022',
      paidDate: '9 Aug 2022',
      status: PaymentStatus.paid,
      receiptNumber: 'RCP-2022-0809-001',
    ),
  ];

  String _formatCurrency(int amount) {
    // Format: Rp 7.500.000
    String str = amount.toString();
    String result = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) result = '.$result';
      result = str[i] + result;
      count++;
    }
    return 'Rp $result';
  }

  int get _totalPaid => _payments
      .where((p) => p.status == PaymentStatus.paid)
      .fold(0, (s, p) => s + p.amount);

  int get _pendingCount =>
      _payments.where((p) => p.status == PaymentStatus.pending || p.status == PaymentStatus.overdue).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            // Background gradient header
            Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF4097FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // ===== APP BAR =====
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text('Tuition',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),

                  // ===== SUMMARY CARD =====
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 20, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Paid',
                                      style: TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatCurrency(_totalPaid),
                                    style: const TextStyle(
                                        fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _pendingCount > 0
                                      ? Colors.orange.withOpacity(0.1)
                                      : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _pendingCount > 0 ? Icons.warning_amber_rounded : Icons.check_circle,
                                      size: 16,
                                      color: _pendingCount > 0 ? Colors.orange : Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _pendingCount > 0 ? '$_pendingCount Pending' : 'All Settled',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _pendingCount > 0 ? Colors.orange : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          const Divider(height: 1, color: Color(0xFFF0F0F0)),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              _statItem('Semesters', '${_payments.length}', Icons.school_outlined, const Color(0xFF4097FC)),
                              _verticalDivider(),
                              _statItem('Paid', '${_payments.where((p) => p.status == PaymentStatus.paid).length}', Icons.check_circle_outline, Colors.green),
                              _verticalDivider(),
                              _statItem('Pending', '$_pendingCount', Icons.schedule_outlined, Colors.orange),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== PAYMENT HISTORY LABEL =====
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Payment History',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
                        Text('${_payments.length} records',
                            style: const TextStyle(fontSize: 12, color: Colors.black45)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ===== LIST =====
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: _payments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) => _PaymentCard(
                        payment: _payments[index],
                        formatCurrency: _formatCurrency,
                        onTap: () => _showReceiptDetail(context, _payments[index]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45)),
        ],
      ),
    );
  }

  Widget _verticalDivider() => Container(
        width: 1, height: 40, color: const Color(0xFFF0F0F0),
      );

  void _showReceiptDetail(BuildContext context, TuitionPayment payment) {
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
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),

            // Status icon
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: _statusColor(payment.status).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_statusIcon(payment.status), color: _statusColor(payment.status), size: 32),
            ),
            const SizedBox(height: 12),

            Text(
              payment.status == PaymentStatus.paid ? 'Payment Confirmed' : 'Payment Pending',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(payment.semester,
                style: const TextStyle(fontSize: 13, color: Colors.black45)),

            const SizedBox(height: 24),

            // Receipt details
            _receiptRow('Academic Year', payment.academicYear),
            _receiptRow('Amount', _formatCurrency(payment.amount), bold: true),
            _receiptRow('Due Date', payment.dueDate),
            if (payment.paidDate != null) _receiptRow('Paid Date', payment.paidDate!),
            if (payment.receiptNumber != null) _receiptRow('Receipt No.', payment.receiptNumber!),

            const SizedBox(height: 20),

            if (payment.status == PaymentStatus.paid)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download_outlined, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Text('Download Receipt',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black45)),
          Text(value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                color: bold ? const Color(0xFF1565C0) : Colors.black87,
              )),
        ],
      ),
    );
  }

  Color _statusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid: return Colors.green;
      case PaymentStatus.pending: return Colors.orange;
      case PaymentStatus.overdue: return Colors.red;
    }
  }

  IconData _statusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid: return Icons.check_circle;
      case PaymentStatus.pending: return Icons.schedule;
      case PaymentStatus.overdue: return Icons.warning_amber_rounded;
    }
  }
}

// ===== PAYMENT CARD =====

class _PaymentCard extends StatelessWidget {
  final TuitionPayment payment;
  final String Function(int) formatCurrency;
  final VoidCallback onTap;

  const _PaymentCard({
    required this.payment,
    required this.formatCurrency,
    required this.onTap,
  });

  Color get _statusColor {
    switch (payment.status) {
      case PaymentStatus.paid: return Colors.green;
      case PaymentStatus.pending: return Colors.orange;
      case PaymentStatus.overdue: return Colors.red;
    }
  }

  String get _statusLabel {
    switch (payment.status) {
      case PaymentStatus.paid: return 'Paid';
      case PaymentStatus.pending: return 'Pending';
      case PaymentStatus.overdue: return 'Overdue';
    }
  }

  IconData get _statusIcon {
    switch (payment.status) {
      case PaymentStatus.paid: return Icons.check_circle;
      case PaymentStatus.pending: return Icons.schedule;
      case PaymentStatus.overdue: return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            // Color top accent
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_statusIcon, color: _statusColor, size: 24),
                  ),
                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(payment.semester,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(_statusLabel,
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(payment.academicYear,
                            style: const TextStyle(fontSize: 12, color: Colors.black45)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(formatCurrency(payment.amount),
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.black38),
                                const SizedBox(width: 4),
                                Text(
                                  payment.paidDate != null ? payment.paidDate! : 'Due: ${payment.dueDate}',
                                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
