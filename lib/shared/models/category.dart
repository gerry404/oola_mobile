import '../../core/utils/parse.dart';

/// Categorie de produits.
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.sortOrder = 0,
  });

  final int id;
  final String name;
  final String slug;
  final String? icon;
  final int sortOrder;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: asInt(json['id']),
        name: asString(json['name']),
        slug: asString(json['slug']),
        icon: asStringOrNull(json['icon']),
        sortOrder: asInt(json['sort_order']),
      );
}
