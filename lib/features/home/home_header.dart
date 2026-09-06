import 'package:flutter/material.dart';

import '../../core/format/won_format.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';

/// 홈 상단의 잔고 · 절약 헤더. 앱의 얼굴이다.
///
/// 스크롤하면 축소되어 상단에 고정된다.
/// 숫자 애니메이션은 4단계 MoneyCounter 에서 정식 구현한다.
class HomeHeader extends SliverPersistentHeaderDelegate {
  const HomeHeader({required this.balance, required this.saved});

  final int balance;
  final int saved;

  static const _expanded = 132.0;
  static const _collapsed = 64.0;

  @override
  double get maxExtent => _expanded;

  @override
  double get minExtent => _collapsed;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final t = (shrinkOffset / (_expanded - _collapsed)).clamp(0.0, 1.0);

    // 접힐수록 잔고 글자를 줄이고 라벨을 지운다.
    final balanceSize = lerpDouble(32, 20, t);
    final labelOpacity = (1 - t * 1.6).clamp(0.0, 1.0);

    return Container(
      color: AppColors.bg,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: labelOpacity,
            child: Text(Strings.balance, style: AppTypo.caption),
          ),
          SizedBox(height: lerpDouble(4, 0, t)),
          Text(
            Won.format(balance),
            style: AppTypo.display.copyWith(fontSize: balanceSize),
            maxLines: 1,
          ),
          SizedBox(height: lerpDouble(10, 2, t)),
          Row(
            children: [
              Text(Strings.saved, style: AppTypo.caption),
              const SizedBox(width: 8),
              Text(
                Won.format(saved),
                style: AppTypo.price.copyWith(color: AppColors.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRebuild(covariant HomeHeader old) =>
      old.balance != balance || old.saved != saved;
}
