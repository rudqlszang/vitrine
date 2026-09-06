import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

/// 앱 전역 테마.
///
/// Material 기본값(둥근 모서리, 컬러 강조, 그림자)을 걷어내고
/// 무채색 · 각진 모서리 · 그림자 없음으로 통일한다.
abstract final class AppTheme {
  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTypo.fontFamily,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.light(
        surface: AppColors.bg,
        primary: AppColors.textPrimary,
        secondary: AppColors.textPrimary,
        error: AppColors.accent,
        onPrimary: AppColors.bg,
        onSurface: AppColors.textPrimary,
      ),
    );

    return base.copyWith(
      // 물결 효과 · 하이라이트 제거. 명품 UI 는 조용해야 한다.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypo.title,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      textTheme: const TextTheme(
        displayLarge: AppTypo.display,
        titleLarge: AppTypo.title,
        bodyMedium: AppTypo.body,
        bodySmall: AppTypo.caption,
        labelLarge: AppTypo.price,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          foregroundColor: AppColors.bg,
          minimumSize: const Size.fromHeight(56),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.base)),
          ),
          textStyle: AppTypo.body.copyWith(fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          textStyle: AppTypo.body,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.base)),
          ),
        ),
      ),

      cardTheme: const CardThemeData(
        color: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.base)),
        ),
      ),
    );
  }
}
