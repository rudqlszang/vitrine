import 'package:flutter/material.dart';

import '../../core/format/won_format.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/catalog/resolved_item.dart';
import '../../domain/purchase_option.dart';

/// 구매 버튼을 누르면 먼저 뜨는 옵션 선택 바텀시트.
///
/// 선택된 옵션 문자열을 pop 으로 돌려준다. 취소하면 null.
/// 옵션이 없는 카테고리(가방 등)는 이 시트를 띄우지 않는다.
class OptionSheet extends StatefulWidget {
  const OptionSheet({super.key, required this.item});

  final ResolvedItem item;

  static Future<String?> show(BuildContext context, ResolvedItem item) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.bg,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.base)),
      ),
      builder: (_) => OptionSheet(item: item),
    );
  }

  @override
  State<OptionSheet> createState() => _OptionSheetState();
}

class _OptionSheetState extends State<OptionSheet> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final options = PurchaseOption.forCategory(widget.item.category);
    final label = PurchaseOption.labelFor(widget.item.category);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          20,
          AppSpacing.screenPadding,
          16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypo.caption),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final o in options)
                  _Chip(
                    label: o,
                    selected: _selected == o,
                    onTap: () => setState(() => _selected = o),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _selected == null
                  ? null
                  : () => Navigator.of(context).pop(_selected),
              child: Text(
                '${Won.format(widget.item.priceKrw)}  ${Strings.buy}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.textPrimary : AppColors.divider,
          ),
          color: selected ? AppColors.textPrimary : AppColors.bg,
        ),
        child: Text(
          label,
          style: AppTypo.body.copyWith(
            color: selected ? AppColors.bg : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
