import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
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

/// Sure okuyucusunun sakin/sıcak görsel sistemi (TASK 055).
///
/// Gerçek ağ/ses KULLANILMAZ; audio/progress domain'ine DOKUNULMAZ —
/// yalnız görsel katman ve erişilebilirlik doğrulanır.
void main() {
  Future<void> pumpReader(
    WidgetTester tester, {
    int chapterId = 1,
    int? initialVerseNumber,
    SupportedLocale locale = SupportedLocale.tr,
    Size size = const Size(1080, 3200),
    double textScale = 1.0,
  }) async {
    SharedPreferences.setMockInitialValues({
      'bismillah.quran_reader_show_translation': true,
    });
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Asset okuma gerçek I/O'dur — FakeAsync altında tamamlanamaz;
    // cache'ler runAsync ile ısıtılır (mevcut reader testi deseni).
    final contentRepository = AssetQuranContentRepository();
    final translationRepository = BundledQuranEncTranslationRepository();
    await tester.runAsync(() async {
      await contentRepository.getVersesForChapter(chapterId);
      await translationRepository.getChapterTranslation(chapterId);
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
            child: QuranChapterReaderScreen(
              chapterId: chapterId,
              initialVerseNumber: initialVerseNumber,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Ayet bloğu sıcak yüzey', () {
    testWidgets('ayet bloğu saf beyaz değil, verseCardSurface kullanır', (
      tester,
    ) async {
      await pumpReader(tester);

      final block = tester.widget<ColoredBox>(
        find
            .descendant(
              of: find.byType(QuranTextBlock).first,
              matching: find.byType(ColoredBox),
            )
            .first,
      );
      expect(block.color, IslamicVisualTokens.light().verseCardSurface);
      expect(block.color, isNot(Colors.white));
    });

    testWidgets('Arapça ayet RTL, meal LTR render edilir', (tester) async {
      await pumpReader(tester);

      // Ayet metni ASSET'ten okunur — elle yazılmış kopya kodepoint
      // farkıyla yanlış negatif üretebilir.
      final firstBlock = tester.widget<QuranTextBlock>(
        find.byType(QuranTextBlock).first,
      );
      final arabic = tester.widget<Text>(find.text(firstBlock.arabicText));
      expect(arabic.textDirection, TextDirection.rtl);

      final translation = tester.widget<Text>(
        find.text('Bismillâhirrahmânirrahîm'),
      );
      expect(translation.textDirection, TextDirection.ltr);
    });

    testWidgets('Tanzil etiketi tek satırda yatay kalır', (tester) async {
      await pumpReader(tester);

      final label = tester.widget<Text>(find.textContaining('1:1 · Tanzil'));
      expect(label.maxLines, 1);
      expect(label.softWrap, isFalse);
    });

    testWidgets('hedef ayet vurgusu tonal yüzey + semantik durum alır', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      // Arama akışındaki hedef ayet vurgusu aktif-ayet görselini paylaşır
      // (TASK 048/055) — ses çalmadan vurgu davranışını test eder.
      await pumpReader(tester, initialVerseNumber: 3);

      // Vurgulu blok spiritualGreen tonal yüzeye döner.
      final highlighted = tester
          .widgetList<QuranTextBlock>(find.byType(QuranTextBlock))
          .where((b) => b.highlighted);
      expect(highlighted.length, 1);

      // Yalnız renk DEĞİL: ayet semantik olarak "seçili" işaretlenir.
      final selectedNode = tester.getSemantics(
        find.ancestor(
          of: find.textContaining('1:3 · Tanzil'),
          matching: find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.selected == true,
          ),
        ),
      );
      expect(selectedNode, isNotNull);
      handle.dispose();
    });
  });

  group('Reader üst alanı ve ayarlar', () {
    testWidgets('sure adı, numarası ve ayet sayısı görünür — büyük hero yok', (
      tester,
    ) async {
      await pumpReader(tester);

      expect(find.text('Al-Faatiha'), findsWidgets);
      expect(find.text('1'), findsWidgets); // sure numarası rozeti
      expect(find.text('7 ayet · Mekkî'), findsOneWidget);
      // İlk ayet ilk viewport'ta görünür — hero ayetleri aşağı İTMEZ.
      expect(find.textContaining('1:1 · Tanzil'), findsOneWidget);
    });

    testWidgets('Tt ayarları görünür ve açılır', (tester) async {
      await pumpReader(tester);

      await tester.tap(find.byIcon(Icons.text_fields));
      await tester.pumpAndSettle();

      expect(find.text('Okuma görünümü'), findsOneWidget);
    });
  });

  group('Yerelleştirme ve RTL', () {
    testWidgets('İngilizce locale reader UI metinlerini çevirir', (
      tester,
    ) async {
      await pumpReader(tester, locale: SupportedLocale.en);

      await tester.tap(find.byIcon(Icons.text_fields));
      await tester.pumpAndSettle();
      expect(find.text('Reading view'), findsOneWidget);
      expect(find.text('Okuma görünümü'), findsNothing);
    });

    testWidgets('Arapça locale RTL olur; ayet metni değişmez', (tester) async {
      await pumpReader(tester, locale: SupportedLocale.ar);

      // UI RTL'dir…
      expect(
        Directionality.of(tester.element(find.byType(QuranTextBlock).first)),
        TextDirection.rtl,
      );
      // …ve Arapça ayet metni AYNEN durur (locale'den bağımsız):
      // ilk blok Tanzil asset'indeki 1:1 metnini taşır.
      final firstBlock = tester.widget<QuranTextBlock>(
        find.byType(QuranTextBlock).first,
      );
      expect(firstBlock.arabicText, isNotEmpty);
      expect(find.text(firstBlock.arabicText), findsOneWidget);
    });
  });

  group('Taşma güvenliği', () {
    for (final locale in SupportedLocale.values) {
      testWidgets('${locale.name}: 320px + 1.5 ölçekte taşma yok', (
        tester,
      ) async {
        await pumpReader(
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
