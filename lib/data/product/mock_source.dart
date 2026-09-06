import '../catalog/catalog_item.dart';
import 'product_item.dart';
import 'product_source.dart';

/// API 키가 없거나 쿼터가 소진됐을 때 쓰는 폴백.
///
/// 카탈로그의 참고 시세를 그대로 표시가로 쓴다.
/// 이미지가 없으므로 화면은 타이포 중심으로 렌더링된다.
class MockSource implements ProductSource {
  const MockSource();

  @override
  Future<ProductItem> resolve(CatalogItem item) async =>
      ProductItem.fallback(item);

  @override
  Future<List<ProductItem>> resolveAll(List<CatalogItem> items) async =>
      items.map(ProductItem.fallback).toList();
}
