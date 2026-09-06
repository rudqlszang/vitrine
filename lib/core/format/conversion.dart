/// 절약 금액을 실감나는 단위로 환산한다.
///
/// 숫자만 보여주면 크기가 와닿지 않는다.
/// "₩43,000,000" 보다 "제네시스 G80 한 대" 가 몸으로 느껴진다.
///
/// 항목마다 한국어 단위를 따로 둔다.
/// 이름에 "한 대"를 붙여두고 뒤에 "2개"를 이으면 "경차 한 대 2개"가 되어 어색하다.
abstract final class Conversion {
  /// (기준 금액, 이름, 단위). 오름차순이어야 한다.
  static const items = <(int, String, String)>[
    (4500, '아메리카노', '잔'),
    (12000, '점심', '끼'),
    (60000, '한우 오마카세', '번'),
    (1200000, '아이폰', '대'),
    (7000000, '유럽 왕복 항공권', '장'),
    (15000000, '경차', '대'),
    (70000000, '제네시스 G80', '대'),
    (300000000, '수도권 아파트 전세보증금', '건'),
    (2000000000, '강남 아파트', '채'),
  ];

  /// 금액에 맞는 환산 문구. 예: "제네시스 G80 한 대", "경차 두 대"
  static String describe(int amount) {
    if (amount <= 0) return '';

    // 하나 이상 살 수 있는 것 중 가장 비싼 항목을 고른다.
    var chosen = items.first;
    for (final item in items) {
      if (amount >= item.$1) chosen = item;
    }

    final count = amount ~/ chosen.$1;
    return '${chosen.$2} ${_counted(count, chosen.$3)}';
  }

  /// 환산 카드·결제 화면에 쓰는 한 문장.
  static String sentence(int amount) {
    if (amount <= 0) return '';
    return '$question ${describe(amount)}';
  }

  static const question = '지금까지 아낀 돈이면';

  /// 개수 + 단위. 한국어는 열까지 고유어로 세는 편이 자연스럽다.
  static String _counted(int n, String unit) {
    if (n >= 1000) return '$unit 세는 게 의미 없을 만큼';
    final native = _native(n);
    return native == null ? '$n$unit' : '$native $unit';
  }

  static String? _native(int n) => switch (n) {
        1 => '한',
        2 => '두',
        3 => '세',
        4 => '네',
        5 => '다섯',
        6 => '여섯',
        7 => '일곱',
        8 => '여덟',
        9 => '아홉',
        10 => '열',
        _ => null,
      };
}
