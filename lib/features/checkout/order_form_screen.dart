import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/won_format.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/catalog/resolved_item.dart';
import '../../data/local/providers.dart';
import '../../domain/payment.dart';
import '../../domain/profile.dart';
import '../address/address_form_screen.dart';

/// 주문서.
///
/// 크림·무신사의 주문서 구성을 따른다.
/// 상품 요약 → 배송지 → 금액 명세 → 결제수단 → 약관 동의 → 결제.
/// 구매 버튼 하나로 바로 끝나면 지르는 감각이 남지 않는다.
///
/// 결제를 누르면 총 결제금액을 pop 으로 돌려준다.
class OrderFormScreen extends ConsumerStatefulWidget {
  const OrderFormScreen({super.key, required this.item, this.option});

  final ResolvedItem item;
  final String? option;

  @override
  ConsumerState<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends ConsumerState<OrderFormScreen> {
  PaymentMethod _method = PaymentMethod.card;
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    final address = ref.watch(addressProvider);
    final price = PriceBreakdown(item: widget.item.priceKrw);
    final savings = ref.watch(savingsProvider);

    final hasAddress = address != null && address.isComplete;
    final affordable = savings.balance >= price.total;

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.orderFormTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _ProductSummary(item: widget.item, option: widget.option),
                  const _Gap(),
                  _AddressSection(
                    address: address,
                    onEdit: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AddressFormScreen(),
                      ),
                    ),
                  ),
                  const _Gap(),
                  _PriceSection(price: price),
                  const _Gap(),
                  _MethodSection(
                    selected: _method,
                    onSelect: (m) => setState(() => _method = m),
                  ),
                  const _Gap(),
                  _AgreeSection(
                    value: _agreed,
                    onChanged: (v) => setState(() => _agreed = v),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            _PayBar(
              total: price.total,
              enabled: hasAddress && _agreed && affordable,
              hint: _hint(hasAddress, affordable),
              onPay: () => Navigator.of(context).pop(price.total),
            ),
          ],
        ),
      ),
    );
  }

  /// 왜 결제할 수 없는지 한 줄로 알려준다. 버튼만 비활성이면 답답하다.
  String? _hint(bool hasAddress, bool affordable) {
    if (!affordable) return Strings.notEnoughBalance;
    if (!hasAddress) return Strings.orderNeedAddress;
    if (!_agreed) return Strings.orderNeedAgree;
    return null;
  }
}

/// 섹션 사이를 회색 띠로 나눈다. 국내 커머스 주문서의 공통 문법이다.
class _Gap extends StatelessWidget {
  const _Gap();

  @override
  Widget build(BuildContext context) =>
      Container(height: 8, color: AppColors.surface);
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        20,
        AppSpacing.screenPadding,
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypo.body.copyWith(fontWeight: FontWeight.w600),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ProductSummary extends StatelessWidget {
  const _ProductSummary({required this.item, this.option});

  final ResolvedItem item;
  final String? option;

  @override
  Widget build(BuildContext context) {
    final url = item.imageUrl;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: url == null || url.isEmpty
                ? Container(color: AppColors.surface)
                : Image.network(url, fit: BoxFit.contain),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.brand.toUpperCase(), style: AppTypo.brand),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  style: AppTypo.body.copyWith(color: AppColors.textSecond),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (option != null) ...[
                  const SizedBox(height: 4),
                  Text('${Strings.orderOption}  $option',
                      style: AppTypo.caption),
                ],
                const SizedBox(height: 8),
                Text(Won.format(item.priceKrw), style: AppTypo.price),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressSection extends StatelessWidget {
  const _AddressSection({required this.address, required this.onEdit});

  final Address? address;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final a = address;
    return _Section(
      title: Strings.orderAddress,
      trailing: GestureDetector(
        onTap: onEdit,
        child: Text(
          a == null ? Strings.orderAddressAdd : Strings.orderAddressEdit,
          style: AppTypo.caption.copyWith(
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      child: a == null
          ? Text(Strings.orderNeedAddress, style: AppTypo.caption)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${a.recipient}  ${a.phone}', style: AppTypo.body),
                const SizedBox(height: 4),
                Text(
                  a.postcode.isEmpty ? a.full : '(${a.postcode}) ${a.full}',
                  style: AppTypo.caption,
                ),
              ],
            ),
    );
  }
}

class _PriceSection extends StatelessWidget {
  const _PriceSection({required this.price});

  final PriceBreakdown price;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: Strings.orderPrice,
      child: Column(
        children: [
          _row(Strings.orderItemPrice, Won.format(price.item)),
          const SizedBox(height: 10),
          _row(Strings.orderInspection, Won.format(price.inspection)),
          const SizedBox(height: 10),
          _row(Strings.orderShipping, Strings.orderFree),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Strings.orderTotal,
                style: AppTypo.body.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                Won.format(price.total),
                style: AppTypo.price.copyWith(fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypo.caption),
          Text(value, style: AppTypo.body),
        ],
      );
}

class _MethodSection extends StatelessWidget {
  const _MethodSection({required this.selected, required this.onSelect});

  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onSelect;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: Strings.orderMethod,
      child: Column(
        children: [
          for (final m in PaymentMethod.values)
            GestureDetector(
              onTap: () => onSelect(m),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    _Radio(on: selected == m),
                    const SizedBox(width: 10),
                    Text(m.label, style: AppTypo.body),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AgreeSection extends StatelessWidget {
  const _AgreeSection({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: 20,
      ),
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            _Check(on: value),
            const SizedBox(width: 10),
            Expanded(child: Text(Strings.orderAgree, style: AppTypo.caption)),
          ],
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: on ? AppColors.textPrimary : AppColors.divider,
          width: on ? 5 : 1,
        ),
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: on ? AppColors.textPrimary : AppColors.bg,
        border: Border.all(
          color: on ? AppColors.textPrimary : AppColors.divider,
        ),
      ),
      child: on ? const Icon(Icons.check, size: 13, color: AppColors.bg) : null,
    );
  }
}

class _PayBar extends StatelessWidget {
  const _PayBar({
    required this.total,
    required this.enabled,
    required this.onPay,
    this.hint,
  });

  final int total;
  final bool enabled;
  final VoidCallback onPay;
  final String? hint;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hint != null) ...[
            Text(hint!, style: AppTypo.caption),
            const SizedBox(height: 10),
          ],
          FilledButton(
            onPressed: enabled ? onPay : null,
            child: Text('${Won.format(total)}  ${Strings.pay}'),
          ),
        ],
      ),
    );
  }
}
