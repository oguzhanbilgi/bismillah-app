import 'package:bismillah_app/app/bismillah_app.dart';
import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/storage/database_providers.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/quran/data/asset_quran_content_repository.dart';
import 'package:bismillah_app/features/quran/data/bundled_quranenc_translation_repository.dart';
import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_verse.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_content_repository.dart';
import 'package:bismillah_app/features/quran/presentation/quran_chapter_reader_screen.dart';
import 'package:bismillah_app/features/today/domain/daily_verse_reference.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_daily_verse_card.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_prayer_summary_card.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_quran_center_card.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_spiritual_hero.dart';
import 'package:bismillah_app/shared/islamic/mosque_silhouette.dart';
import 'package:bismillah_app/shared/islamic/referenced_verse_card.dart';
import 'package:bismillah_app/shared/islamic/spiritual_hero_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';
import '../../../helpers/test_prayer_times.dart';
import '../../../helpers/test_reminders.dart';
import '../../../helpers/test_session.dart';
import '../../../helpers/widget_test_utils.dart';

/// TASK 052: Today manevi hero + kaynaklı günün ayeti.
/// Ağ/ses KULLANILMAZ; ayet metni bundled Tanzil/QuranEnc'ten gelir.
void main() {
  final fixedLocalNow = DateTime(2026, 7, 11, 9, 30);

  // ---------------------------------------------------------------------
  // Günlük seçim (saf domain — depo/ağ yok)
  // ---------------------------------------------------------------------
  group('DailyVerseReference', () {
    test('aynı gün için deterministiktir', () {
      final a = DailyVerseReference.forLocalDate(DateTime(2026, 7, 11, 0, 1));
      final b = DailyVerseReference.forLocalDate(DateTime(2026, 7, 11, 23, 59));
      expect(a, b);
    });

    test('her gün curated liste içinden geçerli referans döner', () {
      for (var i = 0; i < 40; i++) {
        final date = DateTime(2026, 1, 1).add(Duration(days: i));
        final reference = DailyVerseReference.forLocalDate(date);
        expect(DailyVerseReference.curated, contains(reference));
        final parts = reference.split(':');
        expect(int.parse(parts.first), inInclusiveRange(1, 114));
        expect(int.parse(parts.last), greaterThan(0));
      }
    });

    test('ardışık günler listeyi dolaşır (tek ayete sabitlenmez)', () {
      final seen = <String>{};
      for (var i = 0; i < DailyVerseReference.curated.length; i++) {
        seen.add(
          DailyVerseReference.forLocalDate(
            DateTime(2026, 3, 1).add(Duration(days: i)),
          ),
        );
      }
      expect(seen.length, DailyVerseReference.curated.length);
    });
  });

  // ---------------------------------------------------------------------
  // Hero + cami silueti (hafif harness)
  // ---------------------------------------------------------------------
  group('TodaySpiritualHero', () {
    Widget host(Widget child, {double textScale = 1.0}) => ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('tr', 'TR'),
        supportedLocales: SupportedLocale.locales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    );

    testWidgets('hero başlık, açıklama ve tek aksiyonla render eder', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        host(TodaySpiritualHero(onSeeTodaysPlan: () => tapped = true)),
      );
      // Localization delegate'leri ilk frame'de hazır olmaz.
      await tester.pumpAndSettle();
      expect(find.text('Bugün yeniden başlayabilirsin'), findsOneWidget);
      expect(
        find.text('Her küçük adım, kalbini ibadete biraz daha yaklaştırır.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Bugünün planını gör'));
      expect(tapped, isTrue);
    });

    testWidgets('cami ufku semantics ağacına girmez', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(host(const TodaySpiritualHero()));
      await tester.pumpAndSettle();

      expect(find.byType(MosqueHorizonIllustration), findsOneWidget);
      // Siluet dekoratiftir: kendi düğümü yoktur, hero etiketi tek anlamdır.
      final node = tester.getSemantics(find.byType(SpiritualHeroCard));
      expect(node.label, contains('Bugün yeniden başlayabilirsin'));
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
      semantics.dispose();
    });

    testWidgets('metin ölçeği 1.3 ve 1.5 iken taşma yapmaz', (tester) async {
      for (final scale in [1.3, 1.5]) {
        await tester.pumpWidget(
          host(TodaySpiritualHero(onSeeTodaysPlan: () {}), textScale: scale),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'ölçek $scale');
        expect(find.byType(TodaySpiritualHero), findsOneWidget);
      }
    });
  });

  // ---------------------------------------------------------------------
  // Günün ayeti — gerçek bundled depolarla tam uygulama kabuğunda
  // ---------------------------------------------------------------------
  group('Today günün ayeti', () {
    late AppDatabase db;

    setUp(() => db = createTestDatabase());
    tearDown(() async => db.close());

    /// Asset okuma gerçek I/O'dur; FakeAsync altında tamamlanamaz — depolar
    /// runAsync ile ısıtılıp sıcak cache'leriyle override edilir.
    Future<void> pumpToday(
      WidgetTester tester, {
      QuranContentRepository? contentOverride,
    }) async {
      tester.platformDispatcher.localeTestValue = const Locale('tr', 'TR');
      tester.platformDispatcher.localesTestValue = const [Locale('tr', 'TR')];
      addTearDown(tester.platformDispatcher.clearAllTestValues);

      tester.view.physicalSize = const Size(1080, 4200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final reference = DailyVerseReference.forLocalDate(fixedLocalNow);
      final chapterId = int.parse(reference.split(':').first);

      final content = AssetQuranContentRepository();
      final translation = BundledQuranEncTranslationRepository();
      await tester.runAsync(() async {
        await content.getChapters();
        await content.getVerse(reference);
        await translation.getChapterTranslation(chapterId);
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            clockProvider.overrideWithValue(FixedClock(fixedLocalNow)),
            quranContentRepositoryProvider.overrideWithValue(
              contentOverride ?? content,
            ),
            quranTranslationRepositoryProvider.overrideWithValue(translation),
            fakeLocationOverride(),
            ...fakeReminderOverrides(),
            ...testSessionOverrides(),
          ],
          child: const BismillahApp(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('ayet bundled depodan yüklenir; referans ve kaynak görünür', (
      tester,
    ) async {
      await pumpToday(tester);

      expect(find.text('Bugünün Ayeti'), findsOneWidget);
      expect(find.byType(ReferencedVerseCard), findsOneWidget);
      // Kaynak künyesi her zaman gösterilir.
      expect(find.text('Tanzil · QuranEnc Rowad'), findsOneWidget);

      // Referans, günün curated seçimiyle tutarlıdır.
      final reference = DailyVerseReference.forLocalDate(fixedLocalNow);
      expect(
        find.textContaining(reference),
        findsOneWidget,
        reason: 'kartta sure adı + $reference referansı görünmeli',
      );

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('karta dokununca ayetin reader ekranı açılır', (tester) async {
      await pumpToday(tester);

      await tester.tap(find.byType(ReferencedVerseCard));
      // Reader okuma takipçisi periyodik timer kurduğu için pumpAndSettle
      // YERLEŞMEZ; sınırlı pump ile geçiş doğrulanır.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(QuranChapterReaderScreen), findsOneWidget);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('depo hatasında crash olmaz, sakin fallback gösterilir', (
      tester,
    ) async {
      await pumpToday(tester, contentOverride: _FailingContentRepository());

      expect(tester.takeException(), isNull);
      expect(find.text('Bugünün ayeti şu anda yüklenemedi.'), findsOneWidget);
      // Yanlış/boş ayet ASLA render edilmez.
      expect(find.byType(ReferencedVerseCard), findsNothing);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('mevcut namaz kartı ve Kur\'an merkezi korunur', (
      tester,
    ) async {
      await pumpToday(tester);

      expect(find.byType(TodayPrayerSummaryCard), findsOneWidget);
      expect(find.byType(TodayQuranCenterCard), findsOneWidget);
      expect(find.byType(TodaySpiritualHero), findsOneWidget);
      expect(find.byType(TodayDailyVerseCard), findsOneWidget);
      expect(find.text('0/5 tamamlandı'), findsOneWidget);

      await unmountAndFlushDriftTimers(tester);
    });
  });
}

/// Tüm okumaları başarısız olan içerik deposu — günün ayeti fallback'ini
/// kanıtlamak için (ağ YOK, yalnız kontrollü failure).
final class _FailingContentRepository implements QuranContentRepository {
  static const Result<Never> _failure = Result.failure(StorageFailure());

  @override
  ResultFuture<List<QuranChapter>> getChapters() async => _failure;

  @override
  ResultFuture<QuranChapter?> getChapter(int id) async => _failure;

  @override
  ResultFuture<List<QuranVerse>> getVersesForChapter(int chapterId) async =>
      _failure;

  @override
  ResultFuture<QuranVerse?> getVerse(String verseKey) async => _failure;
}
