import 'package:flutter/foundation.dart';

/// 개발용 시간 배속.
///
/// 주문은 배송 완료까지 24시간이 걸린다. 그대로 두면 테스트가 불가능하므로
/// 경과 시간에 배율을 곱해 24시간을 1분까지 압축한다.
/// 릴리스 빌드에서는 항상 1배다.
class TimeScale extends ChangeNotifier {
  TimeScale._();

  static final instance = TimeScale._();

  /// 1x(실시간) · 60x(24시간→24분) · 1440x(24시간→1분)
  static const options = <int>[1, 60, 1440];

  int _factor = 1;

  int get factor => kReleaseMode ? 1 : _factor;

  set factor(int value) {
    if (kReleaseMode || value == _factor) return;
    _factor = value;
    notifyListeners();
  }

  /// [from] 이후 흐른 것으로 간주할 시간.
  Duration elapsedSince(DateTime from) {
    final real = DateTime.now().difference(from);
    return real * factor;
  }
}
