import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'image_scorer.dart';
import 'package:vitrine/data/product/result_filter.dart';

/// 후보 하나와 그 썸네일 평가.
class ScoredCandidate {
  const ScoredCandidate({required this.result, this.image});

  final RawResult result;
  final ImageScore? image;

  /// 이미지를 못 받았거나 못 읽으면 최하점.
  double get total => image?.score ?? -1;
}

/// 필터를 통과한 후보들의 썸네일을 실제로 받아보고 가장 깨끗한 것을 고른다.
///
/// 첫 번째 결과를 그냥 쓰면 나무 테이블 위에서 찍은 워터마크 사진이 걸린다.
/// 검색 API 는 이미 호출된 뒤라 여기서 이미지를 더 받아도 쿼터를 쓰지 않는다.
class CandidatePicker {
  CandidatePicker({Dio? dio, this.maxCandidates = 6})
      : _dio = dio ?? Dio();

  final Dio _dio;

  /// 몇 개까지 실제로 받아볼지. 늘리면 품질이 오르고 느려진다.
  final int maxCandidates;

  Future<List<ScoredCandidate>> rank(List<RawResult> candidates) async {
    final targets = candidates.take(maxCandidates).toList();
    final scored = await Future.wait(targets.map(_evaluate));
    scored.sort((a, b) => b.total.compareTo(a.total));
    return scored;
  }

  Future<ScoredCandidate> _evaluate(RawResult r) async {
    final url = r.imageUrl;
    if (url == null || url.isEmpty) return ScoredCandidate(result: r);

    try {
      final res = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      final data = res.data;
      if (data == null) return ScoredCandidate(result: r);

      return ScoredCandidate(
        result: r,
        image: ImageScorer.evaluate(Uint8List.fromList(data)),
      );
    } catch (_) {
      return ScoredCandidate(result: r);
    }
  }
}
