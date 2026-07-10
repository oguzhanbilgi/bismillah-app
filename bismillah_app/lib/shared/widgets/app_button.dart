import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/app/theme/app_typography.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Buton ailesi (03_DESIGN_SYSTEM §11).
///
/// Kurallar: 52dp yükseklik, pill radius, ekran başına tek primary;
/// ALTIN BUTON YOKTUR — bu enum'da altın varyant tanımlı değildir ve
/// eklenemez (02_BRAND_GUIDELINES §13).
enum AppButtonVariant { primary, secondary, ghost, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
  });

  /// Kullanıcıya görünen etiket — daima localization'dan gelir.
  final String label;

  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ext = AppThemeExtension.of(context);
    final effectiveOnPressed = isLoading ? null : onPressed;

    final child = isLoading
        ? SizedBox(
            width: AppSizes.iconMd,
            height: AppSizes.iconMd,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == AppButtonVariant.primary
                  ? scheme.onPrimary
                  : scheme.primary,
            ),
          )
        : Text(label, style: AppTypography.button);

    const minSize = Size(AppSizes.touchTarget * 2.5, AppSizes.buttonHeight);
    const shape = RoundedRectangleBorder(borderRadius: AppRadius.pillAll);
    const padding = EdgeInsets.symmetric(horizontal: AppSpacing.s6);

    return switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: effectiveOnPressed,
        style: FilledButton.styleFrom(
          minimumSize: minSize,
          shape: shape,
          padding: padding,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: ext.disabled,
        ),
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: minSize,
          shape: shape,
          padding: padding,
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary, width: 1.5),
        ),
        child: child,
      ),
      AppButtonVariant.ghost => FilledButton.tonal(
        onPressed: effectiveOnPressed,
        style: FilledButton.styleFrom(
          minimumSize: minSize,
          shape: shape,
          padding: padding,
          backgroundColor: ext.surfaceAlt,
          foregroundColor: ext.textPrimary,
        ),
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: effectiveOnPressed,
        style: TextButton.styleFrom(
          minimumSize: const Size(AppSizes.touchTarget, AppSizes.touchTarget),
          shape: shape,
          padding: padding,
          foregroundColor: scheme.primary,
        ),
        child: child,
      ),
    };
  }
}
