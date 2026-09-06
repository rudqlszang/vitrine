import 'package:flutter/widgets.dart';

/// 디자인 토큰.
///
/// SSENSE 계열의 무채색·여백 중심 구성.
/// 색은 여기 정의된 것만 쓴다. 특히 [AppColors.accent] 는 절약 금액 전용이다.
abstract final class AppColors {
  /// 기본 배경
  static const bg = Color(0xFFFFFFFF);

  /// 상품 이미지 배경. 네이버 이미지의 배경 편차를 덮기 위해 반드시 통일한다.
  static const surface = Color(0xFFF5F5F5);

  static const textPrimary = Color(0xFF0A0A0A);
  static const textSecond = Color(0xFF767676);
  static const divider = Color(0xFFEAEAEA);

  /// 절약 금액 전용. 다른 곳에 쓰지 말 것.
  static const accent = Color(0xFFDA2727);

  /// 완료 상태. 초록 금지 — 검정으로 처리한다.
  static const success = Color(0xFF1A1A1A);
}

abstract final class AppSpacing {
  static const screenPadding = 20.0;
  static const cardGap = 12.0;
  static const sectionGap = 40.0;
}

abstract final class AppRadius {
  /// 거의 각지게. 둥글면 명품 느낌이 죽는다.
  static const base = 2.0;
  static const zero = 0.0;
}
