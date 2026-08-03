import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/today/application/daily_plan_state.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/value_objects/missed_day_recovery.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_recovery_note.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sakin dönüş notu (TASK 084).
///
/// Kaçırılan gün SAYISI gösterilmez; kırmızı/uyarı, seri kaybı, ceza,
/// puan ve manevi değerlendirme dili YASAKTIR.
void main() {
  final today = DayKey('2026-07-27');

  const tr = AppLocalizations(SupportedLocale.tr);
  const en = AppLocalizations(SupportedLocale.en);
  const ar = AppLocalizations(SupportedLocale.ar);

  DailyPlan plan({int completedCount = 0, int itemCount = 3}) => DailyPlan(
    dayKey: today,
    items: [
      for (var i = 0; i < itemCount; i++)
        PlanItem(
          itemId: EntityId('item-$i'),
          type: PlanItemType.prayer,
          status: i < completedCount
              ? PlanItemStatus.completed
              : PlanItemStatus.pending,
          completedAt: i < completedCount
              ? UtcDateTime(DateTime.utc(2026, 7, 27))
              : null,
        ),
    ],
    profileType: 'beginner',
    sizeMinutes: 10,
    weekIndex: 0,
    generatedBy: 'rule-engine-v1',
  );

  Future<void> pumpNote(
    WidgetTester tester,
    MissedDayRecovery recovery, {
    SupportedLocale locale = SupportedLocale.tr,
    Size size = const Size(1080, 1200),
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
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
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
            child: SingleChildScrollView(
              child: TodayRecoveryNote(recovery: recovery),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  String visibleText(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .join('\n');

  group('gösterim kuralı', () {
    final cases = <String, (int, DailyPlanState?, bool)>{
      'kaçırılmış gün yok': (0, null, false),
      'bir gün kaçırılmış, plan yüklenmemiş': (1, null, true),
      'üç gün kaçırılmış, plan yüklenmemiş': (3, null, true),
    };

    for (final entry in cases.entries) {
      test(entry.key, () {
        final (days, state, expected) = entry.value;
        expect(
          TodayRecoveryNote.shouldShow(
            MissedDayRecovery(consecutiveMissedDays: days),
            state,
          ),
          expected,
        );
      });
    }

    test('bugün henüz hiçbir görev işaretlenmemişse gösterilir', () {
      expect(
        TodayRecoveryNote.shouldShow(
          const MissedDayRecovery(consecutiveMissedDays: 2),
          DailyPlanAvailable(plan: plan()),
        ),
        isTrue,
      );
    });

    test('bugün bir görev işaretlenince DOĞAL olarak kaybolur', () {
      expect(
        TodayRecoveryNote.shouldShow(
          const MissedDayRecovery(consecutiveMissedDays: 2),
          DailyPlanAvailable(plan: plan(completedCount: 1)),
        ),
        isFalse,
      );
    });

    test('boş/bozuk/hatalı gün notu gizlemez', () {
      const recovery = MissedDayRecovery(consecutiveMissedDays: 2);
      for (final state in <DailyPlanState>[
        DailyPlanEmpty(dayKey: today),
        DailyPlanCorrupt(dayKey: today),
        DailyPlanFailure(dayKey: today),
        DailyPlanLoading(dayKey: today),
      ]) {
        expect(TodayRecoveryNote.shouldShow(recovery, state), isTrue);
      }
    });
  });

  group('metin varyantları', () {
    testWidgets('bir gün → nazik dönüş metni', (tester) async {
      await pumpNote(tester, const MissedDayRecovery(consecutiveMissedDays: 1));

      expect(find.text(tr.todayRecoveryTitle), findsOneWidget);
      expect(find.text(tr.todayRecoveryGentleBody), findsOneWidget);
      expect(find.text(tr.todayRecoveryExtendedBody), findsNothing);
    });

    testWidgets('iki gün → hâlâ nazik metin', (tester) async {
      await pumpNote(tester, const MissedDayRecovery(consecutiveMissedDays: 2));

      expect(find.text(tr.todayRecoveryGentleBody), findsOneWidget);
    });

    testWidgets('üç gün → sade dönüş metni', (tester) async {
      await pumpNote(tester, const MissedDayRecovery(consecutiveMissedDays: 3));

      expect(find.text(tr.todayRecoveryExtendedBody), findsOneWidget);
      expect(find.text(tr.todayRecoveryGentleBody), findsNothing);
    });

    testWidgets('uzun ara → yine sade dönüş metni', (tester) async {
      await pumpNote(
        tester,
        const MissedDayRecovery(consecutiveMissedDays: 12),
      );

      expect(find.text(tr.todayRecoveryExtendedBody), findsOneWidget);
    });

    testWidgets('kaçırılan gün SAYISI ekranda görünmez', (tester) async {
      await pumpNote(tester, const MissedDayRecovery(consecutiveMissedDays: 7));

      final text = visibleText(tester);
      for (final forbidden in ['7', '12', 'gün önce', 'kaçırdın']) {
        expect(text, isNot(contains(forbidden)));
      }
    });
  });

  group('ton ve güvenlik', () {
    testWidgets('hata/uyarı rengi ve ikonu KULLANILMAZ', (tester) async {
      await pumpNote(tester, const MissedDayRecovery(consecutiveMissedDays: 4));

      final scheme = AppTheme.light().colorScheme;
      for (final icon in tester.widgetList<Icon>(find.byType(Icon))) {
        expect(icon.color, isNot(scheme.error));
        expect(icon.icon, isNot(Icons.error));
        expect(icon.icon, isNot(Icons.error_outline));
        expect(icon.icon, isNot(Icons.warning));
        expect(icon.icon, isNot(Icons.warning_amber));
        expect(icon.icon, isNot(Icons.local_fire_department));
      }
    });

    testWidgets('seri/ceza/puan/paywall dili YOK', (tester) async {
      for (final locale in SupportedLocale.values) {
        await pumpNote(
          tester,
          const MissedDayRecovery(consecutiveMissedDays: 5),
          locale: locale,
        );
        final text = visibleText(tester).toLowerCase();
        for (final forbidden in [
          'seri',
          'streak',
          'puan',
          'xp',
          'rozet',
          'ceza',
          'günah',
          'sevap',
          'başarısız',
          'kaybettin',
          'premium',
          'bismillah+',
          'abonelik',
          'bağış',
          'reklam',
        ]) {
          expect(
            text,
            isNot(contains(forbidden)),
            reason: '$locale/$forbidden',
          );
        }
      }
    });

    testWidgets('modal/animasyon YOK (azaltılmış hareket dostu)', (
      tester,
    ) async {
      await pumpNote(tester, const MissedDayRecovery(consecutiveMissedDays: 3));

      // Not, ekranın akışında duran sıradan bir karttır: rota/modal
      // AÇMAZ ve dikkat çeken hiçbir animasyon çalıştırmaz.
      expect(find.byType(Dialog), findsNothing);
      final attentionSeeking = find.descendant(
        of: find.byType(TodayRecoveryNote),
        matching: find.byWidgetPredicate(
          (w) =>
              w is AnimatedWidget ||
              w is CircularProgressIndicator ||
              w is LinearProgressIndicator,
        ),
      );
      expect(attentionSeeking, findsNothing);

      // TASK 095: ortak kart yüzeyi (`AppCard`) tamamlanma/seçim rengini
      // sakin bir süreye yayar. Notun KENDİSİ örtük animasyon EKLEMEZ —
      // buradaki tek örtük animasyonlu widget o paylaşılan yüzeydir ve
      // notun `completed` değeri hiç değişmediği için pratikte hiç
      // oynamaz. Reduced-motion açıkken süresi zaten sıfırdır.
      final implicit = find.descendant(
        of: find.byType(TodayRecoveryNote),
        matching: find.byWidgetPredicate((w) => w is ImplicitlyAnimatedWidget),
      );
      for (final widget in tester.widgetList(implicit)) {
        expect(
          widget,
          isA<AnimatedContainer>(),
          reason: 'nota ait ek bir örtük animasyon eklenmemelidir',
        );
      }
      expect(
        find.descendant(
          of: find.byType(TodayRecoveryNote),
          matching: find.byType(AppCard),
        ),
        findsWidgets,
      );
    });

    testWidgets('ham gün anahtarı veya şablon kimliği yazılmaz', (
      tester,
    ) async {
      await pumpNote(tester, const MissedDayRecovery(consecutiveMissedDays: 2));

      final text = visibleText(tester);
      for (final forbidden in [
        '2026-',
        'prayer_track_daily',
        'rule-engine-v1',
        'MissedDayRecovery',
      ]) {
        expect(text, isNot(contains(forbidden)));
      }
    });
  });

  group('erişilebilirlik ve düzen', () {
    testWidgets('tek ekran-okuyucu düğümü başlık + mesaj taşır', (
      tester,
    ) async {
      await pumpNote(tester, const MissedDayRecovery(consecutiveMissedDays: 1));

      final handle = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel(
          '${tr.todayRecoveryTitle}. ${tr.todayRecoveryGentleBody}',
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('dar ekran (320 px) taşmaz', (tester) async {
      await pumpNote(
        tester,
        const MissedDayRecovery(consecutiveMissedDays: 4),
        size: const Size(320, 1200),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('büyük yazı (1.5x) dar ekranda taşmaz', (tester) async {
      await pumpNote(
        tester,
        const MissedDayRecovery(consecutiveMissedDays: 4),
        size: const Size(320, 1600),
        textScale: 1.5,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('Arapça RTL yönünde çizilir', (tester) async {
      await pumpNote(
        tester,
        const MissedDayRecovery(consecutiveMissedDays: 1),
        locale: SupportedLocale.ar,
      );

      expect(
        Directionality.of(tester.element(find.byType(TodayRecoveryNote))),
        TextDirection.rtl,
      );
      expect(find.text(ar.todayRecoveryTitle), findsOneWidget);
    });

    testWidgets('İngilizce metin çözülür', (tester) async {
      await pumpNote(
        tester,
        const MissedDayRecovery(consecutiveMissedDays: 1),
        locale: SupportedLocale.en,
      );

      expect(find.text(en.todayRecoveryTitle), findsOneWidget);
      expect(find.text(en.todayRecoveryGentleBody), findsOneWidget);
    });

    test('üç dil de gerçekten çevrilmiştir', () {
      final keys = <String Function(AppLocalizations)>[
        (l) => l.todayRecoveryTitle,
        (l) => l.todayRecoveryGentleBody,
        (l) => l.todayRecoveryExtendedBody,
      ];
      for (final key in keys) {
        expect(key(tr), isNotEmpty);
        expect(key(en), isNot(key(tr)));
        expect(key(ar), isNot(key(tr)));
        expect(key(ar), isNot(key(en)));
      }
    });
  });
}
