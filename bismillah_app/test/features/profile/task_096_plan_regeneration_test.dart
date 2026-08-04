import 'dart:async';

import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/onboarding/domain/entities/onboarding_preferences.dart';
import 'package:bismillah_app/features/onboarding/domain/repositories/onboarding_preferences_repository.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_daily_pace.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_journey_stage.dart';
import 'package:bismillah_app/features/today/application/initial_daily_plan_orchestrator.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/repositories/daily_plan_repository.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_generator.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 096 — plan yenileme.
///
/// Bu bir **veri bütünlüğü** testidir: yenileme yalnız açık onaydan sonra
/// çalışır (arayüz testi ayrı dosyada), geçmiş günlere dokunmaz, hata
/// hâlinde depo değişmez ve hızlı çift dokunuş ikinci yazma üretmez.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixedLocalNow = DateTime(2026, 8, 4, 9, 30);
  final today = DayKey('2026-08-04');
  DayKey dayAt(int offset) => DailyPlanGenerator.dayAt(today, offset);

  OnboardingPreferences prefs({
    Set<OnboardingFocusGoal> goals = const {
      OnboardingFocusGoal.trackPrayers,
      OnboardingFocusGoal.quranHabit,
      OnboardingFocusGoal.islamicKnowledge,
    },
  }) => OnboardingPreferences(
    goals: goals,
    journeyStage: OnboardingJourneyStage.justBeginning,
    dailyPace: OnboardingDailyPace.balanced,
    completedAtUtc: fixedLocalNow.toUtc(),
  );

  late _FakePlanRepository planRepo;
  late _FakePreferencesRepository prefsRepo;

  setUp(() {
    planRepo = _FakePlanRepository();
    prefsRepo = _FakePreferencesRepository()..stored = prefs();
  });

  InitialDailyPlanOrchestrator orchestrator() => InitialDailyPlanOrchestrator(
    planRepository: planRepo,
    preferencesRepository: prefsRepo,
    clock: FixedClock(fixedLocalNow),
  );

  /// Geçmişte kalan, yenilemenin ASLA dokunmaması gereken bir gün.
  DailyPlan pastPlan() => DailyPlan(
    dayKey: dayAt(-3),
    items: [
      PlanItem(
        itemId: EntityId('rule-engine-v1:${dayAt(-3).value}:prayer:0'),
        type: PlanItemType.prayer,
        status: PlanItemStatus.completed,
        completedAt: UtcDateTime(DateTime.utc(2026, 8)),
      ),
    ],
    profileType: 'beginner',
    sizeMinutes: 10,
    weekIndex: 0,
    generatedBy: 'rule-engine-v1',
  );

  test('yenileme bugünden başlayan 30 günü TEK yazmayla üretir', () async {
    final outcome = await orchestrator().regenerateFromToday();

    expect(outcome, isA<PlanRegenerated>());
    final regenerated = outcome as PlanRegenerated;
    expect(regenerated.startDay, today);
    expect(regenerated.dayCount, 30);
    expect(planRepo.batchSaveCalls, 1);
    expect(planRepo.singleSaveCalls, 0, reason: '30 ayrı yazma YASAK');
    expect(planRepo.lastBatchSize, 30);
  });

  test('GEÇMİŞ günlere dokunulmaz', () async {
    final past = pastPlan();
    planRepo.plans[past.dayKey] = past;

    await orchestrator().regenerateFromToday();

    final preserved = planRepo.plans[past.dayKey]!;
    expect(identical(preserved, past), isTrue);
    expect(preserved.items.single.isCompleted, isTrue);
    // Toplu yazma yalnız bugün ve sonrasını içerir.
    expect(
      planRepo.lastBatch!.every((p) => p.dayKey.compareTo(today) >= 0),
      isTrue,
    );
  });

  test('aynı kimlikli görevlerin tamamlanma işareti KORUNUR', () async {
    // Önce bir plan üret ve bugünün ilk görevini tamamla.
    await orchestrator().regenerateFromToday();
    final before = planRepo.plans[today]!;
    expect(before.items, isNotEmpty);
    final completedItem = before.items.first;
    planRepo.plans[today] = DailyPlan(
      dayKey: today,
      items: [
        PlanItem(
          itemId: completedItem.itemId,
          type: completedItem.type,
          targetRef: completedItem.targetRef,
          sizeParam: completedItem.sizeParam,
          status: PlanItemStatus.completed,
          completedAt: UtcDateTime(DateTime.utc(2026, 8, 4, 10)),
        ),
        ...before.items.skip(1),
      ],
      profileType: before.profileType,
      sizeMinutes: before.sizeMinutes,
      weekIndex: before.weekIndex,
      generatedBy: before.generatedBy,
    );

    final outcome =
        await orchestrator().regenerateFromToday() as PlanRegenerated;

    expect(outcome.preservedCompletedItems, 1);
    expect(outcome.droppedCompletedItems, 0);
    final after = planRepo.plans[today]!;
    final carried = after.items.firstWhere(
      (i) => i.itemId == completedItem.itemId,
    );
    expect(carried.isCompleted, isTrue);
    expect(carried.completedAt, isNotNull);
  });

  test('tercih değişince kalkan görevin işareti DÜRÜSTÇE bildirilir', () async {
    await orchestrator().regenerateFromToday();
    final before = planRepo.plans[today]!;
    // Kur'an görevini tamamlanmış işaretle.
    final quranItem = before.items.firstWhere(
      (i) => i.type == PlanItemType.quran,
    );
    planRepo.plans[today] = DailyPlan(
      dayKey: today,
      items: [
        for (final item in before.items)
          if (item.itemId == quranItem.itemId)
            PlanItem(
              itemId: item.itemId,
              type: item.type,
              targetRef: item.targetRef,
              sizeParam: item.sizeParam,
              status: PlanItemStatus.completed,
              completedAt: UtcDateTime(DateTime.utc(2026, 8, 4, 10)),
            )
          else
            item,
      ],
      profileType: before.profileType,
      sizeMinutes: before.sizeMinutes,
      weekIndex: before.weekIndex,
      generatedBy: before.generatedBy,
    );

    // Kullanıcı Kur'an hedefini kaldırdı.
    prefsRepo.stored = prefs(goals: const {OnboardingFocusGoal.trackPrayers});

    final outcome =
        await orchestrator().regenerateFromToday() as PlanRegenerated;

    expect(outcome.preservedCompletedItems, 0);
    expect(
      outcome.droppedCompletedItems,
      1,
      reason: 'artık üretilmeyen görevin işareti taşınamaz ve bu bildirilir',
    );
    expect(
      planRepo.plans[today]!.items.any((i) => i.type == PlanItemType.quran),
      isFalse,
    );
  });

  test('hızlı çift çağrı TEK yazma üretir', () async {
    final instance = orchestrator();
    final first = instance.regenerateFromToday();
    final second = instance.regenerateFromToday();
    final results = await Future.wait([first, second]);

    expect(planRepo.batchSaveCalls, 1);
    expect(identical(results[0], results[1]), isTrue);
  });

  test('üretim/yazma hatasında depo DEĞİŞMEZ ve başarı bildirilmez', () async {
    planRepo.batchFailure = const StorageFailure();
    final past = pastPlan();
    planRepo.plans[past.dayKey] = past;

    final outcome = await orchestrator().regenerateFromToday();

    expect(outcome, isA<PlanRegenerationPersistenceFailed>());
    expect(planRepo.plans.length, 1, reason: 'yalnız eski gün durur');
    expect(planRepo.plans[past.dayKey], same(past));
  });

  test('mevcut aralık OKUNAMIYORSA üzerine yazılmaz', () async {
    planRepo.rangeFailure = const StorageCorruptionFailure();

    final outcome = await orchestrator().regenerateFromToday();

    expect(outcome, isA<PlanRegenerationPersistenceFailed>());
    expect(planRepo.batchSaveCalls, 0);
  });

  test('tercih yoksa plan üretilmez', () async {
    prefsRepo.stored = null;

    final outcome = await orchestrator().regenerateFromToday();

    expect(outcome, isA<PlanRegenerationOnboardingIncomplete>());
    expect(planRepo.batchSaveCalls, 0);
  });

  test('tercih okunamıyorsa plan üretilmez', () async {
    prefsRepo.loadFailure = const StorageFailure();

    final outcome = await orchestrator().regenerateFromToday();

    expect(outcome, isA<PlanRegenerationPersistenceFailed>());
    expect(planRepo.batchSaveCalls, 0);
  });

  test(
    'yenileme mevcut üreticiyi kullanır — ikinci kural seti yoktur',
    () async {
      await orchestrator().regenerateFromToday();

      final plan = planRepo.plans[today]!;
      expect(plan.generatedBy, 'rule-engine-v1');
      expect(plan.profileType, isNotEmpty);
      // Öğe kimlikleri kanonik biçimi korur.
      for (final item in plan.items) {
        expect(item.itemId.value, startsWith('rule-engine-v1:${today.value}:'));
      }
    },
  );
}

final class _FakePlanRepository implements DailyPlanRepository {
  final Map<DayKey, DailyPlan> plans = {};
  final Map<DayKey, StreamController<DailyPlan?>> _streams = {};

  AppFailure? rangeFailure;
  AppFailure? batchFailure;

  int singleSaveCalls = 0;
  int batchSaveCalls = 0;
  int? lastBatchSize;
  List<DailyPlan>? lastBatch;

  @override
  Stream<DailyPlan?> watchPlan(DayKey dayKey) => _streams
      .putIfAbsent(dayKey, StreamController<DailyPlan?>.broadcast)
      .stream;

  @override
  ResultFuture<DailyPlan?> getPlan(DayKey dayKey) async =>
      Result.success(plans[dayKey]);

  @override
  ResultFuture<void> savePlan(DailyPlan plan) async {
    singleSaveCalls++;
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
      return Result.failure(failure); // atomik: hiçbir gün yazılmaz
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
