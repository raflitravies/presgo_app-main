class EventModel {
  final int id;
  final String title;
  final String? description;
  final String? location;
  final String startAt;
  final String? endAt;
  final String? posterUrl;
  final String? organizer;
  final String? targetRole;
  final String? createdByName;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    this.location,
    required this.startAt,
    this.endAt,
    this.posterUrl,
    this.organizer,
    this.targetRole,
    this.createdByName,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      startAt: json['startAt'],
      endAt: json['endAt'],
      posterUrl: json['posterUrl'],
      organizer: json['organizer'],
      targetRole: json['targetRole'],
      createdByName: json['createdByName'],
    );
  }
}