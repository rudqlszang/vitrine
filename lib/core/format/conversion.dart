import 'won_format.dart';

/// 절약 금액을 실감나는 단위로 환산한다.
///
/// 숫자만 보여주면 크기가 와닿지 않는다.
/// "₩43,000,000" 보다 "제네시스 G80 한 대" 가 몸으로 느껴진다.
abstract final class Conversion {
  /// (기준 금액, 문구). 오름차순이어야 한다.
  static const items = <(int, String)>[
    (500, '스타벅스 아메리카노'),
    (12000, '점심 한 끼'),
    (1200000, '아이폰 한 대'),
    (7000000, '유럽 왕복 항공권'),
    (15000000, '경차 한 대'),
    (70000000, '제네시스 G80 한 대'),
    (300000000, '수도권 아파트 전세보증금'),
    (2000000000, '강남 아파트 한 채'),
  ];

  /// 금액에 맞는 환산 문구. 예: "제네시스 G80 한 대 2번"
  static String describe(int amount) {
    if (amount <= 0) return '';

    // 1개 이상 살 수 있는 것 중 가장 비싼 항목을 고른다.
    var chosen = items.first;
    for (final item in items) {
      if (amount >= item.$1) chosen = item;
    }

    final count = amount ~/ chosen.$1;
    if (count <= 1) return '${chosen.$2} 값';
    return '${chosen.$2} ${_count(count)}';
  }

  /// 너무 큰 수는 세는 의미가 없다.
  static String _count(int n) => n >= 1000 ? '999개 넘게' : '$n개';

  /// 리포트 카드용 전체 문장.
  static String sentence(int amount) {
    if (amount <= 0) return '';
    return '${Won.format(amount)} — ${describe(amount)}';
  }
}
