import 'package:flutter/material.dart';

import 'package:bismillah_app/app/theme/app_colors.dart';
import 'package:bismillah_app/app/theme/app_shadows.dart';

/// Material `ColorScheme`'e sığmayan marka token'larının tema uzantısı
/// (06_FLUTTER_ARCHITECTURE §9). Koyu tema (V2) ikinci bir örnek tanımıyla
/// gelir; widget'lar yalnız bu uzantıdan okur.
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.primarySoft,
    required this.surfaceAlt,
    required this.accentGold,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.divider,
    required this.warning,
    required this.disabled,
    required this.cardShadow,
    required this.floatingShadow,
  });

  final Color primarySoft;
  final Color surfaceAlt;

  /// Yalnız kazanılmış an / premium vurgusu — buton/link/dekor rengi DEĞİL
  /// (02_BRAND_GUIDELINES §13; 03_DESIGN_SYSTEM §4).
  final Color accentGold;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color divider;
  final Color warning;
  final Color disabled;
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> floatingShadow;

  static AppThemeExtension light() => AppThemeExtension(
        primarySoft: AppColors.primarySoft,
        surfaceAlt: AppColors.surfaceAlt,
        accentGold: AppColors.accentGold,
        textPrimary: AppColors.textPrimary,
        textSecondary: AppColors.textSecondary,
        textTertiary: AppColors.textTertiary,
        divider: AppColors.divider,
        warning: AppColors.warning,
        disabled: AppColors.disabled,
        cardShadow: AppShadows.card,
        floatingShadow: AppShadows.floating,
      );

  /// Kısa erişim: `AppThemeExtension.of(context)`.
  static AppThemeExtension of(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>()!;

  @override
  AppThemeExtension copyWith({
    Color? primarySoft,
    Color? surfaceAlt,
    Color? accentGold,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? divider,
    Color? warning,
    Color? disabled,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? floatingShadow,
  }) {
    return AppThemeExtension(
      primarySoft: primarySoft ?? this.primarySoft,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      accentGold: accentGold ?? this.accentGold,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      divider: divider ?? this.divider,
      warning: warning ?? this.warning,
      disabled: disabled ?? this.disabled,
      cardShadow: cardShadow ?? this.cardShadow,
      floatingShadow: floatingShadow ?? this.floatingShadow,
    );
  }

  @override
  AppThemeExtension lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      accentGold: Color.lerp(accentGold, other.accentGold, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
      floatingShadow: t < 0.5 ? floatingShadow : other.floatingShadow,
    );
  }
}
