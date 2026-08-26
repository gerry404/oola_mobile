import '../../core/utils/parse.dart';

/// Page de resultats generique.
///
/// L'API OOLAshop expose deux formes de pagination :
///  - Compacte : `{ data: [...], meta: { current_page, last_page, total } }`
///  - Laravel brut : `{ data: [...], current_page, last_page, total, ... }`
///
/// [Paginated.fromJson] gere les deux.
class Paginated<T> {
  const Paginated({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasMore => currentPage < lastPage;

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parse,
  ) {
    final items = asList(json['data']).map((e) => parse(asMap(e))).toList();
    // meta imbrique (forme compacte) ou champs a la racine (Laravel brut).
    final meta = json['meta'] is Map ? asMap(json['meta']) : json;
    return Paginated<T>(
      items: items,
      currentPage: asInt(meta['current_page'], 1),
      lastPage: asInt(meta['last_page'], 1),
      total: asInt(meta['total'], items.length),
    );
  }

  Paginated<T> merge(Paginated<T> next) => Paginated<T>(
        items: [...items, ...next.items],
        currentPage: next.currentPage,
        lastPage: next.lastPage,
        total: next.total,
      );
}
