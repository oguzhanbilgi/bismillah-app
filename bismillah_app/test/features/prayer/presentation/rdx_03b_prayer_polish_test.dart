import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/storage/database_providers.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:bismillah_app/features/prayer/presentation/prayer_screen.dart';
import 'package:bismillah_app/features/prayer/presentation/widgets/prayer_entry_tile.dart';
import 'package:bismillah_app/features/prayer_reminders/data/prayer_reminders_providers.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/local_notification_service.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/notification_permission_status.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/prayer_reminder.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/reminder_preference_store.dart';
import 'package:bismillah_app/features/prayer_times/data/prayer_times_providers.dart';
import 'package:bismillah_app/features/prayer_times/domain/daily_prayer_times.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_coordinates.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_time_calculation_method.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_time_calculator.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
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

/// RDX-03B — Namaz ekranı cilası ve kullanıcıya görünen sistem dili.
///
/// Kapsam yine SUNUMDUR. Vakit hesabı, konum edinimi, tamamlama kalıcılığı,
/// bildirim zamanlaması ve kesin-alarm mantığı DEĞİŞMEDİ; bu dosya yalnız
/// RDX-03B'nin eklediği/değiştirdiği görünür davranışı doğrular.
void main() {
  // Sabit vakitler (UTC) — RDX-03A ile aynı çerçeve.
  final times = DailyPrayerTimes(
    dayKey: '2026-07-15',
    fajr: DateTime.utc(2026, 7, 15, 3, 40),
    sunrise: DateTime.utc(2026, 7, 15, 5, 35),
    dhuhr: DateTime.utc(2026, 7, 15, 10, 15),
    asr: DateTime.utc(2026, 7, 15, 14, 10),
    maghrib: DateTime.utc(2026, 7, 15, 17, 45),
    isha: DateTime.utc(2026, 7, 15, 19, 30),
    method: PrayerTimeCalculationMethod.turkiyeDiyanet,
    asrMethod: AsrCalculationMethod.standard,
  );

  /// 09:00 UTC — İmsak ve Güneş geçti, sıradaki vakit Öğle.
  final beforeDhuhr = DateTime.utc(2026, 7, 15, 9);

  /// 21:00 UTC — beş vakit de geçti.
  final afterIsha = DateTime.utc(2026, 7, 15, 21);

  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() async => db.close());

  Future<void> pump(
    WidgetTester tester, {
    SupportedLocale locale = SupportedLocale.tr,
    DateTime? nowUtc,
    bool granted = true,
    List<Override> reminderOverrides = const [],
    Size size = const Size(1080, 2600),
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(FixedClock(nowUtc ?? beforeDhuhr)),
          prayerTimeCalculatorProvider.overrideWithValue(
            _FixedPrayerTimeCalculator(times),
          ),
          granted ? grantedLocationOverride() : fakeLocationOverride(),
          ...(reminderOverrides.isEmpty
              ? fakeReminderOverrides()
              : reminderOverrides),
          ...testSessionOverrides(),
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
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const PrayerScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Satırın gerçekten çizilen zemin rengi — bayrağa değil, sonuca bakar.
  Color? rowSurface(WidgetTester tester, int index) {
    final material = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(PrayerEntryTile).at(index),
            matching: find.byType(Material),
          )
          .first,
    );
    return material.color;
  }

  // -------------------------------------------------------------------
  // A. Sıradaki vakit satırı ipucu
  // -------------------------------------------------------------------

  group('sıradaki vakit satırı', () {
    testWidgets('ipucu YALNIZ gerçekten sıradaki vakte düşer', (tester) async {
      await pump(tester);

      final tiles = tester
          .widgetList<PrayerEntryTile>(find.byType(PrayerEntryTile))
          .toList();
      expect(tiles, hasLength(5));

      // 09:00 UTC → Öğle. `PrayerName.values` kronolojik olduğundan index 1.
      final flagged = <int>[
        for (var i = 0; i < tiles.length; i++)
          if (tiles[i].isNext) i,
      ];
      expect(flagged, [PrayerName.values.indexOf(PrayerName.dhuhr)]);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('ipucu bayrak değil, gerçek bir tonal zemin olarak çizilir', (
      tester,
    ) async {
      await pump(tester);

      final ext = AppThemeExtension.of(
        tester.element(find.byType(PrayerEntryTile).first),
      );
      final nextIndex = PrayerName.values.indexOf(PrayerName.dhuhr);

      expect(rowSurface(tester, nextIndex), ext.surfaceAlt);
      for (var i = 0; i < 5; i++) {
        if (i == nextIndex) {
          continue;
        }
        expect(
          rowSurface(tester, i),
          Colors.transparent,
          reason: '$i. satır ipucu almamalı',
        );
      }

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('ipucu ALTIN veya uyarı rengi DEĞİLDİR', (tester) async {
      await pump(tester);

      final element = tester.element(find.byType(PrayerEntryTile).first);
      final ext = AppThemeExtension.of(element);
      final scheme = Theme.of(element).colorScheme;
      final surface = rowSurface(
        tester,
        PrayerName.values.indexOf(PrayerName.dhuhr),
      );

      expect(surface, isNot(ext.accentGold));
      expect(surface, isNot(ext.warning));
      expect(surface, isNot(scheme.error));
      expect(surface, isNot(scheme.primary));

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('beş vakit de geçtiyse HİÇBİR satır işaretlenmez', (
      tester,
    ) async {
      await pump(tester, nowUtc: afterIsha);

      final tiles = tester.widgetList<PrayerEntryTile>(
        find.byType(PrayerEntryTile),
      );
      expect(tiles.where((t) => t.isNext), isEmpty);
      for (var i = 0; i < 5; i++) {
        expect(rowSurface(tester, i), Colors.transparent);
      }
      // Hero de uydurma bir vakit göstermez, sakin bitiş cümlesini gösterir.
      const l10n = AppLocalizations(SupportedLocale.tr);
      expect(find.text(l10n.todayNextPrayerAllDone), findsOneWidget);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('konum yokken de uydurma bir sıradaki vakit üretilmez', (
      tester,
    ) async {
      await pump(tester, granted: false);

      final tiles = tester.widgetList<PrayerEntryTile>(
        find.byType(PrayerEntryTile),
      );
      expect(tiles.where((t) => t.isNext), isEmpty);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('ipucu ekran okuyucuya da bildirilir', (tester) async {
      await pump(tester);

      const l10n = AppLocalizations(SupportedLocale.tr);
      final handle = tester.ensureSemantics();

      // Renk görülmese bile "sıradaki" bilgisi kaybolmaz.
      expect(
        find.bySemanticsLabel(
          RegExp('${l10n.prayerNameDhuhr}.*${l10n.todayNextPrayerTitle}'),
        ),
        findsOneWidget,
      );
      // İpucu almayan satır bu etiketi TAŞIMAZ.
      expect(
        find.bySemanticsLabel(
          RegExp('${l10n.prayerNameAsr}.*${l10n.todayNextPrayerTitle}'),
        ),
        findsNothing,
      );

      handle.dispose();
      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('tamamlanma geri bildirimi ipucundan daha baskın kalır', (
      tester,
    ) async {
      await pump(tester);

      const l10n = AppLocalizations(SupportedLocale.tr);
      final nextIndex = PrayerName.values.indexOf(PrayerName.dhuhr);
      final nextRow = find.byType(PrayerEntryTile).at(nextIndex);

      // İpuçlu satır işaretlenince onay ikonu ve durum metni gelir; ipucu
      // bunları GİZLEMEZ ve satır yerini/sırasını değiştirmez.
      await tester.tap(nextRow);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(PrayerEntryTile).at(nextIndex),
          matching: find.byIcon(Icons.check_circle),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(PrayerEntryTile).at(nextIndex),
          matching: find.text(l10n.prayerCompleted),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(PrayerEntryTile).at(nextIndex),
          matching: find.text(l10n.prayerNameDhuhr),
        ),
        findsOneWidget,
      );

      // Geri alma da çalışmaya devam eder.
      await tester.tap(find.byType(PrayerEntryTile).at(nextIndex));
      await tester.pumpAndSettle();
      expect(find.text(l10n.prayerCompleted), findsNothing);
      expect(find.text(l10n.prayerMark), findsNWidgets(5));

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('sahte geri sayım / canlı rozet YOKTUR', (tester) async {
      await pump(tester);

      final withSeconds = RegExp(r'\d{1,2}:\d{2}:\d{2}');
      expect(
        find.byWidgetPredicate(
          (w) => w is Text && w.data != null && withSeconds.hasMatch(w.data!),
        ),
        findsNothing,
      );
      for (final word in ['LIVE', 'CANLI', 'ŞİMDİ', 'NOW']) {
        expect(find.text(word), findsNothing);
      }

      await unmountAndFlushDriftTimers(tester);
    });
  });

  // -------------------------------------------------------------------
  // B. Üst kompozisyon
  // -------------------------------------------------------------------

  group('üst kompozisyon', () {
    testWidgets('art arda üç başlık benzeri satır kalmaz', (tester) async {
      await pump(tester);

      const l10n = AppLocalizations(SupportedLocale.tr);
      // Ekran kimliği AppBar'da KORUNUR.
      expect(find.text(l10n.tabPrayer), findsOneWidget);
      // Fazlalık bölüm başlığı kaldırıldı (AppBar zaten "Namaz" diyor).
      expect(find.text(l10n.prayerTodaySubtitle), findsNothing);
      // Buna karşılık destek cümlesi ve yerelleştirilmiş tarih KORUNUR.
      expect(find.text(l10n.prayerGentleLine), findsOneWidget);
      expect(find.text('2026-07-15'), findsNothing);
      final localized = MaterialLocalizations.of(
        tester.element(find.byType(PrayerEntryTile).first),
      ).formatMediumDate(DateTime(2026, 7, 15));
      expect(find.text(localized), findsOneWidget);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('marka başlığı Namaz ekranına SIZMAZ', (tester) async {
      await pump(tester);

      // Marka adı Günüm sekmesine aittir; burada tekrar edilmez.
      expect(find.text('Bismillah'), findsNothing);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('başlık bloğu ile vakit adları aynı hizada başlar', (
      tester,
    ) async {
      await pump(tester);

      final localized = MaterialLocalizations.of(
        tester.element(find.byType(PrayerEntryTile).first),
      ).formatMediumDate(DateTime(2026, 7, 15));
      const l10n = AppLocalizations(SupportedLocale.tr);

      final dateLeft = tester.getTopLeft(find.text(localized)).dx;
      final nameLeft = tester.getTopLeft(find.text(l10n.prayerNameFajr)).dx;
      expect((dateLeft - nameLeft).abs(), lessThan(1));

      await unmountAndFlushDriftTimers(tester);
    });
  });

  // -------------------------------------------------------------------
  // C. İkincil girişler
  // -------------------------------------------------------------------

  group('ikincil girişler', () {
    testWidgets('üçü aynı dilbilgisini paylaşır ve erişilebilir kalır', (
      tester,
    ) async {
      await pump(tester);

      const l10n = AppLocalizations(SupportedLocale.tr);
      for (final title in [
        l10n.qiblaEntryTitle,
        l10n.prayerMethodEntryTitle,
        l10n.prayerHistoryTitle,
      ]) {
        final cardFinder = find
            .ancestor(of: find.text(title), matching: find.byType(AppCard))
            .first;
        final card = tester.widget<AppCard>(cardFinder);
        expect(card.onTap, isNotNull, reason: '$title dokunulabilir olmalı');
        expect(card.variant, AppCardVariant.outlined);
        expect(
          tester.getSize(cardFinder).height,
          greaterThanOrEqualTo(AppSizes.touchTarget),
        );
      }
      // Yön duyarlı chevron her girişte vardır.
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(3));

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('hesaplama yöntemi ekranda TEK kez ve sonuçtan okunur', (
      tester,
    ) async {
      await pump(tester);

      const l10n = AppLocalizations(SupportedLocale.tr);
      final name = l10n.prayerMethodName(times.method.stableName);
      expect(find.text(name), findsOneWidget);
      expect(find.text(l10n.prayerMethodEntryTitle), findsOneWidget);

      await unmountAndFlushDriftTimers(tester);
    });
  });

  // -------------------------------------------------------------------
  // D. Hatırlatıcı / izin dili
  // -------------------------------------------------------------------

  group('hatırlatıcı ve izin dili', () {
    const keys = <String>[
      'reminderCardTitle',
      'reminderEnable',
      'reminderDisable',
      'reminderEnabledState',
      'reminderInexactNote',
      'reminderPermissionNeeded',
      'reminderLocationNeeded',
      'reminderExactTitle',
      'reminderExactBody',
      'reminderExactOpenSettings',
      'reminderExactNotNow',
      'reminderExactGranted',
      'reminderExactNotGranted',
      'reminderExactAction',
    ];

    String valueOf(AppLocalizations l10n, String key) => switch (key) {
      'reminderCardTitle' => l10n.reminderCardTitle,
      'reminderEnable' => l10n.reminderEnable,
      'reminderDisable' => l10n.reminderDisable,
      'reminderEnabledState' => l10n.reminderEnabledState,
      'reminderInexactNote' => l10n.reminderInexactNote,
      'reminderPermissionNeeded' => l10n.reminderPermissionNeeded,
      'reminderLocationNeeded' => l10n.reminderLocationNeeded,
      'reminderExactTitle' => l10n.reminderExactTitle,
      'reminderExactBody' => l10n.reminderExactBody,
      'reminderExactOpenSettings' => l10n.reminderExactOpenSettings,
      'reminderExactNotNow' => l10n.reminderExactNotNow,
      'reminderExactGranted' => l10n.reminderExactGranted,
      'reminderExactNotGranted' => l10n.reminderExactNotGranted,
      'reminderExactAction' => l10n.reminderExactAction,
      _ => throw ArgumentError(key),
    };

    test('her anahtar üç dilde de çözülür ve boş değildir', () {
      for (final locale in SupportedLocale.values) {
        final l10n = AppLocalizations(locale);
        for (final key in keys) {
          final value = valueOf(l10n, key);
          expect(value, isNotEmpty, reason: '${locale.name}/$key boş');
          // Çözülemeyen anahtar, `_t` yedeği yüzünden anahtar adı olarak
          // görünür — bu, sessiz bir çeviri kaybının tek işaretidir.
          expect(value, isNot(key), reason: '${locale.name}/$key çözülemedi');
        }
      }
    });

    test('platform/geliştirici terminolojisi kullanıcıya gösterilmez', () {
      // Kullanıcı "Android", "API", "exact alarm" gibi terimleri okumaz.
      const forbidden = <String>[
        'android',
        'api',
        'sdk',
        'exact alarm',
        'schedule exact',
        'setexact',
        'permission_handler',
        'intent',
      ];
      for (final locale in SupportedLocale.values) {
        final l10n = AppLocalizations(locale);
        for (final key in keys) {
          final value = valueOf(l10n, key).toLowerCase();
          for (final term in forbidden) {
            expect(
              value.contains(term),
              isFalse,
              reason: '${locale.name}/$key "$term" içeriyor',
            );
          }
        }
      }
    });

    test('Arapça değerler Arap harfi taşır ve Türkçe ile aynı değildir', () {
      const tr = AppLocalizations(SupportedLocale.tr);
      const ar = AppLocalizations(SupportedLocale.ar);
      final arabic = RegExp(r'[؀-ۿ]');
      for (final key in keys) {
        expect(arabic.hasMatch(valueOf(ar, key)), isTrue, reason: key);
        expect(valueOf(ar, key), isNot(valueOf(tr, key)), reason: key);
      }
    });

    test('sınırlama gizlenmez: hatırlatmalar garanti olarak sunulmaz', () {
      // Kesin-alarm açıklaması, izin verilmediğinde hatırlatmaların
      // ÇALIŞMAYA DEVAM ETTİĞİNİ ama kayabileceğini söylemeye devam eder.
      const tr = AppLocalizations(SupportedLocale.tr);
      expect(tr.reminderExactBody, contains('çalışmaya devam eder'));
      expect(tr.reminderExactBody, contains('kayabilir'));
      expect(tr.reminderExactNotGranted, contains('kayabilir'));
      // "Yaklaşık zaman" durumu ekranda hâlâ dürüstçe anlatılır.
      expect(tr.reminderInexactNote, contains('kayabilir'));

      const en = AppLocalizations(SupportedLocale.en);
      expect(en.reminderExactBody, contains('keep working'));
      expect(en.reminderExactNotGranted, contains('minutes off'));
    });

    testWidgets('kapalıyken açma eylemi korunur', (tester) async {
      await pump(tester);

      const l10n = AppLocalizations(SupportedLocale.tr);
      expect(find.text(l10n.reminderCardTitle), findsOneWidget);
      expect(find.text(l10n.reminderEnable), findsOneWidget);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('açık ama yaklaşık zamandayken not, eylem ve kapatma durur', (
      tester,
    ) async {
      await pump(
        tester,
        reminderOverrides: [
          localNotificationServiceProvider.overrideWithValue(
            _GrantedInexactNotifications(),
          ),
          reminderPreferenceStoreProvider.overrideWithValue(
            _EnabledPreferenceStore(),
          ),
        ],
      );

      const l10n = AppLocalizations(SupportedLocale.tr);
      expect(find.text(l10n.reminderEnabledState), findsOneWidget);
      // Dürüst sınırlama notu ekranda durur.
      expect(find.text(l10n.reminderInexactNote), findsOneWidget);
      // Düzeltme eylemi ve kapatma eylemi KORUNUR.
      expect(find.text(l10n.reminderExactAction), findsOneWidget);
      expect(find.text(l10n.reminderDisable), findsOneWidget);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('kesin-zamanlama diyaloğu açıklama + iki seçeneği korur', (
      tester,
    ) async {
      await pump(
        tester,
        reminderOverrides: [
          localNotificationServiceProvider.overrideWithValue(
            _GrantedInexactNotifications(),
          ),
          reminderPreferenceStoreProvider.overrideWithValue(
            _EnabledPreferenceStore(),
          ),
        ],
      );

      const l10n = AppLocalizations(SupportedLocale.tr);
      await tester.tap(find.text(l10n.reminderExactAction));
      await tester.pumpAndSettle();

      expect(find.text(l10n.reminderExactTitle), findsOneWidget);
      expect(find.text(l10n.reminderExactBody), findsOneWidget);
      expect(find.text(l10n.reminderExactOpenSettings), findsOneWidget);
      expect(find.text(l10n.reminderExactNotNow), findsOneWidget);

      // "Şimdi değil" hiçbir izin akışı başlatmaz.
      await tester.tap(find.text(l10n.reminderExactNotNow));
      await tester.pumpAndSettle();
      expect(find.text(l10n.reminderExactTitle), findsNothing);
      expect(find.text(l10n.reminderEnabledState), findsOneWidget);

      await unmountAndFlushDriftTimers(tester);
    });
  });

  // -------------------------------------------------------------------
  // E. Teknik alt bilgi
  // -------------------------------------------------------------------

  group('teknik alt bilgi', () {
    testWidgets('depolama notu ana Namaz yüzeyinde tekrar edilmez', (
      tester,
    ) async {
      await pump(tester);

      const l10n = AppLocalizations(SupportedLocale.tr);
      expect(find.text(l10n.prayerLocalNote), findsNothing);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('yerine başka bir alıntı/günün cümlesi KONULMAZ', (
      tester,
    ) async {
      await pump(tester);

      // Ekranın son içerik bloğu hatırlatıcı kartıdır; ondan sonra yalnız
      // boşluk gelir. Today'in günlük cümle deseni buraya taşınmaz.
      const l10n = AppLocalizations(SupportedLocale.tr);
      final reminderBottom = tester
          .getBottomLeft(
            find
                .ancestor(
                  of: find.text(l10n.reminderCardTitle),
                  matching: find.byType(AppCard),
                )
                .first,
          )
          .dy;
      final textsBelow = find.byWidgetPredicate((w) {
        if (w is! Text || w.data == null || w.data!.trim().isEmpty) {
          return false;
        }
        return true;
      });
      for (final element in tester.elementList(textsBelow)) {
        final box = element.renderObject;
        if (box is! RenderBox || !box.attached) {
          continue;
        }
        final top = box.localToGlobal(Offset.zero).dy;
        expect(
          top,
          lessThan(reminderBottom),
          reason:
              'hatırlatıcı kartından sonra metin kalmamalı: '
              '${(element.widget as Text).data}',
        );
      }

      await unmountAndFlushDriftTimers(tester);
    });
  });

  // -------------------------------------------------------------------
  // F. Erişilebilirlik ve yön
  // -------------------------------------------------------------------

  group('erişilebilirlik ve RTL', () {
    for (final locale in SupportedLocale.values) {
      testWidgets('${locale.name}: 320dp + 1.5x metinde taşma olmaz', (
        tester,
      ) async {
        await pump(
          tester,
          locale: locale,
          size: const Size(320, 1400),
          textScale: 1.5,
        );
        expect(tester.takeException(), isNull);

        for (var i = 0; i < 6; i++) {
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, -400),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '${locale.name}: $i. kaydırmada taşma',
          );
        }

        await unmountAndFlushDriftTimers(tester);
      });
    }

    testWidgets('yeni izin metinleri dar ekranda kırpılmadan sığar', (
      tester,
    ) async {
      await pump(
        tester,
        size: const Size(320, 1400),
        textScale: 1.5,
        reminderOverrides: [
          localNotificationServiceProvider.overrideWithValue(
            _GrantedInexactNotifications(),
          ),
          reminderPreferenceStoreProvider.overrideWithValue(
            _EnabledPreferenceStore(),
          ),
        ],
      );

      const l10n = AppLocalizations(SupportedLocale.tr);
      await tester.scrollUntilVisible(
        find.text(l10n.reminderInexactNote),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.takeException(), isNull);

      // Uzun açıklama satır sınırıyla KIRPILMAZ: sarmalanarak tam görünür.
      final note = tester.widget<Text>(find.text(l10n.reminderInexactNote));
      expect(note.overflow, isNot(TextOverflow.ellipsis));

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('Arapça RTL: ipucu ve chevron yön duyarlı kalır', (
      tester,
    ) async {
      await pump(tester, locale: SupportedLocale.ar);

      expect(
        Directionality.of(tester.element(find.byType(PrayerEntryTile).first)),
        TextDirection.rtl,
      );
      expect(find.byIcon(Icons.chevron_left), findsNWidgets(3));
      expect(find.byIcon(Icons.chevron_right), findsNothing);

      // İpucu yön değişiminden etkilenmez: yine yalnız Öğle satırındadır.
      final tiles = tester
          .widgetList<PrayerEntryTile>(find.byType(PrayerEntryTile))
          .toList();
      final flagged = <int>[
        for (var i = 0; i < tiles.length; i++)
          if (tiles[i].isNext) i,
      ];
      expect(flagged, [PrayerName.values.indexOf(PrayerName.dhuhr)]);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('dokunma hedefleri 320dp + 1.5x altında korunur', (
      tester,
    ) async {
      await pump(tester, size: const Size(320, 1400), textScale: 1.5);

      for (var i = 0; i < 5; i++) {
        expect(
          tester.getSize(find.byType(PrayerEntryTile).at(i)).height,
          greaterThanOrEqualTo(AppSizes.touchTarget),
        );
      }

      await unmountAndFlushDriftTimers(tester);
    });
  });
}

final class _FixedPrayerTimeCalculator implements PrayerTimeCalculator {
  const _FixedPrayerTimeCalculator(this._times);

  final DailyPrayerTimes _times;

  @override
  DailyPrayerTimes calculate({
    required PrayerCoordinates coordinates,
    required DateTime date,
    PrayerTimeCalculationMethod method =
        PrayerTimeCalculationMethod.defaultMethod,
    AsrCalculationMethod asrMethod = AsrCalculationMethod.standard,
  }) => _times;
}

/// Bildirim izni VERİLMİŞ ama kesin zamanlama erişimi OLMAYAN cihaz —
/// "açık ama yaklaşık zamanda" durumunu üretir. Hiçbir gerçek platform
/// çağrısı yapılmaz.
final class _GrantedInexactNotifications implements LocalNotificationService {
  @override
  Stream<String> get reminderTaps => const Stream.empty();

  @override
  Future<void> initialize() async {}

  @override
  Future<NotificationPermissionStatus> requestPermission() async =>
      NotificationPermissionStatus.granted;

  @override
  Future<NotificationPermissionStatus> checkPermission() async =>
      NotificationPermissionStatus.granted;

  @override
  Future<bool> canScheduleExact() async => false;

  @override
  Future<bool?> requestExactAlarmPermission() async => false;

  @override
  Future<void> schedule(PrayerReminder reminder, {required bool exact}) async {}

  @override
  Future<void> cancelAllPrayerReminders() async {}

  @override
  Future<void> openSettings() async {}
}

final class _EnabledPreferenceStore implements ReminderPreferenceStore {
  @override
  Future<bool> isEnabled() async => true;

  @override
  Future<void> setEnabled(bool enabled) async {}
}
