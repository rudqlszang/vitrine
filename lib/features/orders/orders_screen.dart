import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/won_format.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/local/providers.dart';
import '../../domain/order.dart';
import '../../widgets/status_timeline.dart';

/// 주문 내역.
///
/// 진행중 / 완료 두 탭. 진행중 주문은 배송 타임라인과 취소 버튼을 함께 보여준다.
/// 배송 대기 구간이 곧 냉각기이므로, 취소 버튼은 숨기지 않고 계속 노출한다.
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final ongoing = orders.where((o) => o.isPending).toList();
    final done = orders.where((o) => !o.isPending).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(Strings.ordersTitle),
          bottom: const TabBar(
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecond,
            indicatorColor: AppColors.textPrimary,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: AppColors.divider,
            tabs: [
              Tab(text: Strings.ordersOngoing),
              Tab(text: Strings.ordersDone),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OrderList(
              orders: ongoing,
              empty: Strings.ordersEmpty,
              showTimeline: true,
            ),
            _OrderList(
              orders: done,
              empty: Strings.ordersEmptyDone,
              showTimeline: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends ConsumerWidget {
  const _OrderList({
    required this.orders,
    required this.empty,
    required this.showTimeline,
  });

  final List<Order> orders;
  final String empty;
  final bool showTimeline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      return Center(child: Text(empty, style: AppTypo.caption));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: orders.length,
      separatorBuilder: (_, _) => Container(height: 8, color: AppColors.surface),
      itemBuilder: (context, i) => _OrderTile(
        order: orders[i],
        showTimeline: showTimeline,
      ),
    );
  }
}

class _OrderTile extends ConsumerWidget {
  const _OrderTile({required this.order, required this.showTimeline});

  final Order order;
  final bool showTimeline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = order.imageUrl;
    final remaining = order.remaining;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 상태 머리말 ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.isCancelled ? Strings.cancelled : order.status.label,
                style: AppTypo.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: order.isCancelled
                      ? AppColors.textSecond
                      : AppColors.textPrimary,
                ),
              ),
              if (!order.isCancelled && remaining != null)
                Text(
                  '${Strings.nextStageIn} ${_left(remaining)}',
                  style: AppTypo.caption,
                ),
            ],
          ),
          const SizedBox(height: 14),

          // --- 상품 ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: url == null || url.isEmpty
                    ? Container(color: AppColors.surface)
                    : Opacity(
                        opacity: order.isCancelled ? 0.35 : 1,
                        child: Image.network(url, fit: BoxFit.contain),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.brand.toUpperCase(), style: AppTypo.brand),
                    const SizedBox(height: 4),
                    Text(
                      order.title,
                      style: AppTypo.body.copyWith(color: AppColors.textSecond),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(Won.format(order.price), style: AppTypo.price),
                  ],
                ),
              ),
            ],
          ),

          if (showTimeline && !order.isCancelled) ...[
            const SizedBox(height: 22),
            StatusTimeline(current: order.status),
          ],

          if (order.isConfirmed) ...[
            const SizedBox(height: 14),
            Text(
              Strings.orderSavedConfirmed,
              style: AppTypo.caption.copyWith(color: AppColors.accent),
            ),
          ],

          if (order.isCancellable) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecond,
                  side: const BorderSide(color: AppColors.divider),
                  minimumSize: const Size.fromHeight(46),
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.all(Radius.circular(AppRadius.base)),
                  ),
                ),
                onPressed: () => _confirmCancel(context, ref),
                child: const Text(Strings.cancelOrder),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 취소하면 절약도 함께 사라진다. 되돌릴 수 없으므로 한 번 묻는다.
  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.base)),
        ),
        title: const Text(Strings.cancelConfirmTitle, style: AppTypo.title),
        content: const Text(Strings.cancelConfirmBody, style: AppTypo.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(Strings.cancelKeep),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              Strings.cancelDo,
              style: AppTypo.body.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );

    if (ok == true) {
      await ref.read(ordersProvider.notifier).cancel(order.id);
    }
  }

  /// 남은 시간을 사람이 읽는 형태로. 배속이 걸려 있으면 실제로는 더 빨리 지난다.
  static String _left(Duration d) {
    if (d.inHours >= 1) return '${d.inHours}시간';
    if (d.inMinutes >= 1) return '${d.inMinutes}분';
    return '곧';
  }
}
