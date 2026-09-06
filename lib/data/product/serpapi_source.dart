import 'package:dio/dio.dart';

import '../catalog/catalog_item.dart';
import 'product_item.dart';
import 'product_source.dart';
import 'result_filter.dart';

/// SerpApi 의 Google Shopping 엔진으로 실거래가·이미지를 조회한다.
///
/// Flutter 에 의존하지 않는 순수 Dart 라 `dart run` 스크립트에서도 그대로 쓴다.
class SerpApiSource implements ProductSource {
  SerpApiSource(this._apiKey, {Dio? dio}) : _dio = dio ?? Dio();

  static const _endpoint = 'https://serpapi.com/search.json';

  /// 무료 티어가 월 250회다. 호출 하나가 아깝다.
  static const cacheTtl = Duration(minutes: 30);

  final String _apiKey;
  final Dio _dio;
  final _cache = <String, _CacheEntry>{};

  @override
  Future<ProductItem> resolve(CatalogItem item) async {
    final cached = _cache[item.id];
    if (cached != null && !cached.isExpired) return cached.value;

    try {
      final results = await search(item.query);
      final kept = ResultFilter.apply(results, item.priceKrw);

      final ProductItem product;
      if (kept.isEmpty) {
        // 전부 걸러졌으면 참고 시세로 간다. 앱은 계속 동작해야 한다.
        product = ProductItem.fallback(item);
      } else {
        final best = kept.first;
        product = ProductItem(
          catalog: item,
          price: best.price,
          imageUrl: best.imageUrl,
          seller: best.seller,
          isLive: true,
        );
      }

      _cache[item.id] = _CacheEntry(product);
      return product;
    } catch (_) {
      // 네트워크 실패·쿼터 초과 어느 쪽이든 앱이 멈추면 안 된다.
      return ProductItem.fallback(item);
    }
  }

  @override
  Future<List<ProductItem>> resolveAll(List<CatalogItem> items) async {
    const concurrency = 4;
    final out = <ProductItem>[];

    for (var i = 0; i < items.length; i += concurrency) {
      final chunk = items.skip(i).take(concurrency);
      out.addAll(await Future.wait(chunk.map(resolve)));
    }
    return out;
  }

  /// 검색 결과를 정규화해 돌려준다. 수집 스크립트가 자체 선별을 하려고 쓴다.
  Future<List<RawResult>> search(String query) async {
    final res = await _dio.get<Map<String, dynamic>>(
      _endpoint,
      queryParameters: {
        'engine': 'google_shopping',
        'q': query,
        'gl': 'kr',
        'hl': 'ko',
        'api_key': _apiKey,
      },
      options: Options(receiveTimeout: const Duration(seconds: 30)),
    );

    final raw = res.data?['shopping_results'];
    if (raw is! List) return const [];

    return raw
        .whereType<Map<String, dynamic>>()
        .map(_toRawResult)
        .whereType<RawResult>()
        .toList();
  }

  /// 가격은 `extracted_price` (숫자) 를 우선 쓰고,
  /// 없으면 `price` 문자열("₩12,880,000")에서 숫자만 뽑는다.
  static RawResult? _toRawResult(Map<String, dynamic> json) {
    final title = json['title'] as String?;
    if (title == null || title.isEmpty) return null;

    final price = _parsePrice(json);
    if (price == null || price <= 0) return null;

    return RawResult(
      title: title,
      price: price,
      imageUrl: json['thumbnail'] as String?,
      seller: json['source'] as String?,
    );
  }

  static int? _parsePrice(Map<String, dynamic> json) {
    final extracted = json['extracted_price'];
    if (extracted is num) return extracted.round();

    final text = json['price'];
    if (text is String) {
      final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.isNotEmpty) return int.tryParse(digits);
    }
    return null;
  }
}

class _CacheEntry {
  _CacheEntry(this.value) : storedAt = DateTime.now();

  final ProductItem value;
  final DateTime storedAt;

  bool get isExpired =>
      DateTime.now().difference(storedAt) > SerpApiSource.cacheTtl;
}
