import '../../utils/parse.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    this.body,
    this.readAt,
    this.createdAt,
  });

  final int id;
  final String title;
  final String? body;
  final DateTime? readAt;
  final DateTime? createdAt;

  bool get isRead => readAt != null;

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: asInt(json['id']),
        title: asString(json['title']),
        body: asStringOrNull(json['body']),
        readAt: asDate(json['read_at']),
        createdAt: asDate(json['created_at']),
      );
}
