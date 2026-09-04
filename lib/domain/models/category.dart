import '../../utils/parse.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
  });

  final int id;
  final String name;
  final String slug;
  final String? icon;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: asInt(json['id']),
        name: asString(json['name']),
        slug: asString(json['slug']),
        icon: asStringOrNull(json['icon']),
      );
}
