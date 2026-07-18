import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/features/quran/data/asset_quran_content_repository.dart';
import 'package:bismillah_app/features/quran/data/asset_quran_verse_page_repository.dart';
import 'package:bismillah_app/features/quran/data/bundled_quran_search_repository.dart';
import 'package:bismillah_app/features/quran/data/bundled_quranenc_translation_repository.dart';
import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/presentation/quran_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TASK 033/034B Kur'an ekranı: kurulum kapısı, iç sekmeler, katalog
/// listesi ve lokal arama. Ekran GoRouter olmadan bağımsız pump'lanır.
void main() {
  const completedSetup = {
    'bismillah.quran_setup_completed': true,
    'bismillah.quran_arabic_script': 'uthmani',
    'bismillah.quran_translation': 'turkish',
    'bismillah.quran_goal_type': 'pages',
    'bismillah.quran_goal_amount': 3,
  };

  Future<void> pumpQuranScreen(WidgetTester tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('tr', 'TR');
    tester.platformDispatcher.localesTestValue = const [Locale('tr', 'TR')];
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    tester.view.physicalSize = const Size(1080, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Asset okuma gerçek I/O'dur — FakeAsync altında tamamlanamaz;
    // cache'ler runAsync ile ısıtılır, depolar sıcak cache'iyle override
    // edilir. TASK 047 sayfa-eşleme probe'u ve TASK 048 arama indeksi de
    // ısıtılır; aksi halde İlerlemem/arama gerçek I/O'da asılı kalır.
    final repository = AssetQuranContentRepository();
    await tester.runAsync(repository.getChapters);

    final pageRepository = AssetQuranVersePageRepository();
    await tester.runAsync(() => pageRepository.pagesForChapter(1));

    final searchRepository = BundledQuranSearchRepository(
      contentRepository: repository,
      translationRepository: BundledQuranEncTranslationRepository(),
    );
    // İlk arama indeks asset'ini yükleyip cache'ler (sonraki aramalar
    // FakeAsync altında sıcak cache'ten çözülür).
    await tester.runAsync(() => searchRepository.search('1'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranContentRepositoryProvider.overrideWithValue(repository),
          quranVersePageRepositoryProvider.overrideWithValue(pageRepository),
          quranSearchRepositoryProvider.overrideWithValue(searchRepository),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          supportedLocales: SupportedLocale.locales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const QuranScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('kurulum tamamlanmamışsa üç adımlı kurulum görünür', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await pumpQuranScreen(tester);

    expect(find.text('Arapça yazı biçimini seç'), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.text('Uthmani'), findsOneWidget);
    expect(find.text('IndoPak'), findsOneWidget);
    // Ana ekran sekmeleri görünmez.
    expect(find.text('İlerlemem'), findsNothing);
  });

  testWidgets('kayıtlı kurulumla sekmeler ve 114 surelik katalog görünür', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(completedSetup);
    await pumpQuranScreen(tester);

    expect(find.text('Oku'), findsOneWidget);
    expect(find.text('Öğren'), findsOneWidget);
    expect(find.text('İlerlemem'), findsOneWidget);
    // Katalog ilk suredan başlar; enum .name ekranda görünmez.
    expect(find.text('Al-Faatiha'), findsOneWidget);
    expect(find.text('7 ayet · Mekkî'), findsOneWidget);
    expect(find.text('meccan'), findsNothing);
    expect(find.text('pages'), findsNothing);
  });

  testWidgets('arama: numara, Latin ad ve Arapça ad ile çalışır', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(completedSetup);
    await pumpQuranScreen(tester);

    // TASK 048 arama debounce'ludur (~300 ms); odaklı TextField imleci
    // sürekli frame ürettiği için pumpAndSettle yerine debounce süresi
    // kadar + microtask flush pump'lanır.
    Future<void> pumpSearch() async {
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();
      await tester.pump();
    }

    // Numara ile: 114 → An-Naas.
    await tester.enterText(find.byType(TextField), '114');
    await pumpSearch();
    expect(find.text('An-Naas'), findsOneWidget);
    expect(find.text('Al-Faatiha'), findsNothing);

    // Latin ad ile (büyük/küçük harf duyarsız).
    await tester.enterText(find.byType(TextField), 'baqara');
    await pumpSearch();
    expect(find.text('Al-Baqara'), findsOneWidget);

    // Arapça ad ile.
    await tester.enterText(find.byType(TextField), 'الفاتحة');
    await pumpSearch();
    expect(find.text('Al-Faatiha'), findsOneWidget);

    // Sonuç yok durumu sakin metinle gösterilir (TASK 048 metni).
    await tester.enterText(find.byType(TextField), 'zzzz');
    await pumpSearch();
    expect(
      find.text('Aramanızla eşleşen sure veya ayet bulunamadı.'),
      findsOneWidget,
    );
  });

  testWidgets('İlerlemem doğru hedef türü ve miktarını gösterir', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(completedSetup);
    await pumpQuranScreen(tester);

    await tester.tap(find.text('İlerlemem'));
    await tester.pumpAndSettle();

    expect(find.text('3 sayfa'), findsOneWidget);
    expect(find.text('0 / 3 sayfa'), findsOneWidget);
    expect(find.text('Hedefi düzenle'), findsOneWidget);
  });
}
