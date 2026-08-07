import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_section_header.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// RDX-01B — premium paylaşılan bileşen temeli.
///
/// Sabitlenen şey HEX değil SÖZLEŞMEdir: bileşenler rengini temadan çözer,
/// açık/koyu temada farklı çizilir ve devre dışı durumlar dürüsttür.
void main() {
  Widget host(Widget child, {required ThemeData theme}) => MaterialApp(
    theme: theme,
    home: Scaffold(body: Center(child: child)),
  );

  BoxDecoration cardDecoration(WidgetTester tester) =>
      tester
              .widget<DecoratedBox>(
                find
                    .descendant(
                      of: find.byType(AppCard),
                      matching: find.byType(DecoratedBox),
                    )
                    .first,
              )
              .decoration
          as BoxDecoration;

  TextStyle styleOf(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text)).style!;

  group('AppText tema mürekkebi', () {
    testWidgets('varsayılan metin rengi TEMADAN çözülür, sabit DEĞİLDİR', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const AppText('Bugün'), theme: AppTheme.light()),
      );
      final light = styleOf(tester, 'Bugün').color;

      await tester.pumpWidget(
        host(const AppText('Bugün'), theme: AppTheme.dark()),
      );
      await tester.pumpAndSettle();
      final dark = styleOf(tester, 'Bugün').color;

      expect(light, AppThemeExtension.light().textPrimary);
      expect(dark, AppThemeExtension.dark().textPrimary);
      // Kusurun kendisi: koyu temada açık tema mürekkebinin kalması.
      expect(dark, isNot(light));
    });

    testWidgets('üç vurgu kademesi birbirinden AYRIDIR', (tester) async {
      await tester.pumpWidget(
        host(
          const Column(
            children: [
              AppText('bir', tone: AppTextTone.primary),
              AppText('iki', tone: AppTextTone.secondary),
              AppText('uc', tone: AppTextTone.tertiary),
            ],
          ),
          theme: AppTheme.light(),
        ),
      );

      final primary = styleOf(tester, 'bir').color;
      final secondary = styleOf(tester, 'iki').color;
      final tertiary = styleOf(tester, 'uc').color;

      expect(primary, isNot(secondary));
      expect(secondary, isNot(tertiary));
      // Hiyerarşi gerçekten sönümlenmeli: her kademe zeminine daha yakın.
      expect(
        primary!.computeLuminance(),
        lessThan(secondary!.computeLuminance()),
      );
      expect(
        secondary.computeLuminance(),
        lessThan(tertiary!.computeLuminance()),
      );
    });

    testWidgets('korunan `secondary` bayrağı çalışmaya devam eder', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const AppText('meta', secondary: true), theme: AppTheme.light()),
      );

      expect(
        styleOf(tester, 'meta').color,
        AppThemeExtension.light().textSecondary,
      );
    });

    testWidgets('açık `color` her şeyi EZER', (tester) async {
      await tester.pumpWidget(
        host(
          const AppText('ozel', color: Color(0xFF123456)),
          theme: AppTheme.light(),
        ),
      );

      expect(styleOf(tester, 'ozel').color, const Color(0xFF123456));
    });
  });

  group('AppCard katmanlama', () {
    testWidgets('yükseltilmiş kart gölge VE saç teli kenarlık taşır', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const AppCard(child: Text('x')), theme: AppTheme.light()),
      );

      final decoration = cardDecoration(tester);
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.border, isNotNull);
    });

    testWidgets('outlined varyant AYRI kalır: kenarlık var, gölge YOK', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const AppCard(variant: AppCardVariant.outlined, child: Text('x')),
          theme: AppTheme.light(),
        ),
      );

      final decoration = cardDecoration(tester);
      expect(decoration.border, isNotNull);
      expect(decoration.boxShadow, isNull);
    });

    testWidgets('tonal varyantlar kenarlıksız ve gölgesizdir', (tester) async {
      await tester.pumpWidget(
        host(
          const AppCard(variant: AppCardVariant.sand, child: Text('x')),
          theme: AppTheme.light(),
        ),
      );

      final decoration = cardDecoration(tester);
      expect(decoration.border, isNull);
      expect(decoration.boxShadow, isNull);
    });

    testWidgets('kenarlık ve yüzey koyu temada TEMADAN gelir', (tester) async {
      await tester.pumpWidget(
        host(const AppCard(child: Text('x')), theme: AppTheme.dark()),
      );
      await tester.pumpAndSettle();

      final decoration = cardDecoration(tester);
      expect(decoration.color, AppTheme.dark().colorScheme.surface);
      expect(
        (decoration.border! as Border).top.color,
        IslamicVisualTokens.dark().surfaceBorder,
      );
    });
  });

  group('AppSectionHeader', () {
    testWidgets('yalnız başlık — alt başlık ve eylem yoksa çizilmez', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const AppSectionHeader(title: 'Kategoriler'),
          theme: AppTheme.light(),
        ),
      );

      expect(find.text('Kategoriler'), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('alt başlık ve metin eylemi birlikte çizilir', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        host(
          AppSectionHeader(
            title: 'Önerilen Dersler',
            subtitle: 'Sana uygun içerikler',
            actionLabel: 'Tümünü Gör',
            onActionTap: () => tapped++,
          ),
          theme: AppTheme.light(),
        ),
      );

      expect(find.text('Önerilen Dersler'), findsOneWidget);
      expect(find.text('Sana uygun içerikler'), findsOneWidget);

      await tester.tap(find.text('Tümünü Gör'));
      expect(tapped, 1);
    });

    testWidgets('eylem geri çağrısı yoksa DOKUNULABİLİR görünmez', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const AppSectionHeader(title: 'Kategoriler', actionLabel: 'Tümü'),
          theme: AppTheme.light(),
        ),
      );

      expect(find.text('Tümü'), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
      // Sessiz etiket birincil eylem rengini KULLANMAZ.
      expect(
        styleOf(tester, 'Tümü').color,
        isNot(AppTheme.light().colorScheme.primary),
      );
    });

    testWidgets('serbest trailing ile metin eylemi birlikte kullanılamaz', (
      tester,
    ) async {
      expect(
        () => AppSectionHeader(
          title: 'x',
          actionLabel: 'a',
          trailing: const SizedBox.shrink(),
        ),
        throwsAssertionError,
      );
    });
  });

  group('AppButton devre dışı durumları', () {
    testWidgets('ikincil eylem kapalıyken KENARLIĞI da sönümlenir', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const AppButton(
            label: 'Uygula',
            onPressed: null,
            variant: AppButtonVariant.secondary,
          ),
          theme: AppTheme.light(),
        ),
      );

      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      final side = button.style!.side!.resolve({WidgetState.disabled})!;
      final enabledSide = button.style!.side!.resolve(<WidgetState>{})!;

      expect(side.color, AppThemeExtension.light().disabled);
      expect(enabledSide.color, AppTheme.light().colorScheme.primary);
      expect(side.color, isNot(enabledSide.color));
    });

    testWidgets('birincil eylem etiketlidir — ikonla belirsizleştirilmez', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          AppButton(label: 'Devam Et', onPressed: () {}),
          theme: AppTheme.light(),
        ),
      );

      expect(find.text('Devam Et'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
    });
  });
}
