import 'package:bismillah_app/app/theme/app_colors.dart';
import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/app/theme/app_typography.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Uygulama temasının tek kurulum noktası (06_FLUTTER_ARCHITECTURE §9).
///
/// RDX-01A: [AppTheme.dark] eklendi ve iki tema TEK bir kurucudan
/// ([_build]) üretilir; böylece bir bileşen teması yalnız açık temada
/// güncellenip koyu temada geride kalamaz.
///
/// NOT: koyu tema bu görevde uygulamaya BAĞLANMAZ. `bismillah_app.dart` hâlâ
/// yalnız `theme: AppTheme.light()` kullanır — `darkTheme` eklemek, sistem
/// ayarı koyu olan kullanıcıları anında koyu temaya geçirirdi ve bu bir
/// tasarım TEMELİ görevinin kapsamı dışındadır. Bağlama, ekran redesign
/// görevlerinin kararıdır.
abstract final class AppTheme {
  static ThemeData light() => _build(
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.primaryDark,
      onSecondary: AppColors.onPrimary,
      error: AppColors.error,
      onError: AppColors.onPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceAlt,
      outline: AppColors.divider,
    ),
    background: AppColors.background,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    divider: AppColors.divider,
    navigationIndicator: AppColors.primarySoft,
    navigationSelected: AppColors.primary,
    extension: AppThemeExtension.light(),
    visualTokens: IslamicVisualTokens.light(),
  );

  /// Koyu tema karşılığı — aynı token sözleşmesi, derin zümrüt/petrol ailesi.
  static ThemeData dark() => _build(
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryOnDark,
      onPrimary: AppColors.onPrimaryDark,
      primaryContainer: AppColors.primarySoftDark,
      onPrimaryContainer: AppColors.textPrimaryDark,
      secondary: AppColors.primaryStrongOnDark,
      onSecondary: AppColors.onPrimaryDark,
      error: AppColors.errorDark,
      onError: AppColors.onPrimaryDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.surfaceAltDark,
      outline: AppColors.dividerDark,
    ),
    background: AppColors.backgroundDark,
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    divider: AppColors.dividerDark,
    navigationIndicator: AppColors.primarySoftDark,
    navigationSelected: AppColors.primaryOnDark,
    extension: AppThemeExtension.dark(),
    visualTokens: IslamicVisualTokens.dark(),
  );

  static ThemeData _build({
    required ColorScheme colorScheme,
    required Color background,
    required Color textPrimary,
    required Color textSecondary,
    required Color divider,
    required Color navigationIndicator,
    required Color navigationSelected,
    required AppThemeExtension extension,
    required IslamicVisualTokens visualTokens,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: colorScheme.brightness == Brightness.dark
          ? AppTypography.textTheme(
              primary: textPrimary,
              secondary: textSecondary,
            )
          : AppTypography.textTheme(),
      dividerColor: divider,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.h2.copyWith(color: textPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: navigationIndicator,
        height: AppSizes.bottomNavHeight,
        labelTextStyle: WidgetStatePropertyAll<TextStyle>(
          AppTypography.navLabel.copyWith(color: textSecondary),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? navigationSelected
                : textSecondary,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        margin: EdgeInsets.zero,
      ),
      extensions: <ThemeExtension<dynamic>>[
        extension,
        // İslami görsel kimlik token'ları (TASK 051) — ayrı uzantı;
        // marka temeli değişmez.
        visualTokens,
      ],
    );
  }
}
