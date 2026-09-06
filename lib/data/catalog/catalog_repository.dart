import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'resolved_item.dart';

/// 카탈로그 공급원.
///
/// 번들된 파일로 즉시 시작하고, 원격에 더 새 버전이 있으면 조용히 교체한다.
/// 네트워크가 없거나 원격이 죽어도 앱은 번들 버전으로 정상 동작해야 한다.
class CatalogRepository {
  CatalogRepository({Dio? dio}) : _dio = dio ?? Dio();

  static const bundledAsset = 'assets/catalog_resolved.json';

  /// 시세를 갱신하려면 `dart run tool/harvest.dart` 후 이 파일을 push 하면 된다.
  /// 설치된 앱들이 다음 실행 때 받아간다. 재설치가 필요 없다.
  static const remoteUrl =
      'https://raw.githubusercontent.com/rudqlszang/vitrine/main/assets/catalog_resolved.json';

  final Dio _dio;
  ResolvedCatalog? _cached;

  /// 번들 버전을 즉시 돌려준다. 화면은 이걸로 바로 그린다.
  Future<ResolvedCatalog> loadBundled() async {
    final cached = _cached;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString(bundledAsset);
    final catalog = ResolvedCatalog.parse(raw);
    _cached = catalog;
    return catalog;
  }

  /// 원격에 더 새 버전이 있으면 가져온다. 없거나 실패하면 null.
  /// 실패는 정상 흐름이다. 예외를 밖으로 던지지 않는다.
  Future<ResolvedCatalog?> fetchIfNewer(int currentVersion) async {
    try {
      final res = await _dio.get<String>(
        remoteUrl,
        options: Options(
          responseType: ResponseType.plain,
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      final body = res.data;
      if (body == null || body.isEmpty) return null;

      final remote = ResolvedCatalog.parse(body);
      if (remote.version <= currentVersion) return null;

      _cached = remote;
      debugPrint('[catalog] 원격 갱신 $currentVersion → ${remote.version}');
      return remote;
    } catch (e) {
      debugPrint('[catalog] 원격 갱신 건너뜀: $e');
      return null;
    }
  }
}
