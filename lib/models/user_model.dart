class UserModel {
  final int id;
  final String nimNip;
  final String email;
  final String fullName;
  final String role;
  final String? photoUrl;
  final String? phone;
  final bool isActive;
  final bool isFirstLogin;

  UserModel({
    required this.id,
    required this.nimNip,
    required this.email,
    required this.fullName,
    required this.role,
    this.photoUrl,
    this.phone,
    required this.isActive,
    required this.isFirstLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['userId'] ?? json['id'],
      nimNip: json['nimNip'],
      email: json['email'],
      fullName: json['fullName'],
      role: json['role'],
      photoUrl: json['photoUrl'],
      phone: json['phone'],
      isActive: json['active'] ?? true,
      isFirstLogin: json['firstLogin'] ?? false,
    );
  }
}