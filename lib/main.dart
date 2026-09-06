import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/strings.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/motion.dart';
import 'core/theme/tokens.dart';
import 'core/theme/typography.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 가 없거나 비어 있어도 앱은 떠야 한다.
  // (키가 없으면 목데이터로 폴백 — 2단계에서 구현)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('[env] .env 로드 실패, 목데이터 모드로 진행: $e');
  }

  runApp(const ProviderScope(child: LuxeApp()));
}

class LuxeApp extends StatelessWidget {
  const LuxeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const SetupCheckScreen(),
    );
  }
}

/// 1단계 셋업 검증용 화면.
/// 폰트 · 고정폭 숫자 · 색 토큰이 의도대로 적용됐는지 눈으로 확인한다.
/// 2단계 진입 시 삭제한다.
class SetupCheckScreen extends StatefulWidget {
  const SetupCheckScreen({super.key});

  @override
  State<SetupCheckScreen> createState() => _SetupCheckScreenState();
}

class _SetupCheckScreenState extends State<SetupCheckScreen> {
  static const _initialBalance = 1000000000000; // 1조
  int _balance = _initialBalance;
  int _saved = 0;

  void _spend() {
    setState(() {
      const price = 43000000; // 4300만
      if (_balance < price) return;
      _balance -= price;
      _saved += price;
    });
  }

  void _reset() {
    setState(() {
      _balance = _initialBalance;
      _saved = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasKey = (dotenv.maybeGet('NAVER_CLIENT_ID') ?? '').isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.setupTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          // --- 잔고 / 절약: 앱의 얼굴 ---
          Text(Strings.balance, style: AppTypo.caption),
          const SizedBox(height: 4),
          _Counter(value: _balance, style: AppTypo.display),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(Strings.saved, style: AppTypo.caption),
              const SizedBox(width: 8),
              _Counter(
                value: _saved,
                style: AppTypo.price.copyWith(color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.cardGap),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _spend,
                  child: const Text('₩43,000,000 지르기'),
                ),
              ),
              const SizedBox(width: AppSpacing.cardGap),
              TextButton(onPressed: _reset, child: const Text('초기화')),
            ],
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          // --- 폰트 웨이트 ---
          const _SectionLabel(Strings.setupFontCheck),
          for (final (weight, name) in const [
            (FontWeight.w400, 'Regular 400'),
            (FontWeight.w500, 'Medium 500'),
            (FontWeight.w600, 'SemiBold 600'),
            (FontWeight.w700, 'Bold 700'),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '$name · 명품 쇼핑 LUXE 0123456789',
                style: AppTypo.body.copyWith(fontWeight: weight),
              ),
            ),

          const SizedBox(height: AppSpacing.sectionGap),

          // --- 고정폭 숫자 검증 ---
          const _SectionLabel(Strings.setupTabularCheck),
          Text('1111111111', style: AppTypo.price),
          Text('0000000000', style: AppTypo.price),
          const SizedBox(height: 6),
          Text(
            '위 두 줄의 폭이 같아야 정상 (tabular 적용됨)',
            style: AppTypo.caption,
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          // --- 색 토큰 ---
          const _SectionLabel(Strings.setupColorCheck),
          const _Swatch('surface', AppColors.surface),
          const _Swatch('divider', AppColors.divider),
          const _Swatch('textSecond', AppColors.textSecond),
          const _Swatch('textPrimary', AppColors.textPrimary),
          const _Swatch('accent (절약 전용)', AppColors.accent),

          const SizedBox(height: AppSpacing.sectionGap),

          // --- 환경 상태 ---
          const _SectionLabel('.env'),
          Text(
            hasKey
                ? '네이버 API 키 로드됨'
                : '키 없음 — 2단계에서 목데이터로 폴백',
            style: AppTypo.body,
          ),
        ],
      ),
    );
  }
}

/// 숫자 카운팅. 4단계에서 widgets/money_counter.dart 로 정식 구현 예정.
class _Counter extends StatelessWidget {
  const _Counter({required this.value, required this.style});

  final int value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: value.toDouble(), end: value.toDouble()),
      duration: AppMotion.counterUpdate,
      curve: AppMotion.standardCurve,
      builder: (context, v, _) => Text(_format(v.round()), style: style),
    );
  }

  static String _format(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '₩$buf';
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: AppTypo.title),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.color);

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: AppColors.divider),
            ),
          ),
          const SizedBox(width: 12),
          Text(name, style: AppTypo.body),
        ],
      ),
    );
  }
}
