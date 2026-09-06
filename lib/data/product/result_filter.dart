/// 검색 결과 한 건. 소스별 응답을 이 형태로 정규화한 뒤 필터에 넣는다.
class RawResult {
  const RawResult({
    required this.title,
    required this.price,
    this.imageUrl,
    this.seller,
  });

  final String title;
  final int price;
  final String? imageUrl;
  final String? seller;
}

/// 검색 결과에서 엉뚱한 물건을 걸러내고 가장 적합한 하나를 고른다.
///
/// 큐레이션 방식이라 "무엇을 살지"는 이미 정해져 있다.
/// 여기서 하는 일은 그 물건의 시세를 조회했을 때 딸려온 잡음
/// (키링, 더스트백, 파우치, 중고 등) 을 떨어내는 것뿐이다.
abstract final class ResultFilter {
  /// 참고 시세 대비 허용 배율. 이 범위를 벗어나면 다른 품목으로 본다.
  static const minRatio = 0.3;
  static const maxRatio = 3.0;

  /// 제목에 이 단어가 있으면 본품이 아니다.
  static const _blocked = [
    '중고', '리퍼', '케이스', '보호필름', '스트랩만', '더스트백',
    '키링', '참고용', '보관함', '파우치만', '공병', '샘플',
  ];

  /// 정품 취급 신뢰도가 높은 판매처. 앞에 있을수록 우선.
  static const _preferredSellers = [
    'KREAM', '필웨이', '머스트잇', '발란', '트렌비',
    '신세계', '롯데', '현대', 'SSF', '공식',
  ];

  /// [referencePrice] 는 카탈로그의 참고 시세다.
  static List<RawResult> apply(
    List<RawResult> results,
    int referencePrice,
  ) {
    final min = (referencePrice * minRatio).round();
    final max = (referencePrice * maxRatio).round();

    final kept = results.where((r) {
      if (r.price < min || r.price > max) return false;
      final lower = r.title.toLowerCase();
      for (final word in _blocked) {
        if (lower.contains(word.toLowerCase())) return false;
      }
      return true;
    }).toList();

    kept.sort((a, b) {
      final rank = _sellerRank(a.seller).compareTo(_sellerRank(b.seller));
      if (rank != 0) return rank;
      // 같은 등급이면 참고 시세에 가까운 쪽을 택한다.
      final da = (a.price - referencePrice).abs();
      final db = (b.price - referencePrice).abs();
      return da.compareTo(db);
    });

    return kept;
  }

  /// 낮을수록 우선.
  static int _sellerRank(String? seller) {
    if (seller == null) return _preferredSellers.length;
    for (var i = 0; i < _preferredSellers.length; i++) {
      if (seller.contains(_preferredSellers[i])) return i;
    }
    return _preferredSellers.length;
  }
}
