import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/format/won_format.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/catalog/resolved_item.dart';
import '../../data/local/providers.dart';
import '../../domain/order.dart';
import '../../domain/purchase_option.dart';
import '../checkout/checkout_screen.dart';
import '../checkout/option_sheet.dart';
import '../checkout/order_form_screen.dart';
import '../checkout/payment_progress.dart';

/// 상품 상세.
///
/// 이미지 한 장 · 브랜드 · 상품명 · 가격 · 구매 버튼.
/// 부티크 진열대처럼 상품 하나만 두고 나머지는 비운다.
class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.item});

  final ResolvedItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savings = ref.watch(savingsProvider);
    final affordable = savings.balance >= item.priceKrw;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const SizedBox.shrink(),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _Hero(url: item.imageUrl),
                  const SizedBox(height: AppSpacing.sectionGap),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.brand.toUpperCase(), style: AppTypo.brand),
                        const SizedBox(height: 8),
                        Text(item.title, style: AppTypo.title),
                        const SizedBox(height: 20),
                        Text(
                          Won.format(item.priceKrw),
                          style: AppTypo.display.copyWith(fontSize: 24),
                        ),
                        if (item.seller != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            '${Strings.sellerPrefix} ${item.seller}',
                            style: AppTypo.caption,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sectionGap),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _BuyBar(
              item: item,
              affordable: affordable,
              onBuy: () => _buy(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  /// 구매 버튼 → 옵션 선택 → 주문서 → 결제 진행 → 결제 완료.
  /// 크림·무신사의 흐름을 따른다. 한 번에 끝나면 지른 감각이 남지 않는다.
  Future<void> _buy(BuildContext context, WidgetRef ref) async {
    // 1) 사이즈가 있는 카테고리만 옵션을 묻는다.
    String? option;
    if (PurchaseOption.forCategory(item.category).isNotEmpty) {
      option = await OptionSheet.show(context, item);
      if (option == null || !context.mounted) return;
    }

    // 2) 주문서. 총 결제금액을 돌려받는다.
    final total = await Navigator.of(context).push<int>(
      MaterialPageRoute<int>(
        builder: (_) => OrderFormScreen(item: item, option: option),
      ),
    );
    if (total == null || !context.mounted) return;

    // 3) 결제 승인을 기다리는 시간.
    final before = ref.read(savingsProvider);
    await PaymentProgress.run(context);
    if (!context.mounted) return;

    // 4) 주문 확정.
    final order = Order(
      id: const Uuid().v4(),
      productId: item.id,
      brand: item.brand,
      title: item.title,
      price: total,
      imageUrl: item.imageUrl,
      createdAt: DateTime.now(),
      option: option,
    );
    await ref.read(ordersProvider.notifier).add(order);
    if (!context.mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CheckoutScreen(
          brand: item.brand,
          title: item.title,
          price: total,
          before: before,
        ),
      ),
    );

    // 결제를 마치면 상세에 남을 이유가 없다. 홈으로 돌려보낸다.
    if (context.mounted) Navigator.of(context).maybePop();
  }
}

class _Hero extends StatelessWidget {
  const _Hero({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final src = url;
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: AppColors.bg,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: src == null || src.isEmpty
            ? Container(color: AppColors.surface)
            : Image.network(src, fit: BoxFit.contain),
      ),
    );
  }
}

class _BuyBar extends StatelessWidget {
  const _BuyBar({
    required this.item,
    required this.affordable,
    required this.onBuy,
  });

  final ResolvedItem item;
  final bool affordable;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        12,
        AppSpacing.screenPadding,
        20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: FilledButton(
        // 잔고가 모자랄 때만 잔고 이야기를 꺼낸다.
        onPressed: affordable ? onBuy : null,
        child: Text(
          affordable
              ? '${Won.format(item.priceKrw)}  ${Strings.buy}'
              : Strings.notEnoughBalance,
        ),
      ),
    );
  }
}
