import 'package:flutter/services.dart' show rootBundle;

import 'catalog_item.dart';
import 'catalog_parser.dart';

/// 앱에서 `assets/catalog.json` 을 읽어 큐레이션 목록을 만든다.
abstract final class CatalogLoader {
  static const assetPath = 'assets/catalog.json';

  static List<CatalogItem>? _cached;

  static Future<List<CatalogItem>> load() async {
    final cached = _cached;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString(assetPath);
    final items = CatalogParser.parse(raw);
    _cached = items;
    return items;
  }
}
