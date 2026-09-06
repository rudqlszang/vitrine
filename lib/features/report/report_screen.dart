import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/conversion.dart';
import '../../core/format/won_format.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/local/providers.dart';
import '../../domain/order.dart';
import '../../widgets/brand_mark.dart';

/// 절약 리포트.
///
/// 이 앱의 결과물은 물건이 아니라 절약 기록이다.
/// 숫자만 나열하지 않고 환산 문구를 함께 두어 크기를 몸으로 느끼게 한다.
class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final savings = ref.watch(savingsProvider);
    final confirmed = orders.where((o) => o.isConfirmed).toList();

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.reportTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          _ConversionCard(
            amount: savings.confirmed,
            count: confirmed.length,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          if (confirmed.isEmpty)
            Text(Strings.reportEmpty, style: AppTypo.caption)
          else ...[
            Text(Strings.reportMonthly, style: AppTypo.caption),
            const SizedBox(height: 14),
            _MonthlyBars(orders: confirmed),
          ],
          const SizedBox(height: AppSpacing.sectionGap),
        ],
      ),
    );
  }
}

/// 공유용 카드. RepaintBoundary 로 감싸 두어 이미지로 캡처할 수 있다.
class _ConversionCard extends StatelessWidget {
  const _ConversionCard({required this.amount, required this.count});

  final int amount;
  final int count;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        color: AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BrandMark(height: 12),
            const SizedBox(height: 26),
            Text(Strings.reportTotal, style: AppTypo.caption),
            const SizedBox(height: 6),
            Text(
              Won.format(amount),
              style: AppTypo.display.copyWith(
                fontSize: 30,
                color: AppColors.accent,
              ),
            ),
            if (amount > 0) ...[
              const SizedBox(height: 18),
              Text(Conversion.question, style: AppTypo.caption),
              const SizedBox(height: 4),
              Text(
                Conversion.describe(amount),
                style: AppTypo.title.copyWith(fontSize: 18),
              ),
            ],
            const SizedBox(height: 22),
            Text('${Strings.reportCount}  $count', style: AppTypo.caption),
          ],
        ),
      ),
    );
  }
}

/// 월별 절약 막대. 차트 라이브러리를 쓰지 않는다.
/// 막대 몇 개를 위해 의존성을 늘릴 이유가 없고, 얇은 검정 막대가 톤에도 맞는다.
class _MonthlyBars extends StatelessWidget {
  const _MonthlyBars({required this.orders});

  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    final byMonth = <String, int>{};
    for (final o in orders) {
      final key = '${o.createdAt.year}.${o.createdAt.month.toString().padLeft(2, '0')}';
      byMonth[key] = (byMonth[key] ?? 0) + o.price;
    }

    final keys = byMonth.keys.toList()..sort();
    final max = byMonth.values.fold(0, (a, b) => a > b ? a : b);

    return Column(
      children: [
        for (final k in keys) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 58,
                child: Text(k, style: AppTypo.caption),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final ratio = max == 0 ? 0.0 : byMonth[k]! / max;
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 8,
                        width: c.maxWidth * ratio,
                        color: AppColors.textPrimary,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Text(Won.compact(byMonth[k]!), style: AppTypo.caption),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
