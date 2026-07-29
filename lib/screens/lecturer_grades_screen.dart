import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../models/course_offering_model.dart';
import '../providers/lecturer_attendance_provider.dart';

class LecturerGradesScreen extends StatefulWidget {
  const LecturerGradesScreen({Key? key}) : super(key: key);

  @override
  State<LecturerGradesScreen> createState() => _LecturerGradesScreenState();
}

class _LecturerGradesScreenState extends State<LecturerGradesScreen> {
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
        title: const Text(
          'Grades Management',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
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
              return _buildCourseCard(offering);
            },
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(CourseOfferingModel offering) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LecturerGradeStudentsScreen(offering: offering),
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
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.grade, color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offering.courseName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${offering.courseCode} - ${offering.classCode}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${offering.currentEnrolled} enrolled students',
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
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
// STUDENTS LIST PER COURSE
// ===================================================================

class LecturerGradeStudentsScreen extends StatefulWidget {
  final CourseOfferingModel offering;
  const LecturerGradeStudentsScreen({Key? key, required this.offering}) : super(key: key);

  @override
  State<LecturerGradeStudentsScreen> createState() => _LecturerGradeStudentsScreenState();
}

class _LecturerGradeStudentsScreenState extends State<LecturerGradeStudentsScreen> {
  final ApiClient _api = ApiClient();
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final response = await _api.get('/enrollments/offering/${widget.offering.id}');
      setState(() {
        _students = (response['data'] as List)
            .where((e) => e['status'] == 'APPROVED')
            .map((e) => e as Map<String, dynamic>)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
          ? const Center(child: Text('No students enrolled', style: TextStyle(color: Colors.black54)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];
          return _buildStudentCard(student);
        },
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final String currentGrade = student['finalGradeLetter'] ?? '-';

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LecturerInputGradeScreen(
              offering: widget.offering,
              studentId: student['studentId'],
              studentName: student['studentName'],
              studentNimNip: student['studentNimNip'],
            ),
          ),
        );
        _loadStudents();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black.withOpacity(0.04))],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.orange.withOpacity(0.1),
              child: Text(
                (student['studentName'] as String? ?? '?')[0].toUpperCase(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.orange),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['studentName'] ?? '-',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    student['studentNimNip'] ?? '-',
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: currentGrade == '-' ? Colors.grey.shade100 : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: currentGrade == '-' ? Colors.grey.shade300 : const Color(0xFF4CAF50),
                ),
              ),
              child: Text(
                'Grade: $currentGrade',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: currentGrade == '-' ? Colors.grey : const Color(0xFF2E7D32),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit_note, color: Colors.orange, size: 22),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// INPUT GRADE SCREEN WITH DYNAMIC WEIGHT ADJUSTMENT
// ===================================================================

class LecturerInputGradeScreen extends StatefulWidget {
  final CourseOfferingModel offering;
  final int studentId;
  final String studentName;
  final String studentNimNip;

  const LecturerInputGradeScreen({
    Key? key,
    required this.offering,
    required this.studentId,
    required this.studentName,
    required this.studentNimNip,
  }) : super(key: key);

  @override
  State<LecturerInputGradeScreen> createState() => _LecturerInputGradeScreenState();
}

class _LecturerInputGradeScreenState extends State<LecturerInputGradeScreen> {
  final ApiClient _api = ApiClient();

  final List<String> _components = ['TUGAS', 'KUIS', 'UTS', 'UAS'];

  final Map<String, TextEditingController> _scoreControllers = {};
  final Map<String, TextEditingController> _weightControllers = {};

  Map<String, dynamic> _existingGrades = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final defaultWeights = {'TUGAS': '20', 'KUIS': '10', 'UTS': '35', 'UAS': '35'};

    for (final c in _components) {
      _scoreControllers[c] = TextEditingController();
      _weightControllers[c] = TextEditingController(text: defaultWeights[c] ?? '0');
    }

    _loadExistingGrades();
  }

  @override
  void dispose() {
    for (final c in _scoreControllers.values) {
      c.dispose();
    }
    for (final c in _weightControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadExistingGrades() async {
    try {
      final response = await _api.get('/grades/offering/${widget.offering.id}');
      final allGrades = (response['data'] as List? ?? []);
      final studentGrades = allGrades.where((g) => g['studentId'] == widget.studentId).toList();

      for (final grade in studentGrades) {
        final component = grade['component'] as String;
        _existingGrades[component] = grade;

        if (_scoreControllers.containsKey(component)) {
          _scoreControllers[component]!.text = '${grade['score'] ?? ''}';
        }
        if (_weightControllers.containsKey(component) && grade['weight'] != null) {
          _weightControllers[component]!.text = '${(grade['weight'] * 100).toInt()}';
        }
      }
    } catch (e) {
      // Catch error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double _getTotalWeightPercentage() {
    double total = 0.0;
    for (final c in _components) {
      total += double.tryParse(_weightControllers[c]?.text ?? '0') ?? 0.0;
    }
    return total;
  }

  double _calculateFinalScore() {
    double total = 0.0;
    for (final c in _components) {
      final score = double.tryParse(_scoreControllers[c]?.text.trim() ?? '') ?? 0.0;
      final weightPercent = double.tryParse(_weightControllers[c]?.text.trim() ?? '') ?? 0.0;
      total += score * (weightPercent / 100.0);
    }
    return total;
  }

  String _getLetterGrade(double score) {
    if (score >= 85) return 'A';
    if (score >= 80) return 'A-';
    if (score >= 75) return 'B+';
    if (score >= 70) return 'B';
    if (score >= 65) return 'B-';
    if (score >= 60) return 'C+';
    if (score >= 55) return 'C';
    if (score >= 50) return 'C-';
    if (score >= 40) return 'D';
    return 'E';
  }

  double _getGradePoint(String letter) {
    switch (letter) {
      case 'A': return 4.0;
      case 'A-': return 3.7;
      case 'B+': return 3.3;
      case 'B': return 3.0;
      case 'B-': return 2.7;
      case 'C+': return 2.3;
      case 'C': return 2.0;
      case 'C-': return 1.7;
      case 'D': return 1.0;
      default: return 0.0;
    }
  }

  Color _getGradeColor(String grade) {
    if (grade.startsWith('A')) return const Color(0xFF4CAF50);
    if (grade.startsWith('B')) return const Color(0xFF2196F3);
    if (grade.startsWith('C')) return Colors.orange;
    if (grade.startsWith('D')) return Colors.deepOrange;
    return Colors.red;
  }

  Future<void> _saveGradeComponent(String component) async {
    final totalWeight = _getTotalWeightPercentage();
    if (totalWeight != 100.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Total weight percentage must equal 100% (Current: ${totalWeight.toInt()}%)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final scoreText = _scoreControllers[component]?.text.trim() ?? '';
    final weightText = _weightControllers[component]?.text.trim() ?? '';

    if (scoreText.isEmpty) return;

    final score = double.tryParse(scoreText);
    final weightPercent = double.tryParse(weightText);

    if (score == null || score < 0 || score > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Score must be between 0-100')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final double finalScore = _calculateFinalScore();
      final String letterGrade = _getLetterGrade(finalScore);
      final double gradePoint = _getGradePoint(letterGrade);

      await _api.post('/grades/offering/${widget.offering.id}', {
        'studentId': widget.studentId,
        'component': component,
        'score': score,
        'weight': (weightPercent ?? 0.0) / 100.0,
        'finalScore': finalScore,
        'letterGrade': letterGrade,
        'gradePoint': gradePoint,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$component updated successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
      _loadExistingGrades();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final finalScore = _calculateFinalScore();
    final finalLetter = _getLetterGrade(finalScore);
    final finalPoint = _getGradePoint(finalLetter);
    final accentColor = _getGradeColor(finalLetter);
    final totalWeight = _getTotalWeightPercentage();

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
            Text(widget.studentName,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
            Text(widget.studentNimNip, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Accumulated Final Grade',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        finalScore.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        'Point: ${finalPoint.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black45),
                      ),
                    ],
                  ),
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: accentColor, width: 2),
                    ),
                    child: Text(
                      finalLetter,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: accentColor),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: totalWeight == 100.0 ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: totalWeight == 100.0 ? Colors.green.shade300 : Colors.orange.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Weight: ${totalWeight.toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: totalWeight == 100.0 ? Colors.green.shade800 : Colors.orange.shade900,
                    ),
                  ),
                  Text(
                    totalWeight == 100.0 ? 'Valid' : 'Must equal 100%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: totalWeight == 100.0 ? Colors.green.shade800 : Colors.orange.shade900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            ..._components.map((component) => _buildGradeInput(component)),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeInput(String component) {
    final existing = _existingGrades[component];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black.withOpacity(0.04))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                component,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              if (existing != null)
                Text(
                  'Saved: ${existing['score']}',
                  style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 70,
                child: TextField(
                  controller: _weightControllers[component],
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Weight',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    suffixText: '%',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _scoreControllers[component],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Score',
                    hintText: '0 - 100',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    suffixText: '/100',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSaving ? null : () => _saveGradeComponent(component),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4097FC),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                child: _isSaving
                    ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}