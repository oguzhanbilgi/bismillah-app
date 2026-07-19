import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/features/learn/presentation/learn_placeholder_screen.dart';
import 'package:bismillah_app/shared/islamic/mosque_silhouette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Learn sıcak dönüşümü (TASK 055).
void main() {
  Future<void> pumpLearn(
    WidgetTester tester, {
    SupportedLocale locale = SupportedLocale.tr,
    Size size = const Size(1080, 2400),
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: locale.locale,
        supportedLocales: SupportedLocale.locales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const LearnPlaceholderScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Learn sıcak giriş', () {
    testWidgets('Türkçe hero ve keşif bölümü render eder', (tester) async {
      await pumpLearn(tester);

      expect(find.text('Bilgini sakince derinleştir'), findsOneWidget);
      expect(
        find.text('Bugün küçük bir konuyla başlayabilirsin'),
        findsOneWidget,
      );
      expect(find.text('Keşfetmeye devam et'), findsOneWidget);
      // Mevcut içerik durumu korunur.
      expect(find.text('Bu bölüm hazırlanıyor.'), findsOneWidget);
    });

    testWidgets('İngilizce locale hero metinlerini çevirir', (tester) async {
      await pumpLearn(tester, locale: SupportedLocale.en);

      expect(find.text('Deepen your knowledge gently'), findsOneWidget);
      expect(
        find.text('You can begin with one small topic today'),
        findsOneWidget,
      );
      expect(find.text('Continue exploring'), findsOneWidget);
      expect(find.text('Bilgini sakince derinleştir'), findsNothing);
    });

    testWidgets('Arapça locale Arapça metin ve RTL verir', (tester) async {
      await pumpLearn(tester, locale: SupportedLocale.ar);

      expect(find.text('عمّق معرفتك بهدوء'), findsOneWidget);
      expect(find.text('واصل الاستكشاف'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('عمّق معرفتك بهدوء'))),
        TextDirection.rtl,
      );
    });

    testWidgets('cami ufku dekoratiftir — semantics ve dokunma dışı', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpLearn(tester);

      expect(find.byType(MosqueHorizonIllustration), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(MosqueHorizonIllustration),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(MosqueHorizonIllustration),
          matching: find.byType(IgnorePointer),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('Taşma güvenliği', () {
    for (final locale in SupportedLocale.values) {
      testWidgets('${locale.name}: 320px + 1.5 ölçekte taşma yok', (
        tester,
      ) async {
        await pumpLearn(
          tester,
          locale: locale,
          size: const Size(320 * 3, 720 * 3),
          textScale: 1.5,
        );

        expect(tester.takeException(), isNull);
      });
    }
  });
}
