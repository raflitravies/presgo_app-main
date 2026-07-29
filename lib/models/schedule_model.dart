enum ScheduleType { CLASS, PRACTICUM, EXAM, RESCHEDULE }

class ScheduleModel {
  final int id;
  final int offeringId;
  final String courseCode;
  final String courseName;
  final String classCode;
  final String lecturerName;
  final ScheduleType type;
  final int? dayOfWeek;
  final String? dayName;
  final String? examDate;
  final String? specificDate;
  final String? originalDate;
  final String startTime;
  final String endTime;
  final String room;
  final int credit;

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
    this.specificDate,
    this.originalDate,
    required this.startTime,
    required this.endTime,
    required this.room,
    this.credit = 3,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    int? parsedDayOfWeek;
    final rawDay = json['dayOfWeek'] ?? json['day_of_week'] ?? json['day'];
    if (rawDay != null) {
      parsedDayOfWeek = rawDay is int ? rawDay : int.tryParse(rawDay.toString());
    }

    int parsedCredit = 3;
    final rawCredit = json['credit'] ?? json['credits'] ?? json['sks'];
    if (rawCredit != null) {
      parsedCredit = rawCredit is int
          ? rawCredit
          : int.tryParse(rawCredit.toString()) ?? 3;
    }

    return ScheduleModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      offeringId: json['offeringId'] is int
          ? json['offeringId']
          : int.parse((json['offeringId'] ?? json['offering_id'] ?? 0).toString()),
      courseCode: json['courseCode'] ?? json['course_code'] ?? '',
      courseName: json['courseName'] ?? json['course_name'] ?? json['subject'] ?? '',
      classCode: json['classCode'] ?? json['class_code'] ?? '',
      lecturerName: json['lecturerName'] ?? json['lecturer_name'] ?? json['lecturer'] ?? '',
      type: ScheduleType.values.firstWhere(
            (e) => e.name.toLowerCase() == (json['type'] ?? '').toString().toLowerCase(),
        orElse: () => ScheduleType.CLASS,
      ),
      dayOfWeek: parsedDayOfWeek,
      dayName: json['dayName'] ?? json['day_name'],
      examDate: json['examDate'] ?? json['exam_date'],
      specificDate: json['specificDate'] ?? json['specific_date'],
      originalDate: json['originalDate'] ?? json['original_date'],
      startTime: _formatTime(json['startTime'] ?? json['start_time']),
      endTime: _formatTime(json['endTime'] ?? json['end_time']),
      room: json['room'] ?? json['room_name'] ?? '',
      credit: parsedCredit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'offeringId': offeringId,
      'courseCode': courseCode,
      'courseName': courseName,
      'classCode': classCode,
      'lecturerName': lecturerName,
      'type': type.name,
      'dayOfWeek': dayOfWeek,
      'dayName': dayName,
      'examDate': examDate,
      'specificDate': specificDate,
      'originalDate': originalDate,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'credit': credit,
    };
  }

  static String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return timeStr;
  }
}