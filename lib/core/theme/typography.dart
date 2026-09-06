
import 'package:flutter/widgets.dart';

import 'tokens.dart';

/// Pretendard 기반 타이포 스케일.
///
/// 금액을 표시하는 스타일([display], [price])에는 반드시 tabular figures 를 건다.
/// 안 걸면 카운팅 애니메이션 중 자릿수 폭이 흔들려서 싸구려로 보인다.
abstract final class AppTypo {
  static const fontFamily = 'Pretendard';

  /// 고정폭 숫자. 숫자가 변하는 모든 곳에 필수.
  static const tabular = <FontFeature>[FontFeature.tabularFigures()];

  /// 잔고. 앱에서 가장 큰 숫자.
  static const display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.6,
    fontFeatures: tabular,
  );

  static const title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static const body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecond,
    height: 1.35,
  );

  /// 상품 가격.
  static const price = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
    fontFeatures: tabular,
  );

  /// 브랜드명. 대문자로 표기한다.
  static const brand = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
    letterSpacing: 0.4,
  );
}
