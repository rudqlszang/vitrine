import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/local/providers.dart';
import '../home/home_screen.dart';
import '../mypage/mypage_screen.dart';
import '../onboarding/signup_screen.dart';
import '../onboarding/splash_screen.dart';
import '../orders/orders_screen.dart';

/// 앱 진입 흐름과 하단 탭.
///
/// 스플래시 → (미가입이면) 회원가입 → 홈.
/// 가입 여부는 Hive 에 프로필이 있는지로 판단한다. 세션도 로그인도 없다.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

enum _Phase { splash, signup, main }

class _AppShellState extends ConsumerState<AppShell> {
  _Phase _phase = _Phase.splash;
  int _tab = 0;

  void _afterSplash() {
    final signedUp = ref.read(profileProvider) != null;
    setState(() => _phase = signedUp ? _Phase.main : _Phase.signup);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _Phase.splash => SplashScreen(onDone: _afterSplash),
      _Phase.signup =>
        SignupScreen(onDone: () => setState(() => _phase = _Phase.main)),
      _Phase.main => _main(),
    };
  }

  Widget _main() {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [
          HomeScreen(),
          OrdersScreen(),
          MyPageScreen(),
        ],
      ),
      bottomNavigationBar: _TabBar(
        index: _tab,
        onSelect: (i) => setState(() => _tab = i),
      ),
    );
  }
}

/// 하단 탭. Material 기본 BottomNavigationBar 는 아이콘·색이 요란해서 직접 그린다.
class _TabBar extends StatelessWidget {
  const _TabBar({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  static const _labels = [
    Strings.tabShop,
    Strings.ordersTitle,
    Strings.myPageTitle,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          child: Row(
            children: [
              for (var i = 0; i < _labels.length; i++)
                Expanded(
                  child: GestureDetector(
                    onTap: () => onSelect(i),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Text(
                        _labels[i],
                        style: AppTypo.body.copyWith(
                          fontWeight:
                              i == index ? FontWeight.w600 : FontWeight.w400,
                          color: i == index
                              ? AppColors.textPrimary
                              : AppColors.textSecond,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
