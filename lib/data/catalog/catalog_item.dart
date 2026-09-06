/// 큐레이션된 명품 항목.
///
/// 이 목록이 "무엇이 앱에 나올지"를 100% 결정한다.
/// 검색 결과를 그대로 쓰지 않기 때문에 짝퉁·액세서리가 섞일 자리가 없다.
class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.brand,
    required this.line,
    required this.model,
    required this.category,
    required this.priceKrw,
    required this.query,
  });

  final String id;

  /// 대문자 표기. 로고는 쓰지 않고 텍스트로만 노출한다.
  final String brand;

  /// 라인명. 예: 클래식 플랩
  final String line;

  /// 모델 상세. 예: 미디움 캐비어
  final String model;

  final String category;

  /// 참고 시세. 실시간 조회 실패 시 이 값을 그대로 쓰고,
  /// 조회 성공 시에는 이상값을 걸러내는 기준선이 된다.
  final int priceKrw;

  /// 데이터 소스 조회용 검색어.
  final String query;

  String get displayName => '$line $model';

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(
      id: json['id'] as String,
      brand: json['brand'] as String,
      line: json['line'] as String,
      model: json['model'] as String,
      category: json['category'] as String,
      priceKrw: json['priceKrw'] as int,
      query: json['query'] as String,
    );
  }
}
