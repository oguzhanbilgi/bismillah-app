import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/app/theme/app_typography.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/shared/widgets/app_motion_switcher.dart';
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

    // TASK 094A: etiket ile yükleme göstergesi arasında sert takas yerine
    // sakin bir çapraz geçiş. Kilitlenme ANINDA olur — `effectiveOnPressed`
    // yukarıda zaten `null`'dır; geçiş yalnız görüntüyü yumuşatır, basma
    // davranışını GECİKTİRMEZ.
    final child = AppMotionSwitcher(
      child: isLoading
          ? SizedBox(
              key: const ValueKey<String>('app-button-loading'),
              width: AppSizes.iconMd,
              height: AppSizes.iconMd,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: variant == AppButtonVariant.primary
                    ? scheme.onPrimary
                    : scheme.primary,
              ),
            )
          : Text(
              label,
              key: ValueKey<String>('app-button-label-$label'),
              style: AppTypography.button,
            ),
    );

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
      // RDX-01B: ikincil eylem devre dışıyken KENARLIĞI da sönümlenir.
      // Önceden yalnız etiket soluyor, çerçeve tam zümrüt kalıyordu; buton
      // basılabilir görünüyordu. `side` durum duyarlı çözülür.
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: effectiveOnPressed,
        style:
            OutlinedButton.styleFrom(
              minimumSize: minSize,
              shape: shape,
              padding: padding,
              foregroundColor: scheme.primary,
              disabledForegroundColor: ext.disabled,
            ).copyWith(
              side: WidgetStateProperty.resolveWith(
                (states) => BorderSide(
                  color: states.contains(WidgetState.disabled)
                      ? ext.disabled
                      : scheme.primary,
                  width: 1.5,
                ),
              ),
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
          disabledBackgroundColor: ext.surfaceAlt,
          disabledForegroundColor: ext.disabled,
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
          disabledForegroundColor: ext.disabled,
        ),
        child: child,
      ),
    };
  }
}
