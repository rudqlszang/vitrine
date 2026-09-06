// 카탈로그 전체의 실거래가·이미지를 수집해 assets/catalog_resolved.json 으로 굳힌다.
//
//   dart run tool/harvest.dart
//
// 검색 결과의 첫 번째를 그냥 쓰지 않는다.
// 후보들의 썸네일을 실제로 받아서 스튜디오 누끼인지 판별하고 가장 깨끗한 것을 고른다.
// 이미지 다운로드는 SerpApi 쿼터를 쓰지 않으므로 비용은 상품 수만큼의 검색 호출뿐이다.

import 'dart:convert';
import 'dart:io';

import 'package:vitrine/data/catalog/catalog_item.dart';
import 'package:vitrine/data/catalog/catalog_parser.dart';
import 'package:vitrine/data/product/result_filter.dart';
import 'package:vitrine/data/product/serpapi_source.dart';

import 'candidate_picker.dart';

const _output = 'assets/catalog_resolved.json';

Future<void> main(List<String> args) async {
  final key = _readEnv('SERPAPI_KEY');
  if (key == null || key.isEmpty) {
    stderr.writeln('SERPAPI_KEY 없음. .env 를 확인하라.');
    exitCode = 1;
    return;
  }

  final catalog = CatalogParser.parse(
    await File('assets/catalog.json').readAsString(),
  );
  stdout.writeln('${catalog.length}개 수집 시작 (쿼터 ${catalog.length}회 소진)\n');

  final source = SerpApiSource(key);
  final picker = CandidatePicker();
  final sw = Stopwatch()..start();

  final resolved = <Map<String, dynamic>>[];
  var clean = 0;
  var fallback = 0;

  for (final item in catalog) {
    final chosen = await _resolveOne(source, picker, item);
    if (chosen == null) {
      fallback++;
      stdout.writeln('FALL  ${item.brand} ${item.displayName}  (후보 없음)');
      resolved.add(_row(item, item.priceKrw, null, null, false));
      continue;
    }

    final score = chosen.image;
    if (score != null && score.isClean) clean++;
    stdout.writeln(
      'OK    ${item.brand} ${item.displayName}  '
      '${_won(chosen.result.price)}  ${chosen.result.seller ?? "-"}  '
      '[${score ?? "이미지없음"}]',
    );
    resolved.add(_row(
      item,
      chosen.result.price,
      chosen.result.imageUrl,
      chosen.result.seller,
      true,
    ));
  }
  sw.stop();

  final out = {
    'version': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    'harvestedAt': DateTime.now().toUtc().toIso8601String(),
    'total': resolved.length,
    'cleanImages': clean,
    'items': resolved,
  };
  await File(_output)
      .writeAsString(const JsonEncoder.withIndent('  ').convert(out));

  stdout
    ..writeln('\n${"=" * 60}')
    ..writeln('수집 ${resolved.length - fallback} / ${resolved.length}   '
        '깨끗한 이미지 $clean   ${sw.elapsed.inSeconds}초')
    ..writeln('저장: $_output');
}

/// 검색 → 필터 → 썸네일 평가 → 최고점 선택.
Future<ScoredCandidate?> _resolveOne(
  SerpApiSource source,
  CandidatePicker picker,
  CatalogItem item,
) async {
  try {
    final raw = await source.search(item.query);
    final kept = ResultFilter.apply(raw, item.priceKrw);
    if (kept.isEmpty) return null;

    final ranked = await picker.rank(kept);
    if (ranked.isEmpty) return null;

    final best = ranked.first;
    return best.total < 0 ? null : best;
  } catch (e) {
    stderr.writeln('  ! ${item.id}: $e');
    return null;
  }
}

Map<String, dynamic> _row(
  CatalogItem item,
  int price,
  String? imageUrl,
  String? seller,
  bool isLive,
) =>
    {
      'id': item.id,
      'brand': item.brand,
      'line': item.line,
      'model': item.model,
      'category': item.category,
      'query': item.query,
      'priceKrw': price,
      'imageUrl': imageUrl,
      'seller': seller,
      'isLive': isLive,
    };

String? _readEnv(String name) {
  final file = File('.env');
  if (!file.existsSync()) return null;
  for (final line in file.readAsLinesSync()) {
    final t = line.trim();
    if (t.isEmpty || t.startsWith('#')) continue;
    final i = t.indexOf('=');
    if (i > 0 && t.substring(0, i).trim() == name) {
      return t.substring(i + 1).trim();
    }
  }
  return null;
}

String _won(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '₩$buf';
}
