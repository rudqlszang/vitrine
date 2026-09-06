/// 사용자에게 보이는 문자열은 전부 여기에 모은다.
abstract final class Strings {
  static const appName = 'VITRINE';

  // 홈 헤더
  static const balance = '잔고';
  static const saved = '절약';
  static const categoryAll = '전체';
  static const savedPending = '대기';
  static const savedEmpty = '아직 아낀 금액이 없습니다';
  static const savedConfirmed = '확정';

  // 주문 상태
  static const statusPaid = '결제 완료';
  static const statusPreparing = '상품 준비중';
  static const statusInspecting = '정품 검수중';
  static const statusPacked = '포장 완료';
  static const statusShipping = '배송중';
  static const statusDelivered = '배송 완료';

  static const statusPaidSub = '주문이 접수되었습니다';
  static const statusPreparingSub = '부티크에서 상품을 확인하고 있어요';
  static const statusInspectingSub = '전문 검수팀이 확인하고 있어요';
  static const statusPackedSub = '곧 발송될 예정이에요';
  static const statusShippingSub = '오늘 안에 도착할 예정이에요';

  // 액션
  static const buy = '구매하기';
  static const sellerPrefix = '판매';
  static const detailNotice = '실제로 구매되지 않습니다. 지른 금액은 그대로 절약으로 쌓입니다.';
  static const confirm = '확인';
  static const cancelOrder = '주문 취소';

  // 셋업 검증 화면 (1단계 전용, 이후 제거)
  static const setupTitle = '셋업 검증';
  static const setupFontCheck = 'Pretendard 웨이트';
  static const setupTabularCheck = '고정폭 숫자 (tabular)';
  static const setupColorCheck = '색 토큰';
}
