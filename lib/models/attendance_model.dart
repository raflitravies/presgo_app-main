class AttendanceSessionModel {
  final int id;
  final int offeringId;
  final String courseCode;
  final String courseName;
  final String classCode;
  final String sessionDate;
  final int weekNumber;
  final String? topic;
  final String? pin;
  final String? qrToken;
  final bool isOpen;
  final int totalPresent;
  final int totalAbsent;

  AttendanceSessionModel({
    required this.id,
    required this.offeringId,
    required this.courseCode,
    required this.courseName,
    required this.classCode,
    required this.sessionDate,
    required this.weekNumber,
    this.topic,
    this.pin,
    this.qrToken,
    required this.isOpen,
    required this.totalPresent,
    required this.totalAbsent,
  });

  factory AttendanceSessionModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSessionModel(
      id: json['id'],
      offeringId: json['offeringId'],
      courseCode: json['courseCode'],
      courseName: json['courseName'],
      classCode: json['classCode'],
      sessionDate: json['sessionDate'],
      weekNumber: json['weekNumber'],
      topic: json['topic'],
      pin: json['pin'],
      qrToken: json['qrToken'],
      isOpen: json['open'] ?? false,
      totalPresent: json['totalPresent'] ?? 0,
      totalAbsent: json['totalAbsent'] ?? 0,
    );
  }
}

class AttendanceSummaryModel {
  final int offeringId;
  final String courseCode;
  final String courseName;
  final String classCode;
  final int totalSessions;
  final int totalPresent;
  final int totalAbsent;
  final int totalExcused;
  final int totalSick;
  final double attendancePercentage;

  AttendanceSummaryModel({
    required this.offeringId,
    required this.courseCode,
    required this.courseName,
    required this.classCode,
    required this.totalSessions,
    required this.totalPresent,
    required this.totalAbsent,
    required this.totalExcused,
    required this.totalSick,
    required this.attendancePercentage,
  });

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryModel(
      offeringId: json['offeringId'],
      courseCode: json['courseCode'],
      courseName: json['courseName'],
      classCode: json['classCode'],
      totalSessions: json['totalSessions'] ?? 0,
      totalPresent: json['totalPresent'] ?? 0,
      totalAbsent: json['totalAbsent'] ?? 0,
      totalExcused: json['totalExcused'] ?? 0,
      totalSick: json['totalSick'] ?? 0,
      attendancePercentage: (json['attendancePercentage'] as num).toDouble(),
    );
  }
}

class AttendanceRecordModel {
  final int id;
  final int sessionId;
  final int weekNumber;
  final int studentId;
  final String studentName;
  final String studentNimNip;
  final String status;
  final String? checkedAt;
  final String? note;

  AttendanceRecordModel({
    required this.id,
    required this.sessionId,
    required this.weekNumber,
    required this.studentId,
    required this.studentName,
    required this.studentNimNip,
    required this.status,
    this.checkedAt,
    this.note,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id'],
      sessionId: json['sessionId'],
      weekNumber: json['weekNumber'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      studentNimNip: json['studentNimNip'],
      status: json['status'],
      checkedAt: json['checkedAt'],
      note: json['note'],
    );
  }
}