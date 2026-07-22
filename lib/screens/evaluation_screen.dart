import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/evaluation_provider.dart';
import '../models/evaluation_model.dart';

class EvaluationScreen extends StatefulWidget {
  const EvaluationScreen({Key? key}) : super(key: key);

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EvaluationProvider>(context, listen: false)
          .loadPendingEvaluations();
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
        title: const Text('Evaluation', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
      body: Consumer<EvaluationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.pendingEvaluations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_outline, size: 64, color: Colors.black26),
                  const SizedBox(height: 16),
                  const Text('No pending evaluations',
                      style: TextStyle(color: Colors.black54, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text(
                    'Evaluations will appear here after\nyour course reaches 16 sessions',
                    style: TextStyle(color: Colors.black38, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.pendingEvaluations.length,
            itemBuilder: (context, index) {
              final eval = provider.pendingEvaluations[index];
              return _buildEvaluationCard(eval);
            },
          );
        },
      ),
    );
  }

  Widget _buildEvaluationCard(EvaluationCourseModel eval) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EvaluationFormScreen(evaluation: eval),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05), offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_rate, color: Colors.amber, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(eval.courseName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${eval.courseCode} - ${eval.classCode}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text('${eval.lecturers.length} lecturer(s) to evaluate',
                      style: const TextStyle(fontSize: 12, color: Colors.black45)),
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
// EVALUATION FORM SCREEN
// ===================================================================

class EvaluationFormScreen extends StatefulWidget {
  final EvaluationCourseModel evaluation;
  const EvaluationFormScreen({Key? key, required this.evaluation}) : super(key: key);

  @override
  State<EvaluationFormScreen> createState() => _EvaluationFormScreenState();
}

class _EvaluationFormScreenState extends State<EvaluationFormScreen> {
  // ratings[lecturerId][questionId] = rating value
  final Map<int, Map<int, int>> _ratings = {};
  // comments[lecturerId][questionId] = comment text
  final Map<int, Map<int, String>> _comments = {};

  final List<String> _ratingLabels = ['Poor', 'Fair', 'Good', 'Excellent'];
  final List<Color> _ratingColors = [Colors.red, Colors.orange, Colors.blue, Colors.green];

  @override
  void initState() {
    super.initState();
    // Initialize maps
    for (final lecturer in widget.evaluation.lecturers) {
      _ratings[lecturer.lecturerId] = {};
      _comments[lecturer.lecturerId] = {};
    }
  }

  bool get _isComplete {
    for (final lecturer in widget.evaluation.lecturers) {
      for (final question in widget.evaluation.questions) {
        if (!question.isComment) {
          if (_ratings[lecturer.lecturerId]?[question.id] == null) return false;
        }
      }
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all rating questions'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final responses = <Map<String, dynamic>>[];

    for (final lecturer in widget.evaluation.lecturers) {
      for (final question in widget.evaluation.questions) {
        final response = <String, dynamic>{
          'lecturerId': lecturer.lecturerId,
          'questionId': question.id,
        };

        if (question.isComment) {
          response['comment'] = _comments[lecturer.lecturerId]?[question.id] ?? '';
        } else {
          response['rating'] = _ratings[lecturer.lecturerId]?[question.id];
        }

        responses.add(response);
      }
    }

    final provider = Provider.of<EvaluationProvider>(context, listen: false);
    final success = await provider.submitEvaluation(
      widget.evaluation.offeringId,
      responses,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evaluation submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to submit evaluation'),
          backgroundColor: Colors.red,
        ),
      );
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
            Text(widget.evaluation.courseName,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
            Text('${widget.evaluation.courseCode} - ${widget.evaluation.classCode}',
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Untuk setiap lecturer
            ...widget.evaluation.lecturers.map((lecturer) =>
                _buildLecturerSection(lecturer)),
            const SizedBox(height: 20),
            // Submit button
            Consumer<EvaluationProvider>(
              builder: (context, provider, _) => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: provider.isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4097FC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: provider.isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Evaluation',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLecturerSection(EvaluationLecturerModel lecturer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lecturer header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4097FC).withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF4097FC).withOpacity(0.2),
                  child: Text(
                    lecturer.lecturerName[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4097FC)),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lecturer.lecturerName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    if (lecturer.academicTitle != null && lecturer.academicTitle!.isNotEmpty)
                      Text(lecturer.academicTitle!,
                          style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ],
            ),
          ),
          // Questions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: widget.evaluation.questions.map((question) =>
                  _buildQuestionItem(lecturer, question)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(EvaluationLecturerModel lecturer, EvaluationQuestionModel question) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${question.number}. ${question.text}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          if (question.isComment)
            TextField(
              maxLines: 3,
              onChanged: (value) {
                _comments[lecturer.lecturerId]?[question.id] = value;
              },
              decoration: InputDecoration(
                hintText: 'Write your comments here (optional)',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (i) {
                final rating = i + 1;
                final isSelected = _ratings[lecturer.lecturerId]?[question.id] == rating;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _ratings[lecturer.lecturerId]?[question.id] = rating;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 72,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _ratingColors[i]
                          : _ratingColors[i].withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? _ratingColors[i] : _ratingColors[i].withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : _ratingColors[i],
                          ),
                        ),
                        Text(
                          _ratingLabels[i],
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? Colors.white : _ratingColors[i],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}