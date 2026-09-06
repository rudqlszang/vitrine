import 'package:flutter/widgets.dart';

import '../core/format/won_format.dart';

/// 금액이 [from] 에서 [to] 로 굴러가는 숫자.
///
/// 스타일에 tabular figures 가 걸려 있어야 자릿수가 흔들리지 않는다.
/// [AppTypo.display] · [AppTypo.price] 는 이미 적용되어 있다.
///
/// 시퀀스 연출처럼 시작 시점을 제어해야 하면 [MoneyCounter.driven] 을 쓴다.
/// 지연을 위해 build 안에서 Future 를 만들면 리빌드마다 처음으로 되돌아간다.
class MoneyCounter extends StatelessWidget {
  const MoneyCounter({
    super.key,
    required this.from,
    required this.to,
    required this.style,
    required this.duration,
    this.curve = Curves.easeOutCubic,
  })  : progress = null,
        onEnd = null;

  /// 바깥 [AnimationController] 가 진행도를 준다.
  /// 여러 요소의 타이밍을 맞춰야 하는 화면에서 쓴다.
  const MoneyCounter.driven({
    super.key,
    required this.from,
    required this.to,
    required this.style,
    required Animation<double> this.progress,
  })  : duration = Duration.zero,
        curve = Curves.linear,
        onEnd = null;

  final int from;
  final int to;
  final TextStyle style;
  final Duration duration;
  final Curve curve;
  final Animation<double>? progress;
  final VoidCallback? onEnd;

  @override
  Widget build(BuildContext context) {
    final driver = progress;
    if (driver != null) {
      return AnimatedBuilder(
        animation: driver,
        builder: (context, _) {
          final v = from + (to - from) * driver.value;
          return Text(Won.format(v.round()), style: style);
        },
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: from.toDouble(), end: to.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, value, _) =>
          Text(Won.format(value.round()), style: style),
    );
  }
}
