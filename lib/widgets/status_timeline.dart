import 'package:flutter/material.dart';

import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';
import '../domain/order_status.dart';

/// 배송 단계 타임라인.
///
/// 크림의 주문 상태 화면 구조를 따른다.
/// 지나온 단계는 검게 채우고 남은 단계는 회색으로 둔다.
/// 색으로 상태를 구분하지 않는다. 초록·파랑을 쓰면 명품 톤이 깨진다.
class StatusTimeline extends StatelessWidget {
  const StatusTimeline({
    super.key,
    required this.current,
    this.cancelled = false,
  });

  final OrderStatus current;

  /// 취소된 주문은 진행을 멈춘 것으로 그린다.
  final bool cancelled;

  @override
  Widget build(BuildContext context) {
    final stages = OrderStatus.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < stages.length; i++)
          _Stage(
            status: stages[i],
            done: !cancelled && i <= current.index,
            active: !cancelled && i == current.index,
            isLast: i == stages.length - 1,
          ),
      ],
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage({
    required this.status,
    required this.done,
    required this.active,
    required this.isLast,
  });

  final OrderStatus status;
  final bool done;
  final bool active;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.textPrimary : AppColors.divider;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 점과 연결선
          Column(
            children: [
              Container(
                width: active ? 10 : 6,
                height: active ? 10 : 6,
                margin: EdgeInsets.only(top: active ? 5 : 7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 1, color: color),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.label,
                    style: AppTypo.body.copyWith(
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: done ? AppColors.textPrimary : AppColors.textSecond,
                    ),
                  ),
                  if (active && status.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(status.subtitle, style: AppTypo.caption),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
