import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';

/// 결제 진행 오버레이.
///
/// 실제 결제는 승인까지 1~2초가 걸린다. 그 사이가 없으면
/// 버튼을 누른 순간 결과가 나와서 지른 실감이 나지 않는다.
/// 기다림 자체가 연출이다.
abstract final class PaymentProgress {
  static const duration = Duration(milliseconds: 1800);

  /// 결제 진행을 보여주고 [duration] 뒤에 닫는다.
  static Future<void> run(BuildContext context) async {
    final navigator = Navigator.of(context, rootNavigator: true);

    // 다이얼로그는 닫힐 때까지 완료되지 않으므로 기다리지 않는다.
    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.bg,
      builder: (_) => const PopScope(canPop: false, child: _ProgressView()),
    ));

    await Future<void>.delayed(duration);
    if (navigator.canPop()) navigator.pop();
  }
}

class _ProgressView extends StatelessWidget {
  const _ProgressView();

  @override
  Widget build(BuildContext context) {
    // Material 조상 없이 Text 를 그리면 노란 이중 밑줄이 붙는다.
    // 다이얼로그는 Overlay 위에 떠서 Scaffold 를 상속받지 못하므로 직접 씌운다.
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 1.4,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Text(Strings.payProcessing, style: AppTypo.body),
            const SizedBox(height: 6),
            Text(Strings.payProcessingSub, style: AppTypo.caption),
          ],
        ),
      ),
    );
  }
}
