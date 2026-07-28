import 'dart:async';
import 'dart:convert';

import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/features/onboarding/application/onboarding_completion_controller.dart';
import 'package:bismillah_app/features/onboarding/application/onboarding_goals_controller.dart';
import 'package:bismillah_app/features/onboarding/application/onboarding_journey_controller.dart';
import 'package:bismillah_app/features/onboarding/application/onboarding_pace_controller.dart';
import 'package:bismillah_app/features/onboarding/application/onboarding_status_controller.dart';
import 'package:bismillah_app/features/onboarding/data/onboarding_data_providers.dart';
import 'package:bismillah_app/features/onboarding/domain/entities/onboarding_preferences.dart';
import 'package:bismillah_app/features/onboarding/domain/repositories/onboarding_preferences_repository.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_daily_pace.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_journey_stage.dart';
import 'package:bismillah_app/features/today/application/daily_plan_controller.dart';
import 'package:bismillah_app/features/today/application/daily_plan_state.dart';
import 'package:bismillah_app/features/today/application/initial_daily_plan_bootstrap_controller.dart';
import 'package:bismillah_app/features/today/application/initial_daily_plan_orchestrator.dart';
import 'package:bismillah_app/features/today/application/today_day_controller.dart';
import 'package:bismillah_app/features/today/data/shared_prefs_daily_plan_repository.dart';
import 'package:bismillah_app/features/today/data/today_data_providers.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/repositories/daily_plan_repository.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_generator.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// CP10 uçtan uca kontrol noktası (TASK 085).
///
/// Alt katman birim testlerini TEKRARLAMAZ; yalnız tam akışı ve
/// TASK 084'te değişen abonelik iptali davranışını kanıtlar:
///
/// onboarding → profil → üretim → atomik yazma → bootstrap → Today →
/// tamamlama → yeniden başlatma → gün devri → kaçırılmış gün.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const storageKey = SharedPrefsDailyPlanRepository.storageKey;

  final dayOne = DayKey('2026-07-27');
  DayKey dayAt(int offset) => DailyPlanGenerator.dayAt(dayOne, offset);

  late _MutableClock clock;
  late _FakeScheduler scheduler;
  late _MemoryPreferencesRepository prefs;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    clock = _MutableClock(DateTime(2026, 7, 27, 9, 30));
    scheduler = _FakeScheduler();
    prefs = _MemoryPreferencesRepository();
  });

  /// GERÇEK SharedPreferences deposuyla bir "uygulama oturumu".
  ///
  /// Yeniden başlatma, aynı mock prefs üzerinde YENİ bir container +
  /// YENİ bir repository örneğiyle modellenir — kalıcılık gerçekten
  /// diskten okunur.
  ({ProviderContainer container, SharedPrefsDailyPlanRepository repo})
  session() {
    final repo = SharedPrefsDailyPlanRepository();
    final container = ProviderContainer(
      overrides: [
        dailyPlanRepositoryProvider.overrideWithValue(repo),
        onboardingPreferencesRepositoryProvider.overrideWithValue(prefs),
        clockProvider.overrideWithValue(clock),
        dayRolloverSchedulerProvider.overrideWithValue(scheduler),
        onboardingCompletedAtLaunchProvider.overrideWithValue(false),
      ],
    );
    addTearDown(() {
      container.dispose();
      unawaited(repo.dispose());
    });
    return (container: container, repo: repo);
  }

  OnboardingPreferences preferences() => OnboardingPreferences(
    goals: const {
      OnboardingFocusGoal.trackPrayers,
      OnboardingFocusGoal.prayOnTime,
      OnboardingFocusGoal.quranHabit,
      OnboardingFocusGoal.islamicKnowledge,
    },
    journeyStage: OnboardingJourneyStage.justBeginning,
    dailyPace: OnboardingDailyPace.balanced,
    completedAtUtc: DateTime.utc(2026, 7, 27),
  );

  Future<bool> completeOnboarding(ProviderContainer c) async {
    c.read(onboardingGoalsControllerProvider.notifier)
      ..toggleGoal(OnboardingFocusGoal.trackPrayers)
      ..toggleGoal(OnboardingFocusGoal.prayOnTime)
      ..toggleGoal(OnboardingFocusGoal.quranHabit)
      ..toggleGoal(OnboardingFocusGoal.islamicKnowledge);
    c
        .read(onboardingJourneyControllerProvider.notifier)
        .select(OnboardingJourneyStage.justBeginning);
    c
        .read(onboardingPaceControllerProvider.notifier)
        .select(OnboardingDailyPace.balanced);
    try {
      await c.read(onboardingCompletionControllerProvider.future);
    } on Object {
      // Önceki denemeden kalan hata durumu; yalnız `build` bitmiş olmalı.
    }
    return c.read(onboardingCompletionControllerProvider.notifier).complete();
  }

  Future<List<DailyPlan>> storedRange(
    SharedPrefsDailyPlanRepository repo,
  ) async {
    final result = await repo.getRange(dayAt(-40), dayAt(60));
    return result.valueOrNull ?? const [];
  }

  // ------------------------------------------------------------------
  // 1. Taze kullanıcı: onboarding → 30 plan → Today → tamamlama → restart
  // ------------------------------------------------------------------

  group('taze kullanıcı uçtan uca', () {
    test('onboarding 30 plan üretir ve Today Available olur', () async {
      final first = session();

      expect(await completeOnboarding(first.container), isTrue);
      await first.container.read(todayDayControllerProvider.notifier).start();

      final plans = await storedRange(first.repo);
      expect(plans.length, 30);
      expect(plans.first.dayKey, dayOne, reason: 'ilk gün yerel bugündür');
      for (var offset = 0; offset < 30; offset++) {
        expect(plans[offset].dayKey, dayAt(offset), reason: 'kesintisiz');
      }
      expect(plans.map((p) => p.dayKey.value).toSet().length, 30);

      final state =
          first.container.read(dailyPlanControllerProvider)!
              as DailyPlanAvailable;
      expect(state.plan.dayKey, dayOne);
      expect(state.plan.items.map((i) => i.type).toList(), [
        PlanItemType.prayer,
        PlanItemType.prayer,
        PlanItemType.quran,
        PlanItemType.lesson,
      ]);
    });

    test('onboarding başarısı plan yazımını BEKLER', () async {
      final c = session().container;

      final ok = await completeOnboarding(c);

      expect(ok, isTrue);
      expect(c.read(onboardingCompletedProvider), isTrue);
      expect(prefs.saveCalls, 1, reason: 'tercih tek kez kaydedilir');
    });

    test('tamamlama yeniden başlatmadan SONRA korunur', () async {
      final first = session();
      await completeOnboarding(first.container);
      await first.container.read(todayDayControllerProvider.notifier).start();

      final controller = first.container.read(
        dailyPlanControllerProvider.notifier,
      );
      final plan =
          (first.container.read(dailyPlanControllerProvider)!
                  as DailyPlanAvailable)
              .plan;
      await controller.toggleItemCompletion(plan.items[2].itemId);

      // "Yeniden başlatma": yeni container + yeni repository, aynı prefs.
      final second = session();
      await second.container.read(todayDayControllerProvider.notifier).start();

      final restored =
          second.container.read(dailyPlanControllerProvider)!
              as DailyPlanAvailable;
      expect(restored.plan.items[2].isCompleted, isTrue);
      expect(restored.plan.items[2].completedAt, isNotNull);
      expect(restored.plan.items[0].isCompleted, isFalse);
      expect(restored.plan.items.length, 4);
      expect((await storedRange(second.repo)).length, 30);
    });

    test('kalıcı zarf sürümü 1 ve anahtar DEĞİŞMEZ', () async {
      final c = session().container;
      await completeOnboarding(c);

      final raw = (await SharedPreferences.getInstance()).getString(storageKey);
      expect(raw, isNotNull, reason: 'anahtar aynı kalmalı');
      expect(
        (json.decode(raw!) as Map<String, Object?>)['v'],
        1,
        reason: 'zarf sürümü 1',
      );
    });

    test('tek mantıksal yazma: 30 gün tek anahtarda', () async {
      final c = session().container;
      await completeOnboarding(c);

      final keys = (await SharedPreferences.getInstance()).getKeys();
      expect(keys.where((k) => k.contains('daily_plan')).toList(), [
        storageKey,
      ]);
    });
  });

  // ------------------------------------------------------------------
  // 2. Mevcut kullanıcı bootstrap ve idempotency
  // ------------------------------------------------------------------

  group('mevcut kullanıcı ve idempotency', () {
    test('onboarding tamam + plan yok → bir kez kurar', () async {
      prefs.stored = preferences();
      final s = session();

      await s.container.read(todayDayControllerProvider.notifier).start();

      expect((await storedRange(s.repo)).length, 30);
      expect(
        s.container.read(initialDailyPlanBootstrapProvider),
        isA<InitialDailyPlanCreated>(),
      );
    });

    test('tekrar start YENİDEN ÜRETMEZ', () async {
      prefs.stored = preferences();
      final s = session();
      final controller = s.container.read(todayDayControllerProvider.notifier);

      await controller.start();
      final before = (await storedRange(s.repo)).first;
      await controller.start();
      await controller.start();

      final after = (await storedRange(s.repo)).first;
      expect((await storedRange(s.repo)).length, 30);
      expect(after.generatedBy, before.generatedBy);
      expect(after.items.length, before.items.length);
    });

    test('mevcut eksiksiz aralık YENİDEN YAZILMAZ', () async {
      prefs.stored = preferences();
      final first = session();
      await first.container.read(todayDayControllerProvider.notifier).start();
      final controller = first.container.read(
        dailyPlanControllerProvider.notifier,
      );
      final plan =
          (first.container.read(dailyPlanControllerProvider)!
                  as DailyPlanAvailable)
              .plan;
      await controller.toggleItemCompletion(plan.items.first.itemId);
      final completedAt = (await storedRange(
        first.repo,
      )).first.items.first.completedAt;

      // Yeni oturum: aralık zaten tam → no-op.
      final second = session();
      final outcome = await second.container
          .read(initialDailyPlanBootstrapProvider.notifier)
          .ensureOnce();

      expect(outcome, isA<InitialDailyPlanAlreadyAvailable>());
      final preserved = (await storedRange(second.repo)).first;
      expect(preserved.items.first.isCompleted, isTrue);
      expect(preserved.items.first.completedAt, completedAt);
    });

    test('kısmi aralık ONARILMAZ ve ÜZERİNE YAZILMAZ', () async {
      prefs.stored = preferences();
      final seed = session();
      // Yalnız birkaç gün yaz.
      await seed.repo.savePlans([
        for (var offset = 0; offset < 5; offset++) _stubPlan(dayAt(offset)),
      ]);

      final s = session();
      final outcome = await s.container
          .read(initialDailyPlanBootstrapProvider.notifier)
          .ensureOnce();

      expect(outcome, isA<InitialDailyPlanRangeConflict>());
      final stored = await storedRange(s.repo);
      expect(stored.length, 5, reason: 'eksik günler doldurulmaz');
      expect(stored.every((p) => p.generatedBy == 'stub-engine'), isTrue);
    });

    test('eşzamanlı kurulum tek yazma üretir', () async {
      prefs.stored = preferences();
      final s = session();
      final orchestrator = s.container.read(
        initialDailyPlanOrchestratorProvider,
      );

      final results = await Future.wait([
        orchestrator.ensureInitialPlan(),
        orchestrator.ensureInitialPlan(),
        orchestrator.ensureInitialPlan(),
      ]);

      expect(results.every((r) => r.isPlanAvailable), isTrue);
      expect((await storedRange(s.repo)).length, 30);
    });
  });

  // ------------------------------------------------------------------
  // 3. Gün geçişi ve kaçırılmış gün
  // ------------------------------------------------------------------

  group('gün geçişi', () {
    test('N günü tamamlanır, N+1 gününe geçilir, N DEĞİŞMEZ', () async {
      prefs.stored = preferences();
      final s = session();
      final day = s.container.read(todayDayControllerProvider.notifier);
      await day.start();

      final planController = s.container.read(
        dailyPlanControllerProvider.notifier,
      );
      final dayOnePlan =
          (s.container.read(dailyPlanControllerProvider)! as DailyPlanAvailable)
              .plan;
      await planController.toggleItemCompletion(dayOnePlan.items.first.itemId);

      clock.value = DateTime(2026, 7, 28, 8);
      await day.onAppResumed();

      expect(
        s.container.read(todayDayControllerProvider).selectedDay,
        dayAt(1),
      );
      final shown =
          s.container.read(dailyPlanControllerProvider)! as DailyPlanAvailable;
      expect(shown.plan.dayKey, dayAt(1));
      expect(shown.plan.completedCount, 0, reason: 'yeni gün taze başlar');

      final storedDayOne = (await storedRange(s.repo)).first;
      expect(storedDayOne.dayKey, dayOne);
      expect(storedDayOne.completedCount, 1, reason: 'geçmiş korunur');
      expect(storedDayOne.items.first.completedAt, isNotNull);
    });

    test('aynı gün geri dönüşü tam no-op', () async {
      prefs.stored = preferences();
      final s = session();
      final day = s.container.read(todayDayControllerProvider.notifier);
      await day.start();
      final before =
          s.container.read(dailyPlanControllerProvider)! as DailyPlanAvailable;

      await day.onAppResumed();
      await day.onAppResumed();

      expect(
        identical(s.container.read(dailyPlanControllerProvider), before),
        isTrue,
        reason: 'durum nesnesi bile değişmez',
      );
    });

    test('canlı gece yarısı tek geçiş yapar', () async {
      prefs.stored = preferences();
      final s = session();
      await s.container.read(todayDayControllerProvider.notifier).start();

      clock.value = DateTime(2026, 7, 28, 0, 0, 1);
      await scheduler.fire();

      expect(
        s.container.read(todayDayControllerProvider).selectedDay,
        dayAt(1),
      );
      expect((await storedRange(s.repo)).length, 30, reason: 'plan büyümez');
    });
  });

  group('kaçırılmış gün dönüşü', () {
    test('tamamen bekleyen gün sonrası nazik kurtarma görünür', () async {
      prefs.stored = preferences();
      final s = session();
      final day = s.container.read(todayDayControllerProvider.notifier);
      await day.start(); // gün 1, hiç işaretlenmedi

      clock.value = DateTime(2026, 7, 28, 8);
      await day.onAppResumed();

      final recovery = s.container.read(todayDayControllerProvider).recovery;
      expect(recovery.consecutiveMissedDays, 1);
      expect(recovery.isExtendedAbsence, isFalse);
    });

    test('üç gün ara → uzun ara, plan AYNEN durur', () async {
      prefs.stored = preferences();
      final s = session();
      final day = s.container.read(todayDayControllerProvider.notifier);
      await day.start();

      clock.value = DateTime(2026, 7, 30, 8);
      await day.onAppResumed();

      final recovery = s.container.read(todayDayControllerProvider).recovery;
      expect(recovery.consecutiveMissedDays, 3);
      expect(recovery.isExtendedAbsence, isTrue);

      final shown =
          s.container.read(dailyPlanControllerProvider)! as DailyPlanAvailable;
      expect(shown.plan.items.length, 4, reason: 'plan küçültülmez');
      expect(shown.plan.items.map((i) => i.type).toList(), [
        PlanItemType.prayer,
        PlanItemType.prayer,
        PlanItemType.quran,
        PlanItemType.lesson,
      ], reason: 'sıra korunur');
      expect(shown.plan.sizeMinutes, 10, reason: 'dakika bütçesi değişmez');
    });

    test('kaçırılmış gün hesabı geçmişi DEĞİŞTİRMEZ', () async {
      prefs.stored = preferences();
      final s = session();
      final day = s.container.read(todayDayControllerProvider.notifier);
      await day.start();
      final before = _project(await storedRange(s.repo));

      clock.value = DateTime(2026, 7, 30, 8);
      await day.onAppResumed();

      expect(_project(await storedRange(s.repo)), before);
    });

    test('bugün bir görev işaretlenince geçmiş yine DEĞİŞMEZ', () async {
      prefs.stored = preferences();
      final s = session();
      final day = s.container.read(todayDayControllerProvider.notifier);
      await day.start();
      clock.value = DateTime(2026, 7, 29, 8);
      await day.onAppResumed();

      final shown =
          s.container.read(dailyPlanControllerProvider)! as DailyPlanAvailable;
      await s.container
          .read(dailyPlanControllerProvider.notifier)
          .toggleItemCompletion(shown.plan.items.first.itemId);

      final stored = await storedRange(s.repo);
      expect(stored.first.completedCount, 0, reason: 'gün 1 dokunulmadı');
      expect(stored[1].completedCount, 0, reason: 'gün 2 dokunulmadı');
      expect(stored[2].completedCount, 1, reason: 'yalnız bugün');
    });
  });

  // ------------------------------------------------------------------
  // 4. Abonelik iptali yarış denetimi (TASK 085 §5)
  // ------------------------------------------------------------------

  group('abonelik iptali denetimi', () {
    late _WatchAuditRepository audit;

    ProviderContainer auditSession() {
      final c = ProviderContainer(
        overrides: [
          dailyPlanRepositoryProvider.overrideWithValue(audit),
          onboardingPreferencesRepositoryProvider.overrideWithValue(prefs),
          clockProvider.overrideWithValue(clock),
          dayRolloverSchedulerProvider.overrideWithValue(scheduler),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    setUp(() => audit = _WatchAuditRepository());

    test('hızlı A→B→C geçişi Loading\'de TAKILMAZ', () async {
      for (final day in [dayAt(0), dayAt(1), dayAt(2)]) {
        audit.plans[day] = _stubPlan(day);
      }
      final controller = auditSession().read(
        dailyPlanControllerProvider.notifier,
      );

      // Üç geçişi ARDIŞIK olarak başlat, hiçbirini beklemeden.
      final a = controller.loadDay(dayAt(0));
      final b = controller.loadDay(dayAt(1));
      final c = controller.loadDay(dayAt(2));
      await Future.wait([a, b, c]);

      expect(controller.selectedDay, dayAt(2));
    });

    test('nihai durum YALNIZ C gününe aittir', () async {
      for (final day in [dayAt(0), dayAt(1), dayAt(2)]) {
        audit.plans[day] = _stubPlan(day);
      }
      final container = auditSession();
      final controller = container.read(dailyPlanControllerProvider.notifier);

      await Future.wait([
        controller.loadDay(dayAt(0)),
        controller.loadDay(dayAt(1)),
        controller.loadDay(dayAt(2)),
      ]);

      final state = container.read(dailyPlanControllerProvider)!;
      expect(state, isA<DailyPlanAvailable>());
      expect(state.dayKey, dayAt(2));
      expect((state as DailyPlanAvailable).plan.dayKey, dayAt(2));
    });

    test('A akışından gelen olay B veya C\'yi EZEMEZ', () async {
      audit.plans[dayAt(0)] = _stubPlan(dayAt(0));
      audit.plans[dayAt(2)] = _stubPlan(dayAt(2));
      final container = auditSession();
      final controller = container.read(dailyPlanControllerProvider.notifier);

      await controller.loadDay(dayAt(0));
      await controller.loadDay(dayAt(2));

      // Eski A aboneliği hâlâ elimizde: olay yayınla.
      audit.emit(dayAt(0), _stubPlan(dayAt(0), sizeMinutes: 99));
      await _settle();

      final state =
          container.read(dailyPlanControllerProvider)! as DailyPlanAvailable;
      expect(state.plan.dayKey, dayAt(2));
      expect(state.plan.sizeMinutes, isNot(99));
    });

    test('B akışından gelen olay C\'yi EZEMEZ', () async {
      for (final day in [dayAt(0), dayAt(1), dayAt(2)]) {
        audit.plans[day] = _stubPlan(day);
      }
      final container = auditSession();
      final controller = container.read(dailyPlanControllerProvider.notifier);

      await controller.loadDay(dayAt(0));
      await controller.loadDay(dayAt(1));
      await controller.loadDay(dayAt(2));

      audit.emit(dayAt(1), _stubPlan(dayAt(1), sizeMinutes: 77));
      await _settle();

      final state =
          container.read(dailyPlanControllerProvider)! as DailyPlanAvailable;
      expect(state.plan.dayKey, dayAt(2));
      expect(state.plan.sizeMinutes, isNot(77));
    });

    test('eski abonelikler GERÇEKTEN iptal edilir', () async {
      for (final day in [dayAt(0), dayAt(1), dayAt(2)]) {
        audit.plans[day] = _stubPlan(day);
      }
      final controller = auditSession().read(
        dailyPlanControllerProvider.notifier,
      );

      await controller.loadDay(dayAt(0));
      await controller.loadDay(dayAt(1));
      await controller.loadDay(dayAt(2));
      await _settle();

      expect(audit.listenCalls, 3);
      expect(audit.cancelCalls, 2, reason: 'ilk iki abonelik iptal edildi');
    });

    test('tekrarlı gün değişimi dinleyici BİRİKTİRMEZ', () async {
      for (var offset = 0; offset < 12; offset++) {
        audit.plans[dayAt(offset)] = _stubPlan(dayAt(offset));
      }
      final controller = auditSession().read(
        dailyPlanControllerProvider.notifier,
      );

      for (var offset = 0; offset < 12; offset++) {
        await controller.loadDay(dayAt(offset));
      }
      await _settle();

      expect(audit.listenCalls, 12);
      expect(audit.activeListeners, 1, reason: 'aynı anda tek aktif watch');
    });

    test('controller kapanınca aktif abonelik iptal edilir', () async {
      audit.plans[dayAt(0)] = _stubPlan(dayAt(0));
      final container = ProviderContainer(
        overrides: [
          dailyPlanRepositoryProvider.overrideWithValue(audit),
          onboardingPreferencesRepositoryProvider.overrideWithValue(prefs),
          clockProvider.overrideWithValue(clock),
          dayRolloverSchedulerProvider.overrideWithValue(scheduler),
        ],
      );
      await container
          .read(dailyPlanControllerProvider.notifier)
          .loadDay(dayAt(0));
      expect(audit.activeListeners, 1);

      container.dispose();
      await _settle();

      expect(audit.activeListeners, 0);
    });

    test('iptal HATASI yakalanmamış asenkron hataya dönüşmez', () async {
      // TASK 085 düzeltmesi: `cancel()` hata ile tamamlansa bile zone'a
      // sızmaz. Sızsaydı bu test flutter_test tarafından düşerdi.
      audit.failCancel = true;
      audit.plans[dayAt(0)] = _stubPlan(dayAt(0));
      audit.plans[dayAt(1)] = _stubPlan(dayAt(1));
      final container = auditSession();
      final controller = container.read(dailyPlanControllerProvider.notifier);

      await controller.loadDay(dayAt(0));
      await controller.loadDay(dayAt(1));
      await _settle();

      expect(
        container.read(dailyPlanControllerProvider),
        isA<DailyPlanAvailable>(),
      );
    });

    test('iptal hatası yeni günün yüklenmesini BLOKLAMAZ', () async {
      audit.failCancel = true;
      for (final day in [dayAt(0), dayAt(1), dayAt(2)]) {
        audit.plans[day] = _stubPlan(day);
      }
      final container = auditSession();
      final controller = container.read(dailyPlanControllerProvider.notifier);

      await controller.loadDay(dayAt(0));
      await controller.loadDay(dayAt(1));
      await controller.loadDay(dayAt(2));

      final state =
          container.read(dailyPlanControllerProvider)! as DailyPlanAvailable;
      expect(state.plan.dayKey, dayAt(2));
      expect(audit.cancelCalls, 2, reason: 'iptal yine de İSTENDİ');
    });

    test('geç tamamlanan iptal daha yeni durumu DEĞİŞTİRMEZ', () async {
      audit.holdCancel = true;
      for (final day in [dayAt(0), dayAt(1)]) {
        audit.plans[day] = _stubPlan(day);
      }
      final container = auditSession();
      final controller = container.read(dailyPlanControllerProvider.notifier);

      await controller.loadDay(dayAt(0));
      await controller.loadDay(dayAt(1));
      final before = container.read(dailyPlanControllerProvider);

      audit.releaseCancels(); // bekleyen iptaller şimdi tamamlanır
      await _settle();

      expect(container.read(dailyPlanControllerProvider), before);
      expect(
        (container.read(dailyPlanControllerProvider)! as DailyPlanAvailable)
            .plan
            .dayKey,
        dayAt(1),
      );
    });

    test('gerçek watch hatası SESSİZCE YUTULMAZ ama durumu devirmez', () async {
      audit.plans[dayAt(0)] = _stubPlan(dayAt(0));
      final container = auditSession();
      final controller = container.read(dailyPlanControllerProvider.notifier);
      await controller.loadDay(dayAt(0));

      audit.emitError(dayAt(0), const StorageFailure());
      await _settle();

      // Akış sözleşmesi: hata son bilinen durumu DEVİRMEZ; okuma yolu
      // hatayı ayrıca raporlar (TASK 077).
      final state =
          container.read(dailyPlanControllerProvider)! as DailyPlanAvailable;
      expect(state.plan.dayKey, dayAt(0));
    });
  });

  // ------------------------------------------------------------------
  // 5. 30. gün sınırı
  // ------------------------------------------------------------------

  group('30. gün sınırı', () {
    test('30. gün normal yüklenir', () async {
      prefs.stored = preferences();
      final s = session();
      await s.container.read(todayDayControllerProvider.notifier).start();

      clock.value = DateTime(2026, 8, 25, 9); // dayAt(29)
      await s.container
          .read(todayDayControllerProvider.notifier)
          .onAppResumed();

      expect(
        s.container.read(todayDayControllerProvider).selectedDay,
        dayAt(29),
      );
      expect(
        s.container.read(dailyPlanControllerProvider),
        isA<DailyPlanAvailable>(),
      );
    });

    test('31. gün dürüst Empty kalır — uzatma YOK', () async {
      prefs.stored = preferences();
      final s = session();
      await s.container.read(todayDayControllerProvider.notifier).start();

      clock.value = DateTime(2026, 8, 26, 9); // dayAt(30)
      await s.container
          .read(todayDayControllerProvider.notifier)
          .onAppResumed();

      expect(
        s.container.read(todayDayControllerProvider).selectedDay,
        dayAt(30),
      );
      expect(
        s.container.read(dailyPlanControllerProvider),
        isA<DailyPlanEmpty>(),
      );
      expect(
        (await storedRange(s.repo)).length,
        30,
        reason: 'aralık uzatılmaz, yeniden üretilmez',
      );
    });
  });
}

/// Karşılaştırılabilir kalıcı durum izdüşümü.
List<String> _project(List<DailyPlan> plans) => [
  for (final plan in plans)
    [
      plan.dayKey.value,
      plan.profileType,
      '${plan.sizeMinutes}',
      '${plan.weekIndex}',
      plan.generatedBy,
      plan.items
          .map(
            (i) =>
                '${i.itemId.value}|${i.type.name}|${i.status.name}|'
                '${i.targetRef}|${i.completedAt}',
          )
          .join(','),
    ].join('#'),
];

DailyPlan _stubPlan(DayKey dayKey, {int sizeMinutes = 10}) => DailyPlan(
  dayKey: dayKey,
  items: [
    PlanItem(
      itemId: EntityId('stub:${dayKey.value}:0'),
      type: PlanItemType.prayer,
      status: PlanItemStatus.pending,
    ),
  ],
  profileType: 'beginner',
  sizeMinutes: sizeMinutes,
  weekIndex: 0,
  generatedBy: 'stub-engine',
);

/// Mikro görev kuyruğunu boşaltır.
Future<void> _settle() async {
  for (var i = 0; i < 8; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

/// Abonelik yaşam döngüsünü denetleyen sahte depo (TASK 085 §5).
///
/// `listen`/`cancel` sayımı, iptal gecikmesi ve iptal hatası enjeksiyonu
/// sağlar — gerçek bir akışın kapanma davranışını taklit etmek yerine
/// doğrudan gözlemlenebilir kılar.
final class _WatchAuditRepository implements DailyPlanRepository {
  final Map<DayKey, DailyPlan> plans = {};
  final Map<DayKey, StreamController<DailyPlan?>> _controllers = {};
  final List<Completer<void>> _heldCancels = [];

  int listenCalls = 0;
  int cancelCalls = 0;
  int activeListeners = 0;

  /// `cancel()` hata ile tamamlansın mı?
  bool failCancel = false;

  /// `cancel()` serbest bırakılana kadar askıda kalsın mı?
  bool holdCancel = false;

  void releaseCancels() {
    for (final gate in _heldCancels) {
      if (!gate.isCompleted) {
        gate.complete();
      }
    }
    _heldCancels.clear();
  }

  StreamController<DailyPlan?> _controllerFor(DayKey dayKey) =>
      _controllers.putIfAbsent(dayKey, StreamController<DailyPlan?>.broadcast);

  void emit(DayKey dayKey, DailyPlan plan) => _controllerFor(dayKey).add(plan);

  void emitError(DayKey dayKey, Object error) =>
      _controllerFor(dayKey).addError(error);

  @override
  Stream<DailyPlan?> watchPlan(DayKey dayKey) =>
      _AuditStream(this, _controllerFor(dayKey).stream);

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
    for (final plan in incoming) {
      plans[plan.dayKey] = plan;
    }
    return const Result.success(null);
  }

  @override
  ResultFuture<List<DailyPlan>> getRange(DayKey from, DayKey to) async {
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

/// `listen` çağrılarını sayan ve denetlenebilir abonelik döndüren akış.
final class _AuditStream extends Stream<DailyPlan?> {
  _AuditStream(this._audit, this._inner);

  final _WatchAuditRepository _audit;
  final Stream<DailyPlan?> _inner;

  @override
  bool get isBroadcast => true;

  @override
  StreamSubscription<DailyPlan?> listen(
    void Function(DailyPlan?)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    _audit.listenCalls++;
    _audit.activeListeners++;
    return _AuditSubscription(
      _audit,
      _inner.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      ),
    );
  }
}

final class _AuditSubscription implements StreamSubscription<DailyPlan?> {
  _AuditSubscription(this._audit, this._inner);

  final _WatchAuditRepository _audit;
  final StreamSubscription<DailyPlan?> _inner;
  bool _cancelled = false;

  @override
  Future<void> cancel() async {
    if (!_cancelled) {
      _cancelled = true;
      _audit.cancelCalls++;
      _audit.activeListeners--;
    }
    await _inner.cancel();
    if (_audit.holdCancel) {
      final gate = Completer<void>();
      _audit._heldCancels.add(gate);
      await gate.future;
    }
    if (_audit.failCancel) {
      throw StateError('cancel failed (test)');
    }
  }

  @override
  void onData(void Function(DailyPlan?)? handleData) =>
      _inner.onData(handleData);

  @override
  void onError(Function? handleError) => _inner.onError(handleError);

  @override
  void onDone(void Function()? handleDone) => _inner.onDone(handleDone);

  @override
  void pause([Future<void>? resumeSignal]) => _inner.pause(resumeSignal);

  @override
  void resume() => _inner.resume();

  @override
  bool get isPaused => _inner.isPaused;

  @override
  Future<E> asFuture<E>([E? futureValue]) => _inner.asFuture<E>(futureValue);
}

final class _MutableClock implements AppClock {
  _MutableClock(this.value);

  DateTime value;

  @override
  DateTime nowLocal() => value;

  @override
  DateTime nowUtc() => value.toUtc();
}

final class _FakeScheduler implements DayRolloverScheduler {
  void Function()? pending;
  int scheduleCalls = 0;
  int cancelCalls = 0;

  @override
  void schedule(Duration delay, void Function() onFire) {
    scheduleCalls++;
    pending = onFire;
  }

  @override
  void cancel() {
    cancelCalls++;
    pending = null;
  }

  Future<void> fire() async {
    pending?.call();
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }
}

/// Bellek içi onboarding tercih deposu (SharedPreferences'a bağlı değil,
/// böylece "yeniden başlatma" yalnız plan kalıcılığını sınar).
final class _MemoryPreferencesRepository
    implements OnboardingPreferencesRepository {
  OnboardingPreferences? stored;
  int saveCalls = 0;

  @override
  Future<bool> isCompleted() async => stored != null;

  @override
  ResultFuture<OnboardingPreferences?> load() async => Result.success(stored);

  @override
  ResultFuture<void> saveCompleted(OnboardingPreferences preferences) async {
    saveCalls++;
    stored = preferences;
    return const Result.success(null);
  }
}
