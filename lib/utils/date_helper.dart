import 'package:intl/intl.dart';

String formatDateHeader(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final messageDate = DateTime(date.year, date.month, date.day);

  if (messageDate == today) {
    return 'Hari Ini'; // Diubah dari 'Today'
  } else if (messageDate == yesterday) {
    return 'Kemarin'; // Diubah dari 'Yesterday'
  } else if (now.difference(date).inDays < 7) {
    // Kalau masih dalam minggu ini, tampilkan hari (misal: Senin)
    return DateFormat('EEEE', 'id_ID').format(date); // Ditambahkan locale Indonesia
  } else if (date.year == now.year) {
    // Kalau tahun ini sama, tampilkan '25 Jul'
    return DateFormat('d MMM', 'id_ID').format(date); // Ditambahkan locale Indonesia
  } else {
    // Kalau beda tahun, tampilkan lengkap '1 Agu 2023'
    return DateFormat('d MMM yyyy', 'id_ID').format(date); // Ditambahkan locale Indonesia
  }
}