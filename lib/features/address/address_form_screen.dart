import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../data/local/providers.dart';
import '../../domain/profile.dart';
import '../../widgets/form_field.dart';

/// 배송지 입력.
///
/// 우편번호 검색 API 는 웹뷰가 필요해 쓰지 않는다.
/// 실제로 물건이 가지 않으므로 직접 입력으로 충분하다.
class AddressFormScreen extends ConsumerStatefulWidget {
  const AddressFormScreen({super.key});

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  late final _recipient = TextEditingController();
  late final _phone = TextEditingController();
  late final _postcode = TextEditingController();
  late final _line1 = TextEditingController();
  late final _line2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    final existing = ref.read(addressProvider);
    if (existing != null) {
      _recipient.text = existing.recipient;
      _phone.text = existing.phone;
      _postcode.text = existing.postcode;
      _line1.text = existing.line1;
      _line2.text = existing.line2;
    } else {
      // 가입할 때 받은 이름을 수령인 기본값으로 채워준다.
      _recipient.text = ref.read(profileProvider)?.name ?? '';
    }
  }

  @override
  void dispose() {
    for (final c in [_recipient, _phone, _postcode, _line1, _line2]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _valid =>
      _recipient.text.trim().isNotEmpty &&
      _phone.text.trim().isNotEmpty &&
      _line1.text.trim().isNotEmpty;

  Future<void> _save() async {
    final address = Address(
      recipient: _recipient.text.trim(),
      phone: _phone.text.trim(),
      postcode: _postcode.text.trim(),
      line1: _line1.text.trim(),
      line2: _line2.text.trim(),
    );
    await ref.read(addressProvider.notifier).save(address);
    if (mounted) Navigator.of(context).pop(address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.addressTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  8,
                  AppSpacing.screenPadding,
                  24,
                ),
                children: [
                  AppTextField(
                    label: Strings.addressRecipient,
                    controller: _recipient,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: Strings.addressPhone,
                    controller: _phone,
                    hint: '010-0000-0000',
                    keyboardType: TextInputType.phone,
                    formatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9-]'))],
                    maxLength: 13,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: Strings.addressPostcode,
                    controller: _postcode,
                    hint: '00000',
                    keyboardType: TextInputType.number,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 5,
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: Strings.addressLine1,
                    controller: _line1,
                    hint: '도로명 주소',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: Strings.addressLine2,
                    controller: _line2,
                    hint: '동 · 호수',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                8,
                AppSpacing.screenPadding,
                20,
              ),
              child: FilledButton(
                onPressed: _valid ? _save : null,
                child: const Text(Strings.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
