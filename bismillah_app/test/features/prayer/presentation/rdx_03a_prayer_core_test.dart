import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/storage/database_providers.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/prayer/presentation/prayer_screen.dart';
import 'package:bismillah_app/features/prayer/presentation/widgets/prayer_entry_tile.dart';
import 'package:bismillah_app/features/prayer_times/data/prayer_times_providers.dart';
import 'package:bismillah_app/features/prayer_times/domain/daily_prayer_times.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_coordinates.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_time_calculation_method.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_time_calculator.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
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

/// RDX-03A — Namaz ekranı premium çekirdek yerleşimi.
///
/// Kapsam SUNUMDUR: vakit hesabı, konum edinimi, tamamlama kalıcılığı,
/// bildirim zamanlaması ve kesin-alarm akışı BU GÖREVDE DEĞİŞMEDİ ve burada
/// yeniden test edilmez — onların mevcut testleri yerinde durur.
///
/// Zaman ve vakitler DAİMA enjekte edilir: saat `FixedClock` ile UTC olarak
/// sabitlenir ve hesaplayıcı sahte bir sabit sonuçla değiştirilir. Böylece
/// "sıradaki vakit" makinenin saat dilimine göre değişmez. Ekranda görünen
/// saatler yine `.toLocal()` ile biçimlendiği için beklenen metinler testte
/// de aynı dönüşümle üretilir — sabit bir "10:15" YAZILMAZ.
void main() {
  // Saat UTC olarak sabitlenir: `FixedClock.nowUtc()` bu değeri aynen
  // döndürür, `nowLocal()` ise yalnız gün anahtarı için kullanılır.
  final fixedNowUtc = DateTime.utc(2026, 7, 15, 9);

  // Sabit vakitler (UTC). 09:00'da sıradaki vakit Öğle'dir (10:15) ve
  // İmsak/Güneş geride kalmıştır — blok "gerçekten sıradaki" olanı seçer.
  final fixedTimes = DailyPrayerTimes(
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

  /// Ekranın kullandığı biçimin testteki karşılığı — makine saat diliminden
  /// bağımsız kalması için aynı `.toLocal()` dönüşümü uygulanır.
  String hhmm(DateTime utc) {
    final local = utc.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() async => db.close());

  Future<void> pump(
    WidgetTester tester, {
    SupportedLocale locale = SupportedLocale.tr,
    bool granted = true,
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
          clockProvider.overrideWithValue(FixedClock(fixedNowUtc)),
          prayerTimeCalculatorProvider.overrideWithValue(
            _FixedPrayerTimeCalculator(fixedTimes),
          ),
          granted ? grantedLocationOverride() : fakeLocationOverride(),
          ...fakeReminderOverrides(),
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

  /// Sıradaki-namaz bloğu: ekrandaki tek `sand` yüzeyli karttır.
  Finder nextPrayerBlock() => find.byWidgetPredicate(
    (w) => w is AppCard && w.variant == AppCardVariant.sand,
  );

  /// Beş vakti taşıyan tek yüzey — satırların ORTAK en yakın kart atası.
  Finder dailyPrayersCard(WidgetTester tester) => find.ancestor(
    of: find.byType(PrayerEntryTile).first,
    matching: find.byType(AppCard),
  );

  // -------------------------------------------------------------------
  // 1. Sıradaki namaz hiyerarşisi
  // -------------------------------------------------------------------

  group('sıradaki namaz', () {
    testWidgets('gerçekten sıradaki vakti ve saatini gösterir', (tester) async {
      await pump(tester);

      const l10n = AppLocalizations(SupportedLocale.tr);
      final block = nextPrayerBlock();
      expect(block, findsOneWidget);

      // Blok başlığı + sıradaki vaktin ADI ve SAATİ bloğun içindedir.
      expect(
        find.descendant(
          of: block,
          matching: find.text(l10n.todayNextPrayerTitle),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: block, matching: find.text(l10n.prayerNameDhuhr)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: block, matching: find.text(hhmm(fixedTimes.dhuhr))),
        findsOneWidget,
      );

      // Geçmiş vakit (İmsak) sıradaki olarak SEÇİLMEZ; Güneş namaz
      // olmadığı için hiçbir zaman seçilmez.
      expect(
        find.descendant(of: block, matching: find.text(l10n.prayerNameFajr)),
        findsNothing,
      );

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('ekrandaki en güçlü tipografi bloğun saatidir', (tester) async {
      await pump(tester);

      // `stat` (28) token'ı ekranda YALNIZ bir kez kullanılır ve o da
      // sıradaki vaktin saatidir. Beş vakit listesi bilinçli olarak bir
      // kademe altta (`h3`) kalır — hiyerarşi iddiası budur.
      final stats = find.byWidgetPredicate(
        (w) => w is AppText && w.token == AppTextStyleToken.stat,
      );
      expect(stats, findsOneWidget);
      expect(
        find.descendant(of: nextPrayerBlock(), matching: stats),
        findsOneWidget,
      );
      expect(tester.widget<AppText>(stats).text, hhmm(fixedTimes.dhuhr));

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('sahte geri sayım YOKTUR — hiçbir metin saniye taşımaz', (
      tester,
    ) async {
      await pump(tester);

      // "HH:mm:ss" biçimi veya kalan-süre sayacı ekranda bulunmaz.
      final withSeconds = RegExp(r'\d{1,2}:\d{2}:\d{2}');
      expect(
        find.byWidgetPredicate(
          (w) => w is Text && w.data != null && withSeconds.hasMatch(w.data!),
        ),
        findsNothing,
      );

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('konum reddedildiğinde davet metni ve eylemi KORUNUR', (
      tester,
    ) async {
      await pump(tester, granted: false);

      const l10n = AppLocalizations(SupportedLocale.tr);
      expect(find.text(l10n.prayerTimesLocationInvite), findsOneWidget);
      expect(find.text(l10n.prayerTimesUseLocation), findsOneWidget);
      // Vakit yokken beş satır yine işaretlenebilir (kayıt konumdan
      // BAĞIMSIZDIR) ve saat gösterilmez.
      expect(find.byType(PrayerEntryTile), findsNWidgets(5));
      expect(find.text(l10n.prayerMark), findsNWidgets(5));

      await unmountAndFlushDriftTimers(tester);
    });
  });

  // -------------------------------------------------------------------
  // 2. Beş vakit tek yüzeyde
  // -------------------------------------------------------------------

  group('günün beş vakti', () {
    testWidgets('beş satır TEK kartın içinde yaşar', (tester) async {
      await pump(tester);

      expect(find.byType(PrayerEntryTile), findsNWidgets(5));

      // Her satırın en yakın kart atası AYNI Element olmalıdır: beş ayrı
      // kart yığını değil, tek bir yüzey.
      final surfaces = <Element>{};
      for (var i = 0; i < 5; i++) {
        surfaces.add(
          tester.element(
            find
                .ancestor(
                  of: find.byType(PrayerEntryTile).at(i),
                  matching: find.byType(AppCard),
                )
                .first,
          ),
        );
      }
      expect(surfaces, hasLength(1));

      // Satırlar saç teli ayraçlarla bölünür: beş satır → dört ayraç.
      expect(
        find.descendant(
          of: dailyPrayersCard(tester),
          matching: find.byType(Divider),
        ),
        findsNWidgets(4),
      );

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('her satır adını ve saatini gösterir, sıra korunur', (
      tester,
    ) async {
      await pump(tester);

      const l10n = AppLocalizations(SupportedLocale.tr);
      final expected = <(String, DateTime)>[
        (l10n.prayerNameFajr, fixedTimes.fajr),
        (l10n.prayerNameDhuhr, fixedTimes.dhuhr),
        (l10n.prayerNameAsr, fixedTimes.asr),
        (l10n.prayerNameMaghrib, fixedTimes.maghrib),
        (l10n.prayerNameIsha, fixedTimes.isha),
      ];

      for (var i = 0; i < expected.length; i++) {
        final row = find.byType(PrayerEntryTile).at(i);
        final (name, instant) = expected[i];
        expect(
          find.descendant(of: row, matching: find.text(name)),
          findsOneWidget,
          reason: '$i. satır $name olmalı (kronolojik sıra korunur)',
        );
        expect(
          find.descendant(of: row, matching: find.text(hhmm(instant))),
          findsOneWidget,
        );
      }

      // Güneş bir NAMAZ VAKTİ DEĞİLDİR: listeye satır olarak girmez.
      expect(find.byType(PrayerEntryTile), findsNWidgets(5));

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('her satır en az 48dp dokunma hedefi taşır', (tester) async {
      await pump(tester);

      for (var i = 0; i < 5; i++) {
        expect(
          tester.getSize(find.byType(PrayerEntryTile).at(i)).height,
          greaterThanOrEqualTo(AppSizes.touchTarget),
        );
      }

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets(
      'ham ISO tarih gösterilmez, yerelleştirilmiş tarih gösterilir',
      (tester) async {
        await pump(tester);

        expect(find.text('2026-07-15'), findsNothing);
        final localized = MaterialLocalizations.of(
          tester.element(find.byType(PrayerEntryTile).first),
        ).formatMediumDate(DateTime(2026, 7, 15));
        expect(find.text(localized), findsOneWidget);

        await unmountAndFlushDriftTimers(tester);
      },
    );
  });

  // -------------------------------------------------------------------
  // 3. Tamamlama durumları
  // -------------------------------------------------------------------

  group('tamamlama', () {
    testWidgets('satıra dokunmak işaretler, tekrar dokunmak geri alır', (
      tester,
    ) async {
      await pump(tester);

      const l10n = AppLocalizations(SupportedLocale.tr);
      final firstRow = find.byType(PrayerEntryTile).first;

      expect(find.text(l10n.prayerMark), findsNWidgets(5));
      expect(find.text(l10n.prayerCompleted), findsNothing);

      await tester.tap(firstRow);
      await tester.pumpAndSettle();

      // Tamamlanan satır durumunu SÖYLER ve geri alma eylemini görünür
      // tutar — eylem kaybolmaz.
      expect(
        find.descendant(
          of: firstRow,
          matching: find.text(l10n.prayerCompleted),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: firstRow, matching: find.text(l10n.prayerUndo)),
        findsOneWidget,
      );
      expect(find.text(l10n.prayerMark), findsNWidgets(4));
      expect(
        find.descendant(
          of: firstRow,
          matching: find.byIcon(Icons.check_circle),
        ),
        findsOneWidget,
      );

      await tester.tap(firstRow);
      await tester.pumpAndSettle();

      expect(find.text(l10n.prayerCompleted), findsNothing);
      expect(find.text(l10n.prayerMark), findsNWidgets(5));

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('tamamlama sakin kalır: kutlama, seri, puan ve uyarı YOKTUR', (
      tester,
    ) async {
      await pump(tester);

      await tester.tap(find.byType(PrayerEntryTile).first);
      await tester.pumpAndSettle();

      // Ödül/uyarı ikonografisi hiçbir durumda ekrana girmez.
      for (final icon in const [
        Icons.emoji_events,
        Icons.local_fire_department,
        Icons.star,
        Icons.warning_amber_rounded,
        Icons.error_outline,
        Icons.lock,
      ]) {
        expect(find.byIcon(icon), findsNothing, reason: '$icon ekranda olamaz');
      }

      // Hata rengi tamamlanmamış vakti işaretlemek için KULLANILMAZ.
      final errorColor = Theme.of(
        tester.element(find.byType(PrayerEntryTile).first),
      ).colorScheme.error;
      final coloredTexts = tester
          .widgetList<Text>(find.byType(Text))
          .where((t) => t.style?.color == errorColor);
      expect(coloredTexts, isEmpty);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('satır semantiği durumu ve eylemi birlikte duyurur', (
      tester,
    ) async {
      await pump(tester);

      const l10n = AppLocalizations(SupportedLocale.tr);
      final handle = tester.ensureSemantics();

      expect(
        find.bySemanticsLabel(
          RegExp('${l10n.prayerNameFajr}.*${l10n.prayerMark}'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byType(PrayerEntryTile).first);
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(
          RegExp(
            '${l10n.prayerNameFajr}.*${l10n.prayerCompleted}.*'
            '${l10n.prayerUndo}',
          ),
        ),
        findsOneWidget,
      );

      handle.dispose();
      await unmountAndFlushDriftTimers(tester);
    });
  });

  // -------------------------------------------------------------------
  // 4. İkincil erişim
  // -------------------------------------------------------------------

  group('ikincil girişler', () {
    testWidgets('Kıble, hesaplama yöntemi ve geçmiş erişilebilir kalır', (
      tester,
    ) async {
      await pump(tester);

      const l10n = AppLocalizations(SupportedLocale.tr);
      for (final title in [
        l10n.qiblaEntryTitle,
        l10n.prayerMethodEntryTitle,
        l10n.prayerHistoryTitle,
      ]) {
        expect(find.text(title), findsOneWidget, reason: '$title kayboldu');
        final card = tester.widget<AppCard>(
          find
              .ancestor(of: find.text(title), matching: find.byType(AppCard))
              .first,
        );
        expect(card.onTap, isNotNull, reason: '$title dokunulabilir olmalı');
        expect(
          tester.getSize(find.text(title)).height,
          greaterThan(0),
          reason: '$title görünür olmalı',
        );
      }

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('ikincil girişler sıradaki namaz yüzeyiyle YARIŞMAZ', (
      tester,
    ) async {
      await pump(tester);

      const l10n = AppLocalizations(SupportedLocale.tr);
      // Sıcak kum yüzeyi ekranda yalnız sıradaki namaz bloğuna aittir;
      // ikincil girişler gölgesiz/ince kenarlıklı `outlined` yüzeydedir.
      expect(nextPrayerBlock(), findsOneWidget);
      for (final title in [
        l10n.qiblaEntryTitle,
        l10n.prayerMethodEntryTitle,
        l10n.prayerHistoryTitle,
      ]) {
        final card = tester.widget<AppCard>(
          find
              .ancestor(of: find.text(title), matching: find.byType(AppCard))
              .first,
        );
        expect(card.variant, AppCardVariant.outlined);
      }

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('yöntem adı vakitleri ÜRETEN sonuçtan okunur', (tester) async {
      await pump(tester);

      const l10n = AppLocalizations(SupportedLocale.tr);
      // TASK 096 dürüstlük kuralı: ekranda görünen yöntem adı, gösterilen
      // vakitleri gerçekten üreten `times.method` değeridir.
      expect(
        find.text(l10n.prayerMethodName(fixedTimes.method.stableName)),
        findsOneWidget,
      );

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('hatırlatıcı kartı ve açma eylemi korunur', (tester) async {
      await pump(tester);

      const l10n = AppLocalizations(SupportedLocale.tr);
      expect(find.text(l10n.reminderCardTitle), findsOneWidget);
      expect(find.text(l10n.reminderEnable), findsOneWidget);

      await unmountAndFlushDriftTimers(tester);
    });
  });

  // -------------------------------------------------------------------
  // 5. TR / EN / AR ve RTL
  // -------------------------------------------------------------------

  group('yerelleştirme ve RTL', () {
    for (final locale in SupportedLocale.values) {
      testWidgets('${locale.name}: ekran kimliği ve çekirdek metinler gelir', (
        tester,
      ) async {
        await pump(tester, locale: locale);

        final l10n = AppLocalizations(locale);
        expect(find.text(l10n.tabPrayer), findsOneWidget);
        expect(find.text(l10n.todayNextPrayerTitle), findsOneWidget);
        expect(find.text(l10n.prayerNameDhuhr), findsWidgets);
        expect(find.text(l10n.qiblaEntryTitle), findsOneWidget);
        expect(find.text(l10n.prayerHistoryTitle), findsOneWidget);
        // Çözülemeyen anahtar ekrana sızmaz.
        expect(find.textContaining('prayerName'), findsNothing);

        await unmountAndFlushDriftTimers(tester);
      });
    }

    testWidgets('Arapça ekran RTL çözer, Türkçe LTR kalır', (tester) async {
      await pump(tester, locale: SupportedLocale.ar);
      expect(
        Directionality.of(tester.element(find.byType(PrayerEntryTile).first)),
        TextDirection.rtl,
      );
      // Yön duyarlı chevron aynalanır: RTL'de sola bakar.
      expect(find.byIcon(Icons.chevron_left), findsWidgets);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
      await unmountAndFlushDriftTimers(tester);

      await pump(tester, locale: SupportedLocale.tr);
      expect(
        Directionality.of(tester.element(find.byType(PrayerEntryTile).first)),
        TextDirection.ltr,
      );
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
      expect(find.byIcon(Icons.chevron_left), findsNothing);
      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('RTL yerleşimde saat satırın SONUNDA (solda) durur', (
      tester,
    ) async {
      await pump(tester, locale: SupportedLocale.ar);

      const l10n = AppLocalizations(SupportedLocale.ar);
      final row = find.byType(PrayerEntryTile).first;
      final nameX = tester
          .getCenter(
            find.descendant(of: row, matching: find.text(l10n.prayerNameFajr)),
          )
          .dx;
      final timeX = tester
          .getCenter(
            find.descendant(
              of: row,
              matching: find.text(hhmm(fixedTimes.fajr)),
            ),
          )
          .dx;
      // Mantıksal hizalama: RTL'de "son" soldadır — sabit bir kenara
      // çivilenmiş olsaydı bu iddia LTR ile aynı çıkardı.
      expect(timeX, lessThan(nameX));

      await unmountAndFlushDriftTimers(tester);
    });
  });

  // -------------------------------------------------------------------
  // 6. Dar ekran + büyük metin
  // -------------------------------------------------------------------

  group('erişilebilirlik', () {
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

        // Liste tembel kurulur: alt bloklar da gerçekten build edilsin
        // diye sona kadar kaydırılır ve her adımda taşma kontrol edilir.
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

    testWidgets('320dp + 1.5x metinde dokunma hedefleri korunur', (
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

/// Sabit sonuç döndüren hesaplayıcı — gerçek astronomik hesabı test
/// dışında bırakır (o hesabın kendi testleri vardır) ve "sıradaki vakit"
/// seçimini makinenin saat diliminden BAĞIMSIZ kılar.
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
