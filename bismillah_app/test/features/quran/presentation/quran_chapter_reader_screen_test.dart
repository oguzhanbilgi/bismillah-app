import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/features/quran/data/asset_quran_content_repository.dart';
import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/presentation/quran_chapter_reader_screen.dart';
import 'package:bismillah_app/shared/sacred/quran_text_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 035 sure okuyucusu: gerçek Tanzil asset'iyle RTL ayet gösterimi,
/// geçersiz id'de sakin hata, sahte meal üretilmediğinin doğrulanması.
void main() {
  Future<void> pumpReader(WidgetTester tester, {required int? chapterId}) async {
    tester.platformDispatcher.localeTestValue = const Locale('tr', 'TR');
    tester.platformDispatcher.localesTestValue = const [Locale('tr', 'TR')];
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    tester.view.physicalSize = const Size(1080, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Asset okuma gerçek I/O'dur — FakeAsync altında tamamlanamaz;
    // cache runAsync ile ısıtılır, depo sıcak cache'iyle override edilir.
    final repository = AssetQuranContentRepository();
    await tester.runAsync(() => repository.getVersesForChapter(1));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranContentRepositoryProvider.overrideWithValue(repository),
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

  testWidgets('Fatiha: başlık, 7 ayet bloğu, RTL metin ve Tanzil rozeti',
      (tester) async {
    await pumpReader(tester, chapterId: 1);

    expect(find.text('Al-Faatiha'), findsWidgets);
    expect(find.text('7 ayet · Mekkî'), findsOneWidget);

    final blocks = tester
        .widgetList<QuranTextBlock>(find.byType(QuranTextBlock))
        .toList();
    expect(blocks.length, 7);
    for (final block in blocks) {
      expect(block.arabicText.trim(), isNotEmpty);
      // Sahte meal ÜRETİLMEZ — meal alanı bu görevde daima boştur.
      expect(block.translation, isNull);
    }

    // Ayet metni RTL render edilir.
    final rtlTexts = find.byWidgetPredicate(
      (widget) => widget is Text && widget.textDirection == TextDirection.rtl,
    );
    expect(rtlTexts, findsWidgets);

    // Ayet başına kaynak rozeti (no source, no render).
    expect(find.textContaining('1:1 · Tanzil'), findsOneWidget);
  });

  testWidgets('geçersiz sure numarası sakin hata gösterir, crash olmaz',
      (tester) async {
    await pumpReader(tester, chapterId: 999);
    expect(find.text("Kur'an metni yüklenemedi."), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bozuk route parametresi (null) sakin hata gösterir',
      (tester) async {
    await pumpReader(tester, chapterId: null);
    expect(find.text("Kur'an metni yüklenemedi."), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
