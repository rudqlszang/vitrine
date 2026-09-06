import '../catalog/catalog_item.dart';
import 'product_item.dart';

/// 상품의 실시간 가격·이미지를 채우는 데이터 소스.
///
/// 네이버 쇼핑 검색 API가 2026-07-31 종료된 전례가 있으므로
/// 소스를 갈아끼울 수 있도록 인터페이스로 분리해 둔다.
/// 구현체를 바꿔도 상위 계층은 건드리지 않는다.
abstract interface class ProductSource {
  /// 카탈로그 항목 하나의 실거래 정보를 조회한다.
  /// 실패해도 예외를 던지지 않고 [ProductItem.fallback] 을 돌려준다.
  Future<ProductItem> resolve(CatalogItem item);

  /// 여러 항목을 조회한다. 구현체가 동시성·호출량을 알아서 조절한다.
  Future<List<ProductItem>> resolveAll(List<CatalogItem> items);
}
