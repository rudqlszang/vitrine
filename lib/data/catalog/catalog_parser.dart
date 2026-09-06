import 'dart:convert';

import 'catalog_item.dart';

/// `catalog.json` 파싱. Flutter 에 의존하지 않아서
/// 앱과 `dart run` 스크립트 양쪽에서 쓴다.
abstract final class CatalogParser {
  static List<CatalogItem> parse(String rawJson) {
    final json = jsonDecode(rawJson) as Map<String, dynamic>;
    final items = json['items'] as List<dynamic>;
    return items
        .cast<Map<String, dynamic>>()
        .map(CatalogItem.fromJson)
        .toList();
  }
}
