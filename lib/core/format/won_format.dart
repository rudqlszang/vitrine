/// 원화 표기. 앱 전체에서 금액은 반드시 이 함수를 거친다.
///
/// 표시 스타일에 `FontFeature.tabularFigures()` 가 걸려 있어야
/// 카운팅 중 자릿수가 흔들리지 않는다. [AppTypo.display] / [AppTypo.price] 참고.
abstract final class Won {
  /// ₩12,880,000
  static String format(int value) {
    final negative = value < 0;
    final digits = value.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return '${negative ? '-' : ''}₩$buf';
  }

  /// 1조 단위처럼 긴 금액을 헤더에서 줄여 쓸 때.
  /// 예: 997850000000 → 9,978억
  static String compact(int value) {
    const jo = 1000000000000;
    const eok = 100000000;
    if (value.abs() >= jo) {
      final v = value / jo;
      return '${_trim(v)}조';
    }
    if (value.abs() >= eok) {
      final v = value / eok;
      return '${_trim(v)}억';
    }
    return format(value);
  }

  static String _trim(double v) {
    final s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }
}
