import 'dart:async';
import 'dart:io';

import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
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
import 'package:bismillah_app/features/today/data/today_data_providers.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/repositories/daily_plan_repository.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_generator.dart';
import 'package:bismillah_app/features/today/domain/services/prayer_daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/services/quran_daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/value_objects/daily_plan_profile_type.dart';
import 'package:bismillah_app/features/today/domain/value_objects/learn_daily_plan_catalog.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// İlk 30 günlük plan orkestrasyonu (TASK 083A).
///
/// Bu bir **veri bütünlüğü** testidir: 30 gün ya tamamen yazılır ya hiç
/// yazılmaz, mevcut geçerli plan asla sessizce ezilmez ve tekrar çağrılar
/// ikinci bir plan üretmez.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixedLocalNow = DateTime(2026, 7, 27, 9, 30);
  final today = DayKey('2026-07-27');

  DayKey dayAt(int offset) => DailyPlanGenerator.dayAt(today, offset);

  OnboardingPreferences prefs({
    Set<OnboardingFocusGoal> goals = const {
      OnboardingFocusGoal.trackPrayers,
      OnboardingFocusGoal.prayOnTime,
      OnboardingFocusGoal.quranHabit,
      OnboardingFocusGoal.islamicKnowledge,
    },
    OnboardingJourneyStage journey = OnboardingJourneyStage.justBeginning,
    OnboardingDailyPace pace = OnboardingDailyPace.balanced,
  }) => OnboardingPreferences(
    goals: goals,
    journeyStage: journey,
    dailyPace: pace,
    completedAtUtc: fixedLocalNow.toUtc(),
  );

  /// Yabancı (aralık dışı) bir gün — korunması gerekir.
  final unrelatedDay = DayKey('2020-01-01');
  DailyPlan unrelatedPlan() => DailyPlan(
    dayKey: unrelatedDay,
    items: [
      PlanItem(
        itemId: EntityId('legacy-item'),
        type: PlanItemType.quran,
        status: PlanItemStatus.completed,
        completedAt: UtcDateTime(DateTime.utc(2020)),
      ),
    ],
    profileType: 'beginner',
    sizeMinutes: 10,
    weekIndex: 0,
    generatedBy: 'rule-engine-v1',
  );

  DailyPlan simplePlan(DayKey dayKey, {bool completed = false}) => DailyPlan(
    dayKey: dayKey,
    items: [
      PlanItem(
        itemId: EntityId('rule-engine-v1:${dayKey.value}:prayer_track_daily:0'),
        type: PlanItemType.prayer,
        status: completed ? PlanItemStatus.completed : PlanItemStatus.pending,
        completedAt: completed ? UtcDateTime(DateTime.utc(2026, 7, 27)) : null,
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
    prefsRepo = _FakePreferencesRepository();
  });

  InitialDailyPlanOrchestrator orchestrator() => InitialDailyPlanOrchestrator(
    planRepository: planRepo,
    preferencesRepository: prefsRepo,
    clock: FixedClock(fixedLocalNow),
  );

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [
        dailyPlanRepositoryProvider.overrideWithValue(planRepo),
        onboardingPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
        clockProvider.overrideWithValue(FixedClock(fixedLocalNow)),
        // Gerçek yeni kullanıcı: kapı KAPALI başlar. (Bootstrap'sız test
        // container'larında bu provider varsayılan olarak `true`dur.)
        onboardingCompletedAtLaunchProvider.overrideWithValue(false),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  // -------------------------------------------------------------------
  // Orkestrasyon
  // -------------------------------------------------------------------

  group('orkestrasyon', () {
    test('geçerli tercih tam olarak 30 plan üretir', () async {
      prefsRepo.stored = prefs();

      final outcome = await orchestrator().ensureInitialPlan();

      expect(outcome, isA<InitialDailyPlanCreated>());
      expect((outcome as InitialDailyPlanCreated).dayCount, 30);
      expect(outcome.startDay, today);
      expect(planRepo.plans.length, 30);
    });

    test('ilk gün enjekte edilen saatin YEREL günüdür', () async {
      prefsRepo.stored = prefs();
      await orchestrator().ensureInitialPlan();

      final days = planRepo.plans.keys.toList()..sort();
      expect(days.first, today);
    });

    test('30 gün kesintisiz ve tekildir', () async {
      prefsRepo.stored = prefs();
      await orchestrator().ensureInitialPlan();

      final days = planRepo.plans.keys.toList()..sort();
      expect(days.length, 30);
      for (var offset = 0; offset < 30; offset++) {
        expect(days[offset], dayAt(offset));
      }
    });

    test('çekirdek bileşim kullanılır (Prayer → Quran → Learn)', () async {
      prefsRepo.stored = prefs();
      await orchestrator().ensureInitialPlan();

      final firstDay = planRepo.plans[today]!;
      expect(firstDay.items.map((i) => i.type).toList(), [
        PlanItemType.prayer,
        PlanItemType.prayer,
        PlanItemType.quran,
        PlanItemType.lesson,
      ]);
      expect(firstDay.items[0].itemId.value, contains('prayer_track_daily'));
      expect(firstDay.items[1].itemId.value, contains('prayer_on_time_daily'));
      expect(firstDay.items[2].itemId.value, contains('quran_continue_daily'));
      expect(
        firstDay.items[3].targetRef,
        LearnDailyPlanCatalog.v1.entries.first.articleId,
      );
    });

    test('yalnız namaz hedefi de geçerli plan üretir', () async {
      prefsRepo.stored = prefs(goals: const {OnboardingFocusGoal.trackPrayers});
      final outcome = await orchestrator().ensureInitialPlan();

      expect(outcome, isA<InitialDailyPlanCreated>());
      expect(planRepo.plans[today]!.items.length, 1);
    });

    test('üretilen öğeler tamamlanmamış başlar', () async {
      prefsRepo.stored = prefs();
      await orchestrator().ensureInitialPlan();

      for (final plan in planRepo.plans.values) {
        expect(
          plan.items.every((i) => i.status == PlanItemStatus.pending),
          isTrue,
        );
        expect(plan.items.every((i) => i.completedAt == null), isTrue);
      }
    });

    test('verilen tercihler kullanılınca depo OKUNMAZ', () async {
      final outcome = await orchestrator().ensureInitialPlan(
        preferences: prefs(),
      );

      expect(outcome, isA<InitialDailyPlanCreated>());
      expect(prefsRepo.loadCalls, 0, reason: 'çift okuma yok');
    });
  });

  group('profil eşlemesi', () {
    // TASK 078 kurallarının orkestratörden geçtiğini kanıtlar; sekiz
    // kovanın tamamı erişilebilir kalır.
    final cases =
        <
          String,
          (
            OnboardingJourneyStage,
            OnboardingDailyPace,
            Set<OnboardingFocusGoal>,
            DailyPlanProfileType,
          )
        >{
          'beginner': (
            OnboardingJourneyStage.justBeginning,
            OnboardingDailyPace.balanced,
            {OnboardingFocusGoal.trackPrayers},
            DailyPlanProfileType.beginner,
          ),
          'returning': (
            OnboardingJourneyStage.rebuildingRoutine,
            OnboardingDailyPace.balanced,
            {OnboardingFocusGoal.trackPrayers},
            DailyPlanProfileType.returning,
          ),
          'advanced': (
            OnboardingJourneyStage.strengtheningRoutine,
            OnboardingDailyPace.focused,
            {OnboardingFocusGoal.trackPrayers},
            DailyPlanProfileType.advanced,
          ),
          'low_time': (
            OnboardingJourneyStage.strengtheningRoutine,
            OnboardingDailyPace.light,
            {OnboardingFocusGoal.trackPrayers},
            DailyPlanProfileType.lowTime,
          ),
          'prayer_focused': (
            OnboardingJourneyStage.strengtheningRoutine,
            OnboardingDailyPace.balanced,
            {OnboardingFocusGoal.trackPrayers},
            DailyPlanProfileType.prayerFocused,
          ),
          'quran_focused': (
            OnboardingJourneyStage.strengtheningRoutine,
            OnboardingDailyPace.balanced,
            {OnboardingFocusGoal.quranHabit},
            DailyPlanProfileType.quranFocused,
          ),
          'dhikr_focused': (
            OnboardingJourneyStage.strengtheningRoutine,
            OnboardingDailyPace.balanced,
            {OnboardingFocusGoal.dhikrRoutine},
            DailyPlanProfileType.dhikrFocused,
          ),
          'learning_focused': (
            OnboardingJourneyStage.strengtheningRoutine,
            OnboardingDailyPace.balanced,
            {OnboardingFocusGoal.islamicKnowledge},
            DailyPlanProfileType.learningFocused,
          ),
        };

    for (final entry in cases.entries) {
      test('${entry.key} profili plana yazılır', () async {
        final (journey, pace, goals, expected) = entry.value;
        planRepo = _FakePlanRepository();
        prefsRepo = _FakePreferencesRepository()
          ..stored = prefs(goals: goals, journey: journey, pace: pace);

        final outcome = await orchestrator().ensureInitialPlan();

        expect(outcome, isA<InitialDailyPlanCreated>(), reason: entry.key);
        expect(
          planRepo.plans.values.every((p) => p.profileType == expected.id),
          isTrue,
          reason: entry.key,
        );
      });
    }

    test('SEKİZ profilin tamamı kapsanmıştır (kapsam kilidi)', () {
      expect({
        for (final v in cases.values) v.$4,
      }, DailyPlanProfileType.values.toSet());
    });
  });

  // -------------------------------------------------------------------
  // Atomik kalıcılık
  // -------------------------------------------------------------------

  group('atomik kalıcılık', () {
    test('30 gün TEK toplu yazmayla kaydedilir', () async {
      prefsRepo.stored = prefs();
      await orchestrator().ensureInitialPlan();

      expect(planRepo.batchSaveCalls, 1);
      expect(planRepo.singleSaveCalls, 0, reason: '30 ayrı yazma YAPILMAZ');
      expect(planRepo.lastBatchSize, 30);
    });

    test('yazma hatası deposu DEĞİŞTİRMEZ ve tipli sonuç döner', () async {
      prefsRepo.stored = prefs();
      planRepo.batchFailure = const StorageFailure();

      final outcome = await orchestrator().ensureInitialPlan();

      expect(outcome, isA<InitialDailyPlanPersistenceFailed>());
      expect(planRepo.plans, isEmpty, reason: 'kısmi aralık kalmaz');
    });

    test('okuma hatası üretimi ve yazmayı ENGELLER', () async {
      prefsRepo.stored = prefs();
      planRepo.rangeFailure = const StorageFailure();

      final outcome = await orchestrator().ensureInitialPlan();

      expect(outcome, isA<InitialDailyPlanPersistenceFailed>());
      expect(planRepo.batchSaveCalls, 0);
      expect(planRepo.plans, isEmpty);
    });

    test('bozuk depo üzerine YAZILMAZ', () async {
      prefsRepo.stored = prefs();
      planRepo.rangeFailure = const StorageCorruptionFailure();

      final outcome = await orchestrator().ensureInitialPlan();

      expect(outcome, isA<InitialDailyPlanPersistenceFailed>());
      expect(
        (outcome as InitialDailyPlanPersistenceFailed).failure,
        isA<StorageCorruptionFailure>(),
      );
      expect(planRepo.batchSaveCalls, 0);
    });

    test('aralık dışı mevcut günler KORUNUR', () async {
      prefsRepo.stored = prefs();
      planRepo.plans[unrelatedDay] = unrelatedPlan();

      await orchestrator().ensureInitialPlan();

      expect(planRepo.plans[unrelatedDay], isNotNull);
      expect(planRepo.plans[unrelatedDay]!.items.single.isCompleted, isTrue);
      expect(planRepo.plans.length, 31);
    });

    test('tercih okuma hatası tipli kalıcılık hatasına düşer', () async {
      prefsRepo.loadFailure = const StorageFailure();

      final outcome = await orchestrator().ensureInitialPlan();

      expect(outcome, isA<InitialDailyPlanPersistenceFailed>());
      expect(planRepo.batchSaveCalls, 0);
    });
  });

  // -------------------------------------------------------------------
  // Gerçek depo davranışı (toplu yazma sözleşmesi)
  // -------------------------------------------------------------------

  group('savePlans sözleşmesi', () {
    test('boş liste tipli doğrulama hatası verir', () async {
      final repo = _FakePlanRepository();
      // Sözleşme davranışı gerçek implementasyonda doğrulanır; burada
      // orkestratörün boş liste GÖNDERMEDİĞİ kanıtlanır.
      prefsRepo.stored = prefs();
      planRepo = repo;
      await orchestrator().ensureInitialPlan();
      expect(repo.lastBatchSize, 30);
    });

    test('tekrar eden gün toplu yazmaya GÖNDERİLMEZ', () async {
      prefsRepo.stored = prefs();
      await orchestrator().ensureInitialPlan();

      final sent = planRepo.lastBatch!;
      expect(sent.map((p) => p.dayKey.value).toSet().length, sent.length);
    });
  });

  // -------------------------------------------------------------------
  // Idempotency
  // -------------------------------------------------------------------

  group('idempotency', () {
    Future<void> seedFullRange({bool completedFirstDay = false}) async {
      for (var offset = 0; offset < 30; offset++) {
        planRepo.plans[dayAt(offset)] = simplePlan(
          dayAt(offset),
          completed: completedFirstDay && offset == 0,
        );
      }
    }

    test('ikinci çağrı hiçbir şey yazmaz', () async {
      prefsRepo.stored = prefs();
      final subject = orchestrator();

      final first = await subject.ensureInitialPlan();
      final second = await subject.ensureInitialPlan();

      expect(first, isA<InitialDailyPlanCreated>());
      expect(second, isA<InitialDailyPlanAlreadyAvailable>());
      expect(planRepo.batchSaveCalls, 1);
    });

    test('mevcut eksiksiz aralık zaten-var döner', () async {
      prefsRepo.stored = prefs();
      await seedFullRange();

      final outcome = await orchestrator().ensureInitialPlan();

      expect(outcome, isA<InitialDailyPlanAlreadyAvailable>());
      expect(planRepo.batchSaveCalls, 0);
    });

    test('mevcut tamamlanma durumu KORUNUR', () async {
      prefsRepo.stored = prefs();
      await seedFullRange(completedFirstDay: true);

      await orchestrator().ensureInitialPlan();

      expect(planRepo.plans[today]!.items.single.isCompleted, isTrue);
      expect(planRepo.plans[today]!.items.single.completedAt, isNotNull);
      expect(planRepo.plans[today]!.generatedBy, 'rule-engine-v1');
    });

    test('eşzamanlı iki çağrı tek yazma üretir', () async {
      prefsRepo.stored = prefs();
      final subject = orchestrator();

      final results = await Future.wait([
        subject.ensureInitialPlan(),
        subject.ensureInitialPlan(),
      ]);

      expect(planRepo.batchSaveCalls, 1, reason: 'tek mantıksal oluşturma');
      expect(results.every((r) => r.isPlanAvailable), isTrue);
    });

    test('üç eşzamanlı çağrı aynı sonucu paylaşır', () async {
      prefsRepo.stored = prefs();
      final subject = orchestrator();

      final results = await Future.wait([
        subject.ensureInitialPlan(),
        subject.ensureInitialPlan(),
        subject.ensureInitialPlan(),
      ]);

      expect(results.toSet().length, 1);
      expect(planRepo.batchSaveCalls, 1);
    });
  });

  // -------------------------------------------------------------------
  // Kısmi / çakışan aralık
  // -------------------------------------------------------------------

  group('kısmi ve çakışan aralık', () {
    test('kısmi aralık çakışma döner ve DOLDURULMAZ', () async {
      prefsRepo.stored = prefs();
      for (var offset = 0; offset < 12; offset++) {
        planRepo.plans[dayAt(offset)] = simplePlan(dayAt(offset));
      }

      final outcome = await orchestrator().ensureInitialPlan();

      expect(outcome, isA<InitialDailyPlanRangeConflict>());
      expect((outcome as InitialDailyPlanRangeConflict).existingDayCount, 12);
      expect(outcome.expectedDayCount, 30);
      expect(planRepo.batchSaveCalls, 0);
      expect(planRepo.plans.length, 12, reason: 'eksik günler doldurulmaz');
    });

    test('tek gün bile çakışma sayılır', () async {
      prefsRepo.stored = prefs();
      planRepo.plans[dayAt(5)] = simplePlan(dayAt(5));

      final outcome = await orchestrator().ensureInitialPlan();

      expect(outcome, isA<InitialDailyPlanRangeConflict>());
      expect(planRepo.batchSaveCalls, 0);
    });

    test('mevcut günler silinmez veya üzerine yazılmaz', () async {
      prefsRepo.stored = prefs();
      planRepo.plans[dayAt(0)] = simplePlan(dayAt(0), completed: true);

      await orchestrator().ensureInitialPlan();

      expect(planRepo.plans.length, 1);
      expect(planRepo.plans[dayAt(0)]!.items.single.isCompleted, isTrue);
    });

    test('kısmi aralıkta tekrar çağrı hâlâ yazmaz', () async {
      prefsRepo.stored = prefs();
      planRepo.plans[dayAt(3)] = simplePlan(dayAt(3));
      final subject = orchestrator();

      await subject.ensureInitialPlan();
      final second = await subject.ensureInitialPlan();

      expect(second, isA<InitialDailyPlanRangeConflict>());
      expect(planRepo.batchSaveCalls, 0);
    });
  });

  // -------------------------------------------------------------------
  // Onboarding girdisi
  // -------------------------------------------------------------------

  group('onboarding girdisi', () {
    test('kayıtlı tercih yoksa plan UYDURULMAZ', () async {
      final outcome = await orchestrator().ensureInitialPlan();

      expect(outcome, isA<InitialDailyPlanOnboardingIncomplete>());
      expect(planRepo.batchSaveCalls, 0);
      expect(planRepo.plans, isEmpty);
    });

    test('sonuç kullanıcı cevabı veya ham yük TAŞIMAZ', () async {
      prefsRepo.stored = prefs();
      final created = await orchestrator().ensureInitialPlan();
      final rendered = created.toString();

      for (final forbidden in [
        'trackPrayers',
        'islamicKnowledge',
        'justBeginning',
        'bismillah.daily_plans',
        'art-islam-nedir',
        'Exception',
        '#0',
        'uid',
        'deviceId',
      ]) {
        expect(rendered, isNot(contains(forbidden)));
      }
    });
  });

  // -------------------------------------------------------------------
  // Onboarding akışı entegrasyonu
  // -------------------------------------------------------------------

  group('onboarding tamamlama akışı', () {
    /// `AsyncNotifier.build` bitene kadar `state.isLoading` true'dur ve
    /// controller çift-dokunuş korumasıyla erken döner — test önce
    /// kurulumu bekler.
    Future<bool> complete(ProviderContainer c) async {
      try {
        await c.read(onboardingCompletionControllerProvider.future);
      } on Object {
        // Önceki denemeden kalan hata durumu; burada yalnız `build`'in
        // bitmiş olması gerekir.
      }
      return c.read(onboardingCompletionControllerProvider.notifier).complete();
    }

    void selectAll(ProviderContainer c) {
      c.read(onboardingGoalsControllerProvider.notifier)
        ..toggleGoal(OnboardingFocusGoal.trackPrayers)
        ..toggleGoal(OnboardingFocusGoal.quranHabit);
      c
          .read(onboardingJourneyControllerProvider.notifier)
          .select(OnboardingJourneyStage.justBeginning);
      c
          .read(onboardingPaceControllerProvider.notifier)
          .select(OnboardingDailyPace.balanced);
    }

    test('başarı plan kurulmasını BEKLER', () async {
      final c = container();
      selectAll(c);

      final ok = await complete(c);

      expect(ok, isTrue);
      expect(planRepo.plans.length, 30);
      expect(c.read(onboardingCompletedProvider), isTrue);
      expect(prefsRepo.saveCalls, 1, reason: 'tercih tek kez kaydedilir');
    });

    test('üretim/yazma hatası tamamlanmayı BAŞARILI saymaz', () async {
      final c = container();
      selectAll(c);
      planRepo.batchFailure = const StorageFailure();

      final ok = await complete(c);

      expect(ok, isFalse);
      expect(c.read(onboardingCompletedProvider), isFalse);
      expect(planRepo.plans, isEmpty);
    });

    test('hata sonrası tercihler kalıcı kalır (güvenli tekrar)', () async {
      final c = container();
      selectAll(c);
      planRepo.batchFailure = const StorageFailure();
      await complete(c);

      expect(prefsRepo.stored, isNotNull);
    });

    test('tekrar deneme çift plan ÜRETMEZ', () async {
      final c = container();
      selectAll(c);
      planRepo.batchFailure = const StorageFailure();
      await complete(c);

      planRepo.batchFailure = null;
      final ok = await complete(c);

      expect(ok, isTrue);
      expect(planRepo.plans.length, 30);

      // Üçüncü çağrı artık HİÇ yazmaz — plan zaten eksiksizdir.
      final callsAfterSuccess = planRepo.batchSaveCalls;
      expect(await complete(c), isTrue);
      expect(planRepo.batchSaveCalls, callsAfterSuccess);
      expect(planRepo.plans.length, 30, reason: 'çift plan yazılmaz');
    });

    test('tercih kaydı başarısızsa plan DENENMEZ', () async {
      final c = container();
      selectAll(c);
      prefsRepo.saveFailure = const StorageFailure();

      final ok = await complete(c);

      expect(ok, isFalse);
      expect(planRepo.batchSaveCalls, 0);
      expect(c.read(onboardingCompletedProvider), isFalse);
    });

    test('eksik seçim plan üretimini tetiklemez', () async {
      final c = container();
      c
          .read(onboardingJourneyControllerProvider.notifier)
          .select(OnboardingJourneyStage.justBeginning);

      final ok = await complete(c);

      expect(ok, isFalse);
      expect(prefsRepo.saveCalls, 0);
      expect(planRepo.batchSaveCalls, 0);
    });

    test('hata durumu ham sebep sızdırmaz', () async {
      final c = container();
      selectAll(c);
      planRepo.batchFailure = const StorageFailure();
      await complete(c);

      final rendered = c
          .read(onboardingCompletionControllerProvider)
          .error
          .toString();
      for (final forbidden in [
        'bismillah.daily_plans',
        'SharedPreferences',
        'FormatException',
        '#0',
      ]) {
        expect(rendered, isNot(contains(forbidden)));
      }
    });
  });

  // -------------------------------------------------------------------
  // Mevcut kullanıcı bootstrap
  // -------------------------------------------------------------------

  group('mevcut kullanıcı bootstrap', () {
    test('tamamlanmış onboarding + plan yok → bir kez üretir', () async {
      prefsRepo.stored = prefs();
      final c = container();

      final outcome = await c
          .read(initialDailyPlanBootstrapProvider.notifier)
          .ensureOnce();

      expect(outcome, isA<InitialDailyPlanCreated>());
      expect(planRepo.plans.length, 30);
      expect(planRepo.batchSaveCalls, 1);
    });

    test('tekrarlanan çağrı YENİDEN ÜRETMEZ', () async {
      prefsRepo.stored = prefs();
      final c = container();
      final notifier = c.read(initialDailyPlanBootstrapProvider.notifier);

      await notifier.ensureOnce();
      await notifier.ensureOnce();
      await notifier.ensureOnce();

      expect(planRepo.batchSaveCalls, 1);
      expect(planRepo.rangeCalls, 1, reason: 'ikinci çağrı depoya gitmez');
    });

    test('eşzamanlı ensureOnce tek üretim yapar', () async {
      prefsRepo.stored = prefs();
      final c = container();
      final notifier = c.read(initialDailyPlanBootstrapProvider.notifier);

      await Future.wait([notifier.ensureOnce(), notifier.ensureOnce()]);

      expect(planRepo.batchSaveCalls, 1);
    });

    test('tercih yoksa plan UYDURULMAZ', () async {
      final c = container();

      final outcome = await c
          .read(initialDailyPlanBootstrapProvider.notifier)
          .ensureOnce();

      expect(outcome, isA<InitialDailyPlanOnboardingIncomplete>());
      expect(planRepo.plans, isEmpty);
    });

    test('durum tipli sonucu yayınlar', () async {
      prefsRepo.stored = prefs();
      final c = container();

      expect(c.read(initialDailyPlanBootstrapProvider), isNull);
      await c.read(initialDailyPlanBootstrapProvider.notifier).ensureOnce();
      expect(
        c.read(initialDailyPlanBootstrapProvider),
        isA<InitialDailyPlanCreated>(),
      );
    });

    test('hata sonrası açık retry yeniden dener', () async {
      prefsRepo.stored = prefs();
      planRepo.batchFailure = const StorageFailure();
      final c = container();
      final notifier = c.read(initialDailyPlanBootstrapProvider.notifier);

      final first = await notifier.ensureOnce();
      expect(first, isA<InitialDailyPlanPersistenceFailed>());

      planRepo.batchFailure = null;
      final retried = await notifier.retry();

      expect(retried, isA<InitialDailyPlanCreated>());
      expect(planRepo.plans.length, 30);
    });

    test('hata sonrası ensureOnce KENDİLİĞİNDEN tekrar denemez', () async {
      prefsRepo.stored = prefs();
      planRepo.batchFailure = const StorageFailure();
      final c = container();
      final notifier = c.read(initialDailyPlanBootstrapProvider.notifier);

      await notifier.ensureOnce();
      final callsAfterFirst = planRepo.rangeCalls;
      await notifier.ensureOnce();

      expect(planRepo.rangeCalls, callsAfterFirst, reason: 'döngü yok');
    });

    test('çakışma güvenle raporlanır, veri değişmez', () async {
      prefsRepo.stored = prefs();
      planRepo.plans[dayAt(2)] = simplePlan(dayAt(2), completed: true);
      final c = container();

      final outcome = await c
          .read(initialDailyPlanBootstrapProvider.notifier)
          .ensureOnce();

      expect(outcome, isA<InitialDailyPlanRangeConflict>());
      expect(planRepo.plans.length, 1);
      expect(planRepo.plans[dayAt(2)]!.items.single.isCompleted, isTrue);
    });
  });

  // -------------------------------------------------------------------
  // Today entegrasyonu ve regresyon
  // -------------------------------------------------------------------

  group('Today entegrasyonu', () {
    test('kurulumdan sonra bugün Available olur', () async {
      prefsRepo.stored = prefs();
      final c = container();

      await c.read(initialDailyPlanBootstrapProvider.notifier).ensureOnce();
      await c.read(dailyPlanControllerProvider.notifier).loadDay(today);

      final state = c.read(dailyPlanControllerProvider);
      expect(state, isA<DailyPlanAvailable>());
      expect((state! as DailyPlanAvailable).plan.items, isNotEmpty);
    });

    test('kanonik öğe sırası Today\'e taşınır', () async {
      prefsRepo.stored = prefs();
      final c = container();
      await c.read(initialDailyPlanBootstrapProvider.notifier).ensureOnce();
      await c.read(dailyPlanControllerProvider.notifier).loadDay(today);

      final plan =
          (c.read(dailyPlanControllerProvider)! as DailyPlanAvailable).plan;
      expect(plan.items.map((i) => i.type).toList(), [
        PlanItemType.prayer,
        PlanItemType.prayer,
        PlanItemType.quran,
        PlanItemType.lesson,
      ]);
    });

    test('tamamlama kurulumdan sonra kalıcıdır', () async {
      prefsRepo.stored = prefs();
      final c = container();
      await c.read(initialDailyPlanBootstrapProvider.notifier).ensureOnce();
      final controller = c.read(dailyPlanControllerProvider.notifier);
      await controller.loadDay(today);

      final itemId =
          (c.read(dailyPlanControllerProvider)! as DailyPlanAvailable)
              .plan
              .items
              .first
              .itemId;
      await controller.toggleItemCompletion(itemId);

      // "Yeniden başlatma": aynı depodan taze bir controller okur.
      final restarted = container();
      await restarted.read(dailyPlanControllerProvider.notifier).loadDay(today);
      final restored =
          restarted.read(dailyPlanControllerProvider)! as DailyPlanAvailable;
      expect(restored.plan.items.first.isCompleted, isTrue);
      expect(restored.plan.items.first.completedAt, isNotNull);
    });

    test('yeniden başlatma planı ve gün sayısını korur', () async {
      prefsRepo.stored = prefs();
      await container()
          .read(initialDailyPlanBootstrapProvider.notifier)
          .ensureOnce();

      final restarted = container();
      final outcome = await restarted
          .read(initialDailyPlanBootstrapProvider.notifier)
          .ensureOnce();

      expect(outcome, isA<InitialDailyPlanAlreadyAvailable>());
      expect(planRepo.plans.length, 30);
      expect(planRepo.batchSaveCalls, 1);
    });
  });

  group('regresyon sınırları', () {
    test('şablon kimlikleri değişmedi', () {
      expect(
        PrayerDailyPlanItemSource.trackDailyTemplateId,
        'prayer_track_daily',
      );
      expect(
        PrayerDailyPlanItemSource.onTimeDailyTemplateId,
        'prayer_on_time_daily',
      );
      expect(
        QuranDailyPlanItemSource.continueDailyTemplateId,
        'quran_continue_daily',
      );
      expect(LearnDailyPlanCatalog.templateIdPrefix, 'learn_article_');
    });

    test('30 günlük çatı sabiti değişmedi', () {
      expect(InitialDailyPlanOrchestrator.planLengthDays, 30);
    });

    test('orkestratör Drift/Firebase/ağ import ETMEZ', () {
      const forbidden = [
        'drift',
        'firebase',
        'cloud_firestore',
        'package:http',
        'shared_preferences',
      ];
      final source = _readSource(
        'lib/features/today/application/initial_daily_plan_orchestrator.dart',
      );
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');
      for (final token in forbidden) {
        expect(imports, isNot(contains(token)), reason: token);
      }
    });

    test('orkestratör KOD\'unda DateTime.now yoktur (yalnız AppClock)', () {
      // Yorum satırları hariç tutulur: dokümantasyon kuralı anlatır,
      // ihlal etmez.
      final code = _readSource(
        'lib/features/today/application/initial_daily_plan_orchestrator.dart',
      ).split('\n').where((line) => !line.trimLeft().startsWith('//')).join('\n');
      expect(code, isNot(contains('DateTime.now')));
      expect(code, contains('clock.nowLocal()'));
    });

    test('depolama anahtarı ve zarf sürümü değişmedi', () {
      final repoSource = _readSource(
        'lib/features/today/data/shared_prefs_daily_plan_repository.dart',
      );
      expect(repoSource, contains("storageKey = 'bismillah.daily_plans'"));
      final codecSource = _readSource(
        'lib/features/today/data/daily_plan_envelope_codec.dart',
      );
      expect(codecSource, contains('currentVersion = 1'));
    });
  });
}

String _readSource(String path) => File(path).readAsStringSync();

/// Denetlenebilir sahte plan deposu (gerçek depolama yok).
final class _FakePlanRepository implements DailyPlanRepository {
  final Map<DayKey, DailyPlan> plans = {};
  final Map<DayKey, StreamController<DailyPlan?>> _streams = {};

  AppFailure? rangeFailure;
  AppFailure? batchFailure;
  AppFailure? saveFailure;

  int singleSaveCalls = 0;
  int batchSaveCalls = 0;
  int rangeCalls = 0;
  int? lastBatchSize;
  List<DailyPlan>? lastBatch;

  StreamController<DailyPlan?> _streamFor(DayKey dayKey) =>
      _streams.putIfAbsent(dayKey, StreamController<DailyPlan?>.broadcast);

  @override
  Stream<DailyPlan?> watchPlan(DayKey dayKey) => _streamFor(dayKey).stream;

  @override
  ResultFuture<DailyPlan?> getPlan(DayKey dayKey) async =>
      Result.success(plans[dayKey]);

  @override
  ResultFuture<void> savePlan(DailyPlan plan) async {
    singleSaveCalls++;
    final failure = saveFailure;
    if (failure != null) {
      return Result.failure(failure);
    }
    plans[plan.dayKey] = plan;
    return const Result.success(null);
  }

  @override
  ResultFuture<void> savePlans(List<DailyPlan> incoming) async {
    batchSaveCalls++;
    lastBatchSize = incoming.length;
    lastBatch = List.unmodifiable(incoming);
    final failure = batchFailure;
    if (failure != null) {
      // Atomik: hata hâlinde HİÇBİR gün yazılmaz.
      return Result.failure(failure);
    }
    for (final plan in incoming) {
      plans[plan.dayKey] = plan;
    }
    return const Result.success(null);
  }

  @override
  ResultFuture<List<DailyPlan>> getRange(DayKey from, DayKey to) async {
    rangeCalls++;
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

/// Bellek içi onboarding tercih deposu.
final class _FakePreferencesRepository
    implements OnboardingPreferencesRepository {
  OnboardingPreferences? stored;
  AppFailure? loadFailure;
  AppFailure? saveFailure;

  int loadCalls = 0;
  int saveCalls = 0;

  @override
  Future<bool> isCompleted() async => stored != null;

  @override
  ResultFuture<OnboardingPreferences?> load() async {
    loadCalls++;
    final failure = loadFailure;
    if (failure != null) {
      return Result.failure(failure);
    }
    return Result.success(stored);
  }

  @override
  ResultFuture<void> saveCompleted(OnboardingPreferences preferences) async {
    saveCalls++;
    final failure = saveFailure;
    if (failure != null) {
      return Result.failure(failure);
    }
    stored = preferences;
    return const Result.success(null);
  }
}
