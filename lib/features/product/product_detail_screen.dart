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
import '../checkout/checkout_screen.dart';

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
                        const _Notice(),
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

  Future<void> _buy(BuildContext context, WidgetRef ref) async {
    // 결제 화면이 "결제 직전" 상태를 보여줘야 하므로 먼저 읽어둔다.
    final before = ref.read(savingsProvider);

    final order = Order(
      id: const Uuid().v4(),
      productId: item.id,
      brand: item.brand,
      title: item.title,
      price: item.priceKrw,
      imageUrl: item.imageUrl,
      createdAt: DateTime.now(),
    );
    await ref.read(ordersProvider.notifier).add(order);

    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CheckoutScreen(
          brand: item.brand,
          title: item.title,
          price: item.priceKrw,
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

/// 이 앱이 무엇인지 잊지 않도록 상세에 한 줄 남긴다.
class _Notice extends StatelessWidget {
  const _Notice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Text(Strings.detailNotice, style: AppTypo.caption),
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
