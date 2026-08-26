import 'package:flutter_test/flutter_test.dart';
import 'package:oola_mobile/shared/models/order.dart';
import 'package:oola_mobile/shared/models/paginated.dart';
import 'package:oola_mobile/shared/models/product_card.dart';
import 'package:oola_mobile/shared/models/product_detail.dart';

void main() {
  group('ProductCard', () {
    test('mappe une carte du feed et calcule le prix promo', () {
      final card = ProductCard.fromJson({
        'id': 12,
        'slug': 'sac-cuir',
        'title': 'Sac en cuir',
        'price': 15000,
        'is_sponsored': true,
        'flash_sale': {'promo_price': 12000},
        'shop_name': 'Boutique A',
        'video_url': 'https://x/v.mp4',
        'poster_url': null,
      });
      expect(card.title, 'Sac en cuir');
      expect(card.isSponsored, true);
      expect(card.hasVideo, true);
      expect(card.onSale, true);
      expect(card.effectivePrice, 12000);
    });

    test('sans promo, le prix effectif est le prix normal', () {
      final card = ProductCard.fromJson({
        'id': 1,
        'slug': 's',
        'title': 't',
        'price': 5000,
      });
      expect(card.onSale, false);
      expect(card.effectivePrice, 5000);
      expect(card.hasVideo, false);
    });
  });

  group('Paginated', () {
    test('lit la forme compacte (meta imbrique)', () {
      final page = Paginated.fromJson({
        'data': [
          {'id': 1, 'slug': 'a', 'title': 'A', 'price': 100},
        ],
        'meta': {'current_page': 1, 'last_page': 3, 'total': 42},
      }, ProductCard.fromJson);
      expect(page.items.length, 1);
      expect(page.lastPage, 3);
      expect(page.total, 42);
      expect(page.hasMore, true);
    });

    test('lit la forme Laravel brute (champs a la racine)', () {
      final page = Paginated.fromJson({
        'data': [
          {'id': 2, 'slug': 'b', 'title': 'B', 'price': 200},
        ],
        'current_page': 2,
        'last_page': 2,
        'total': 2,
      }, ProductCard.fromJson);
      expect(page.currentPage, 2);
      expect(page.hasMore, false);
    });
  });

  group('ProductDetail', () {
    test('mappe variantes, rating et libelle de variante', () {
      final p = ProductDetail.fromJson({
        'id': 3,
        'slug': 'chaussure',
        'title': 'Chaussure',
        'price': 20000,
        'rating': {'average': 4.5, 'count': 8},
        'variants': [
          {'id': 1, 'size': '42', 'color': 'Noir', 'stock': 3},
          {'id': 2, 'size': '43', 'color': null, 'stock': 0},
        ],
      });
      expect(p.ratingAverage, 4.5);
      expect(p.ratingCount, 8);
      expect(p.hasVariants, true);
      expect(p.variants.first.label, '42 / Noir');
      expect(p.variants[1].inStock, false);
    });
  });

  group('OrderStatus', () {
    test('parse les statuts backend', () {
      expect(OrderStatus.parse('out_for_delivery'), OrderStatus.outForDelivery);
      expect(OrderStatus.parse('delivered'), OrderStatus.delivered);
      expect(OrderStatus.parse('inconnu'), OrderStatus.unknown);
    });
  });
}
