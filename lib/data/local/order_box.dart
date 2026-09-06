import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/order.dart';

/// 주문 영속화.
///
/// Hive 어댑터를 코드 생성하지 않고 Map 으로 직렬화한다.
/// 모델이 단순하고, build_runner 를 붙이면 의존성만 무거워진다.
class OrderBox {
  OrderBox._(this._box);

  static const boxName = 'orders';

  final Box<Map<dynamic, dynamic>> _box;

  static Future<OrderBox> open() async {
    final box = await Hive.openBox<Map<dynamic, dynamic>>(boxName);
    return OrderBox._(box);
  }

  /// 최신 주문이 앞에 오도록.
  List<Order> all() {
    final list = _box.values.map(Order.fromMap).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> put(Order order) => _box.put(order.id, order.toMap());

  Future<void> clear() => _box.clear();
}
