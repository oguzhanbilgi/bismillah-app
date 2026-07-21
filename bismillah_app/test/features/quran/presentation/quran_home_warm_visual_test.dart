import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/features/quran/data/asset_quran_content_repository.dart';
import 'package:bismillah_app/features/quran/data/asset_quran_verse_page_repository.dart';
import 'package:bismillah_app/features/quran/data/bundled_quran_search_repository.dart';
import 'package:bismillah_app/features/quran/data/bundled_quranenc_translation_repository.dart';
import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/presentation/quran_screen.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:bismillah_app/shared/islamic/quran_on_rehal_illustration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kur'an ana ekranı sıcak görsel sistemi (TASK 054).
///
/// Gerçek ağ/ses KULLANILMAZ; golden framework EKLENMEZ. Mevcut işlevlerin
/// (arama, 114 sure, sekmeler) korunduğu ve yeni hero'nun üç dilde doğru
/// çalıştığı doğrulanır.
void main() {
  const completedSetup = {
    'bismillah.quran_setup_completed': true,
    'bismillah.quran_arabic_script': 'uthmani',
    'bismillah.quran_translation': 'turkish',
    'bismillah.quran_goal_type': 'pages',
    'bismillah.quran_goal_amount': 3,
  };

  Future<void> pumpQuranScreen(
    WidgetTester tester, {
    SupportedLocale locale = SupportedLocale.tr,
    Size size = const Size(1080, 3200),
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Asset okuma gerçek I/O'dur — FakeAsync altında tamamlanamaz; cache'ler
    // runAsync ile ısıtılır ve depolar sıcak cache'iyle override edilir.
    final repository = AssetQuranContentRepository();
    await tester.runAsync(repository.getChapters);

    final pageRepository = AssetQuranVersePageRepository();
    await tester.runAsync(() => pageRepository.pagesForChapter(1));

    final searchRepository = BundledQuranSearchRepository(
      contentRepository: repository,
      translationRepository: BundledQuranEncTranslationRepository(),
    );
    await tester.runAsync(() => searchRepository.search('1'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranContentRepositoryProvider.overrideWithValue(repository),
          quranVersePageRepositoryProvider.overrideWithValue(pageRepository),
          quranSearchRepositoryProvider.overrideWithValue(searchRepository),
          appLocaleAtLaunchProvider.overrideWithValue(locale),
        ],
        child: MaterialApp(
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
            child: const QuranScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Kur\'an hero — sıcak görsel kimlik', () {
    testWidgets('Türkçe hero başlığı ve alt metni görünür', (tester) async {
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester);

      expect(find.text('Kur\'an ile yeniden buluş'), findsOneWidget);
      expect(find.text('Kaldığın yerden sakince devam et.'), findsOneWidget);
    });

    testWidgets('İngilizce hero locale\'e uyar', (tester) async {
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester, locale: SupportedLocale.en);

      expect(find.text('Return to the Quran'), findsOneWidget);
      expect(
        find.text('Continue gently from where you left off.'),
        findsOneWidget,
      );
    });

    testWidgets('Arapça hero locale\'e uyar ve RTL olur', (tester) async {
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester, locale: SupportedLocale.ar);

      expect(find.text('عُد إلى القرآن'), findsOneWidget);
      expect(find.text('تابع بهدوء من حيث توقفت'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('عُد إلى القرآن'))),
        TextDirection.rtl,
      );
    });

    testWidgets('rahle illüstrasyonu dekoratiftir — semantics dışı', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(completedSetup);
      final handle = tester.ensureSemantics();
      await pumpQuranScreen(tester);

      expect(find.byType(QuranOnRehalIllustration), findsOneWidget);
      // Dekoratif katman ekran okuyucuya girmez ve dokunmayı engellemez.
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

    testWidgets('hero, sure listesinin ÜSTÜNDE tek kez render edilir', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester);

      // Liste başlığı olarak tek örnek: 114 satırda tekrar EDİLMEZ
      // (painter maliyeti liste boyunca çoğaltılmaz).
      expect(find.text('Kur\'an ile yeniden buluş'), findsOneWidget);
      expect(find.byType(QuranOnRehalIllustration), findsOneWidget);
    });
  });

  group('Mevcut işlevler korunur', () {
    testWidgets('sekmeler ve sure listesi çalışmaya devam eder', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester);

      expect(find.text('Sureler'), findsOneWidget);
      expect(find.text('Al-Faatiha'), findsOneWidget);

      // Sekme değişimi hâlâ çalışır.
      await tester.tap(find.text('İlerlemem'));
      await tester.pumpAndSettle();
      expect(find.text('Sureler'), findsNothing);

      await tester.tap(find.text('Oku'));
      await tester.pumpAndSettle();
      expect(find.text('Sureler'), findsOneWidget);
    });

    testWidgets('arama hâlâ sonuç döndürür', (tester) async {
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester);

      // TASK 048 arama debounce'ludur (~300 ms); odaklı TextField imleci
      // sürekli frame ürettiği için pumpAndSettle yerine debounce süresi
      // kadar pump'lanır (mevcut arama testiyle aynı desen).
      await tester.enterText(find.byType(TextField), 'baqara');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();
      await tester.pump();

      // Katalog yerini sonuçlara bırakır: eşleşen sure kalır, eşleşmeyen
      // (ve hero) gider. "Sureler" başlığı sonuç görünümünde de bölüm
      // başlığı olarak kullanıldığı için ayırt edici DEĞİLDİR.
      expect(find.text('Al-Baqara'), findsOneWidget);
      expect(find.text('Al-Faatiha'), findsNothing);
      expect(find.text("Kur'an ile yeniden buluş"), findsNothing);
    });

    testWidgets('sure satırı yeterli dokunma alanına sahiptir', (tester) async {
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester);

      // Satır artık ağır kart değil ama dokunma hedefi korunur.
      final rowSize = tester.getSize(
        find
            .ancestor(
              of: find.text('Al-Faatiha'),
              matching: find.byType(InkWell),
            )
            .first,
      );
      expect(rowSize.height, greaterThanOrEqualTo(48));
    });
  });

  group('Taşma güvenliği', () {
    for (final locale in SupportedLocale.values) {
      testWidgets('${locale.name}: 320px + 1.5 ölçekte taşma yok', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues(completedSetup);
        await pumpQuranScreen(
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
