import 'package:flutter/material.dart';

import '../core/strings.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';

/// 상단 워드마크.
///
/// 지금은 자간을 넓힌 텍스트다.
/// 스플래시에 쓰인 Didone 계열 세리프 워드마크 이미지를 받으면 그것으로 교체한다.
/// (assets/brand/wordmark.png — 검정, 배경 투명)
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      Strings.appName,
      style: AppTypo.title.copyWith(
        fontSize: size,
        fontWeight: FontWeight.w500,
        // 명품 워드마크의 넓은 자간을 흉내낸다.
        letterSpacing: size * 0.42,
        color: AppColors.textPrimary,
        height: 1,
      ),
    );
  }
}
