import 'order.dart';

/// 잔고와 절약은 저장하지 않는다. 주문 목록에서 매번 계산한다.
///
/// 값을 따로 들고 있으면 취소·환원 과정에서 반드시 어긋난다.
/// 주문 목록 하나만 진실로 두면 그런 버그가 생길 자리가 없다.
class Savings {
  const Savings({
    required this.balance,
    required this.confirmed,
    required this.pending,
  });

  /// 초기 가상 잔고 1조원.
  static const initialBalance = 1000000000000;

  /// 남은 잔고.
  final int balance;

  /// 배송 완료로 확정된 절약.
  final int confirmed;

  /// 배송 중이라 아직 확정되지 않은 절약. 취소하면 사라진다.
  final int pending;

  int get spent => initialBalance - balance;

  static Savings from(Iterable<Order> orders) {
    var confirmed = 0;
    var pending = 0;
    for (final o in orders) {
      if (o.isCancelled) continue;
      if (o.isConfirmed) {
        confirmed += o.price;
      } else {
        pending += o.price;
      }
    }
    // 취소되지 않은 주문 전액이 잔고에서 빠져 있다.
    return Savings(
      balance: initialBalance - confirmed - pending,
      confirmed: confirmed,
      pending: pending,
    );
  }
}
