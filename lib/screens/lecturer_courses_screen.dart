import 'package:flutter/material.dart';

class LecturerCoursesScreen extends StatelessWidget {
  const LecturerCoursesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: const Center(child: Text('Coming soon')),
    );
  }
}