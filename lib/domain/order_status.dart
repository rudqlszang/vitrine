import '../core/strings.dart';

/// 주문 진행 단계.
///
/// 크림·무신사의 배송 플로우를 차용하되 종착점을 "절약 확정"으로 바꿨다.
/// 각 단계에 걸리는 시간은 [OrderSchedule] 이 주문마다 30~60분 사이로 정한다.
/// 고정 시간표를 쓰면 모든 주문이 똑같이 움직여서 가짜 티가 난다.
enum OrderStatus {
  paid(Strings.statusPaid, Strings.statusPaidSub),
  preparing(Strings.statusPreparing, Strings.statusPreparingSub),
  inspecting(Strings.statusInspecting, Strings.statusInspectingSub),
  packed(Strings.statusPacked, Strings.statusPackedSub),
  shipping(Strings.statusShipping, Strings.statusShippingSub),
  delivered(Strings.statusDelivered, '');

  const OrderStatus(this.label, this.subtitle);

  final String label;
  final String subtitle;

  /// 배송 완료 전까지만 취소할 수 있다. 이 구간이 곧 냉각기다.
  bool get isCancellable => this != OrderStatus.delivered;

  /// 절약이 확정되었는가.
  bool get isConfirmed => this == OrderStatus.delivered;

  OrderStatus? get next {
    final i = index + 1;
    return i < OrderStatus.values.length ? OrderStatus.values[i] : null;
  }
}
