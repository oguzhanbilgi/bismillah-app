import 'package:bismillah_app/app/theme/app_colors.dart';
import 'package:bismillah_app/app/theme/app_shadows.dart';
import 'package:flutter/material.dart';

/// Material `ColorScheme`'e sığmayan marka token'larının tema uzantısı
/// (06_FLUTTER_ARCHITECTURE §9). Widget'lar yalnız bu uzantıdan okur.
///
/// RDX-01A: koyu tema karşılığı [AppThemeExtension.dark] ile eklendi ve
/// kapsam premium temel için genişletildi ([background], [surfaceElevated],
/// [success]). `ColorScheme`'in zaten taşıdığı roller (primary/surface/error/
/// outline) burada TEKRARLANMAZ — token'ın tek bir sahibi olur.
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.background,
    required this.primarySoft,
    required this.surfaceAlt,
    required this.surfaceElevated,
    required this.accentGold,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.divider,
    required this.success,
    required this.warning,
    required this.disabled,
    required this.cardShadow,
    required this.floatingShadow,
  });

  /// Ekran zemini — `Scaffold` arkası. Yüzeyden (kart) AYRIDIR.
  final Color background;

  final Color primarySoft;

  /// İkincil yüzey — zemin ile kart arasındaki tonal katman.
  final Color surfaceAlt;

  /// Yüzeyin bir kademe üstü — sheet, seçili satır, yükseltilmiş panel.
  final Color surfaceElevated;

  /// Yalnız kazanılmış an / premium vurgusu — buton/link/dekor rengi DEĞİL
  /// (02_BRAND_GUIDELINES §13; 03_DESIGN_SYSTEM §4).
  final Color accentGold;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color divider;

  /// Tamamlanma/olumlu durum. Kutlama rengi DEĞİLDİR ve kaçırılan ibadet
  /// için hiçbir zaman karşıt bir "başarısızlık" rengiyle eşleştirilmez.
  final Color success;

  final Color warning;
  final Color disabled;
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> floatingShadow;

  static AppThemeExtension light() => AppThemeExtension(
    background: AppColors.background,
    primarySoft: AppColors.primarySoft,
    surfaceAlt: AppColors.surfaceAlt,
    surfaceElevated: AppColors.surfaceElevated,
    accentGold: AppColors.accentGold,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textTertiary: AppColors.textTertiary,
    divider: AppColors.divider,
    success: AppColors.success,
    warning: AppColors.warning,
    disabled: AppColors.disabled,
    cardShadow: AppShadows.card,
    floatingShadow: AppShadows.floating,
  );

  static AppThemeExtension dark() => AppThemeExtension(
    background: AppColors.backgroundDark,
    primarySoft: AppColors.primarySoftDark,
    surfaceAlt: AppColors.surfaceAltDark,
    surfaceElevated: AppColors.surfaceElevatedDark,
    accentGold: AppColors.accentGoldDark,
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    textTertiary: AppColors.textTertiaryDark,
    divider: AppColors.dividerDark,
    success: AppColors.successDark,
    warning: AppColors.warningDark,
    disabled: AppColors.disabledDark,
    cardShadow: AppShadows.cardDark,
    floatingShadow: AppShadows.floatingDark,
  );

  /// Kısa erişim: `AppThemeExtension.of(context)`.
  ///
  /// Uzantı kayıtlı değilse (ör. çıplak `ThemeData` kuran bir test) açık tema
  /// varsayılanına düşer — widget ASLA crash etmez. Bu, kardeş uzantı
  /// `IslamicVisualTokens.of` ile aynı davranıştır.
  static AppThemeExtension of(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>() ?? light();

  @override
  AppThemeExtension copyWith({
    Color? background,
    Color? primarySoft,
    Color? surfaceAlt,
    Color? surfaceElevated,
    Color? accentGold,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? divider,
    Color? success,
    Color? warning,
    Color? disabled,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? floatingShadow,
  }) {
    return AppThemeExtension(
      background: background ?? this.background,
      primarySoft: primarySoft ?? this.primarySoft,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      accentGold: accentGold ?? this.accentGold,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      divider: divider ?? this.divider,
      success: success ?? this.success,
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
      background: Color.lerp(background, other.background, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      accentGold: Color.lerp(accentGold, other.accentGold, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
      floatingShadow: t < 0.5 ? floatingShadow : other.floatingShadow,
    );
  }
}
