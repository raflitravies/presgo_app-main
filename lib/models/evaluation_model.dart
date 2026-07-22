class EvaluationCourseModel {
  final int offeringId;
  final String courseCode;
  final String courseName;
  final String classCode;
  final List<EvaluationLecturerModel> lecturers;
  final List<EvaluationQuestionModel> questions;
  final int totalAnswered;
  final int totalRequired;

  EvaluationCourseModel({
    required this.offeringId,
    required this.courseCode,
    required this.courseName,
    required this.classCode,
    required this.lecturers,
    required this.questions,
    required this.totalAnswered,
    required this.totalRequired,
  });

  factory EvaluationCourseModel.fromJson(Map<String, dynamic> json) {
    return EvaluationCourseModel(
      offeringId: json['offeringId'],
      courseCode: json['courseCode'],
      courseName: json['courseName'],
      classCode: json['classCode'],
      lecturers: (json['lecturers'] as List)
          .map((l) => EvaluationLecturerModel.fromJson(l))
          .toList(),
      questions: (json['questions'] as List)
          .map((q) => EvaluationQuestionModel.fromJson(q))
          .toList(),
      totalAnswered: json['totalAnswered'] ?? 0,
      totalRequired: json['totalRequired'] ?? 0,
    );
  }
}

class EvaluationLecturerModel {
  final int lecturerId;
  final String lecturerName;
  final String? academicTitle;

  EvaluationLecturerModel({
    required this.lecturerId,
    required this.lecturerName,
    this.academicTitle,
  });

  factory EvaluationLecturerModel.fromJson(Map<String, dynamic> json) {
    return EvaluationLecturerModel(
      lecturerId: json['lecturerId'],
      lecturerName: json['lecturerName'],
      academicTitle: json['academicTitle'],
    );
  }
}

class EvaluationQuestionModel {
  final int id;
  final int number;
  final String text;
  final bool isComment;

  EvaluationQuestionModel({
    required this.id,
    required this.number,
    required this.text,
    required this.isComment,
  });

  factory EvaluationQuestionModel.fromJson(Map<String, dynamic> json) {
    return EvaluationQuestionModel(
      id: json['id'],
      number: json['number'],
      text: json['text'],
      isComment: json['comment'] ?? false,
    );
  }
}