import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/auth_provider.dart';
import 'providers/home_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/attendance_provider.dart';
import 'screens/splash_screen.dart';
import 'providers/transcript_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/advisor_provider.dart';
import 'providers/evaluation_provider.dart';
import 'providers/announcement_provider.dart';
import 'providers/event_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/lecturer_attendance_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const PresGOApp());
}

class PresGOApp extends StatelessWidget {
  const PresGOApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => TranscriptProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => AdvisorProvider()),
        ChangeNotifierProvider(create: (_) => EvaluationProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => LecturerAttendanceProvider()),
      ],
      child: MaterialApp(
        title: 'PresGO',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Inter',
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}