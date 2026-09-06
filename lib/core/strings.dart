/// 사용자에게 보이는 문자열은 전부 여기에 모은다.
abstract final class Strings {
  static const appName = 'VITRINE';

  // 금액
  static const balance = '잔고';
  static const saved = '절약';
  static const savedPending = '대기';
  static const savedConfirmed = '확정';
  static const savedEmpty = '아직 아낀 금액이 없습니다';
  static const categoryAll = '전체';
  static const tabShop = '쇼핑';

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

  // 상품
  static const buy = '구매하기';
  static const notEnoughBalance = '잔고가 부족합니다';
  static const sellerPrefix = '판매';

  // 주문서
  static const orderFormTitle = '주문서';
  static const orderOption = '옵션';
  static const orderAddress = '배송지';
  static const orderAddressAdd = '입력';
  static const orderAddressEdit = '변경';
  static const orderPrice = '결제 정보';
  static const orderItemPrice = '상품 금액';
  static const orderInspection = '정품 검수비';
  static const orderShipping = '배송비';
  static const orderFree = '무료';
  static const orderTotal = '총 결제금액';
  static const orderMethod = '결제수단';
  static const orderAgree = '주문 내용을 확인했으며 결제에 동의합니다';
  static const orderNeedAddress = '배송지를 입력해주세요';
  static const orderNeedAgree = '결제 동의가 필요합니다';
  static const pay = '결제하기';
  static const payProcessing = '결제를 진행하고 있습니다';
  static const payProcessingSub = '잠시만 기다려주세요';

  // 배송지
  static const addressTitle = '배송지 입력';
  static const addressRecipient = '받는 분';
  static const addressPhone = '연락처';
  static const addressPostcode = '우편번호';
  static const addressLine1 = '주소';
  static const addressLine2 = '상세주소';
  static const save = '저장';

  // 결제 완료
  static const confirm = '확인';
  static const checkoutPaid = '결제 완료';
  static const checkoutBalance = '잔액';
  static const checkoutCoolingHint = '배송 완료 전까지 취소할 수 있습니다';

  // 주문 내역
  static const ordersTitle = '주문 내역';
  static const ordersOngoing = '진행중';
  static const ordersDone = '완료';
  static const ordersEmpty = '아직 주문한 상품이 없습니다';
  static const ordersEmptyDone = '완료된 주문이 없습니다';
  static const cancelOrder = '주문 취소';
  static const cancelConfirmTitle = '주문을 취소할까요?';
  static const cancelConfirmBody = '취소하면 이 주문으로 쌓인 절약도 함께 사라집니다.';
  static const cancelKeep = '유지';
  static const cancelDo = '취소하기';
  static const cancelled = '취소됨';
  static const orderSavedConfirmed = '절약이 확정되었습니다';
  static const nextStageIn = '다음 단계까지';

  // 마이페이지
  static const myPageTitle = '마이페이지';
  static const myBalance = '남은 잔고';
  static const mySavedConfirmed = '확정 절약';
  static const mySavedPending = '대기 절약';
  static const myOrders = '주문 내역';
  static const myAddress = '배송지 관리';
  static const myReport = '절약 리포트';
  static const myJoined = '가입일';
  static const myTimeScale = '시간 배속 (개발용)';

  // 회원가입
  static const signupTitle = '시작하기';
  static const signupLead = '이름을 알려주세요';
  static const signupSub = '주문과 배송에 사용됩니다';
  static const signupName = '이름';
  static const signupNickname = '닉네임 (선택)';
  static const signupStart = '입장하기';
  static const signupGranted = '가상 잔고 ₩1조가 지급되었습니다';

  // 리포트
  static const reportTitle = '절약 리포트';
  static const reportTotal = '누적 절약';
  static const reportCount = '지른 횟수';
  static const reportEmpty = '아직 기록이 없습니다';
  static const reportShare = '공유하기';
  static const reportMonthly = '월별';
}
