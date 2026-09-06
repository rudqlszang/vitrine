/// 남은 시간 표기.
///
/// 실제 배송 안내는 분 단위까지 정확히 말하지 않는다.
/// "28분"이 아니라 "약 30분"이라고 해야 시스템이 계산한 티가 덜 나고
/// 사람이 안내하는 것처럼 읽힌다. 그래서 반올림해서 보여준다.
abstract final class DurationText {
  /// 예: "약 30분", "약 1시간", "약 2시간 30분"
  static String approximate(Duration d) {
    if (d.inSeconds <= 0) return soon;

    final minutes = d.inMinutes;
    if (minutes < 1) return soon;

    if (minutes < 60) {
      final rounded = _roundTo(minutes, 5);
      return rounded == 0 ? soon : '약 $rounded분';
    }

    final hours = minutes ~/ 60;
    // 시간 단위에서는 분을 10분 단위로 뭉갠다. "약 1시간 23분"은 지나치게 정확하다.
    final rest = _roundTo(minutes % 60, 10);

    if (rest == 0) return '약 $hours시간';
    if (rest >= 60) return '약 ${hours + 1}시간';
    return '약 $hours시간 $rest분';
  }

  static const soon = '곧';

  static int _roundTo(int value, int unit) =>
      ((value + unit / 2) ~/ unit) * unit;
}
