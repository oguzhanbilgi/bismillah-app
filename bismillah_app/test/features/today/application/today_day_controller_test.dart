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
import 'package:bismillah_app/features/onboarding/data/onboarding_data_providers.dart';
import 'package:bismillah_app/features/onboarding/domain/entities/onboarding_preferences.dart';
import 'package:bismillah_app/features/onboarding/domain/repositories/onboarding_preferences_repository.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_daily_pace.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_journey_stage.dart';
import 'package:bismillah_app/features/today/application/daily_plan_controller.dart';
import 'package:bismillah_app/features/today/application/daily_plan_state.dart';
import 'package:bismillah_app/features/today/application/today_day_controller.dart';
import 'package:bismillah_app/features/today/data/today_data_providers.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/repositories/daily_plan_repository.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_generator.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Yerel takvim günü devri (TASK 084).
///
/// Gün yalnız enjekte edilen saatten türetilir; geçiş tek atışlık,
/// enjekte edilmiş bir zamanlayıcıyla deterministik olarak tetiklenir.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final dayOne = DayKey('2026-07-27');
  final dayTwo = DayKey('2026-07-28');

  DayKey back(DayKey from, int days) => DailyPlanGenerator.dayAt(from, -days);

  DailyPlan plan(DayKey dayKey, {int itemCount = 2, int completedCount = 0}) =>
      DailyPlan(
        dayKey: dayKey,
        items: [
          for (var i = 0; i < itemCount; i++)
            PlanItem(
              itemId: EntityId('${dayKey.value}-$i'),
              type: PlanItemType.prayer,
              status: i < completedCount
                  ? PlanItemStatus.completed
                  : PlanItemStatus.pending,
              completedAt: i < completedCount
                  ? UtcDateTime(DateTime.utc(2026, 7, 20))
                  : null,
            ),
        ],
        profileType: 'beginner',
        sizeMinutes: 10,
        weekIndex: 0,
        generatedBy: 'rule-engine-v1',
      );

  late _FakePlanRepository repo;
  late _FakePreferencesRepository prefs;
  late _MutableClock clock;
  late _FakeScheduler scheduler;

  setUp(() {
    repo = _FakePlanRepository();
    prefs = _FakePreferencesRepository();
    clock = _MutableClock(DateTime(2026, 7, 27, 9, 30));
    scheduler = _FakeScheduler();
  });

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [
        dailyPlanRepositoryProvider.overrideWithValue(repo),
        onboardingPreferencesRepositoryProvider.overrideWithValue(prefs),
        clockProvider.overrideWithValue(clock),
        dayRolloverSchedulerProvider.overrideWithValue(scheduler),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  TodayDayController controllerOf(ProviderContainer c) =>
      c.read(todayDayControllerProvider.notifier);

  group('gün seçimi', () {
    test('start yerel takvim gününü seçer', () async {
      repo.plans[dayOne] = plan(dayOne);
      final c = container();

      await controllerOf(c).start();

      expect(c.read(todayDayControllerProvider).selectedDay, dayOne);
      expect(c.read(dailyPlanControllerProvider), isA<DailyPlanAvailable>());
    });

    test('gün UTC dönüşümüyle DEĞİL yerel saatle türetilir', () async {
      // Yerel 00:30; UTC'ye çevrilseydi önceki güne düşerdi.
      clock.value = DateTime(2026, 7, 28, 0, 30);
      final c = container();

      await controllerOf(c).start();

      expect(c.read(todayDayControllerProvider).selectedDay, dayTwo);
    });

    test('start yalnız bir kez kurulum çağırır', () async {
      prefs.stored = _preferences();
      final c = container();

      await controllerOf(c).start();
      await controllerOf(c).start();

      expect(repo.batchSaveCalls, 1);
    });

    test('aynı gün için tekrar start yeni abonelik açmaz', () async {
      repo.plans[dayOne] = plan(dayOne);
      final c = container();

      await controllerOf(c).start();
      await controllerOf(c).start();
      await controllerOf(c).start();

      expect(repo.watchCalls, 1);
    });
  });

  group('uygulama geri dönüşü', () {
    test('aynı gün → hiçbir şey yapılmaz', () async {
      repo.plans[dayOne] = plan(dayOne);
      final c = container();
      await controllerOf(c).start();
      final getsAfterStart = repo.getCalls;

      await controllerOf(c).onAppResumed();

      expect(repo.getCalls, getsAfterStart);
      expect(repo.watchCalls, 1);
    });

    test('tarih değiştiyse bir kez yeni güne geçer', () async {
      repo.plans[dayOne] = plan(dayOne);
      repo.plans[dayTwo] = plan(dayTwo, itemCount: 3);
      final c = container();
      await controllerOf(c).start();

      clock.value = DateTime(2026, 7, 28, 8);
      await controllerOf(c).onAppResumed();

      expect(c.read(todayDayControllerProvider).selectedDay, dayTwo);
      final state = c.read(dailyPlanControllerProvider)! as DailyPlanAvailable;
      expect(state.plan.dayKey, dayTwo);
      expect(state.plan.items.length, 3);
      expect(repo.watchCalls, 2, reason: 'gün başına tek abonelik');
    });

    test('art arda geri dönüş tek geçiş yapar', () async {
      repo.plans[dayOne] = plan(dayOne);
      repo.plans[dayTwo] = plan(dayTwo);
      final c = container();
      await controllerOf(c).start();

      clock.value = DateTime(2026, 7, 28, 8);
      await controllerOf(c).onAppResumed();
      await controllerOf(c).onAppResumed();
      await controllerOf(c).onAppResumed();

      expect(repo.watchCalls, 2);
    });

    test('birkaç gün sonra dönüşte doğru gün seçilir', () async {
      final later = DayKey('2026-08-03');
      repo.plans[dayOne] = plan(dayOne);
      repo.plans[later] = plan(later);
      final c = container();
      await controllerOf(c).start();

      clock.value = DateTime(2026, 8, 3, 11);
      await controllerOf(c).onAppResumed();

      expect(c.read(todayDayControllerProvider).selectedDay, later);
    });
  });

  group('gece yarısı devri', () {
    test('bir sonraki yerel sınır 24 saat VARSAYILMAZ', () {
      clock.value = DateTime(2026, 7, 27, 21, 15);
      final c = container();

      expect(
        controllerOf(c).durationUntilNextLocalDay(),
        const Duration(hours: 2, minutes: 45),
      );
    });

    test('gece yarısında kalan süre tam bir gündür', () {
      clock.value = DateTime(2026, 7, 27);
      final c = container();

      final remaining = controllerOf(c).durationUntilNextLocalDay();
      expect(remaining.inHours, greaterThanOrEqualTo(23));
      expect(remaining.inHours, lessThanOrEqualTo(25));
    });

    test('takvim sınırı ay/yıl geçişinde doğru hesaplanır', () {
      clock.value = DateTime(2026, 12, 31, 23, 30);
      final c = container();

      expect(
        controllerOf(c).durationUntilNextLocalDay(),
        const Duration(minutes: 30),
      );
    });

    test('şubat sonu artık yıl sınırı doğru', () {
      clock.value = DateTime(2028, 2, 29, 23);
      final c = container();

      expect(
        controllerOf(c).durationUntilNextLocalDay(),
        const Duration(hours: 1),
      );
    });

    test('start sonrası tek atışlık zamanlama kurulur', () async {
      repo.plans[dayOne] = plan(dayOne);
      final c = container();

      await controllerOf(c).start();

      expect(scheduler.scheduleCalls, 1);
      expect(scheduler.lastDelay, isNotNull);
    });

    test('zamanlayıcı tetiklenince yeni güne geçilir', () async {
      repo.plans[dayOne] = plan(dayOne);
      repo.plans[dayTwo] = plan(dayTwo, itemCount: 4);
      final c = container();
      await controllerOf(c).start();

      // Yerel gece yarısı geçti.
      clock.value = DateTime(2026, 7, 28, 0, 0, 1);
      await scheduler.fire();

      expect(c.read(todayDayControllerProvider).selectedDay, dayTwo);
      expect(
        (c.read(dailyPlanControllerProvider)! as DailyPlanAvailable)
            .plan
            .items
            .length,
        4,
      );
    });

    test('geçişten sonra sonraki sınır yeniden zamanlanır', () async {
      repo.plans[dayOne] = plan(dayOne);
      repo.plans[dayTwo] = plan(dayTwo);
      final c = container();
      await controllerOf(c).start();

      clock.value = DateTime(2026, 7, 28, 0, 0, 1);
      await scheduler.fire();

      expect(scheduler.scheduleCalls, 2);
    });

    test('gün değişmeden tetiklenirse yeni abonelik açılmaz', () async {
      repo.plans[dayOne] = plan(dayOne);
      final c = container();
      await controllerOf(c).start();

      await scheduler.fire(); // saat aynı gün içinde

      expect(repo.watchCalls, 1);
      expect(c.read(todayDayControllerProvider).selectedDay, dayOne);
    });

    test('container kapanınca zamanlama iptal edilir', () async {
      repo.plans[dayOne] = plan(dayOne);
      final c = ProviderContainer(
        overrides: [
          dailyPlanRepositoryProvider.overrideWithValue(repo),
          onboardingPreferencesRepositoryProvider.overrideWithValue(prefs),
          clockProvider.overrideWithValue(clock),
          dayRolloverSchedulerProvider.overrideWithValue(scheduler),
        ],
      );
      await c.read(todayDayControllerProvider.notifier).start();

      c.dispose();

      expect(scheduler.cancelCalls, greaterThanOrEqualTo(1));
      expect(scheduler.pending, isNull);
    });

    test('kapatıldıktan sonra tetikleme durum DEĞİŞTİRMEZ', () async {
      repo.plans[dayOne] = plan(dayOne);
      final c = ProviderContainer(
        overrides: [
          dailyPlanRepositoryProvider.overrideWithValue(repo),
          onboardingPreferencesRepositoryProvider.overrideWithValue(prefs),
          clockProvider.overrideWithValue(clock),
          dayRolloverSchedulerProvider.overrideWithValue(scheduler),
        ],
      );
      final controller = c.read(todayDayControllerProvider.notifier);
      await controller.start();
      final callsBefore = repo.getCalls;
      c.dispose();

      clock.value = DateTime(2026, 7, 28, 1);
      await controller.onAppResumed();

      expect(repo.getCalls, callsBefore);
    });
  });

  group('bayat sonuç koruması', () {
    test('eski günün geç okuması yeni günü EZEMEZ', () async {
      repo.plans[dayOne] = plan(dayOne, itemCount: 1);
      repo.plans[dayTwo] = plan(dayTwo, itemCount: 5);
      final c = container();
      await controllerOf(c).start();

      // Eski gün için geciken bir aralık okuması başlat, sonra gün değiştir.
      repo.holdNextRange();
      clock.value = DateTime(2026, 7, 28, 8);
      final pending = controllerOf(c).onAppResumed();
      await Future<void>.delayed(Duration.zero);
      repo.releaseRange();
      await pending;

      final state = c.read(dailyPlanControllerProvider)! as DailyPlanAvailable;
      expect(state.plan.dayKey, dayTwo);
      expect(c.read(todayDayControllerProvider).selectedDay, dayTwo);
    });
  });

  group('kaçırılmış gün durumu', () {
    test('geçmiş yoksa kurtarma durumu boştur', () async {
      repo.plans[dayOne] = plan(dayOne);
      final c = container();

      await controllerOf(c).start();

      expect(
        c.read(todayDayControllerProvider).recovery.hasMissedDays,
        isFalse,
      );
    });

    test('kaçırılmış günler durumda görünür', () async {
      repo.plans[dayOne] = plan(dayOne);
      repo.plans[back(dayOne, 1)] = plan(back(dayOne, 1));
      repo.plans[back(dayOne, 2)] = plan(back(dayOne, 2));
      final c = container();

      await controllerOf(c).start();

      expect(
        c.read(todayDayControllerProvider).recovery.consecutiveMissedDays,
        2,
      );
    });

    test('gün devrinde kurtarma yeniden hesaplanır', () async {
      repo.plans[dayOne] = plan(dayOne);
      repo.plans[dayTwo] = plan(dayTwo);
      final c = container();
      await controllerOf(c).start();
      expect(
        c.read(todayDayControllerProvider).recovery.hasMissedDays,
        isFalse,
      );

      // Gün 1 hiç tamamlanmadan gün 2'ye geçilir.
      clock.value = DateTime(2026, 7, 28, 0, 0, 1);
      await scheduler.fire();

      expect(
        c.read(todayDayControllerProvider).recovery.consecutiveMissedDays,
        1,
      );
    });

    test('okuma hatasında kurtarma sessizce boş kalır', () async {
      repo.plans[dayOne] = plan(dayOne);
      repo.rangeFailure = const StorageCorruptionFailure();
      final c = container();

      await controllerOf(c).start();

      expect(
        c.read(todayDayControllerProvider).recovery.hasMissedDays,
        isFalse,
      );
    });

    test('geçmiş planlar okunur ama DEĞİŞTİRİLMEZ', () async {
      final yesterday = back(dayOne, 1);
      repo.plans[dayOne] = plan(dayOne);
      repo.plans[yesterday] = plan(yesterday);
      final c = container();

      await controllerOf(c).start();

      expect(repo.savePlanCalls, 0);
      expect(repo.batchSaveCalls, 0);
      expect(repo.plans[yesterday]!.completedCount, 0);
      expect(repo.plans[yesterday]!.items.length, 2);
      expect(repo.plans[yesterday]!.generatedBy, 'rule-engine-v1');
    });
  });

  group('eksik/aralık dışı gün', () {
    test('planı olmayan yeni gün dürüst Empty kalır', () async {
      repo.plans[dayOne] = plan(dayOne);
      final c = container();
      await controllerOf(c).start();

      clock.value = DateTime(2026, 7, 28, 8);
      await controllerOf(c).onAppResumed();

      expect(c.read(dailyPlanControllerProvider), isA<DailyPlanEmpty>());
      expect(repo.batchSaveCalls, 0, reason: 'yerine plan ÜRETİLMEZ');
      expect(repo.savePlanCalls, 0);
    });

    test('30. günden sonra plan uzatılmaz', () async {
      final beyond = DayKey('2026-09-30');
      repo.plans[dayOne] = plan(dayOne);
      prefs.stored = _preferences();
      final c = container();
      await controllerOf(c).start();
      final savesAfterStart = repo.batchSaveCalls;

      clock.value = DateTime(2026, 9, 30, 10);
      await controllerOf(c).onAppResumed();

      expect(c.read(todayDayControllerProvider).selectedDay, beyond);
      expect(c.read(dailyPlanControllerProvider), isA<DailyPlanEmpty>());
      expect(repo.batchSaveCalls, savesAfterStart);
    });

    test('dünün görevleri bugüne KOPYALANMAZ', () async {
      repo.plans[dayOne] = plan(dayOne, itemCount: 4);
      final c = container();
      await controllerOf(c).start();

      clock.value = DateTime(2026, 7, 28, 8);
      await controllerOf(c).onAppResumed();

      expect(repo.plans.containsKey(dayTwo), isFalse);
      expect(c.read(dailyPlanControllerProvider), isA<DailyPlanEmpty>());
    });
  });

  group('regresyon sınırları', () {
    // Yorum satırları hariç tutulur: dokümantasyon kuralı ANLATIR,
    // ihlal etmez.
    String codeOf(String path) => File(path)
        .readAsStringSync()
        .split('\n')
        .where((line) => !line.trimLeft().startsWith('//'))
        .join('\n');

    test('controller DateTime.now KULLANMAZ (yalnız AppClock)', () {
      final code = codeOf(
        'lib/features/today/application/today_day_controller.dart',
      );
      expect(code, isNot(contains('DateTime.now')));
      expect(code, contains('clockProvider'));
      expect(code, contains('nowLocal()'));
    });

    test('kaçırılmış gün hesabı yazma çağrısı İÇERMEZ', () {
      final code = codeOf(
        'lib/features/today/domain/value_objects/missed_day_recovery.dart',
      );
      for (final forbidden in ['savePlan', 'Repository', 'DateTime.now']) {
        expect(code, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('controller Drift/Firebase/ağ/bildirim import ETMEZ', () {
      final imports =
          File('lib/features/today/application/today_day_controller.dart')
              .readAsStringSync()
              .split('\n')
              .where((l) => l.trimLeft().startsWith('import '))
              .join('\n');
      for (final forbidden in [
        'drift',
        'firebase',
        'cloud_firestore',
        'package:http',
        'shared_preferences',
        'notification',
      ]) {
        expect(imports, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('seri/puan kalıcılığı EKLENMEDİ', () {
      final code = codeOf(
        'lib/features/today/application/today_day_controller.dart',
      ).toLowerCase();
      for (final forbidden in [
        'streak',
        'setstring',
        'setint',
        'sharedpreferences',
        'badge',
      ]) {
        expect(code, isNot(contains(forbidden)), reason: forbidden);
      }
    });
  });
}

OnboardingPreferences _preferences() => OnboardingPreferences(
  goals: const {OnboardingFocusGoal.trackPrayers},
  journeyStage: OnboardingJourneyStage.justBeginning,
  dailyPace: OnboardingDailyPace.balanced,
  completedAtUtc: DateTime.utc(2026, 7, 27),
);

/// İleri alınabilen saat.
final class _MutableClock implements AppClock {
  _MutableClock(this.value);

  DateTime value;

  @override
  DateTime nowLocal() => value;

  @override
  DateTime nowUtc() => value.toUtc();
}

/// Elle tetiklenen zamanlayıcı — testler saatlerce beklemez.
final class _FakeScheduler implements DayRolloverScheduler {
  void Function()? pending;
  Duration? lastDelay;
  int scheduleCalls = 0;
  int cancelCalls = 0;

  @override
  void schedule(Duration delay, void Function() onFire) {
    scheduleCalls++;
    lastDelay = delay;
    pending = onFire;
  }

  @override
  void cancel() {
    cancelCalls++;
    pending = null;
  }

  /// Bekleyen zamanlamayı çalıştırır ve zincirin bitmesini bekler.
  Future<void> fire() async {
    pending?.call();
    // Devir zinciri birkaç mikro-görev sürer.
    for (var i = 0; i < 8; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }
}

final class _FakePlanRepository implements DailyPlanRepository {
  final Map<DayKey, DailyPlan> plans = {};
  final Map<DayKey, StreamController<DailyPlan?>> _streams = {};

  AppFailure? getFailure;
  AppFailure? rangeFailure;

  int getCalls = 0;
  int savePlanCalls = 0;
  int batchSaveCalls = 0;
  int watchCalls = 0;
  int rangeCalls = 0;

  Completer<void>? _rangeGate;

  void holdNextRange() => _rangeGate = Completer<void>();
  void releaseRange() {
    final gate = _rangeGate;
    if (gate != null && !gate.isCompleted) {
      gate.complete();
    }
  }

  @override
  Stream<DailyPlan?> watchPlan(DayKey dayKey) {
    watchCalls++;
    return _streams
        .putIfAbsent(dayKey, StreamController<DailyPlan?>.broadcast)
        .stream;
  }

  @override
  ResultFuture<DailyPlan?> getPlan(DayKey dayKey) async {
    getCalls++;
    final failure = getFailure;
    if (failure != null) {
      return Result.failure(failure);
    }
    return Result.success(plans[dayKey]);
  }

  @override
  ResultFuture<void> savePlan(DailyPlan plan) async {
    savePlanCalls++;
    plans[plan.dayKey] = plan;
    return const Result.success(null);
  }

  @override
  ResultFuture<void> savePlans(List<DailyPlan> incoming) async {
    batchSaveCalls++;
    for (final plan in incoming) {
      plans[plan.dayKey] = plan;
    }
    return const Result.success(null);
  }

  @override
  ResultFuture<List<DailyPlan>> getRange(DayKey from, DayKey to) async {
    rangeCalls++;
    final failure = rangeFailure;
    final gate = _rangeGate;
    if (gate != null && !gate.isCompleted) {
      await gate.future;
    }
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

  @override
  Future<bool> isCompleted() async => stored != null;

  @override
  ResultFuture<OnboardingPreferences?> load() async => Result.success(stored);

  @override
  ResultFuture<void> saveCompleted(OnboardingPreferences preferences) async {
    stored = preferences;
    return const Result.success(null);
  }
}
