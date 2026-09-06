/// 카테고리별 선택 옵션.
///
/// 크림·무신사가 구매 버튼을 누르면 먼저 사이즈를 묻는다.
/// 그 한 단계가 "고르는 감각"을 만들기 때문에 그대로 가져온다.
abstract final class PurchaseOption {
  /// 카테고리에 해당하는 선택지. 비어 있으면 옵션 단계를 건너뛴다.
  static List<String> forCategory(String category) => switch (category) {
        '슈즈' => const ['220', '225', '230', '235', '240', '245', '250', '255', '260', '265', '270', '275', '280'],
        '의류' => const ['XS', 'S', 'M', 'L', 'XL'],
        '주얼리' => const ['9호', '10호', '11호', '12호', '13호', '14호', '15호', '16호', '17호'],
        '시계' => const ['기본'],
        // 가방·준명품은 사이즈 개념이 없다.
        _ => const [],
      };

  static String labelFor(String category) => switch (category) {
        '슈즈' => '사이즈 (mm)',
        '의류' => '사이즈',
        '주얼리' => '호수',
        '시계' => '구성',
        _ => '옵션',
      };
}
