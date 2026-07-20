import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transcript_provider.dart';
import '../models/transcript_model.dart';

class TranscriptScreen extends StatefulWidget {
  const TranscriptScreen({Key? key}) : super(key: key);

  @override
  State<TranscriptScreen> createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends State<TranscriptScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TranscriptProvider>(context, listen: false).loadTranscript();
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
        title: const Text('Transcript', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
      body: Consumer<TranscriptProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.transcript == null) {
            return const Center(
              child: Text('No transcript data', style: TextStyle(color: Colors.black54)),
            );
          }

          final transcript = provider.transcript!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // GPA Summary Card
                _buildGpaSummaryCard(transcript),
                const SizedBox(height: 16),
                // Semester list
                ...transcript.semesters.map((s) => _buildSemesterCard(s)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGpaSummaryCard(TranscriptModel transcript) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4097FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cumulative GPA', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            transcript.cumulativeGpa.toStringAsFixed(2),
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildGpaStatItem('${transcript.totalCredits}', 'Credits Earned'),
              const SizedBox(width: 32),
              _buildGpaStatItem('${transcript.semesters.length}', 'Semesters'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGpaStatItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildSemesterCard(SemesterModel semester) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05), offset: const Offset(0, 2))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${semester.semester} ${semester.academicYear}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${semester.semesterCredits} Credits',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4097FC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF4097FC)),
                ),
                child: Text(
                  'GPA ${semester.semesterGpa.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF4097FC)),
                ),
              ),
            ],
          ),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Header
            Row(
              children: const [
                Expanded(flex: 3, child: Text('Course', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54))),
                SizedBox(width: 8),
                SizedBox(width: 32, child: Text('SKS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54), textAlign: TextAlign.center)),
                SizedBox(width: 8),
                SizedBox(width: 32, child: Text('Grade', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54), textAlign: TextAlign.center)),
                SizedBox(width: 8),
                SizedBox(width: 32, child: Text('Point', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54), textAlign: TextAlign.center)),
              ],
            ),
            const SizedBox(height: 8),
            ...semester.courses.map((c) => _buildCourseRow(c)),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseRow(CourseGradeModel course) {
    final gradeColor = _getGradeColor(course.letterGrade);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.courseName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text('${course.courseCode} - ${course.classCode}', style: const TextStyle(fontSize: 11, color: Colors.black45)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text('${course.credits}', style: const TextStyle(fontSize: 13), textAlign: TextAlign.center),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: gradeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                course.letterGrade,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: gradeColor),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              course.gradePoint.toStringAsFixed(1),
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
      case 'A-':
        return Colors.green;
      case 'B+':
      case 'B':
      case 'B-':
        return Colors.blue;
      case 'C+':
      case 'C':
      case 'C-':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      default:
        return Colors.red;
    }
  }
}