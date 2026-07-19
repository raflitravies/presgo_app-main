import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ===== DATA MODELS =====

class EvaluationQuestion {
  final int number;
  final String text;
  final bool isComment;
  EvaluationQuestion({required this.number, required this.text, this.isComment = false});
}

class LecturerEval {
  final String name;
  final String title;
  final int meetings;
  Map<int, int> ratings; // questionNumber -> star (1-4)
  Map<int, String> comments; // questionNumber -> comment text

  LecturerEval({
    required this.name,
    required this.title,
    required this.meetings,
    Map<int, int>? ratings,
    Map<int, String>? comments,
  }) : ratings = ratings ?? {}, comments = comments ?? {};
}

class CourseEval {
  final String code;
  final String name;
  final List<LecturerEval> lecturers;
  final List<EvaluationQuestion> questions;
  bool isSubmitted;

  CourseEval({
    required this.code,
    required this.name,
    required this.lecturers,
    required this.questions,
    this.isSubmitted = false,
  });

  int get totalAnswered {
    int answered = 0;
    for (final l in lecturers) {
      for (final q in questions) {
        if (q.isComment) {
          if (l.comments.containsKey(q.number)) answered++;
        } else {
          if (l.ratings.containsKey(q.number)) answered++;
        }
      }
    }
    return answered;
  }

  int get totalRequired => lecturers.length * questions.length;
  bool get isComplete => totalAnswered == totalRequired;
}

// ===== EVALUATION LIST SCREEN =====

class EvaluationScreen extends StatefulWidget {
  const EvaluationScreen({Key? key}) : super(key: key);

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  // Dynamic data — nanti dari API berdasarkan matkul yang diambil user
  final List<CourseEval> _courses = [
    CourseEval(
      code: 'FIS301',
      name: 'Atmospheric Thermodynamics',
      questions: _defaultQuestions(),
      lecturers: [
        LecturerEval(name: 'Dr. Bambang Kartono', title: 'M.Si.', meetings: 7),
        LecturerEval(name: 'Dr. Ir. Siti Rahayu', title: 'M.Sc.', meetings: 7),
      ],
    ),
    CourseEval(
      code: 'FIS302',
      name: 'Optics and Photonics',
      questions: _defaultQuestions(),
      lecturers: [
        LecturerEval(name: 'Prof. Gunawan Sjahriza', title: 'Ph.D.', meetings: 7),
      ],
    ),
    CourseEval(
      code: 'FIS303',
      name: 'Fluid Mechanics',
      questions: _defaultQuestions(),
      lecturers: [
        LecturerEval(name: 'Dr. Hannan Radefa Putra', title: 'M.T.', meetings: 6),
        LecturerEval(name: 'Donny Fahrizal Anhar', title: 'M.Si.', meetings: 6),
      ],
    ),
    CourseEval(
      code: 'FIS304',
      name: 'Human Computer Interaction',
      questions: _defaultQuestions(),
      lecturers: [
        LecturerEval(name: 'Dr. Dean Apriana', title: 'M.Kom.', meetings: 6),
      ],
      isSubmitted: true,
    ),
    CourseEval(
      code: 'FIS305',
      name: 'Ordinary Differential Equations',
      questions: _defaultQuestions(),
      lecturers: [
        LecturerEval(name: 'Clara Aurelia Setiady', title: 'M.Si.', meetings: 7),
      ],
    ),
  ];

  static List<EvaluationQuestion> _defaultQuestions() => [
    EvaluationQuestion(number: 1, text: 'The lecturer delivers course material clearly and systematically for easy understanding'),
    EvaluationQuestion(number: 2, text: 'The lecturer uses varied and interactive teaching methods (discussion, case studies, practicum, etc.)'),
    EvaluationQuestion(number: 3, text: 'The lecturer provides constructive feedback on assignments, quizzes, and exams'),
    EvaluationQuestion(number: 4, text: 'The lecturer arrives on time, acts professionally, and respects students throughout the course'),
    EvaluationQuestion(number: 5, isComment: true, text: 'Comments & Suggestions'),
  ];

  int get _submittedCount => _courses.where((c) => c.isSubmitted).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Column(
            children: [
              // ===== HEADER =====
              Container(
                color: const Color(0xFFD6E9F8),
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text('Evaluation',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                        ],
                      ),
                    ),

                    // Progress summary
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$_submittedCount/${_courses.length} Courses Evaluated',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: _courses.isEmpty ? 0 : _submittedCount / _courses.length,
                                      backgroundColor: Colors.grey.shade100,
                                      valueColor: const AlwaysStoppedAnimation(Color(0xFF4097FC)),
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${(_courses.isEmpty ? 0 : (_submittedCount / _courses.length * 100)).round()}%',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4097FC)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ===== LIST =====
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: _courses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final course = _courses[index];
                    return _CourseTile(
                      course: course,
                      onTap: course.isSubmitted
                          ? null
                          : () async {
                              await Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                  pageBuilder: (_, __, ___) => EvaluationDetailScreen(course: course),
                                ),
                              );
                              setState(() {});
                            },
                    );
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

// ===== COURSE TILE =====

class _CourseTile extends StatelessWidget {
  final CourseEval course;
  final VoidCallback? onTap;
  const _CourseTile({required this.course, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = course.isSubmitted
        ? Colors.green
        : course.isComplete
            ? const Color(0xFF4097FC)
            : Colors.orange;

    final statusLabel = course.isSubmitted
        ? 'Submitted'
        : course.isComplete
            ? 'Ready to Submit'
            : 'Incomplete';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: color, width: 4)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4097FC).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(course.code,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF4097FC), fontWeight: FontWeight.w700)),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          course.isSubmitted ? Icons.check_circle : Icons.star_outline,
                          size: 12, color: color,
                        ),
                        const SizedBox(width: 4),
                        Text(statusLabel,
                            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(course.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 13, color: Colors.black38),
                  const SizedBox(width: 4),
                  Text('${course.lecturers.length} Lecturer${course.lecturers.length > 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 12, color: Colors.black45)),
                  const SizedBox(width: 12),
                  Icon(Icons.quiz_outlined, size: 13, color: Colors.black38),
                  const SizedBox(width: 4),
                  Text('${course.questions.length} Questions',
                      style: const TextStyle(fontSize: 12, color: Colors.black45)),
                  const Spacer(),
                  if (!course.isSubmitted)
                    Text(
                      '${course.totalAnswered}/${course.totalRequired} answered',
                      style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== EVALUATION DETAIL SCREEN =====

class EvaluationDetailScreen extends StatefulWidget {
  final CourseEval course;
  const EvaluationDetailScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<EvaluationDetailScreen> createState() => _EvaluationDetailScreenState();
}

class _EvaluationDetailScreenState extends State<EvaluationDetailScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  CourseEval get course => widget.course;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage < course.questions.length - 1) {
      setState(() => _currentPage++);
      _pageController.jumpToPage(_currentPage);
    }
  }

  void _goPrev() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _pageController.jumpToPage(_currentPage);
    }
  }

  bool get _currentPageComplete {
    final q = course.questions[_currentPage];
    if (q.isComment) {
      return course.lecturers.every((l) =>
          l.comments.containsKey(q.number) && l.comments[q.number]!.trim().isNotEmpty);
    }
    return course.lecturers.every((l) => l.ratings.containsKey(q.number));
  }

  void _submit() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Submit Evaluation'),
        content: Text('Submit evaluation for ${course.name}?\nThis cannot be changed after submission.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => course.isSubmitted = true);
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to list
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4097FC),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalQ = course.questions.length;
    final answered = course.totalAnswered;
    final total = course.totalRequired;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Column(
            children: [
              // ===== HEADER =====
              Container(
                color: const Color(0xFFD6E9F8),
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(course.code,
                                    style: const TextStyle(fontSize: 11, color: Colors.black45)),
                                Text(course.name,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Progress bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                      child: Row(
                        children: [
                          Text('$answered/$total',
                              style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: total == 0 ? 0 : answered / total,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation(
                                  answered == total ? Colors.green : const Color(0xFF4097FC),
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ===== QUESTIONS PAGE VIEW =====
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  
                  itemCount: totalQ,
                  itemBuilder: (context, qIndex) {
                    final question = course.questions[qIndex];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 28, height: 28,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4097FC),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text('${qIndex + 1}',
                                          style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text('Question',
                                        style: TextStyle(fontSize: 12, color: Colors.black45)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(question.text,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.4)),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Lecturers rating or comment
                          ...course.lecturers.map((lecturer) => question.isComment
                            ? _LecturerCommentCard(
                                lecturer: lecturer,
                                question: question,
                                onChanged: (text) {
                                  setState(() => lecturer.comments[question.number] = text);
                                },
                              )
                            : _LecturerRatingCard(
                                lecturer: lecturer,
                                question: question,
                                onRated: (star) {
                                  setState(() => lecturer.ratings[question.number] = star);
                                },
                              ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ===== BOTTOM NAV =====
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))],
                ),
                child: Column(
                  children: [
                    // Page dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(course.questions.length, (i) {
                        final isDone = course.lecturers.every((l) => l.ratings.containsKey(course.questions[i].number));
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _currentPage ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isDone
                                ? Colors.green
                                : i == _currentPage
                                    ? const Color(0xFF4097FC)
                                    : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        // Previous
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _currentPage > 0 ? _goPrev : null,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: _currentPage > 0 ? Colors.grey.shade400 : Colors.grey.shade200),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text('Previous',
                                style: TextStyle(color: _currentPage > 0 ? Colors.black87 : Colors.grey.shade400)),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Next / Submit
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _currentPage < course.questions.length - 1
                                ? (_currentPageComplete ? _goNext : null)
                                : (course.isComplete ? _submit : null),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _currentPage < course.questions.length - 1
                                  ? const Color(0xFF4097FC)
                                  : Colors.green,
                              disabledBackgroundColor: Colors.grey.shade300,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            child: Text(
                              _currentPage < course.questions.length - 1 ? 'Next' : 'Submit',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== LECTURER RATING CARD =====

class _LecturerRatingCard extends StatelessWidget {
  final LecturerEval lecturer;
  final EvaluationQuestion question;
  final ValueChanged<int> onRated;

  const _LecturerRatingCard({
    required this.lecturer,
    required this.question,
    required this.onRated,
  });

  @override
  Widget build(BuildContext context) {
    final currentRating = lecturer.ratings[question.number] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lecturer info
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF4097FC).withOpacity(0.1),
                child: Text(
                  lecturer.name.split(' ').take(2).map((w) => w[0]).join(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4097FC)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lecturer.name,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87)),
                    Text(lecturer.title,
                        style: const TextStyle(fontSize: 11, color: Colors.black45)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${lecturer.meetings} Sessions',
                    style: const TextStyle(fontSize: 11, color: Colors.black45)),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Text('Your Rating:',
              style: TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),

          // Star rating row
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: currentRating > 0 ? const Color(0xFF4097FC).withOpacity(0.3) : Colors.grey.shade200,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (i) {
                final star = i + 1;
                final filled = star <= currentRating;
                return GestureDetector(
                  onTap: () => onRated(star),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 36,
                      color: filled ? const Color(0xFFFFC107) : Colors.grey.shade300,
                    ),
                  ),
                );
              }),
            ),
          ),

          // Rating label
          if (currentRating > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  ['', 'Poor', 'Fair', 'Good', 'Excellent'][currentRating],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: [Colors.transparent, Colors.red, Colors.orange, const Color(0xFF4097FC), Colors.green][currentRating],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}


// ===== LECTURER COMMENT CARD =====

class _LecturerCommentCard extends StatefulWidget {
  final LecturerEval lecturer;
  final EvaluationQuestion question;
  final ValueChanged<String> onChanged;

  const _LecturerCommentCard({
    required this.lecturer,
    required this.question,
    required this.onChanged,
  });

  @override
  State<_LecturerCommentCard> createState() => _LecturerCommentCardState();
}

class _LecturerCommentCardState extends State<_LecturerCommentCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.lecturer.comments[widget.question.number] ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lecturer info
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF4097FC).withOpacity(0.1),
                child: Text(
                  widget.lecturer.name.split(' ').take(2).map((w) => w[0]).join(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4097FC)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.lecturer.name,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87)),
                    Text(widget.lecturer.title,
                        style: const TextStyle(fontSize: 11, color: Colors.black45)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Text('Comments & Suggestions:',
              style: TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),

          // Text input
          TextField(
            controller: _controller,
            maxLines: 4,
            minLines: 3,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintText: 'Write your comments or suggestions for this lecturer...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              filled: true,
              fillColor: const Color(0xFFF5F7FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4097FC), width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),

          // Char count
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${_controller.text.trim().length} characters',
                style: const TextStyle(fontSize: 11, color: Colors.black38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}