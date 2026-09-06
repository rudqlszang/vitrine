import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/won_format.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/time/time_scale.dart';
import '../../data/local/providers.dart';
import '../address/address_form_screen.dart';
import '../orders/orders_screen.dart';
import '../report/report_screen.dart';

/// 마이페이지.
///
/// 잔고를 볼 수 있는 유일한 상시 화면이다.
/// 홈에서 감춰둔 숫자를 여기 와서 확인한다. 통장을 조회하는 감각이다.
class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final address = ref.watch(addressProvider);
    final savings = ref.watch(savingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.myPageTitle)),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // --- 프로필 ---
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.displayName ?? '',
                  style: AppTypo.title.copyWith(fontSize: 22),
                ),
                if (profile != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${Strings.myJoined} ${_date(profile.joinedAt)}',
                    style: AppTypo.caption,
                  ),
                ],
              ],
            ),
          ),

          Container(height: 8, color: AppColors.surface),

          // --- 금액 ---
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              children: [
                _Amount(
                  label: Strings.myBalance,
                  value: Won.format(savings.balance),
                  big: true,
                ),
                const SizedBox(height: 20),
                _Amount(
                  label: Strings.mySavedConfirmed,
                  value: Won.format(savings.confirmed),
                  color: AppColors.accent,
                ),
                const SizedBox(height: 12),
                _Amount(
                  label: Strings.mySavedPending,
                  value: Won.format(savings.pending),
                ),
              ],
            ),
          ),

          Container(height: 8, color: AppColors.surface),

          // --- 메뉴 ---
          _Menu(
            label: Strings.myOrders,
            onTap: () => _push(context, const OrdersScreen()),
          ),
          _Menu(
            label: Strings.myReport,
            onTap: () => _push(context, const ReportScreen()),
          ),
          _Menu(
            label: Strings.myAddress,
            detail: address?.recipient,
            onTap: () => _push(context, const AddressFormScreen()),
          ),

          // --- 개발용 ---
          if (!kReleaseMode) ...[
            Container(height: 8, color: AppColors.surface),
            const _TimeScaleRow(),
          ],

          Container(height: 8, color: AppColors.surface),
          _Menu(
            label: Strings.logout,
            onTap: () => _confirmLogout(context, ref),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  /// 계정이 없으므로 로그아웃과 데이터 삭제가 같은 동작이다.
  /// 주문·절약이 전부 사라지고 되돌릴 수 없으니 분명히 알린다.
  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.base)),
        ),
        title: const Text(Strings.logoutConfirmTitle, style: AppTypo.title),
        content: const Text(Strings.logoutConfirmBody, style: AppTypo.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(Strings.cancelKeep),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              Strings.logout,
              style: AppTypo.body.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );

    // 프로필이 사라지면 AppShell 이 가입 화면으로 되돌린다.
    if (ok == true) await resetEverything(ref);
  }

  static String _date(DateTime d) =>
      '${d.year}. ${d.month.toString().padLeft(2, '0')}. '
      '${d.day.toString().padLeft(2, '0')}';
}

class _Amount extends StatelessWidget {
  const _Amount({
    required this.label,
    required this.value,
    this.big = false,
    this.color,
  });

  final String label;
  final String value;
  final bool big;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: AppTypo.caption),
        Text(
          value,
          style: big
              ? AppTypo.display.copyWith(fontSize: 26)
              : AppTypo.price.copyWith(fontSize: 16, color: color),
        ),
      ],
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu({required this.label, required this.onTap, this.detail});

  final String label;
  final String? detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: 18,
        ),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTypo.body)),
            if (detail != null)
              Text(detail!, style: AppTypo.caption),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textSecond,
            ),
          ],
        ),
      ),
    );
  }
}

/// 배송이 몇 시간씩 걸려서 그대로는 단계 전환을 볼 수 없다.
/// 릴리스 빌드에서는 노출하지 않는다.
class _TimeScaleRow extends StatefulWidget {
  const _TimeScaleRow();

  @override
  State<_TimeScaleRow> createState() => _TimeScaleRowState();
}

class _TimeScaleRowState extends State<_TimeScaleRow> {
  @override
  Widget build(BuildContext context) {
    final scale = TimeScale.instance;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Strings.myTimeScale, style: AppTypo.caption),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final f in TimeScale.options) ...[
                GestureDetector(
                  onTap: () => setState(() => scale.factor = f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: scale.factor == f
                          ? AppColors.textPrimary
                          : AppColors.bg,
                      border: Border.all(
                        color: scale.factor == f
                            ? AppColors.textPrimary
                            : AppColors.divider,
                      ),
                    ),
                    child: Text(
                      '${f}x',
                      style: AppTypo.caption.copyWith(
                        color: scale.factor == f
                            ? AppColors.bg
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
