import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';

/// 앱 전역 입력 필드.
///
/// Material 기본 테두리를 걷어내고 밑줄 하나만 남긴다.
/// 둥근 테두리 상자는 이 앱의 각진 무채색 톤과 맞지 않는다.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.formatters,
    this.maxLength,
    this.autofocus = false,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final int? maxLength;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypo.caption),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          maxLength: maxLength,
          autofocus: autofocus,
          onChanged: onChanged,
          style: AppTypo.body,
          cursorColor: AppColors.textPrimary,
          cursorWidth: 1,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypo.body.copyWith(color: AppColors.textSecond),
            counterText: '',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}
