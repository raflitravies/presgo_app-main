class AdvisorAssignmentModel {
  final int id;
  final int studentId;
  final String studentName;
  final String studentNimNip;
  final int advisorId;
  final String advisorName;
  final String academicYear;

  AdvisorAssignmentModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentNimNip,
    required this.advisorId,
    required this.advisorName,
    required this.academicYear,
  });

  factory AdvisorAssignmentModel.fromJson(Map<String, dynamic> json) {
    return AdvisorAssignmentModel(
      id: json['id'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      studentNimNip: json['studentNimNip'],
      advisorId: json['advisorId'],
      advisorName: json['advisorName'],
      academicYear: json['academicYear'],
    );
  }
}

class AppointmentModel {
  final int id;
  final int studentId;
  final String studentName;
  final int advisorId;
  final String advisorName;
  final String? scheduledAt;
  final String topic;
  final String status;
  final String? notes;

  AppointmentModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.advisorId,
    required this.advisorName,
    this.scheduledAt,
    required this.topic,
    required this.status,
    this.notes,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      advisorId: json['advisorId'],
      advisorName: json['advisorName'],
      scheduledAt: json['scheduledAt'],
      topic: json['topic'],
      status: json['status'],
      notes: json['notes'],
    );
  }
}