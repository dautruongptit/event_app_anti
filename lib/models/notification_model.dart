class NotificationModel {
  final int id;
  final String title;
  final String body;
  final bool isRead;
  final int? eventId;
  final String? eventTitle;
  final DateTime sentAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.isRead = false,
    this.eventId,
    this.eventTitle,
    required this.sentAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      isRead: json['isRead'] as bool? ?? false,
      eventId: json['eventId'] as int?,
      eventTitle: json['eventTitle'] as String?,
      sentAt: DateTime.parse(json['sentAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'isRead': isRead,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'sentAt': sentAt.toIso8601String(),
    };
  }

  NotificationModel markRead() {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      isRead: true,
      eventId: eventId,
      eventTitle: eventTitle,
      sentAt: sentAt,
    );
  }
}
