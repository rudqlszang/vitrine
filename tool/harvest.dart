// 카탈로그 전체의 실거래가·이미지를 수집해 assets/catalog_resolved.json 으로 굳힌다.
//
//   dart run tool/harvest.dart
//
// 앱은 이 결과물을 번들로 들고 시작하고, 갱신본은 원격에서 받아 덮어쓴다.
// 따라서 실행 시점의 쿼터만 쓰고 사용자 기기에서는 API 를 호출하지 않는다.

import 'dart:convert';
import 'dart:io';

import 'package:vitrine/data/catalog/catalog_parser.dart';
import 'package:vitrine/data/product/serpapi_source.dart';

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
  stdout.writeln('${catalog.length}개 조회 시작 (쿼터 ${catalog.length}회 소진)\n');

  final source = SerpApiSource(key);
  final sw = Stopwatch()..start();
  final items = await source.resolveAll(catalog);
  sw.stop();

  var live = 0;
  final resolved = <Map<String, dynamic>>[];
  for (final p in items) {
    if (p.isLive) live++;
    stdout.writeln(
      '${p.isLive ? "OK  " : "FALL"}  ${p.brand} ${p.title}  '
      '${_won(p.price)}  ${p.seller ?? "-"}',
    );
    resolved.add({
      'id': p.catalog.id,
      'brand': p.catalog.brand,
      'line': p.catalog.line,
      'model': p.catalog.model,
      'category': p.catalog.category,
      'query': p.catalog.query,
      // 조회 성공분은 실거래가로 참고 시세를 갱신한다.
      'priceKrw': p.price,
      'imageUrl': p.imageUrl,
      'seller': p.seller,
      'isLive': p.isLive,
    });
  }

  final now = DateTime.now().toUtc().toIso8601String();
  final out = {
    'version': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    'harvestedAt': now,
    'liveCount': live,
    'total': items.length,
    'items': resolved,
  };

  await File(_output).writeAsString(
    const JsonEncoder.withIndent('  ').convert(out),
  );

  stdout
    ..writeln('\n${"=" * 60}')
    ..writeln('실시간 $live / ${items.length}   ${sw.elapsed.inSeconds}초')
    ..writeln('저장: $_output');
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
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '₩$buf';
}
