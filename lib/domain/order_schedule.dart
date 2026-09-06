import 'order_status.dart';

/// 주문별 배송 스케줄.
///
/// 단계마다 30~60분이 걸리며, 그 시간은 주문마다 다르다.
/// 다만 **주문 안에서는 고정**이어야 한다.
/// 조회할 때마다 새로 뽑으면 상태가 앞뒤로 튀어서 배송이 거꾸로 가는 것처럼 보인다.
/// 그래서 저장하지 않고 주문 id 로부터 결정적으로 유도한다.
abstract final class OrderSchedule {
  static const minMinutes = 30;
  static const maxMinutes = 60;

  /// 주문 시각으로부터 [status] 에 진입하기까지 걸리는 누적 시간.
  static Duration offsetTo(String orderId, OrderStatus status) {
    var total = Duration.zero;
    for (var i = 1; i <= status.index; i++) {
      total += stageDuration(orderId, i);
    }
    return total;
  }

  /// [stageIndex] 단계로 넘어가는 데 걸리는 시간. 30~60분.
  static Duration stageDuration(String orderId, int stageIndex) {
    final span = maxMinutes - minMinutes + 1;
    final minutes = minMinutes + (_hash(orderId, stageIndex) % span);
    return Duration(minutes: minutes);
  }

  /// 배송 완료까지 걸리는 총 시간.
  static Duration total(String orderId) =>
      offsetTo(orderId, OrderStatus.delivered);

  /// 경과 시간에 해당하는 단계.
  static OrderStatus statusOf(String orderId, Duration elapsed) {
    var current = OrderStatus.paid;
    for (final s in OrderStatus.values) {
      if (elapsed >= offsetTo(orderId, s)) current = s;
    }
    return current;
  }

  /// 다음 단계까지 남은 시간. 배송 완료면 null.
  static Duration? remaining(String orderId, Duration elapsed) {
    final now = statusOf(orderId, elapsed);
    final next = now.next;
    if (next == null) return null;
    final left = offsetTo(orderId, next) - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  /// FNV-1a. Dart 의 hashCode 는 실행 환경에 따라 달라질 수 있어 쓰지 않는다.
  /// 같은 주문은 언제 어디서 계산해도 같은 스케줄이어야 한다.
  static int _hash(String id, int salt) {
    var h = 2166136261 ^ salt;
    for (var i = 0; i < id.length; i++) {
      h ^= id.codeUnitAt(i);
      h = (h * 16777619) & 0x7FFFFFFF;
    }
    return h;
  }
}
