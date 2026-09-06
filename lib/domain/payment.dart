/// 결제 금액 명세.
///
/// 크림이 검수비를, 무신사가 배송비를 따로 보여주는 것과 같다.
/// 총액 한 줄만 있으면 주문서가 비어 보이고 실감이 떨어진다.
class PriceBreakdown {
  const PriceBreakdown({required this.item});

  /// 상품 금액.
  final int item;

  /// 정품 검수비. 명품 플랫폼이 공통으로 받는 항목이다.
  int get inspection => 30000;

  /// 배송비. 이 금액대에 배송비를 받는 곳은 없다.
  int get shipping => 0;

  int get total => item + inspection + shipping;
}

/// 결제수단.
enum PaymentMethod {
  card('신용·체크카드'),
  easyPay('간편결제'),
  transfer('계좌이체');

  const PaymentMethod(this.label);

  final String label;
}
