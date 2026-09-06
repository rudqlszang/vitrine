import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// 썸네일 품질 평가 결과.
class ImageScore {
  const ImageScore({
    required this.brightness,
    required this.variance,
    required this.score,
  });

  /// 테두리 평균 밝기 0~255.
  final double brightness;

  /// 테두리 밝기 표준편차. 클수록 배경이 지저분하다.
  final double variance;

  /// 높을수록 좋다.
  final double score;

  /// 스튜디오 누끼로 볼 수 있는가.
  bool get isClean => variance < 24;

  @override
  String toString() =>
      'b=${brightness.toStringAsFixed(0)} v=${variance.toStringAsFixed(1)} '
      's=${score.toStringAsFixed(1)}';
}

/// 상품 썸네일이 "스튜디오 누끼"인지 "현장 사진"인지 판별한다.
///
/// 테두리 픽셀만 본다. 상품은 대개 가운데 있으므로 테두리는 배경이다.
/// 배경이 균일하고 밝으면 누끼, 얼룩덜룩하면 테이블 위에서 찍은 판매자 사진이다.
/// 워터마크가 박힌 사진은 대부분 후자라 이 지표로 같이 걸러진다.
abstract final class ImageScorer {
  /// 디코딩 실패 시 null.
  static ImageScore? evaluate(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    // 긴 변 96px 로 줄여서 평가한다. 정확도보다 속도가 중요하다.
    final small = img.copyResize(
      decoded,
      width: decoded.width >= decoded.height ? 96 : null,
      height: decoded.height > decoded.width ? 96 : null,
    );

    final samples = <double>[];
    final w = small.width;
    final h = small.height;
    const inset = 2;

    void sample(int x, int y) {
      if (x < 0 || y < 0 || x >= w || y >= h) return;
      final p = small.getPixel(x, y);
      // 지각 밝기(luma).
      samples.add(0.299 * p.r + 0.587 * p.g + 0.114 * p.b);
    }

    for (var x = 0; x < w; x++) {
      sample(x, inset);
      sample(x, h - 1 - inset);
    }
    for (var y = 0; y < h; y++) {
      sample(inset, y);
      sample(w - 1 - inset, y);
    }
    if (samples.isEmpty) return null;

    final mean = samples.reduce((a, b) => a + b) / samples.length;
    final varSum = samples
        .map((v) => (v - mean) * (v - mean))
        .reduce((a, b) => a + b);
    final sd = math.sqrt(varSum / samples.length);

    return ImageScore(
      brightness: mean,
      variance: sd,
      score: _score(mean, sd),
    );
  }

  /// 균일함을 가장 무겁게 보고, 그다음이 밝기다.
  /// 검정 누끼도 지저분한 현장 사진보다는 낫기 때문이다.
  static double _score(double brightness, double sd) {
    // 균일도: 표준편차 0 이면 60점, 40 이상이면 0점.
    final uniformity = math.max(0, 60 - sd * 1.5);
    // 밝기: 흰 배경(240 이상)이 만점 40점.
    final light = (brightness / 255) * 40;
    return uniformity + light;
  }
}
