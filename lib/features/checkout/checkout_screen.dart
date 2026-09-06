import 'package:flutter/material.dart';

import '../../core/format/conversion.dart';
import '../../core/format/won_format.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../domain/savings.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/money_counter.dart';

/// 결제 완료. 이 앱의 클라이맥스.
///
/// 한국 은행 앱의 결제 알림을 차용한다.
/// 홈에서 잔고를 감춰둔 이유가 여기 있다.
/// 잔고는 이 화면에서 처음 드러나고, 그래서 깎이는 장면이 무겁다.
///
/// 전체 연출을 컨트롤러 하나로 돌린다. 요소별로 타이머를 두면
/// 리빌드마다 타이밍이 어긋난다.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.brand,
    required this.title,
    required this.price,
    required this.before,
  });

  final String brand;
  final String title;
  final int price;

  /// 결제 직전 상태. 여기서 [price] 만큼 깎인다.
  final Savings before;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  // 총 2.4초. 구간은 아래 Interval 들이 나눠 쓴다.
  static const _total = Duration(milliseconds: 2400);

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: _total,
  )..forward();

  // 0.00~0.125  머리말
  late final _head = _fade(0, 0.125);
  // 0.125~0.25  결제 금액
  late final _amount = _fade(0.125, 0.25);
  // 0.25~0.583  잔액·절약 카운팅 (800ms)
  late final _count = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.25, 0.583, curve: Curves.easeOutCubic),
  );
  // 0.583~0.792  환산 문구
  late final _conversion = _fade(0.583, 0.792);
  // 0.792~1.0  확인 버튼
  late final _button = _fade(0.792, 1);

  Animation<double> _fade(double begin, double end) => CurvedAnimation(
        parent: _c,
        curve: Interval(begin, end, curve: Curves.easeOut),
      );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final afterBalance = widget.before.balance - widget.price;
    final savedBefore = widget.before.confirmed + widget.before.pending;
    final afterSaved = savedBefore + widget.price;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              FadeTransition(
                opacity: _head,
                child: Row(
                  children: [
                    const BrandMark(height: 13),
                    const SizedBox(width: 8),
                    Text(Strings.checkoutPaid, style: AppTypo.caption),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              FadeTransition(
                opacity: _amount,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Won.format(widget.price),
                      style: AppTypo.display.copyWith(fontSize: 34),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.brand}  ${widget.title}',
                      style: AppTypo.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 22),

              // 잔액은 깎이고, 절약은 오른다. 같은 순간 반대 방향으로 움직인다.
              _Line(
                label: Strings.checkoutBalance,
                child: MoneyCounter.driven(
                  from: widget.before.balance,
                  to: afterBalance,
                  style: AppTypo.price.copyWith(fontSize: 17),
                  progress: _count,
                ),
              ),
              const SizedBox(height: 14),
              _Line(
                label: Strings.saved,
                child: MoneyCounter.driven(
                  from: savedBefore,
                  to: afterSaved,
                  style: AppTypo.price
                      .copyWith(fontSize: 17, color: AppColors.accent),
                  progress: _count,
                ),
              ),

              const SizedBox(height: 26),
              FadeTransition(
                opacity: _conversion,
                child: Text(
                  Conversion.sentence(afterSaved),
                  style: AppTypo.body.copyWith(color: AppColors.textSecond),
                ),
              ),

              const Spacer(flex: 2),

              FadeTransition(
                opacity: _button,
                child: Column(
                  children: [
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(Strings.confirm),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      Strings.checkoutCoolingHint,
                      style: AppTypo.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: AppTypo.caption), child],
    );
  }
}
