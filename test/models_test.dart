import 'package:flutter_test/flutter_test.dart';
import 'package:oola_mobile/domain/models/order.dart';
import 'package:oola_mobile/domain/models/paginated.dart';
import 'package:oola_mobile/domain/models/product.dart';

void main() {
  group('ProductCard', () {
    test('mappe une carte et calcule le prix promo', () {
      final card = ProductCard.fromJson({
        'id': 12,
        'slug': 'sac',
        'title': 'Sac',
        'price': 15000,
        'flash_sale': {'promo_price': 12000},
        'video_url': 'https://x/v.mp4',
      });
      expect(card.hasVideo, true);
      expect(card.onSale, true);
      expect(card.effectivePrice, 12000);
    });
  });

  group('Paginated', () {
    test('lit la forme compacte et la forme Laravel', () {
      final compact = Paginated.fromJson({
        'data': [
          {'id': 1, 'slug': 'a', 'title': 'A', 'price': 100},
        ],
        'meta': {'current_page': 1, 'last_page': 3, 'total': 42},
      }, ProductCard.fromJson);
      expect(compact.lastPage, 3);
      expect(compact.hasMore, true);

      final raw = Paginated.fromJson({
        'data': const [],
        'current_page': 2,
        'last_page': 2,
      }, ProductCard.fromJson);
      expect(raw.currentPage, 2);
      expect(raw.hasMore, false);
    });
  });

  group('OrderStatus', () {
    test('parse les statuts backend', () {
      expect(OrderStatus.parse('out_for_delivery'), OrderStatus.outForDelivery);
      expect(OrderStatus.parse('delivered'), OrderStatus.delivered);
      expect(OrderStatus.parse('???'), OrderStatus.unknown);
      expect(OrderStatus.cancelled.isTerminalBad, true);
    });
  });
}
