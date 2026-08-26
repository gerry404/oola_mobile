import '../../core/utils/parse.dart';

/// Notification in-app.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    this.actionUrl,
    this.readAt,
    this.createdAt,
  });

  final int id;
  final String type;
  final String title;
  final String? body;
  final String? actionUrl;
  final DateTime? readAt;
  final DateTime? createdAt;

  bool get isRead => readAt != null;

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: asInt(json['id']),
        type: asString(json['type']),
        title: asString(json['title']),
        body: asStringOrNull(json['body']),
        actionUrl: asStringOrNull(json['action_url']),
        readAt: asDate(json['read_at']),
        createdAt: asDate(json['created_at']),
      );
}
