import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/features/quran/data/asset_quran_content_repository.dart';
import 'package:bismillah_app/features/quran/data/bundled_quranenc_translation_repository.dart';
import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/presentation/quran_chapter_reader_screen.dart';
import 'package:bismillah_app/shared/sacred/quran_text_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TASK 035/040 + CHECKPOINT 06 Recovery sure okuyucusu: gerçek Tanzil
/// asset'iyle RTL ayet gösterimi, paketlenmiş QuranEnc Rowad meali
/// (internet/Firebase OLMADAN), meal aç/kapat tercihi ve geçersiz id'de
/// sakin hata.
void main() {
  Future<void> pumpReader(
    WidgetTester tester, {
    required int? chapterId,
    bool showTranslation = true,
  }) async {
    // TASK 036/037: reader konum + bookmark + boyut tercihlerini okur;
    // mock prefs olmadan platform kanalı FakeAsync altında tamamlanmaz.
    SharedPreferences.setMockInitialValues({
      'bismillah.quran_reader_show_translation': showTranslation,
    });
    tester.platformDispatcher.localeTestValue = const Locale('tr', 'TR');
    tester.platformDispatcher.localesTestValue = const [Locale('tr', 'TR')];
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    tester.view.physicalSize = const Size(1080, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Asset okuma gerçek I/O'dur — FakeAsync altında tamamlanamaz;
    // cache'ler runAsync ile ısıtılır, depolar sıcak cache'le override
    // edilir. Meal deposu OFFLINE asset'tir (HTTP/Firebase yok).
    final contentRepository = AssetQuranContentRepository();
    final translationRepository = BundledQuranEncTranslationRepository();
    await tester.runAsync(() async {
      await contentRepository.getVersesForChapter(1);
      await translationRepository.getChapterTranslation(1);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranContentRepositoryProvider.overrideWithValue(contentRepository),
          quranTranslationRepositoryProvider.overrideWithValue(
            translationRepository,
          ),
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
          home: QuranChapterReaderScreen(chapterId: chapterId),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Fatiha: 7 ayet bloğu, RTL metin, Tanzil rozeti ve OFFLINE '
      'QuranEnc meali', (tester) async {
    await pumpReader(tester, chapterId: 1);

    expect(find.text('Al-Faatiha'), findsWidgets);
    expect(find.text('7 ayet · Mekkî'), findsOneWidget);

    final blocks = tester
        .widgetList<QuranTextBlock>(find.byType(QuranTextBlock))
        .toList();
    expect(blocks.length, 7);
    for (final block in blocks) {
      expect(block.arabicText.trim(), isNotEmpty);
      // Meal paketlenmiş asset'ten HER ayette gelir (offline).
      expect(block.translation, isNotNull);
      expect(block.translation!.trim(), isNotEmpty);
    }
    // Verbatim örnek: 1:1 meali kaynak metniyle birebir görünür.
    expect(find.text('Bismillâhirrahmânirrahîm'), findsOneWidget);

    // Doğrulanmış kaynak etiketleri (Rowad + QuranEnc) görünür.
    expect(find.text('Meal: Rowad Tercüme Merkezi'), findsOneWidget);
    expect(find.text('Kaynak: QuranEnc.com · V1.0.4'), findsOneWidget);

    // Ayet metni RTL render edilir.
    final rtlTexts = find.byWidgetPredicate(
      (widget) => widget is Text && widget.textDirection == TextDirection.rtl,
    );
    expect(rtlTexts, findsWidgets);

    // Ayet başına kaynak rozeti (no source, no render).
    expect(find.textContaining('1:1 · Tanzil'), findsOneWidget);
  });

  testWidgets('meal tercihi kapalıyken meal ve kaynak etiketi gizlenir', (
    tester,
  ) async {
    await pumpReader(tester, chapterId: 1, showTranslation: false);

    final blocks = tester
        .widgetList<QuranTextBlock>(find.byType(QuranTextBlock))
        .toList();
    expect(blocks.length, 7);
    for (final block in blocks) {
      expect(block.translation, isNull); // Arapça metin etkilenmez
    }
    expect(find.text('Meal: Rowad Tercüme Merkezi'), findsNothing);
    expect(find.text('Bismillâhirrahmânirrahîm'), findsNothing);
  });

  testWidgets('geçersiz sure numarası sakin hata gösterir, crash olmaz', (
    tester,
  ) async {
    await pumpReader(tester, chapterId: 999);
    expect(find.text("Kur'an metni yüklenemedi."), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bozuk route parametresi (null) sakin hata gösterir', (
    tester,
  ) async {
    await pumpReader(tester, chapterId: null);
    expect(find.text("Kur'an metni yüklenemedi."), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
