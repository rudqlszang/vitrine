import '../core/time/time_scale.dart';
import 'order_status.dart';

/// 주문 한 건.
///
/// 상태는 저장하지 않는다. [createdAt] 과 현재 시각의 차이로 매번 계산한다.
/// 타이머가 죽거나 앱이 꺼져 있어도 상태가 어긋나지 않는다.
class Order {
  const Order({
    required this.id,
    required this.productId,
    required this.brand,
    required this.title,
    required this.price,
    required this.createdAt,
    this.imageUrl,
    this.cancelledAt,
  });

  final String id;
  final String productId;
  final String brand;
  final String title;
  final int price;
  final String? imageUrl;
  final DateTime createdAt;

  /// null 이면 유효한 주문이다.
  final DateTime? cancelledAt;

  bool get isCancelled => cancelledAt != null;

  Duration get elapsed => TimeScale.instance.elapsedSince(createdAt);

  OrderStatus get status => OrderStatus.fromElapsed(elapsed);

  /// 절약이 확정되었는가. 취소된 주문은 확정되지 않는다.
  bool get isConfirmed => !isCancelled && status.isConfirmed;

  /// 아직 배송 중이라 절약이 확정되지 않은 상태.
  bool get isPending => !isCancelled && !status.isConfirmed;

  bool get isCancellable => !isCancelled && status.isCancellable;

  Order cancel() => Order(
        id: id,
        productId: productId,
        brand: brand,
        title: title,
        price: price,
        imageUrl: imageUrl,
        createdAt: createdAt,
        cancelledAt: DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'productId': productId,
        'brand': brand,
        'title': title,
        'price': price,
        'imageUrl': imageUrl,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'cancelledAt': cancelledAt?.millisecondsSinceEpoch,
      };

  static Order fromMap(Map<dynamic, dynamic> m) => Order(
        id: m['id'] as String,
        productId: m['productId'] as String,
        brand: m['brand'] as String,
        title: m['title'] as String,
        price: m['price'] as int,
        imageUrl: m['imageUrl'] as String?,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['createdAt'] as int),
        cancelledAt: m['cancelledAt'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(m['cancelledAt'] as int),
      );
}
