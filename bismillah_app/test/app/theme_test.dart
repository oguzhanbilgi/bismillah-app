import 'package:bismillah_app/app/theme/app_colors.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tema temeli (RDX-01A). Burada HEX değerleri sabitlenmez — palet
/// rafine edilebilir kalmalıdır; sabitlenen şey SÖZLEŞMEdir: her iki tema
/// da aynı token setini bağlar, koyu tema gerçekten koyudur ve metin
/// kontrastı erişilebilir sınırın üstündedir.
void main() {
  /// WCAG 2.1 göreli parlaklık.
  double luminance(Color c) => c.computeLuminance();

  double contrast(Color a, Color b) {
    final la = luminance(a);
    final lb = luminance(b);
    final hi = la > lb ? la : lb;
    final lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  group('AppTheme.light', () {
    test('uzantılar bağlanır ve zemin/renk şeması token\'lardan gelir', () {
      final theme = AppTheme.light();

      expect(theme.extension<AppThemeExtension>(), isNotNull);
      expect(theme.extension<IslamicVisualTokens>(), isNotNull);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.colorScheme.brightness, Brightness.light);
    });

    test('zemin, yüzey ve yükseltilmiş yüzey birbirinden AYRIDIR', () {
      final theme = AppTheme.light();
      final ext = theme.extension<AppThemeExtension>()!;

      expect(ext.background, isNot(theme.colorScheme.surface));
      expect(ext.surfaceAlt, isNot(theme.colorScheme.surface));
      expect(ext.surfaceElevated, isNot(ext.surfaceAlt));
    });
  });

  group('AppTheme.dark', () {
    test('uzantılar bağlanır ve tema gerçekten KOYUdur', () {
      final theme = AppTheme.dark();

      expect(theme.extension<AppThemeExtension>(), isNotNull);
      expect(theme.extension<IslamicVisualTokens>(), isNotNull);
      expect(theme.colorScheme.brightness, Brightness.dark);
      // Zemin koyu; "koyu tema" adı taşıyıp açık kalamaz.
      expect(luminance(theme.scaffoldBackgroundColor), lessThan(0.1));
    });

    test('yüzeyler zeminden YÜKSELİR (düz tek renk değil)', () {
      final theme = AppTheme.dark();
      final ext = theme.extension<AppThemeExtension>()!;

      expect(
        luminance(theme.colorScheme.surface),
        greaterThan(luminance(ext.background)),
      );
      expect(
        luminance(ext.surfaceAlt),
        greaterThan(luminance(theme.colorScheme.surface)),
      );
      expect(
        luminance(ext.surfaceElevated),
        greaterThan(luminance(ext.surfaceAlt)),
      );
    });

    test('koyu tema açık temanın kopyası DEĞİLDİR', () {
      final light = AppTheme.light().extension<AppThemeExtension>()!;
      final dark = AppTheme.dark().extension<AppThemeExtension>()!;

      expect(dark.background, isNot(light.background));
      expect(dark.textPrimary, isNot(light.textPrimary));
      expect(dark.divider, isNot(light.divider));
      expect(dark.accentGold, isNot(light.accentGold));
      expect(dark.cardShadow, isNot(light.cardShadow));
    });

    test('metin teması koyu zeminde YENİDEN renklendirilir', () {
      final dark = AppTheme.dark();
      // `AppTypography` sabitleri açık mürekkep taşır; koyu temada
      // `ThemeData.textTheme` bunu devralırsa metin okunamaz olurdu.
      expect(dark.textTheme.bodyLarge!.color, isNot(AppColors.textPrimary));
      expect(dark.textTheme.bodyLarge!.color, AppColors.textPrimaryDark);
    });
  });

  group('Kontrast', () {
    test('metin katmanları kendi zeminlerinde erişilebilirdir', () {
      for (final theme in [AppTheme.light(), AppTheme.dark()]) {
        final ext = theme.extension<AppThemeExtension>()!;
        // Gövde metni için WCAG AA.
        expect(contrast(ext.textPrimary, ext.background), greaterThan(4.5));
        expect(contrast(ext.textSecondary, ext.background), greaterThan(4.5));
        // Üçüncül metin sönük olmalı ama okunur kalmalı.
        expect(contrast(ext.textTertiary, ext.background), greaterThan(4.4));
        expect(
          contrast(ext.textPrimary, theme.colorScheme.surface),
          greaterThan(4.5),
        );
      }
    });

    test('birincil eylem ve altın vurgu kendi zemininde okunur', () {
      for (final theme in [AppTheme.light(), AppTheme.dark()]) {
        final ext = theme.extension<AppThemeExtension>()!;
        expect(
          contrast(theme.colorScheme.onPrimary, theme.colorScheme.primary),
          greaterThan(4.5),
        );
        // Altın METİN rengi olarak da kullanılabildiğinden zeminden
        // yeterince ayrışmalıdır.
        expect(contrast(ext.accentGold, ext.background), greaterThan(3.0));
      }
    });
  });

  group('Uzantı sözleşmesi', () {
    test('lerp t=1 hedefe ulaşır — unutulan alan burada düşer', () {
      final light = AppThemeExtension.light();
      final dark = AppThemeExtension.dark();
      final lerped = light.lerp(dark, 1.0);

      expect(lerped.background, dark.background);
      expect(lerped.surfaceAlt, dark.surfaceAlt);
      expect(lerped.surfaceElevated, dark.surfaceElevated);
      expect(lerped.accentGold, dark.accentGold);
      expect(lerped.textPrimary, dark.textPrimary);
      expect(lerped.textSecondary, dark.textSecondary);
      expect(lerped.textTertiary, dark.textTertiary);
      expect(lerped.divider, dark.divider);
      expect(lerped.success, dark.success);
      expect(lerped.warning, dark.warning);
      expect(lerped.disabled, dark.disabled);
      expect(lerped.cardShadow, dark.cardShadow);
      expect(lerped.floatingShadow, dark.floatingShadow);
    });

    test('copyWith yalnız verilen alanı değiştirir', () {
      final light = AppThemeExtension.light();
      final copied = light.copyWith(success: const Color(0xFF123456));

      expect(copied.success, const Color(0xFF123456));
      expect(copied.background, light.background);
      expect(copied.accentGold, light.accentGold);
    });

    /// Tek bir temayı taze bir ağaçta çözer. İki temayı AYNI `pumpWidget`
    /// döngüsünde denemek yanıltıcıdır: `ThemeData` tema değişiminde lerp
    /// edilir ve ara bir değer okunur.
    Future<AppThemeExtension> resolveIn(
      WidgetTester tester,
      ThemeData theme,
    ) async {
      late AppThemeExtension resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              resolved = AppThemeExtension.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      return resolved;
    }

    testWidgets('of(context) açık temada bağlı uzantıyı çözer', (tester) async {
      final theme = AppTheme.light();
      final resolved = await resolveIn(tester, theme);

      expect(tester.takeException(), isNull);
      expect(
        resolved.background,
        theme.extension<AppThemeExtension>()!.background,
      );
    });

    testWidgets('of(context) koyu temada bağlı uzantıyı çözer', (tester) async {
      final theme = AppTheme.dark();
      final resolved = await resolveIn(tester, theme);

      expect(tester.takeException(), isNull);
      expect(
        resolved.background,
        theme.extension<AppThemeExtension>()!.background,
      );
    });
  });
}
