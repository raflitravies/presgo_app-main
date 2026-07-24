class CourseOfferingModel {
  final int id;
  final int courseId;
  final String courseCode;
  final String courseName;
  final int credits;
  final int lecturerId;
  final String lecturerName;
  final int? assistantId;
  final String? assistantName;
  final String academicYear;
  final String semester;
  final String classCode;
  final String? room;
  final int maxStudents;
  final int currentEnrolled;
  final bool isOpen;

  CourseOfferingModel({
    required this.id,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.credits,
    required this.lecturerId,
    required this.lecturerName,
    this.assistantId,
    this.assistantName,
    required this.academicYear,
    required this.semester,
    required this.classCode,
    this.room,
    required this.maxStudents,
    required this.currentEnrolled,
    required this.isOpen,
  });

  factory CourseOfferingModel.fromJson(Map<String, dynamic> json) {
    return CourseOfferingModel(
      id: json['id'],
      courseId: json['courseId'],
      courseCode: json['courseCode'],
      courseName: json['courseName'],
      credits: json['credits'],
      lecturerId: json['lecturerId'],
      lecturerName: json['lecturerName'],
      assistantId: json['assistantId'],
      assistantName: json['assistantName'],
      academicYear: json['academicYear'],
      semester: json['semester'],
      classCode: json['classCode'],
      room: json['room'],
      maxStudents: json['maxStudents'],
      currentEnrolled: json['currentEnrolled'],
      isOpen: json['open'] ?? false,
    );
  }
}