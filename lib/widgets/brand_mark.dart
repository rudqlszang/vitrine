import 'package:flutter/material.dart';

import '../core/strings.dart';
import '../core/theme/tokens.dart';

/// VITRINE 워드마크.
///
/// Didone 계열 세리프라 Pretendard 로는 재현이 안 된다. 이미지로 쓴다.
/// 원본은 투명 배경에 검정 글자이며, 색은 [color] 로 덮어쓸 수 있다.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.height = 17, this.color});

  /// 글자 높이(px). 워드마크 비율이 약 5.7:1 이라 폭은 이 값의 5.7배가 된다.
  final double height;

  /// 어두운 배경에 얹을 때 흰색 등으로 바꾼다. 기본은 원본 검정.
  final Color? color;

  static const _asset = 'assets/brand/wordmark.png';

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      _asset,
      height: height,
      fit: BoxFit.contain,
      color: color,
      filterQuality: FilterQuality.high,
      // 이미지가 없을 때도 브랜드는 보여야 한다.
      errorBuilder: (context, _, _) => Text(
        Strings.appName,
        style: TextStyle(
          fontSize: height,
          fontWeight: FontWeight.w500,
          letterSpacing: height * 0.4,
          color: color ?? AppColors.textPrimary,
        ),
      ),
    );

    return Semantics(label: Strings.appName, child: image);
  }
}
