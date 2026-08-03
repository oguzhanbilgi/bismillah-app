import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/shared/islamic/mosque_silhouette.dart';
import 'package:bismillah_app/shared/islamic/quran_on_rehal_illustration.dart';
import 'package:bismillah_app/shared/islamic/warm_section.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sıcak görsel sistem bileşenleri (TASK 054).
void main() {
  Widget host(Widget child, {Size size = const Size(300, 200)}) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: Center(
        child: SizedBox.fromSize(size: size, child: child),
      ),
    ),
  );

  group('Token genişlemesi', () {
    test('sıcak yüzeyler light/dark için TANIMLIDIR', () {
      for (final tokens in [
        IslamicVisualTokens.light(),
        IslamicVisualTokens.dark(),
      ]) {
        expect(tokens.sandSurface, isNotNull);
        expect(tokens.sageSurface, isNotNull);
        expect(tokens.sectionSurface, isNotNull);
        expect(tokens.surfaceBorder, isNotNull);
        expect(tokens.nightCalm, isNotNull);
      }
    });

    test('light ve dark yüzeyleri birbirinden FARKLIDIR', () {
      final light = IslamicVisualTokens.light();
      final dark = IslamicVisualTokens.dark();
      expect(light.sandSurface, isNot(dark.sandSurface));
      expect(light.sageSurface, isNot(dark.sageSurface));
      expect(light.sectionSurface, isNot(dark.sectionSurface));
    });

    test('kart yüzeyi artık SAF BEYAZ değildir (sıcak kırık beyaz)', () {
      // TASK 054 geri bildiriminin kökü: saf beyaz kart yığını.
      expect(IslamicVisualTokens.light().sacredSurface, isNot(Colors.white));
    });

    test('lerp ve copyWith yeni alanları TAŞIR', () {
      final light = IslamicVisualTokens.light();
      final dark = IslamicVisualTokens.dark();

      // t=1 tam olarak hedefe ulaşmalı — alan lerp'te unutulmuşsa bu düşer.
      final lerped = light.lerp(dark, 1.0);
      expect(lerped.sandSurface, dark.sandSurface);
      expect(lerped.sageSurface, dark.sageSurface);
      expect(lerped.sectionSurface, dark.sectionSurface);
      expect(lerped.surfaceBorder, dark.surfaceBorder);
      expect(lerped.nightCalm, dark.nightCalm);

      final copied = light.copyWith(sandSurface: const Color(0xFF123456));
      expect(copied.sandSurface, const Color(0xFF123456));
      // Diğer alanlar korunur.
      expect(copied.sageSurface, light.sageSurface);
    });

    test('sıcak bölüm gradient\'i kum ve adaçayı tonlarını kullanır', () {
      final tokens = IslamicVisualTokens.light();
      expect(tokens.warmSectionGradient.colors, [
        tokens.sandSurface,
        tokens.sageSurface,
      ]);
    });
  });

  group('QuranOnRehalIllustration', () {
    testWidgets('dekoratiftir: semantics dışı ve dokunmayı engellemez', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(const QuranOnRehalIllustration()));

      expect(
        find.descendant(
          of: find.byType(QuranOnRehalIllustration),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(QuranOnRehalIllustration),
          matching: find.byType(IgnorePointer),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('sıfır ve çok küçük alanda crash etmez', (tester) async {
      await tester.pumpWidget(
        host(const QuranOnRehalIllustration(), size: Size.zero),
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        host(const QuranOnRehalIllustration(), size: const Size(4, 4)),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('opacity 0 verildiğinde de güvenle çizilir', (tester) async {
      await tester.pumpWidget(host(const QuranOnRehalIllustration(opacity: 0)));
      expect(tester.takeException(), isNull);
    });
  });

  group('MosqueHorizonIllustration', () {
    testWidgets('dekoratiftir ve küçük alanda crash etmez', (tester) async {
      await tester.pumpWidget(
        host(const MosqueHorizonIllustration(), size: const Size(2, 2)),
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(host(const MosqueHorizonIllustration()));
      expect(
        find.descendant(
          of: find.byType(MosqueHorizonIllustration),
          matching: find.byType(IgnorePointer),
        ),
        findsOneWidget,
      );
    });

    testWidgets('mevcut tek-yapı silueti ile birlikte yaşar', (tester) async {
      // Geometri ortaktır ama iki bileşen de ayrı ayrı kullanılabilir.
      await tester.pumpWidget(
        host(
          const Stack(
            children: [MosqueSilhouette(), MosqueHorizonIllustration()],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(MosqueSilhouette), findsOneWidget);
      expect(find.byType(MosqueHorizonIllustration), findsOneWidget);
    });
  });

  group('AppCard varyantları', () {
    testWidgets('varsayılan varyant mevcut davranışı KORUR (gölgeli)', (
      tester,
    ) async {
      await tester.pumpWidget(host(const AppCard(child: Text('x'))));

      final decoration =
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
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.border, isNull);
    });

    testWidgets('tonal varyantlar gölgesizdir ve yüzeyleri farklıdır', (
      tester,
    ) async {
      BoxDecoration decorationOf(WidgetTester t) =>
          t
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

      await tester.pumpWidget(
        host(const AppCard(variant: AppCardVariant.sand, child: Text('x'))),
      );
      final sand = decorationOf(tester);
      expect(sand.boxShadow, isNull);
      expect(sand.color, IslamicVisualTokens.light().sandSurface);

      await tester.pumpWidget(
        host(const AppCard(variant: AppCardVariant.sage, child: Text('x'))),
      );
      // TASK 094A: kart yüzeyi artık seçim süresinde yumuşuyor; ölçülen
      // şey **duran** yüzeydir, ara karedeki karışım değil.
      await tester.pumpAndSettle();
      final sage = decorationOf(tester);
      expect(sage.boxShadow, isNull);
      expect(sage.color, IslamicVisualTokens.light().sageSurface);

      expect(sand.color, isNot(sage.color));
    });

    testWidgets('outlined varyant gölge yerine kenarlık kullanır', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const AppCard(variant: AppCardVariant.outlined, child: Text('x'))),
      );

      final decoration =
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
      expect(decoration.boxShadow, isNull);
      expect(decoration.border, isNotNull);
    });

    testWidgets('completed durumu varyant yüzeyini EZER', (tester) async {
      await tester.pumpWidget(
        host(
          const AppCard(
            variant: AppCardVariant.sand,
            completed: true,
            child: Text('x'),
          ),
        ),
      );

      final decoration =
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
      // Tamamlanma geri bildirimi görsel varyanttan önce gelir.
      expect(decoration.color, isNot(IslamicVisualTokens.light().sandSurface));
    });
  });

  group('WarmSection', () {
    testWidgets('desen varsayılan olarak KAPALIDIR (kutsal metin güvenliği)', (
      tester,
    ) async {
      await tester.pumpWidget(host(const WarmSection(child: Text('x'))));
      expect(tester.takeException(), isNull);
      expect(find.text('x'), findsOneWidget);
    });

    testWidgets('yüzey ailesi seçilebilir', (tester) async {
      await tester.pumpWidget(
        host(
          const WarmSection(surface: WarmSectionSurface.sage, child: Text('x')),
        ),
      );

      final decoration =
          tester
                  .widget<DecoratedBox>(
                    find
                        .descendant(
                          of: find.byType(WarmSection),
                          matching: find.byType(DecoratedBox),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration;
      expect(decoration.color, IslamicVisualTokens.light().sageSurface);
    });
  });
}
