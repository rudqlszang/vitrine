import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/won_format.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/local/providers.dart';
import '../../domain/profile.dart';
import '../../domain/savings.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/form_field.dart';

/// 회원가입.
///
/// 서버도 인증도 없다. Hive 에 이름 한 줄 쓰는 것이 전부다.
/// 그럼에도 이 단계를 두는 이유는 배송 연출 때문이다.
/// 받는 사람이 없으면 주문 화면이 비어 보인다.
///
/// 가입을 마치는 순간 잔고 ₩1조가 들어온다. 계좌를 개설하는 감각이다.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _name = TextEditingController();
  final _nickname = TextEditingController();
  bool _granting = false;

  @override
  void dispose() {
    _name.dispose();
    _nickname.dispose();
    super.dispose();
  }

  bool get _valid => _name.text.trim().isNotEmpty;

  Future<void> _submit() async {
    setState(() => _granting = true);

    await ref.read(profileProvider.notifier).save(
          Profile(
            name: _name.text.trim(),
            nickname: _nickname.text.trim(),
            joinedAt: DateTime.now(),
          ),
        );

    // 잔고가 들어오는 장면을 잠깐 보여준다.
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (mounted) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _granting ? const _Granted() : _form(),
        ),
      ),
    );
  }

  Widget _form() {
    return Padding(
      key: const ValueKey('form'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          const BrandMark(height: 20),
          const SizedBox(height: 40),
          Text(Strings.signupLead, style: AppTypo.title),
          const SizedBox(height: 6),
          Text(Strings.signupSub, style: AppTypo.caption),
          const SizedBox(height: 36),
          AppTextField(
            label: Strings.signupName,
            controller: _name,
            autofocus: true,
            maxLength: 20,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 26),
          AppTextField(
            label: Strings.signupNickname,
            controller: _nickname,
            maxLength: 20,
          ),
          const Spacer(flex: 2),
          FilledButton(
            onPressed: _valid ? _submit : null,
            child: const Text(Strings.signupStart),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// 잔고 지급 연출.
class _Granted extends StatelessWidget {
  const _Granted();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('granted'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(Strings.signupGranted, style: AppTypo.caption),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            builder: (context, t, _) => Text(
              Won.format((Savings.initialBalance * t).round()),
              style: AppTypo.display.copyWith(fontSize: 26),
            ),
          ),
        ],
      ),
    );
  }
}
