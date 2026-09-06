// 데이터 소스 품질 검증용 스크립트. 앱과 별개로 콘솔에서 돌린다.
//
//   dart run tool/check_source.dart [조회할_개수]
//
// SerpApi 무료 티어가 월 250회라 기본값을 10 으로 둔다.

import 'dart:io';

import 'package:vitrine/data/catalog/catalog_parser.dart';
import 'package:vitrine/data/product/mock_source.dart';
import 'package:vitrine/data/product/product_source.dart';
import 'package:vitrine/data/product/serpapi_source.dart';

Future<void> main(List<String> args) async {
  final limit = args.isEmpty ? 10 : int.tryParse(args.first) ?? 10;

  final catalog = CatalogParser.parse(
    await File('assets/catalog.json').readAsString(),
  );
  stdout.writeln('카탈로그 ${catalog.length}개 로드');

  final key = _readEnv('SERPAPI_KEY');
  final ProductSource source;
  if (key == null || key.isEmpty) {
    stdout.writeln('SERPAPI_KEY 없음 → 목데이터 모드');
    source = const MockSource();
  } else {
    stdout.writeln('SerpApi 모드 ($limit건 조회 = 쿼터 $limit회 소진)');
    source = SerpApiSource(key);
  }

  final targets = catalog.take(limit).toList();
  final sw = Stopwatch()..start();
  final items = await source.resolveAll(targets);
  sw.stop();

  stdout.writeln('\n${'=' * 72}');
  var live = 0;
  for (final p in items) {
    if (p.isLive) live++;
    final diff = p.price - p.catalog.priceKrw;
    final sign = diff >= 0 ? '+' : '-';
    stdout
      ..writeln('${p.brand}  ${p.title}')
      ..writeln('  표시가   ${_won(p.price)}'
          '   (참고 ${_won(p.catalog.priceKrw)}, $sign${_won(diff)})')
      ..writeln('  판매처   ${p.seller ?? '-'}'
          '   이미지 ${p.imageUrl != null ? 'O' : 'X'}'
          '   ${p.isLive ? 'LIVE' : 'FALLBACK'}')
      ..writeln('');
  }

  stdout
    ..writeln('=' * 72)
    ..writeln('실시간 조회 성공 $live / ${items.length}'
        '   소요 ${sw.elapsed.inSeconds}초');
}

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
  final s = v.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '₩$buf';
}
