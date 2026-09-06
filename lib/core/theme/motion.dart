import 'package:flutter/animation.dart';

/// 애니메이션 duration / curve 상수.
/// 화면 코드에 숫자를 흩뿌리지 말고 전부 여기서 가져다 쓴다.
abstract final class AppMotion {
  // --- 공통 ---
  static const fast = Duration(milliseconds: 180);
  static const normal = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);

  static const standardCurve = Curves.easeOutCubic;

  // --- 결제 완료 시퀀스 (총 2.4초) ---
  /// 1. 흰 화면 페이드인
  static const checkoutFadeIn = Duration(milliseconds: 300);

  /// 2. 상품명 등장
  static const checkoutTitle = Duration(milliseconds: 300);

  /// 3~4. 잔고 카운트다운 + 절약 카운트업 (동시)
  static const checkoutCount = Duration(milliseconds: 800);
  static const checkoutCountCurve = Curves.easeOutCubic;

  /// 5. 환산 문구 페이드인
  static const checkoutConversion = Duration(milliseconds: 500);

  /// 6. 확인 버튼 등장
  static const checkoutButton = Duration(milliseconds: 300);

  // --- 홈 헤더 숫자 갱신 ---
  static const counterUpdate = Duration(milliseconds: 600);

  /// 대기 절약 → 확정 절약 전환 시 짧은 강조
  static const savingsConfirm = Duration(milliseconds: 700);
}
