class AnnouncementModel {
  final int id;
  final String title;
  final String content;
  final String? category;
  final String? targetRole;
  final String? publishedAt;
  final String? expiresAt;
  final String? createdByName;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    this.category,
    this.targetRole,
    this.publishedAt,
    this.expiresAt,
    this.createdByName,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      targetRole: json['targetRole'],
      publishedAt: json['publishedAt'],
      expiresAt: json['expiresAt'],
      createdByName: json['createdByName'],
    );
  }
}