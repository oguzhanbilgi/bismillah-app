import 'package:bismillah_app/app/bismillah_app.dart';
import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/storage/database_providers.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/prayer_times/application/prayer_times_controller.dart';
import 'package:bismillah_app/features/prayer_times/application/prayer_times_state.dart';
import 'package:bismillah_app/features/prayer_times/domain/daily_prayer_times.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_time_calculation_method.dart';
import 'package:bismillah_app/features/profile/presentation/profile_screen.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:bismillah_app/features/today/domain/today_greeting.dart';
import 'package:bismillah_app/features/today/presentation/today_screen.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_brand_header.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';
import '../../../helpers/test_prayer_times.dart';
import '../../../helpers/test_reminders.dart';
import '../../../helpers/test_session.dart';
import '../../../helpers/widget_test_utils.dart';

/// RDX-02A — Today marka başlığı + vakte duyarlı karşılama.
///
/// Zaman DAİMA enjekte edilir (`FixedClock`); hiçbir test gerçek saati
/// beklemez ve gerçek konum/ağ kullanılmaz.
void main() {
  // Sabit bir gün için gerçekçi UTC vakitler (İstanbul yazı, UTC+3):
  // İmsak 03:40, Güneş 05:35, Öğle 10:15, İkindi 14:10, Akşam 17:45,
  // Yatsı 19:30 UTC  ->  yerelde 06:40 / 08:35 / 13:15 / 17:10 / 20:45 / 22:30
  final times = DailyPrayerTimes(
    dayKey: '2026-07-11',
    fajr: DateTime.utc(2026, 7, 11, 3, 40),
    sunrise: DateTime.utc(2026, 7, 11, 5, 35),
    dhuhr: DateTime.utc(2026, 7, 11, 10, 15),
    asr: DateTime.utc(2026, 7, 11, 14, 10),
    maghrib: DateTime.utc(2026, 7, 11, 17, 45),
    isha: DateTime.utc(2026, 7, 11, 19, 30),
    method: PrayerTimeCalculationMethod.turkiyeDiyanet,
    asrMethod: AsrCalculationMethod.standard,
  );

  // ---------------------------------------------------------------
  // 1. Saf çözücü — beş vakit dilimi + gece uçları
  // ---------------------------------------------------------------

  group('vakit tabanlı karşılama dilimleri', () {
    TodayGreetingPeriod at(DateTime nowUtc) =>
        TodayGreetingResolver.fromPrayerTimes(times: times, nowUtc: nowUtc);

    test('İmsak → Öğle arası sabahtır', () {
      expect(at(DateTime.utc(2026, 7, 11, 3, 40)), TodayGreetingPeriod.morning);
      expect(at(DateTime.utc(2026, 7, 11, 7, 0)), TodayGreetingPeriod.morning);
      expect(
        at(DateTime.utc(2026, 7, 11, 10, 14, 59)),
        TodayGreetingPeriod.morning,
      );
    });

    test('Güneş doğuşu dilimi BÖLMEZ (namaz vakti değildir)', () {
      final justBefore = times.sunrise.subtract(const Duration(minutes: 1));
      final justAfter = times.sunrise.add(const Duration(minutes: 1));
      expect(at(justBefore), TodayGreetingPeriod.morning);
      expect(at(justAfter), TodayGreetingPeriod.morning);
    });

    test('Öğle → İkindi arası öğledir', () {
      expect(at(DateTime.utc(2026, 7, 11, 10, 15)), TodayGreetingPeriod.noon);
      expect(at(DateTime.utc(2026, 7, 11, 12, 0)), TodayGreetingPeriod.noon);
      expect(
        at(DateTime.utc(2026, 7, 11, 14, 9, 59)),
        TodayGreetingPeriod.noon,
      );
    });

    test('İkindi → Akşam arası gündür', () {
      expect(at(DateTime.utc(2026, 7, 11, 14, 10)), TodayGreetingPeriod.day);
      expect(at(DateTime.utc(2026, 7, 11, 16, 0)), TodayGreetingPeriod.day);
      expect(
        at(DateTime.utc(2026, 7, 11, 17, 44, 59)),
        TodayGreetingPeriod.day,
      );
    });

    test('Akşam → Yatsı arası akşamdır', () {
      expect(
        at(DateTime.utc(2026, 7, 11, 17, 45)),
        TodayGreetingPeriod.evening,
      );
      expect(
        at(DateTime.utc(2026, 7, 11, 19, 29, 59)),
        TodayGreetingPeriod.evening,
      );
    });

    test('Yatsı SONRASI gecedir', () {
      expect(at(DateTime.utc(2026, 7, 11, 19, 30)), TodayGreetingPeriod.night);
      expect(at(DateTime.utc(2026, 7, 11, 23, 59)), TodayGreetingPeriod.night);
    });

    test('İmsak ÖNCESİ de gecedir (gün ortasından bölünür)', () {
      expect(at(DateTime.utc(2026, 7, 11, 0, 5)), TodayGreetingPeriod.night);
      expect(
        at(DateTime.utc(2026, 7, 11, 3, 39, 59)),
        TodayGreetingPeriod.night,
      );
    });

    test('beş dilimin tamamı gerçek vakitlerle üretilebilir', () {
      final produced = {
        for (final h in [1, 7, 12, 16, 18, 22])
          at(DateTime.utc(2026, 7, 11, h)),
      };
      expect(produced, TodayGreetingPeriod.values.toSet());
    });
  });

  // ---------------------------------------------------------------
  // 2. Yerel saat yedeği
  // ---------------------------------------------------------------

  group('yerel saat yedeği', () {
    TodayGreetingPeriod at(int hour) =>
        TodayGreetingResolver.fromLocalTime(DateTime(2026, 7, 11, hour, 30));

    test('pencereler sözleşmeye uyar', () {
      for (final h in [5, 8, 11]) {
        expect(at(h), TodayGreetingPeriod.morning, reason: '$h');
      }
      for (final h in [12, 13, 14]) {
        expect(at(h), TodayGreetingPeriod.noon, reason: '$h');
      }
      for (final h in [15, 16, 17]) {
        expect(at(h), TodayGreetingPeriod.day, reason: '$h');
      }
      for (final h in [18, 20, 22]) {
        expect(at(h), TodayGreetingPeriod.evening, reason: '$h');
      }
      for (final h in [23, 0, 3, 4]) {
        expect(at(h), TodayGreetingPeriod.night, reason: '$h');
      }
    });

    test('24 saatin tamamı bir dilime düşer (boşluk yok)', () {
      for (var h = 0; h < 24; h++) {
        expect(at(h), isA<TodayGreetingPeriod>());
      }
    });

    test('vakit YOKSA yedeğe düşülür', () {
      expect(
        TodayGreetingResolver.resolve(
          times: null,
          nowUtc: DateTime.utc(2026, 7, 11, 3),
          nowLocal: DateTime(2026, 7, 11, 20),
        ),
        TodayGreetingPeriod.evening,
        reason: 'vakit yokken yerel 20:00 akşamdır',
      );
    });

    test('vakitler TUTARSIZSA yedeğe düşülür (yanıltıcı dilim üretilmez)', () {
      final broken = DailyPrayerTimes(
        dayKey: '2026-07-11',
        fajr: DateTime.utc(2026, 7, 11, 20),
        sunrise: DateTime.utc(2026, 7, 11, 5),
        dhuhr: DateTime.utc(2026, 7, 11, 10),
        asr: DateTime.utc(2026, 7, 11, 14),
        maghrib: DateTime.utc(2026, 7, 11, 17),
        isha: DateTime.utc(2026, 7, 11, 19),
        method: PrayerTimeCalculationMethod.turkiyeDiyanet,
        asrMethod: AsrCalculationMethod.standard,
      );
      expect(broken.isChronological, isFalse);
      expect(
        TodayGreetingResolver.resolve(
          times: broken,
          nowUtc: DateTime.utc(2026, 7, 11, 6),
          nowLocal: DateTime(2026, 7, 11, 9),
        ),
        TodayGreetingPeriod.morning,
      );
    });

    test('gerçek vakitler VARSA yedek KULLANILMAZ', () {
      expect(
        TodayGreetingResolver.resolve(
          times: times,
          nowUtc: DateTime.utc(2026, 7, 11, 18, 0),
          // Yerel saat sabah olsa bile vakitler kazanır.
          nowLocal: DateTime(2026, 7, 11, 8),
        ),
        TodayGreetingPeriod.evening,
      );
    });
  });

  // ---------------------------------------------------------------
  // 3. Yerelleştirme
  // ---------------------------------------------------------------

  group('yerelleştirme', () {
    const tr = AppLocalizations(SupportedLocale.tr);
    const en = AppLocalizations(SupportedLocale.en);
    const ar = AppLocalizations(SupportedLocale.ar);

    test('Türkçe metinler sözleşmeyle birebir aynıdır', () {
      expect(tr.greetingFor(TodayGreetingPeriod.morning), 'Hayırlı sabahlar');
      expect(tr.greetingFor(TodayGreetingPeriod.noon), 'Hayırlı öğlenler');
      expect(tr.greetingFor(TodayGreetingPeriod.day), 'Hayırlı günler');
      expect(tr.greetingFor(TodayGreetingPeriod.evening), 'Hayırlı akşamlar');
      expect(tr.greetingFor(TodayGreetingPeriod.night), 'Hayırlı geceler');
    });

    test('İngilizce karşılıklar verilmiştir', () {
      expect(en.greetingFor(TodayGreetingPeriod.morning), 'Good morning');
      expect(en.greetingFor(TodayGreetingPeriod.noon), 'Good afternoon');
      expect(en.greetingFor(TodayGreetingPeriod.day), 'Have a blessed day');
      expect(en.greetingFor(TodayGreetingPeriod.evening), 'Good evening');
      expect(en.greetingFor(TodayGreetingPeriod.night), 'Good night');
    });

    test('her dilde beş dilim boş değil ve birbirinden farklıdır', () {
      for (final l10n in [tr, en, ar]) {
        final all = [
          for (final p in TodayGreetingPeriod.values) l10n.greetingFor(p),
        ];
        expect(all.any((s) => s.trim().isEmpty), isFalse);
        expect(all.toSet().length, TodayGreetingPeriod.values.length);
      }
    });

    test('diller birbirinden farklıdır (İngilizceye düşme yok)', () {
      for (final p in TodayGreetingPeriod.values) {
        expect(tr.greetingFor(p), isNot(en.greetingFor(p)));
        expect(ar.greetingFor(p), isNot(en.greetingFor(p)));
        expect(ar.greetingFor(p), isNot(tr.greetingFor(p)));
      }
    });

    test('Arapça karşılamalar ARAP HARFLİDİR (harf çevirisi değil)', () {
      final arabic = RegExp(r'[؀-ۿ]');
      final latin = RegExp(r'[A-Za-zçğıöşüÇĞİÖŞÜ]');
      for (final p in TodayGreetingPeriod.values) {
        final value = ar.greetingFor(p);
        expect(arabic.hasMatch(value), isTrue, reason: value);
        expect(latin.hasMatch(value), isFalse, reason: value);
      }
    });

    test('navigasyon etiketi üç dilde de güncellendi', () {
      expect(tr.tabToday, 'Günüm');
      expect(en.tabToday, 'My Day');
      expect(ar.tabToday, 'يومي');
    });

    test('marka adı üç dilde de "Bismillah"tır', () {
      for (final l10n in [tr, en, ar]) {
        expect(l10n.appTitle, 'Bismillah');
      }
    });
  });

  // ---------------------------------------------------------------
  // 4. Ekran
  // ---------------------------------------------------------------

  group('Today marka başlığı', () {
    late AppDatabase db;

    setUp(() => db = createTestDatabase());
    tearDown(() async => db.close());

    Future<void> pumpToday(
      WidgetTester tester, {
      SupportedLocale locale = SupportedLocale.tr,
      DateTime? now,
      Size size = const Size(1080, 3200),
      double textScale = 1.0,
      // Konum servisi TEK bir override ile verilir; Riverpod aynı provider'ın
      // iki kez ezilmesine izin vermez.
      Override? location,
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            clockProvider.overrideWithValue(
              FixedClock(now ?? DateTime(2026, 7, 11, 9, 30)),
            ),
            location ?? fakeLocationOverride(),
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

    testWidgets('marka başlığı görünür: glyph + Bismillah + profil eylemi', (
      tester,
    ) async {
      await pumpToday(tester);

      expect(find.byType(TodayBrandHeader), findsOneWidget);
      expect(find.text('Bismillah'), findsOneWidget);
      final image = tester.widget<Image>(
        find.descendant(
          of: find.byType(TodayBrandHeader),
          matching: find.byType(Image),
        ),
      );
      expect(
        (image.image as AssetImage).assetName,
        TodayBrandHeader.glyphAsset,
      );
      expect(find.byIcon(Icons.person_outline), findsOneWidget);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('ekran başlığı olarak Bugün/Günüm/Bugünün ritmi YOK', (
      tester,
    ) async {
      await pumpToday(tester);

      // Ekran doğrudan pump edilir (alt navigasyon yok), bu yüzden 'Günüm'
      // hiç görünmemelidir: o yalnız bir navigasyon etiketidir.
      expect(find.text('Bugün'), findsNothing);
      expect(find.text('Günüm'), findsNothing);
      expect(find.text('Bugünün ritmi'), findsNothing);
      expect(find.byType(AppBar), findsNothing);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('karşılama ikincil metindir, başlık DEĞİLDİR', (tester) async {
      await pumpToday(tester);

      final greeting = tester.widget<AppText>(
        find.widgetWithText(AppText, 'Hayırlı sabahlar'),
      );
      expect(greeting.token, AppTextStyleToken.bodySmall);
      expect(greeting.tone, AppTextTone.secondary);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('marka başlığı karşılamanın ÜSTÜNDE durur', (tester) async {
      await pumpToday(tester);

      expect(
        tester.getTopLeft(find.byType(TodayBrandHeader)).dy,
        lessThan(tester.getTopLeft(find.text('Hayırlı sabahlar')).dy),
      );

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('profil eylemi 48dp dokunma hedefini karşılar', (tester) async {
      await pumpToday(tester);

      final size = tester.getSize(
        find.ancestor(
          of: find.byIcon(Icons.person_outline),
          matching: find.byType(IconButton),
        ),
      );
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('karşılama GERÇEK vakitleri izler, yerel saati değil', (
      tester,
    ) async {
      // Konum izinli → controller gerçek vakitleri hesaplar.
      //
      // Beklenen dilim TESTE ELLE YAZILMAZ: gerçek hesap makinenin
      // timezone'una bağlıdır ve bir test bunu varsayamaz. Bunun yerine
      // controller'ın ÜRETTİĞİ vakitler okunur ve ekranın tam olarak o
      // vakitlerden çıkan karşılamayı gösterdiği doğrulanır — yani ekranın
      // yerel-saat yedeğini değil, gerçek vakitleri izlediği kanıtlanır.
      final nowLocal = DateTime(2026, 7, 11, 9, 30);
      await pumpToday(
        tester,
        now: nowLocal,
        location: grantedLocationOverride(),
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(TodayScreen)),
      );
      final state = container.read(prayerTimesControllerProvider).value;
      expect(
        state,
        isA<PrayerTimesReady>(),
        reason: 'izin verilmişken vakitler hesaplanmalı',
      );

      final real = (state! as PrayerTimesReady).times;
      final expected = TodayGreetingResolver.fromPrayerTimes(
        times: real,
        nowUtc: nowLocal.toUtc(),
      );
      const tr = AppLocalizations(SupportedLocale.tr);
      expect(find.text(tr.greetingFor(expected)), findsOneWidget);

      // Yedek yol farklı bir dilim verirdi; ekranın onu DEĞİL vakitleri
      // izlediğini bu ayrım gösterir.
      final fallback = TodayGreetingResolver.fromLocalTime(nowLocal);
      if (fallback != expected) {
        expect(find.text(tr.greetingFor(fallback)), findsNothing);
      }

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('vakit yokken yedek çalışır ve TEKNİK dil göstermez', (
      tester,
    ) async {
      // fakeLocationOverride → izin yok → vakit yok → yerel 23:30 = gece.
      await pumpToday(tester, now: DateTime(2026, 7, 11, 23, 30));

      expect(find.text('Hayırlı geceler'), findsOneWidget);

      // Karşılama, yedek yoldayken bile DAİMA beş onaylı ifadeden biridir:
      // "yükleniyor", "konum bulunamadı", "varsayılan" gibi teknik bir dil
      // karşılama olarak GÖRÜNEMEZ. Ekranın başka yerlerindeki meşru konum
      // daveti bu iddianın konusu değildir — sınanan, karşılamanın kendisidir.
      const tr = AppLocalizations(SupportedLocale.tr);
      final approved = {
        for (final p in TodayGreetingPeriod.values) tr.greetingFor(p),
      };
      final rendered = tester
          .widget<AppText>(find.widgetWithText(AppText, 'Hayırlı geceler'))
          .text;
      expect(approved, contains(rendered));

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('İngilizce ve Arapça karşılama ekranda çizilir', (
      tester,
    ) async {
      await pumpToday(tester, locale: SupportedLocale.en);
      expect(find.text('Good morning'), findsOneWidget);
      await unmountAndFlushDriftTimers(tester);

      await pumpToday(tester, locale: SupportedLocale.ar);
      expect(find.text('صباح الخير'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(TodayBrandHeader))),
        TextDirection.rtl,
      );

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('RTL: profil eylemi başlığın SON kenarına aynalanır', (
      tester,
    ) async {
      await pumpToday(tester, locale: SupportedLocale.ar);

      final headerCentre = tester.getCenter(find.byType(TodayBrandHeader)).dx;
      final actionCentre = tester
          .getCenter(
            find.ancestor(
              of: find.byIcon(Icons.person_outline),
              matching: find.byType(IconButton),
            ),
          )
          .dx;
      // RTL'de "son" kenar SOLDADIR — sabit bir kenara çivilenmediğinin kanıtı.
      expect(actionCentre, lessThan(headerCentre));

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('LTR: profil eylemi başlığın SON kenarındadır (sağ)', (
      tester,
    ) async {
      await pumpToday(tester);

      final headerCentre = tester.getCenter(find.byType(TodayBrandHeader)).dx;
      final actionCentre = tester
          .getCenter(
            find.ancestor(
              of: find.byIcon(Icons.person_outline),
              matching: find.byType(IconButton),
            ),
          )
          .dx;
      expect(actionCentre, greaterThan(headerCentre));

      await unmountAndFlushDriftTimers(tester);
    });

    for (final locale in SupportedLocale.values) {
      for (final scale in const [1.0, 1.5]) {
        testWidgets('${locale.name} @${scale}x: 320px başlıkta taşma yok', (
          tester,
        ) async {
          await pumpToday(
            tester,
            locale: locale,
            size: const Size(320, 2400),
            textScale: scale,
          );

          expect(tester.takeException(), isNull);

          await unmountAndFlushDriftTimers(tester);
        });
      }
    }
  });

  // ---------------------------------------------------------------
  // 5. Profil rotası (tam kabuk)
  // ---------------------------------------------------------------

  group('profil erişimi', () {
    late AppDatabase db;

    setUp(() => db = createTestDatabase());
    tearDown(() async => db.close());

    testWidgets('başlıktaki profil eylemi mevcut Profil rotasını açar', (
      tester,
    ) async {
      tester.platformDispatcher.localeTestValue = const Locale('tr', 'TR');
      tester.platformDispatcher.localesTestValue = const [Locale('tr', 'TR')];
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      tester.view.physicalSize = const Size(1080, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpFullApp(tester, db: db);

      expect(find.byType(TodayScreen), findsOneWidget);
      // Alt navigasyonda etiket 'Günüm' olarak görünür.
      expect(find.text('Günüm'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(TodayBrandHeader),
          matching: find.byIcon(Icons.person_outline),
        ),
      );
      // ProfileScreen açılışta plan özetini okurken animasyonlu bir gösterge
      // çizer; `pumpAndSettle` bu yüzden YERLEŞMEZ. Geçişi sınırlı pump ile
      // doğrularız (aynı yaklaşım `today_spiritual_uplift_test`te de var).
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(AppRoutes.profile, '/profile');

      await unmountAndFlushDriftTimers(tester);
    });
  });
}

/// GERÇEK `BismillahApp` (router + alt navigasyon kabuğu) ile pump eder —
/// profil rotasının gerçekten açıldığı ancak tam kabukta kanıtlanabilir.
/// Ayrı bir router kopyası KURULMAZ.
Future<void> pumpFullApp(WidgetTester tester, {required AppDatabase db}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(
          FixedClock(DateTime(2026, 7, 11, 9, 30)),
        ),
        fakeLocationOverride(),
        ...fakeReminderOverrides(),
        ...testSessionOverrides(),
      ],
      child: const BismillahApp(),
    ),
  );
  await tester.pumpAndSettle();
}
