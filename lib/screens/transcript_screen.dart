import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TranscriptScreen extends StatelessWidget {
  const TranscriptScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final semesters = [
      _SemesterData(
        semester: 5,
        gpa: '0.00',
        courses: [
          _CourseData('Atmospheric Thermodynamics', 3, null),
          _CourseData('Electrostatic', 3, null),
          _CourseData('Fluid Mechanics', 3, null),
          _CourseData('Human Computer Interaction', 3, null),
          _CourseData('Integrated Practicum II', 2, null),
          _CourseData('Optics and Photonics', 3, null),
          _CourseData('Ordinary Differential Equations', 3, null),
        ],
      ),
      _SemesterData(
        semester: 4,
        gpa: '4.00',
        courses: [
          _CourseData('Analog Electronics', 2, 'A'),
          _CourseData('Integrated Practicum I', 2, 'A'),
          _CourseData('Lagrange-Hamilton Mechanics', 3, 'A'),
          _CourseData('Linear Algebra', 3, 'A'),
          _CourseData('Newtonian Mechanics', 3, 'A'),
          _CourseData('Thermodynamics', 3, 'A'),
          _CourseData('Waves and Vibration', 3, 'A'),
        ],
      ),
      _SemesterData(
        semester: 3,
        gpa: '4.00',
        courses: [
          _CourseData('Biophysics', 3, 'A'),
          _CourseData('Calculus II', 3, 'A'),
          _CourseData('Mathematical Physics II', 3, 'A'),
          _CourseData('Method of Collecting Data', 3, 'A'),
          _CourseData('Physics Practicum II', 2, 'A'),
          _CourseData('Regression Analysis', 3, 'A'),
        ],
      ),
      _SemesterData(
        semester: 2,
        gpa: '4.00',
        courses: [
          _CourseData('Calculus I', 3, 'A'),
          _CourseData('Citizenship', 2, 'A'),
          _CourseData('Indonesian Languange', 2, 'A'),
          _CourseData('Mathematical Physics I', 3, 'A'),
          _CourseData('Pancasila', 2, 'A'),
          _CourseData('Physics Practicum I', 2, 'A'),
          _CourseData('Statistics', 3, 'A'),
        ],
      ),
      _SemesterData(
        semester: 1,
        gpa: '4.00',
        courses: [
          _CourseData('Biology', 3, 'A'),
          _CourseData('Chemistry', 2, 'A'),
          _CourseData('English Languange', 2, 'A'),
          _CourseData('Mathematical Logic', 3, 'A'),
          _CourseData('Physics', 3, 'A'),
          _CourseData('Religion', 2, 'A'),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFD6E9F8),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Transcript',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: semesters.length,
                  itemBuilder: (context, index) {
                    return _SemesterCard(data: semesters[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== SEMESTER CARD =====

class _SemesterCard extends StatelessWidget {
  final _SemesterData data;
  const _SemesterCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final totalCredits = data.courses.fold<int>(0, (sum, c) => sum + c.credits);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Semester ${data.semester}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black),
              ),
              Row(
                children: [
                  Text(
                    'Semester GPA: ${data.gpa}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Downloading Semester ${data.semester} transcript...'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Icon(Icons.download, size: 20, color: Color(0xFF4097FC)),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              ...data.courses.asMap().entries.map((entry) {
                final i = entry.key;
                final course = entry.value;
                final isLast = i == data.courses.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(course.name,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black)),
                          const SizedBox(height: 2),
                          Text('Credits: ${course.credits}',
                              style: const TextStyle(fontSize: 12, color: Colors.black54)),
                          const SizedBox(height: 1),
                          Row(
                            children: [
                              const Text('Grade: ', style: TextStyle(fontSize: 12, color: Colors.black54)),
                              Text(
                                course.grade ?? '-',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: course.grade != null ? const Color(0xFF2E7D32) : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      const Divider(height: 1, indent: 14, endIndent: 14, color: Color(0xFFDDDDDD)),
                  ],
                );
              }),

              // Total credits
              const Divider(height: 1, color: Color(0xFFDDDDDD)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Total credits: $totalCredits',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ===== DATA MODELS =====

class _SemesterData {
  final int semester;
  final String gpa;
  final List<_CourseData> courses;
  _SemesterData({required this.semester, required this.gpa, required this.courses});
}

class _CourseData {
  final String name;
  final int credits;
  final String? grade;
  _CourseData(this.name, this.credits, this.grade);
}
