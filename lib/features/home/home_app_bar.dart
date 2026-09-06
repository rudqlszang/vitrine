import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../widgets/brand_mark.dart';

/// 홈 상단 바.
///
/// 금액은 여기 없다. 잔고도 절약도 마이페이지로 보냈다.
/// 실제 쇼핑앱 상단에는 브랜드가 있지 내 통장이 있지 않다.
class HomeAppBar extends SliverPersistentHeaderDelegate {
  const HomeAppBar();

  static const _height = 56.0;

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // 스크롤이 시작되면 얇은 경계선만 남겨 그리드와 분리한다.
    final scrolled = shrinkOffset > 0 || overlapsContent;

    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: Border(
          bottom: BorderSide(
            color: scrolled ? AppColors.divider : Colors.transparent,
            width: 1,
          ),
        ),
      ),
      alignment: Alignment.center,
      child: const BrandMark(),
    );
  }

  @override
  bool shouldRebuild(covariant HomeAppBar oldDelegate) => false;
}
