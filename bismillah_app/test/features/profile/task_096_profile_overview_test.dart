import 'dart:async';

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/onboarding/data/onboarding_data_providers.dart';
import 'package:bismillah_app/features/onboarding/domain/entities/onboarding_preferences.dart';
import 'package:bismillah_app/features/onboarding/domain/repositories/onboarding_preferences_repository.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_daily_pace.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_journey_stage.dart';
import 'package:bismillah_app/features/profile/domain/profile_plan_overview.dart';
import 'package:bismillah_app/features/profile/presentation/profile_placeholder_screen.dart';
import 'package:bismillah_app/features/today/data/today_data_providers.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/repositories/daily_plan_repository.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_generator.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

/// TASK 096 — Profil ana ekranı.
///
/// Ekrandaki her sayı KAYITLI gerçek veriden gelmelidir; uydurma metrik,
/// hesap/bulut/eşitleme ifadesi ve çalışmayan satır bulunmamalıdır.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixedLocalNow = DateTime(2026, 8, 4, 9, 30);
  final today = DayKey('2026-08-04');
  DayKey dayAt(int offset) => DailyPlanGenerator.dayAt(today, offset);

  OnboardingPreferences prefs({
    Set<OnboardingFocusGoal> goals = const {
      OnboardingFocusGoal.trackPrayers,
      OnboardingFocusGoal.quranHabit,
    },
    OnboardingJourneyStage journey = OnboardingJourneyStage.justBeginning,
    OnboardingDailyPace pace = OnboardingDailyPace.balanced,
  }) => OnboardingPreferences(
    goals: goals,
    journeyStage: journey,
    dailyPace: pace,
    completedAtUtc: fixedLocalNow.toUtc(),
  );

  DailyPlan planFor(
    DayKey dayKey, {
    int itemCount = 2,
    int completedCount = 0,
  }) => DailyPlan(
    dayKey: dayKey,
    items: [
      for (var i = 0; i < itemCount; i++)
        PlanItem(
          itemId: EntityId('rule-engine-v1:${dayKey.value}:item_$i:$i'),
          type: PlanItemType.prayer,
          status: i < completedCount
              ? PlanItemStatus.completed
              : PlanItemStatus.pending,
          completedAt: i < completedCount
              ? UtcDateTime(DateTime.utc(2026, 8, 4))
              : null,
        ),
    ],
    profileType: 'beginner',
    sizeMinutes: 10,
    weekIndex: 0,
    generatedBy: 'rule-engine-v1',
  );

  late _FakePlanRepository planRepo;
  late _FakePreferencesRepository prefsRepo;

  setUp(() {
    planRepo = _FakePlanRepository();
    prefsRepo = _FakePreferencesRepository()..stored = prefs();
  });

  List<Override> overrides() => [
    clockProvider.overrideWithValue(FixedClock(fixedLocalNow)),
    dailyPlanRepositoryProvider.overrideWithValue(planRepo),
    onboardingPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
  ];

  Future<void> pumpProfile(
    WidgetTester tester, {
    String locale = 'tr',
    double textScale = 1.0,
    Size size = const Size(1080, 3200),
    bool reducedMotion = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: Locale(locale),
          supportedLocales: SupportedLocale.locales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
              disableAnimations: reducedMotion,
            ),
            child: child!,
          ),
          home: const ProfilePlaceholderScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('plan özeti — SAF hesaplama', () {
    test('bugünü içeren kesintisiz blok özetlenir', () {
      final plans = [
        for (var offset = -2; offset <= 5; offset++)
          planFor(dayAt(offset), completedCount: offset <= 0 ? 2 : 0),
      ];

      final summary = ProfilePlanOverviewCalculator.summarize(
        plans: plans,
        today: today,
      )!;

      expect(summary.startDay, dayAt(-2));
      expect(summary.dayCount, 8);
      expect(summary.currentDayNumber, 3);
      expect(summary.totalItems, 16);
      expect(summary.completedItems, 6);
      expect(summary.completedDays, 3);
    });

    test('bugün için plan yoksa özet YOKTUR (sıfır uydurulmaz)', () {
      expect(
        ProfilePlanOverviewCalculator.summarize(
          plans: [planFor(dayAt(-5)), planFor(dayAt(-4))],
          today: today,
        ),
        isNull,
      );
      expect(
        ProfilePlanOverviewCalculator.summarize(plans: [], today: today),
        isNull,
      );
    });

    test('araya boş gün girerse ayrı dönem sayılır', () {
      final plans = [
        planFor(dayAt(-5)),
        // dayAt(-4) YOK — blok burada kesilir
        planFor(dayAt(-3)),
        planFor(dayAt(-2)),
        planFor(dayAt(-1)),
        planFor(today),
      ];

      final summary = ProfilePlanOverviewCalculator.summarize(
        plans: plans,
        today: today,
      )!;

      expect(summary.startDay, dayAt(-3));
      expect(summary.dayCount, 4);
      expect(summary.currentDayNumber, 4);
    });

    test('son ilerleme penceresi geleceği SAYMAZ', () {
      final plans = [
        for (var offset = -2; offset <= 10; offset++)
          planFor(dayAt(offset), completedCount: offset <= 0 ? 2 : 0),
      ];

      final summary = ProfilePlanOverviewCalculator.summarize(
        plans: plans,
        today: today,
      )!;

      // Bugün dahil geriye 3 gün kayıtlı → 6 görev, hepsi tamamlanmış.
      expect(summary.recentTotalItems, 6);
      expect(summary.recentCompletedItems, 6);
    });

    test('öğesiz plan tamamlanmış SAYILMAZ', () {
      final summary = ProfilePlanOverviewCalculator.summarize(
        plans: [planFor(today, itemCount: 0)],
        today: today,
      )!;

      expect(summary.totalItems, 0);
      expect(summary.hasItems, isFalse);
      expect(summary.completedDays, 0);
    });
  });

  group('ekran gerçek veriden render eder', () {
    testWidgets('kayıtlı tercihler ve plan ilerlemesi görünür', (tester) async {
      for (var offset = 0; offset < 5; offset++) {
        planRepo.plans[dayAt(offset)] = planFor(
          dayAt(offset),
          completedCount: offset == 0 ? 1 : 0,
        );
      }

      await pumpProfile(tester);

      expect(find.text('Gün 1 / 5'), findsOneWidget);
      expect(find.text('1 / 10 görev tamamlandı'), findsOneWidget);
      expect(find.text('0 gün tamamen tamamlandı'), findsOneWidget);
      // Profil türü tercihlerden TÜRETİLİR (justBeginning → Başlangıç).
      expect(find.text('Başlangıç'), findsOneWidget);
    });

    testWidgets('plan yokken sakin bir açıklama gösterilir, sıfır DEĞİL', (
      tester,
    ) async {
      await pumpProfile(tester);

      expect(find.textContaining('aktif bir plan görünmüyor'), findsOneWidget);
      expect(find.textContaining('görev tamamlandı'), findsNothing);
      expect(find.textContaining('Gün 1 /'), findsNothing);
    });

    testWidgets('tercih okunamazsa sakin hata + tekrar dene', (tester) async {
      prefsRepo.loadFailure = const StorageFailure();

      await pumpProfile(tester);

      expect(find.textContaining('şu an açılamadı'), findsWidgets);
      expect(find.text('Tekrar dene'), findsWidgets);
    });

    testWidgets('plan deposu hata verse bile ekran çökmez', (tester) async {
      planRepo.rangeFailure = const StorageCorruptionFailure();

      await pumpProfile(tester);

      expect(tester.takeException(), isNull);
      // Tercih özeti yine görünür.
      expect(find.text('Başlangıç'), findsOneWidget);
    });
  });

  group('hesap/bulut dürüstlüğü', () {
    testWidgets('yerel veri açıklaması görünür', (tester) async {
      await pumpProfile(tester);

      expect(find.text('Verilerin bu cihazda'), findsOneWidget);
      expect(find.textContaining('yalnız bu cihazda saklanır'), findsOneWidget);
      expect(
        find.textContaining(
          'Bulut yedekleme ve hesap eşitlemesi şu an etkin '
          'değildir',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('uygulama verilerini temizlemek'),
        findsOneWidget,
      );
    });

    testWidgets('hesap/giriş/eşitleme EYLEMİ sunulmaz', (tester) async {
      await pumpProfile(tester);

      // Asıl risk, kullanıcının dokunabileceği bir "hesap" yolu sunmaktır.
      // Bu yüzden düz metin değil, EYLEM taşıyan yüzeyler taranır: nesir
      // içinde "hesap oluşturmadan kullanıyorsun" gibi olumsuz ve dürüst
      // cümleler meşrudur ve yanlış pozitif üretmemelidir.
      final affordances = <String>[
        for (final row in tester.widgetList<SettingsRow>(
          find.byType(SettingsRow),
        ))
          row.title.toLowerCase(),
        for (final button in tester.widgetList<AppButton>(
          find.byType(AppButton),
        ))
          button.label.toLowerCase(),
      ];

      for (final forbidden in [
        'giriş',
        'oturum',
        'hesap',
        'yedek',
        'senkron',
        'eşitle',
        'bulut',
      ]) {
        expect(
          affordances.any((label) => label.contains(forbidden)),
          isFalse,
          reason: 'dokunulabilir "$forbidden" eylemi sunulmamalı',
        );
      }

      // "Bulut" yalnız AKTİF OLMADIĞINI söyleyen cümlede geçebilir.
      for (final line
          in tester
              .widgetList<Text>(find.byType(Text))
              .map((t) => t.data ?? '')
              .where((t) => t.toLowerCase().contains('bulut'))) {
        expect(
          line.contains('etkin değil'),
          isTrue,
          reason: 'buluttan söz eden her cümle etkin olmadığını söylemeli',
        );
      }
    });
  });

  group('ayar satırları', () {
    testWidgets('her görünen satırın çalışan bir hedefi vardır', (
      tester,
    ) async {
      await pumpProfile(tester);

      final rows = tester
          .widgetList<SettingsRow>(find.byType(SettingsRow))
          .toList();
      expect(rows, isNotEmpty);

      for (final row in rows) {
        // "Son okunan" satırı içerik yokken bilinçli olarak pasiftir ve
        // boş durumunu değerinde söyler — ölü satır DEĞİLDİR.
        if (row.onTap == null) {
          expect(
            row.value,
            isNotNull,
            reason: '"${row.title}" pasif ama boş durum metni yok',
          );
        }
      }
    });

    testWidgets('desteklenmeyen ayarlar HİÇ gösterilmez', (tester) async {
      await pumpProfile(tester);

      // Tema/koyu mod ve hareket azaltma uygulamada YOK: satır açılmaz.
      for (final absent in ['Tema', 'Koyu mod', 'Hareketi azalt', 'Abonelik']) {
        expect(
          find.text(absent),
          findsNothing,
          reason: 'çalışmayan "$absent" satırı gösterilmemeli',
        );
      }
    });
  });

  group('dil, RTL, büyük metin ve azaltılmış hareket', () {
    test('yeni anahtarlar TR/EN/AR üçünde de doludur ve farklıdır', () {
      const tr = AppLocalizations(SupportedLocale.tr);
      const en = AppLocalizations(SupportedLocale.en);
      const ar = AppLocalizations(SupportedLocale.ar);
      final arabic = RegExp(r'[؀-ۿ]');

      for (final read in <(String Function(AppLocalizations), String)>[
        ((l) => l.profilePlanSection, 'profilePlanSection'),
        ((l) => l.profilePlanTypeLabel, 'profilePlanTypeLabel'),
        ((l) => l.profileLocalDataTitle, 'profileLocalDataTitle'),
        ((l) => l.profileLocalDataBody, 'profileLocalDataBody'),
        ((l) => l.profilePlanRegenerateBody, 'profilePlanRegenerateBody'),
        ((l) => l.profilePlanTypeBeginner, 'profilePlanTypeBeginner'),
      ]) {
        expect(read.$1(tr).trim(), isNotEmpty);
        expect(read.$1(en), isNot(read.$1(tr)), reason: read.$2);
        expect(
          arabic.hasMatch(read.$1(ar)),
          isTrue,
          reason: '${read.$2} Arapça değil',
        );
      }
    });

    testWidgets('Arapça yerelde RTL çözülür ve plan özeti görünür', (
      tester,
    ) async {
      planRepo.plans[today] = planFor(today, completedCount: 1);

      await pumpProfile(tester, locale: 'ar');

      expect(
        Directionality.of(tester.element(find.byType(ListView).first)),
        TextDirection.rtl,
      );
      expect(find.text('نمط خطتك'), findsOneWidget);
      expect(find.textContaining('اليوم 1 من 1'), findsOneWidget);
    });

    testWidgets('1.5x metin ölçeğinde dar ekranda taşma olmaz', (tester) async {
      planRepo.plans[today] = planFor(today, completedCount: 1);

      await pumpProfile(tester, textScale: 1.5, size: const Size(360, 2400));

      expect(tester.takeException(), isNull);
    });

    testWidgets('Arapça + 1.5x metin ölçeğinde de taşma olmaz', (tester) async {
      planRepo.plans[today] = planFor(today, completedCount: 1);

      await pumpProfile(
        tester,
        locale: 'ar',
        textScale: 1.5,
        size: const Size(360, 2400),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('azaltılmış harekette ekran dinlenirken animasyon kalmaz', (
      tester,
    ) async {
      planRepo.plans[today] = planFor(today, completedCount: 1);

      await pumpProfile(tester, reducedMotion: true);

      expect(tester.hasRunningAnimations, isFalse);
      expect(find.textContaining('Gün 1 / 1'), findsOneWidget);
    });

    testWidgets('plan özeti ekran okuyucuya tek düğüm olarak sunulur', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      planRepo.plans[today] = planFor(today, completedCount: 1);

      await pumpProfile(tester);

      expect(find.bySemanticsLabel(RegExp('Gün 1 / 1')), findsWidgets);

      handle.dispose();
    });
  });

  group('plan yenileme arayüzü', () {
    testWidgets('yenileme ONAY olmadan çalışmaz', (tester) async {
      planRepo.plans[today] = planFor(today);

      await pumpProfile(tester);
      await tester.tap(find.text('Planı tercihlerine göre yenile'));
      await tester.pumpAndSettle();

      expect(find.text('Plan yenilensin mi?'), findsOneWidget);
      expect(find.textContaining('Geçmiş günlere dokunulmaz'), findsOneWidget);
      expect(planRepo.batchSaveCalls, 0);
    });

    testWidgets('vazgeçmek mevcut planı DEĞİŞTİRMEZ', (tester) async {
      final original = planFor(today);
      planRepo.plans[today] = original;

      await pumpProfile(tester);
      await tester.tap(find.text('Planı tercihlerine göre yenile'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('İptal'));
      await tester.pumpAndSettle();

      expect(planRepo.batchSaveCalls, 0);
      expect(planRepo.plans[today], same(original));
      expect(find.textContaining('yenilendi'), findsNothing);
    });

    testWidgets('onaylandığında plan yazılır ve başarı dürüstçe bildirilir', (
      tester,
    ) async {
      await pumpProfile(tester);
      await tester.tap(find.text('Planı tercihlerine göre yenile'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Planı yenile'));
      await tester.pumpAndSettle();

      expect(planRepo.batchSaveCalls, 1);
      expect(planRepo.lastBatchSize, 30);
      expect(
        find.textContaining('Plan tercihlerine göre yenilendi'),
        findsOneWidget,
      );
    });

    testWidgets('hata BAŞARI gibi gösterilmez', (tester) async {
      planRepo.batchFailure = const StorageFailure();

      await pumpProfile(tester);
      await tester.tap(find.text('Planı tercihlerine göre yenile'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Planı yenile'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Plan yenilenemedi'), findsOneWidget);
      expect(find.textContaining('yenilendi.'), findsNothing);
    });

    testWidgets('hızlı çift dokunuş TEK yazma üretir', (tester) async {
      await pumpProfile(tester);
      await tester.tap(find.text('Planı tercihlerine göre yenile'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Planı yenile'));
      // İkinci dokunuşu işlem sürerken dene: buton pasiftir.
      await tester.pump();
      final button = find.text('Planı tercihlerine göre yenile');
      if (button.evaluate().isNotEmpty) {
        await tester.tap(button, warnIfMissed: false);
      }
      await tester.pumpAndSettle();

      expect(planRepo.batchSaveCalls, 1);
    });
  });
}

final class _FakePlanRepository implements DailyPlanRepository {
  final Map<DayKey, DailyPlan> plans = {};
  final Map<DayKey, StreamController<DailyPlan?>> _streams = {};

  AppFailure? rangeFailure;
  AppFailure? batchFailure;

  int batchSaveCalls = 0;
  int? lastBatchSize;

  @override
  Stream<DailyPlan?> watchPlan(DayKey dayKey) => _streams
      .putIfAbsent(dayKey, StreamController<DailyPlan?>.broadcast)
      .stream;

  @override
  ResultFuture<DailyPlan?> getPlan(DayKey dayKey) async =>
      Result.success(plans[dayKey]);

  @override
  ResultFuture<void> savePlan(DailyPlan plan) async {
    plans[plan.dayKey] = plan;
    return const Result.success(null);
  }

  @override
  ResultFuture<void> savePlans(List<DailyPlan> incoming) async {
    batchSaveCalls++;
    lastBatchSize = incoming.length;
    final failure = batchFailure;
    if (failure != null) {
      return Result.failure(failure);
    }
    for (final plan in incoming) {
      plans[plan.dayKey] = plan;
    }
    return const Result.success(null);
  }

  @override
  ResultFuture<List<DailyPlan>> getRange(DayKey from, DayKey to) async {
    final failure = rangeFailure;
    if (failure != null) {
      return Result.failure(failure);
    }
    final selected =
        plans.entries
            .where(
              (e) => e.key.compareTo(from) >= 0 && e.key.compareTo(to) <= 0,
            )
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    return Result.success([for (final e in selected) e.value]);
  }
}

final class _FakePreferencesRepository
    implements OnboardingPreferencesRepository {
  OnboardingPreferences? stored;
  AppFailure? loadFailure;

  @override
  Future<bool> isCompleted() async => stored != null;

  @override
  ResultFuture<OnboardingPreferences?> load() async {
    final failure = loadFailure;
    if (failure != null) {
      return Result.failure(failure);
    }
    return Result.success(stored);
  }

  @override
  ResultFuture<void> saveCompleted(OnboardingPreferences preferences) async {
    stored = preferences;
    return const Result.success(null);
  }
}
