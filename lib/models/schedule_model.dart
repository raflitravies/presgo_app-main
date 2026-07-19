class ScheduleModel {
  final int id;
  final int offeringId;
  final String courseCode;
  final String courseName;
  final String classCode;
  final String lecturerName;
  final String type;
  final int? dayOfWeek;
  final String? dayName;
  final String? examDate;
  final String startTime;
  final String endTime;
  final String? room;

  ScheduleModel({
    required this.id,
    required this.offeringId,
    required this.courseCode,
    required this.courseName,
    required this.classCode,
    required this.lecturerName,
    required this.type,
    this.dayOfWeek,
    this.dayName,
    this.examDate,
    required this.startTime,
    required this.endTime,
    this.room,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'],
      offeringId: json['offeringId'],
      courseCode: json['courseCode'],
      courseName: json['courseName'],
      classCode: json['classCode'],
      lecturerName: json['lecturerName'],
      type: json['type'],
      dayOfWeek: json['dayOfWeek'],
      dayName: json['dayName'],
      examDate: json['examDate'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      room: json['room'],
    );
  }
}