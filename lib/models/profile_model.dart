class StudentProfileModel {
  final int userId;
  final String nimNip;
  final String fullName;
  final String email;
  final String? phone;
  final String? photoUrl;
  final int facultyId;
  final String facultyName;
  final int departmentId;
  final String departmentName;
  final int batchYear;
  final int currentSemester;
  final String academicStatus;

  StudentProfileModel({
    required this.userId,
    required this.nimNip,
    required this.fullName,
    required this.email,
    this.phone,
    this.photoUrl,
    required this.facultyId,
    required this.facultyName,
    required this.departmentId,
    required this.departmentName,
    required this.batchYear,
    required this.currentSemester,
    required this.academicStatus,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      userId: json['userId'],
      nimNip: json['nimNip'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      photoUrl: json['photoUrl'],
      facultyId: json['facultyId'],
      facultyName: json['facultyName'],
      departmentId: json['departmentId'],
      departmentName: json['departmentName'],
      batchYear: json['batchYear'],
      currentSemester: json['currentSemester'],
      academicStatus: json['academicStatus'],
    );
  }
}

class LecturerProfileModel {
  final int userId;
  final String nimNip;
  final String fullName;
  final String email;
  final String? phone;
  final String? photoUrl;
  final int facultyId;
  final String facultyName;
  final int departmentId;
  final String departmentName;
  final String? specialization;
  final String? academicTitle;

  LecturerProfileModel({
    required this.userId,
    required this.nimNip,
    required this.fullName,
    required this.email,
    this.phone,
    this.photoUrl,
    required this.facultyId,
    required this.facultyName,
    required this.departmentId,
    required this.departmentName,
    this.specialization,
    this.academicTitle,
  });

  factory LecturerProfileModel.fromJson(Map<String, dynamic> json) {
    return LecturerProfileModel(
      userId: json['userId'],
      nimNip: json['nimNip'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      photoUrl: json['photoUrl'],
      facultyId: json['facultyId'],
      facultyName: json['facultyName'],
      departmentId: json['departmentId'],
      departmentName: json['departmentName'],
      specialization: json['specialization'],
      academicTitle: json['academicTitle'],
    );
  }
}