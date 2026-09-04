import '../../utils/parse.dart';

/// Page de resultats generique. Gere la forme compacte
/// (`{data, meta:{...}}`) et la forme Laravel brute (`{data, current_page,...}`).
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
    final meta = json['meta'] is Map ? asMap(json['meta']) : json;
    return Paginated<T>(
      items: items,
      currentPage: asInt(meta['current_page'], 1),
      lastPage: asInt(meta['last_page'], 1),
      total: asInt(meta['total'], items.length),
    );
  }
}
