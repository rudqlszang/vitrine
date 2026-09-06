import '../catalog/catalog_item.dart';

/// 화면에 실제로 뿌려지는 상품.
///
/// [catalog] 은 큐레이션된 정체성(브랜드·라인·모델)이고,
/// [price] / [imageUrl] / [seller] 는 데이터 소스에서 채워진 실감 정보다.
class ProductItem {
  const ProductItem({
    required this.catalog,
    required this.price,
    this.imageUrl,
    this.seller,
    this.isLive = false,
  });

  final CatalogItem catalog;

  /// 표시가. 조회 성공 시 실거래가, 실패 시 참고 시세.
  final int price;

  /// 저장하지 않는다. 런타임 표시 전용 URL.
  final String? imageUrl;

  /// 판매처. 예: KREAM
  final String? seller;

  /// 실시간 조회로 채워졌는지 여부. false 면 참고 시세를 쓰고 있다.
  final bool isLive;

  String get id => catalog.id;
  String get brand => catalog.brand;
  String get title => catalog.displayName;
  String get category => catalog.category;

  /// 조회 실패 시 참고 시세로 폴백한 항목.
  factory ProductItem.fallback(CatalogItem item) =>
      ProductItem(catalog: item, price: item.priceKrw);
}
