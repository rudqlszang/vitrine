import 'dart:convert';

/// 수집 완료된 상품. `catalog_resolved.json` 한 줄에 대응한다.
///
/// 앱은 번들된 파일로 시작하고, 원격에 더 높은 [version] 이 있으면 교체한다.
class ResolvedItem {
  const ResolvedItem({
    required this.id,
    required this.brand,
    required this.line,
    required this.model,
    required this.category,
    required this.priceKrw,
    this.imageUrl,
    this.seller,
  });

  final String id;
  final String brand;
  final String line;
  final String model;
  final String category;
  final int priceKrw;
  final String? imageUrl;
  final String? seller;

  String get title => '$line $model';

  factory ResolvedItem.fromJson(Map<String, dynamic> json) => ResolvedItem(
        id: json['id'] as String,
        brand: json['brand'] as String,
        line: json['line'] as String,
        model: json['model'] as String,
        category: json['category'] as String,
        priceKrw: json['priceKrw'] as int,
        imageUrl: json['imageUrl'] as String?,
        seller: json['seller'] as String?,
      );
}

/// 카탈로그 한 벌. [version] 으로 원격 갱신 여부를 판단한다.
class ResolvedCatalog {
  const ResolvedCatalog({required this.version, required this.items});

  final int version;
  final List<ResolvedItem> items;

  static ResolvedCatalog parse(String rawJson) {
    final json = jsonDecode(rawJson) as Map<String, dynamic>;
    final items = (json['items'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(ResolvedItem.fromJson)
        .toList();
    return ResolvedCatalog(
      version: json['version'] as int? ?? 0,
      items: items,
    );
  }

  List<String> get categories {
    final seen = <String>[];
    for (final i in items) {
      if (!seen.contains(i.category)) seen.add(i.category);
    }
    return seen;
  }
}
