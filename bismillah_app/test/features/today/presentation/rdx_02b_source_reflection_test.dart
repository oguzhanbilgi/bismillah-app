import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/storage/database_providers.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/quran/data/asset_quran_content_repository.dart';
import 'package:bismillah_app/features/quran/data/bundled_quranenc_translation_repository.dart';
import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:bismillah_app/features/today/domain/daily_verse_reference.dart';
import 'package:bismillah_app/features/today/domain/today_reflection.dart';
import 'package:bismillah_app/features/today/presentation/today_screen.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_daily_reflection.dart';
import 'package:bismillah_app/shared/islamic/referenced_verse_card.dart';
import 'package:bismillah_app/shared/sacred/sacred_content_source_badge.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';
import '../../../helpers/test_prayer_times.dart';
import '../../../helpers/test_reminders.dart';
import '../../../helpers/test_session.dart';
import '../../../helpers/widget_test_utils.dart';

/// RDX-02B — Today kaynak sadeleştirmesi + günün sakin kapanış cümlesi.
///
/// Zaman DAİMA enjekte edilir; gerçek saat beklenmez, ağ kullanılmaz.
void main() {
  const tr = AppLocalizations(SupportedLocale.tr);
  const en = AppLocalizations(SupportedLocale.en);
  const ar = AppLocalizations(SupportedLocale.ar);

  /// Today kartında ASLA görünmemesi gereken sağlayıcı adları.
  const providerNames = ['Tanzil', 'QuranEnc', 'Rowad'];

  // ---------------------------------------------------------------
  // A. Kaynak sunumu
  // ---------------------------------------------------------------

  group('ReferencedVerseCard künye sunumu', () {
    Widget host(Widget child, {SupportedLocale locale = SupportedLocale.tr}) =>
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
          home: Scaffold(body: SingleChildScrollView(child: child)),
        );

    /// `AppLocalizations.delegate` bir frame'de çözülmez; delege yüklenene
    /// kadar `MaterialApp` çocuğu kurmaz. Bu yüzden pump'tan sonra yerleşilir.
    Future<void> pumpCard(WidgetTester tester, Widget card) async {
      await tester.pumpWidget(host(card));
      await tester.pumpAndSettle();
    }

    testWidgets('VARSAYILAN davranış değişmedi: künye satırı görünür', (
      tester,
    ) async {
      await pumpCard(
        tester,
        const ReferencedVerseCard(
          arabicText: 'بِسْمِ ٱللَّهِ',
          reference: 'Fâtiha 1:1',
          sourceLabel: 'Tanzil · QuranEnc Rowad',
          translation: 'Rahmân ve Rahîm olan Allah’ın adıyla.',
        ),
      );

      // Diğer çağıranlar için hiçbir şey değişmemiştir.
      expect(find.byType(SacredContentSourceBadge), findsOneWidget);
      expect(find.text('Tanzil · QuranEnc Rowad'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsNothing);
    });

    testWidgets('compact mod künye satırını çizmez, bilgi eylemi verir', (
      tester,
    ) async {
      await pumpCard(
        tester,
        ReferencedVerseCard(
          arabicText: 'بِسْمِ ٱللَّهِ',
          reference: 'Fâtiha 1:1',
          sourceLabel: 'Tanzil · QuranEnc Rowad',
          translation: 'Rahmân ve Rahîm olan Allah’ın adıyla.',
          sourceDisclosure: VerseSourceDisclosure.compact,
          onShowSource: () {},
        ),
      );

      expect(find.byType(SacredContentSourceBadge), findsNothing);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      for (final name in providerNames) {
        expect(find.textContaining(name), findsNothing, reason: name);
      }
      // Ayet, referans ve meal AYNEN durur.
      expect(find.text('Fâtiha 1:1'), findsOneWidget);
      expect(find.text('بِسْمِ ٱللَّهِ'), findsOneWidget);
      expect(
        find.text('Rahmân ve Rahîm olan Allah’ın adıyla.'),
        findsOneWidget,
      );
    });

    test('compact mod, künyeyi açacak eylem OLMADAN kurulamaz', () {
      expect(
        () => ReferencedVerseCard(
          arabicText: 'بِسْمِ ٱللَّهِ',
          reference: 'Fâtiha 1:1',
          sourceLabel: 'Tanzil · QuranEnc Rowad',
          sourceDisclosure: VerseSourceDisclosure.compact,
        ),
        throwsAssertionError,
        reason: 'kaynak kullanıcı için erişilemez hâle GELEMEZ',
      );
    });

    test('sourceLabel hâlâ ZORUNLU veridir ("no source, no render")', () {
      // Adlandırılmış parametre `required` olduğu için kaynaksız bir kart
      // DERLENEMEZ; bu test sözleşmenin varlığını çalışma zamanında da
      // sabitler.
      const card = ReferencedVerseCard(
        arabicText: 'بِسْمِ ٱللَّهِ',
        reference: 'Fâtiha 1:1',
        sourceLabel: 'Tanzil · QuranEnc Rowad',
      );
      expect(card.sourceLabel, isNotEmpty);
      expect(card.sourceDisclosure, VerseSourceDisclosure.inline);
    });
  });

  // ---------------------------------------------------------------
  // B. Günün cümlesi — saf çözücü
  // ---------------------------------------------------------------

  group('günün cümlesi seçimi', () {
    test('aynı yerel gün, saatten bağımsız AYNI cümleyi verir', () {
      final morning = TodayReflection.indexForLocalDate(
        DateTime(2026, 8, 8, 0, 1),
      );
      final noon = TodayReflection.indexForLocalDate(
        DateTime(2026, 8, 8, 12, 30),
      );
      final lateNight = TodayReflection.indexForLocalDate(
        DateTime(2026, 8, 8, 23, 59),
      );
      expect(morning, noon);
      expect(noon, lateNight);
    });

    test('ertesi yerel gün FARKLI bir cümleye geçer', () {
      for (var d = 1; d <= 40; d++) {
        final today = TodayReflection.indexForLocalDate(DateTime(2026, 8, d));
        final tomorrow = TodayReflection.indexForLocalDate(
          DateTime(2026, 8, d + 1),
        );
        expect(today, isNot(tomorrow), reason: 'gün $d');
      }
    });

    test('döngü deterministik ve tam kapsayıcıdır', () {
      final seen = <int>{};
      for (var d = 0; d < TodayReflection.count; d++) {
        seen.add(TodayReflection.indexForLocalDate(DateTime(2026, 8, 8 + d)));
      }
      expect(seen.length, TodayReflection.count);
      // Tam bir tur sonra başa döner.
      expect(
        TodayReflection.indexForLocalDate(
          DateTime(2026, 8, 8 + TodayReflection.count),
        ),
        TodayReflection.indexForLocalDate(DateTime(2026, 8, 8)),
      );
    });

    test('indeks daima 0..count-1 aralığındadır (geçmiş tarihler dâhil)', () {
      for (final date in [
        DateTime(1990, 1, 1),
        DateTime(2020, 2, 29),
        DateTime(2026, 12, 31),
        DateTime(2099, 6, 15),
      ]) {
        final i = TodayReflection.indexForLocalDate(date);
        expect(i, inInclusiveRange(0, TodayReflection.count - 1));
      }
    });

    test('gün sınırı YEREL takvimdir, UTC değil', () {
      // Yerel 23:30 ile ertesi yerel 00:30 FARKLI günlerdir; UTC sınırı
      // kullanılsaydı bu iki an aynı UTC gününe düşüp aynı cümleyi verebilirdi.
      final lateToday = DateTime(2026, 8, 8, 23, 30);
      final earlyTomorrow = DateTime(2026, 8, 9, 0, 30);
      expect(
        TodayReflection.indexForLocalDate(lateToday),
        isNot(TodayReflection.indexForLocalDate(earlyTomorrow)),
      );
      // Ve seçim, aynı yerel alanları taşıyan bir UTC damgasından DEĞİL,
      // yerel alanlardan türer: yerel 00:30'un UTC karşılığı önceki güne
      // düşse bile sonuç ertesi günün cümlesidir.
      expect(
        TodayReflection.indexForLocalDate(earlyTomorrow),
        TodayReflection.indexForLocalDate(DateTime(2026, 8, 9, 15)),
      );
    });
  });

  // ---------------------------------------------------------------
  // C. Cümle içeriği ve yerelleştirme
  // ---------------------------------------------------------------

  group('cümle içeriği', () {
    test('üç dilde de 14 cümle vardır ve hiçbiri boş değildir', () {
      for (final l10n in [tr, en, ar]) {
        for (var i = 0; i < TodayReflection.count; i++) {
          expect(l10n.reflectionAt(i).trim(), isNotEmpty, reason: '$i');
        }
      }
    });

    test('her dilde 14 cümle birbirinden FARKLIDIR', () {
      for (final l10n in [tr, en, ar]) {
        final all = {
          for (var i = 0; i < TodayReflection.count; i++) l10n.reflectionAt(i),
        };
        expect(all.length, TodayReflection.count);
      }
    });

    test('diller birbirinden farklıdır (İngilizceye düşme yok)', () {
      for (var i = 0; i < TodayReflection.count; i++) {
        expect(tr.reflectionAt(i), isNot(en.reflectionAt(i)));
        expect(ar.reflectionAt(i), isNot(en.reflectionAt(i)));
        expect(ar.reflectionAt(i), isNot(tr.reflectionAt(i)));
      }
    });

    test('Arapça cümleler ARAP HARFLİDİR (harf çevirisi değil)', () {
      final arabic = RegExp(r'[؀-ۿ]');
      final latin = RegExp(r'[A-Za-zçğıöşüÇĞİÖŞÜ]');
      for (var i = 0; i < TodayReflection.count; i++) {
        final value = ar.reflectionAt(i);
        expect(arabic.hasMatch(value), isTrue, reason: value);
        expect(latin.hasMatch(value), isFalse, reason: value);
      }
    });

    test('hiçbir cümle AYET/HADİS gibi sunulmaz', () {
      // Kutsal metin iddiası yaratacak işaretler ve diller yasaktır.
      const forbidden = [
        'Kur’an-ı Kerim’de buyurulur',
        'buyurdu',
        'Peygamber',
        'Hadis',
        'Ayet',
        'rivayet',
        'sevap',
        'Hadith',
        'Prophet',
        'verse says',
        'reward',
        'قال النبي',
        'حديث',
        'روى',
        'ثواب',
      ];
      for (final l10n in [tr, en, ar]) {
        for (var i = 0; i < TodayReflection.count; i++) {
          final value = l10n.reflectionAt(i);
          for (final word in forbidden) {
            expect(
              value.toLowerCase().contains(word.toLowerCase()),
              isFalse,
              reason: '"$value" içinde "$word" olmamalı',
            );
          }
          // Kutsal metin izlenimi veren tırnak işaretleri de yasaktır.
          for (final quote in ['"', '“', '”', '«', '»']) {
            expect(value.contains(quote), isFalse, reason: value);
          }
        }
      }
    });

    test('cümleler küçük bir telefon alt bilgisine sığacak kadar kısadır', () {
      for (final l10n in [tr, en, ar]) {
        for (var i = 0; i < TodayReflection.count; i++) {
          expect(l10n.reflectionAt(i).length, lessThanOrEqualTo(90));
        }
      }
    });
  });

  // ---------------------------------------------------------------
  // D. Ekran
  // ---------------------------------------------------------------

  group('Today ekranı', () {
    late AppDatabase db;

    setUp(() => db = createTestDatabase());
    tearDown(() async => db.close());

    Future<void> pumpToday(
      WidgetTester tester, {
      SupportedLocale locale = SupportedLocale.tr,
      DateTime? now,
      Size size = const Size(1080, 3600),
      double textScale = 1.0,
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Günün ayeti gerçek bundled asset'ten gelir; asset okuma gerçek
      // I/O'dur ve FakeAsync altında tamamlanamaz. Depolar `runAsync` ile
      // ısıtılıp sıcak cache'leriyle override edilir (mevcut
      // `today_spiritual_uplift_test` ile aynı yaklaşım).
      final clockNow = now ?? DateTime(2026, 8, 8, 9, 30);
      final content = AssetQuranContentRepository();
      final translation = BundledQuranEncTranslationRepository();
      final reference = DailyVerseReference.forLocalDate(clockNow);
      await tester.runAsync(() async {
        await content.getChapters();
        await content.getVerse(reference);
        await translation.getChapterTranslation(
          int.parse(reference.split(':').first),
        );
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            quranContentRepositoryProvider.overrideWithValue(content),
            quranTranslationRepositoryProvider.overrideWithValue(translation),
            clockProvider.overrideWithValue(FixedClock(clockNow)),
            fakeLocationOverride(),
            ...fakeReminderOverrides(),
            ...testSessionOverrides(),
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
              child: const TodayScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('teknik depolama alt bilgisi KALDIRILDI', (tester) async {
      await pumpToday(tester);

      expect(find.text('Kayıtların cihazında saklanır.'), findsNothing);
      expect(find.textContaining('cihazında saklanır'), findsNothing);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('günün cümlesi görünür ve yerel güne karşılık gelir', (
      tester,
    ) async {
      final now = DateTime(2026, 8, 8, 9, 30);
      await pumpToday(tester, now: now);

      expect(find.byType(TodayDailyReflection), findsOneWidget);
      final expected = tr.reflectionAt(TodayReflection.indexForLocalDate(now));
      expect(find.text(expected), findsOneWidget);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('aynı gün yeniden kurulumda AYNI cümle çıkar', (tester) async {
      final now = DateTime(2026, 8, 8, 7, 0);
      await pumpToday(tester, now: now);
      final first = tester
          .widget<AppText>(
            find.descendant(
              of: find.byType(TodayDailyReflection),
              matching: find.byType(AppText),
            ),
          )
          .text;
      await unmountAndFlushDriftTimers(tester);

      // "Uygulama yeniden başlatıldı": yeni container, aynı yerel gün.
      await pumpToday(tester, now: DateTime(2026, 8, 8, 21, 45));
      final second = tester
          .widget<AppText>(
            find.descendant(
              of: find.byType(TodayDailyReflection),
              matching: find.byType(AppText),
            ),
          )
          .text;

      expect(second, first);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('ertesi gün FARKLI cümle çıkar', (tester) async {
      await pumpToday(tester, now: DateTime(2026, 8, 8, 9, 30));
      final first = tester
          .widget<AppText>(
            find.descendant(
              of: find.byType(TodayDailyReflection),
              matching: find.byType(AppText),
            ),
          )
          .text;
      await unmountAndFlushDriftTimers(tester);

      await pumpToday(tester, now: DateTime(2026, 8, 9, 9, 30));
      final second = tester
          .widget<AppText>(
            find.descendant(
              of: find.byType(TodayDailyReflection),
              matching: find.byType(AppText),
            ),
          )
          .text;

      expect(second, isNot(first));

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('Today kartında sağlayıcı adları GÖRÜNMEZ', (tester) async {
      await pumpToday(tester);

      for (final name in providerNames) {
        expect(find.textContaining(name), findsNothing, reason: name);
      }
      // Kaynak yine de bir dokunuş uzakta: sessiz bilgi eylemi durur.
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.byType(SacredContentSourceBadge), findsNothing);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('bilgi eylemi TAM künyeyi açar', (tester) async {
      await pumpToday(tester);

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();

      expect(find.text(tr.verseSourceTitle), findsOneWidget);
      // Sağlayıcı adları burada TAM metniyle görünür — atıf kaybolmadı.
      expect(find.text('Tanzil · QuranEnc Rowad'), findsOneWidget);
      expect(find.byType(SacredContentSourceBadge), findsOneWidget);
      expect(find.text(tr.verseSourceAllSources), findsOneWidget);

      await tester.tap(find.text(tr.commonClose));
      await tester.pumpAndSettle();
      expect(find.text('Tanzil · QuranEnc Rowad'), findsNothing);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('ayet, referans ve yer imi eylemi korunur', (tester) async {
      await pumpToday(tester);

      expect(find.byType(ReferencedVerseCard), findsOneWidget);
      final card = tester.widget<ReferencedVerseCard>(
        find.byType(ReferencedVerseCard),
      );
      expect(card.sourceLabel, isNotEmpty);
      expect(card.sourceDisclosure, VerseSourceDisclosure.compact);
      expect(card.reference, isNotEmpty);
      expect(card.arabicText, isNotEmpty);
      expect(find.byIcon(Icons.bookmark_outline), findsOneWidget);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('İngilizce ve Arapça cümle ekranda çizilir', (tester) async {
      final now = DateTime(2026, 8, 8, 9, 30);
      final index = TodayReflection.indexForLocalDate(now);

      await pumpToday(tester, locale: SupportedLocale.en, now: now);
      expect(find.text(en.reflectionAt(index)), findsOneWidget);
      await unmountAndFlushDriftTimers(tester);

      await pumpToday(tester, locale: SupportedLocale.ar, now: now);
      expect(find.text(ar.reflectionAt(index)), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(TodayDailyReflection))),
        TextDirection.rtl,
      );

      await unmountAndFlushDriftTimers(tester);
    });

    for (final locale in SupportedLocale.values) {
      for (final scale in const [1.0, 1.5]) {
        testWidgets('${locale.name} @${scale}x: 320px taşma yok', (
          tester,
        ) async {
          await pumpToday(
            tester,
            locale: locale,
            size: const Size(320, 3600),
            textScale: scale,
          );

          expect(tester.takeException(), isNull);

          await unmountAndFlushDriftTimers(tester);
        });
      }
    }
  });
}
