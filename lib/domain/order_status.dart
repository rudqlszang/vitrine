import '../core/strings.dart';

/// 주문 진행 단계.
///
/// 크림·무신사의 배송 플로우를 차용하되 종착점을 "절약 확정"으로 바꿨다.
/// 총 24시간이 걸리는 이유는 하루에 한 번 앱을 열게 만들기 위해서다.
enum OrderStatus {
  paid(Duration.zero, Strings.statusPaid, Strings.statusPaidSub),
  preparing(Duration(minutes: 5), Strings.statusPreparing,
      Strings.statusPreparingSub),
  inspecting(Duration(minutes: 30), Strings.statusInspecting,
      Strings.statusInspectingSub),
  packed(Duration(hours: 2), Strings.statusPacked, Strings.statusPackedSub),
  shipping(Duration(hours: 6), Strings.statusShipping,
      Strings.statusShippingSub),
  delivered(Duration(hours: 24), Strings.statusDelivered, '');

  const OrderStatus(this.after, this.label, this.subtitle);

  /// 주문 시점으로부터 이 단계에 진입하기까지 걸리는 시간.
  final Duration after;
  final String label;
  final String subtitle;

  /// 배송 완료 전까지만 취소할 수 있다. 이 구간이 곧 냉각기다.
  bool get isCancellable => this != OrderStatus.delivered;

  /// 절약이 확정되었는가.
  bool get isConfirmed => this == OrderStatus.delivered;

  /// 경과 시간에 해당하는 단계.
  static OrderStatus fromElapsed(Duration elapsed) {
    var current = OrderStatus.paid;
    for (final s in OrderStatus.values) {
      if (elapsed >= s.after) current = s;
    }
    return current;
  }

  /// 다음 단계까지 남은 시간. 마지막 단계면 null.
  Duration? remainingTo(Duration elapsed) {
    final next = _next;
    if (next == null) return null;
    final left = next.after - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  OrderStatus? get _next {
    final i = index + 1;
    return i < OrderStatus.values.length ? OrderStatus.values[i] : null;
  }
}
