import 'package:flutter/material.dart';

/// 스플래시.
///
/// 어두운 쇼윈도 아트워크를 꽉 채운다.
/// 이 화면이 곧 비트린(진열창)이고, 여기를 지나면 밝은 매장 안으로 들어간다.
/// 앱 내부가 흰 무채색인 것과 어긋나 보이지만 그 낙차가 의도다.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  static const hold = Duration(milliseconds: 1600);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(SplashScreen.hold).then((_) {
      if (mounted) widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        // 화면 비율이 제각각이므로 채우고 남는 부분은 잘라낸다.
        // 로고와 상품이 중앙에 있어 가장자리가 잘려도 괜찮다.
        child: Image.asset(
          'assets/brand/splash.png',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
