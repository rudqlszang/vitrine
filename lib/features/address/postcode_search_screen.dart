import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/strings.dart';
import '../../core/theme/tokens.dart';

/// 다음(카카오) 우편번호 검색 결과.
class PostcodeResult {
  const PostcodeResult({
    required this.postcode,
    required this.address,
    this.buildingName = '',
  });

  final String postcode;
  final String address;
  final String buildingName;

  /// "(12345) 서울 강남구 테헤란로 1 (건물명)" 형태로 쓰기 좋게.
  String get displayAddress =>
      buildingName.isEmpty ? address : '$address ($buildingName)';
}

/// 도로명주소 검색.
///
/// 행안부 juso.go.kr 은 승인키 신청이 필요하지만
/// 다음 우편번호 서비스는 키도 가입도 없이 쓸 수 있고,
/// 국내 앱 대부분이 쓰는 바로 그 화면이라 낯설지 않다.
///
/// 웹 위젯이라 WebView 로 띄운다. 안드로이드는 시스템 WebView 를 쓰므로
/// APK 가 거의 늘지 않는다.
class PostcodeSearchScreen extends StatefulWidget {
  const PostcodeSearchScreen({super.key});

  /// 선택한 주소를 돌려준다. 닫으면 null.
  static Future<PostcodeResult?> show(BuildContext context) {
    return Navigator.of(context).push<PostcodeResult>(
      MaterialPageRoute<PostcodeResult>(
        builder: (_) => const PostcodeSearchScreen(),
      ),
    );
  }

  @override
  State<PostcodeSearchScreen> createState() => _PostcodeSearchScreenState();
}

class _PostcodeSearchScreenState extends State<PostcodeSearchScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  /// 위젯을 감싸는 최소한의 페이지.
  /// 스크립트가 프로토콜 상대 경로(`//t1.daumcdn.net/...`)라
  /// baseUrl 을 https 로 줘야 로드된다.
  static const _html = '''
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
  <style>html,body,#wrap{margin:0;padding:0;width:100%;height:100%}</style>
</head>
<body>
  <div id="wrap"></div>
  <script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
  <script>
    new daum.Postcode({
      oncomplete: function (data) {
        Postcode.postMessage(JSON.stringify({
          zonecode: data.zonecode,
          address: data.roadAddress || data.jibunAddress,
          buildingName: data.buildingName || ''
        }));
      },
      onresize: function (size) {
        document.getElementById('wrap').style.height = size.height + 'px';
      },
      width: '100%',
      height: '100%'
    }).embed(document.getElementById('wrap'));
  </script>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.bg)
      ..addJavaScriptChannel(
        'Postcode',
        onMessageReceived: _onSelected,
      )
      ..setOnConsoleMessage(
        (m) => debugPrint('[postcode:js] ${m.message}'),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (e) => debugPrint(
            '[postcode:err] ${e.errorCode} ${e.description} ${e.url}',
          ),
        ),
      )
      ..loadHtmlString(_html, baseUrl: 'https://postcode.map.daum.net');
  }

  void _onSelected(JavaScriptMessage message) {
    try {
      final json = jsonDecode(message.message) as Map<String, dynamic>;
      final result = PostcodeResult(
        postcode: json['zonecode'] as String? ?? '',
        address: json['address'] as String? ?? '',
        buildingName: json['buildingName'] as String? ?? '',
      );
      if (mounted) Navigator.of(context).pop(result);
    } catch (_) {
      // 형식이 바뀌었더라도 화면이 멈추면 안 된다. 직접 입력으로 돌아간다.
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.postcodeTitle)),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading)
              const ColoredBox(
                color: AppColors.bg,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
