class TranscriptModel {
  final int studentId;
  final String studentName;
  final String studentNimNip;
  final List<SemesterModel> semesters;
  final double cumulativeGpa;
  final int totalCredits;

  TranscriptModel({
    required this.studentId,
    required this.studentName,
    required this.studentNimNip,
    required this.semesters,
    required this.cumulativeGpa,
    required this.totalCredits,
  });

  factory TranscriptModel.fromJson(Map<String, dynamic> json) {
    return TranscriptModel(
      studentId: json['studentId'],
      studentName: json['studentName'],
      studentNimNip: json['studentNimNip'],
      semesters: (json['semesters'] as List)
          .map((s) => SemesterModel.fromJson(s))
          .toList(),
      cumulativeGpa: (json['cumulativeGpa'] as num).toDouble(),
      totalCredits: json['totalCredits'],
    );
  }
}

class SemesterModel {
  final String academicYear;
  final String semester;
  final List<CourseGradeModel> courses;
  final double semesterGpa;
  final int semesterCredits;

  SemesterModel({
    required this.academicYear,
    required this.semester,
    required this.courses,
    required this.semesterGpa,
    required this.semesterCredits,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      academicYear: json['academicYear'],
      semester: json['semester'],
      courses: (json['courses'] as List)
          .map((c) => CourseGradeModel.fromJson(c))
          .toList(),
      semesterGpa: (json['semesterGpa'] as num).toDouble(),
      semesterCredits: json['semesterCredits'],
    );
  }
}

class CourseGradeModel {
  final String courseCode;
  final String courseName;
  final int credits;
  final String classCode;
  final double? finalScore;
  final String letterGrade;
  final double gradePoint;

  CourseGradeModel({
    required this.courseCode,
    required this.courseName,
    required this.credits,
    required this.classCode,
    this.finalScore,
    required this.letterGrade,
    required this.gradePoint,
  });

  factory CourseGradeModel.fromJson(Map<String, dynamic> json) {
    return CourseGradeModel(
      courseCode: json['courseCode'],
      courseName: json['courseName'],
      credits: json['credits'],
      classCode: json['classCode'],
      finalScore: json['finalScore'] != null
          ? (json['finalScore'] as num).toDouble()
          : null,
      letterGrade: json['letterGrade'],
      gradePoint: (json['gradePoint'] as num).toDouble(),
    );
  }
}