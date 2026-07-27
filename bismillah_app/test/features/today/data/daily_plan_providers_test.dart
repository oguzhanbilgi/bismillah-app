import 'package:bismillah_app/app/app_bootstrap.dart';
import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/today/data/shared_prefs_daily_plan_repository.dart';
import 'package:bismillah_app/features/today/data/today_data_providers.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/repositories/daily_plan_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/test_database.dart';
import '../../../helpers/test_session.dart';

/// Günlük plan DI bağlaması (TASK 076): üretim implementasyonu çözülür,
/// test sahtesi enjekte edilebilir ve bootstrap planı OKUMAZ/ÜRETMEZ.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('üretim provider\'ı SharedPreferences adaptörünü çözer', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final repo = container.read(dailyPlanRepositoryProvider);

    expect(repo, isA<SharedPrefsDailyPlanRepository>());
    expect(repo, isA<DailyPlanRepository>());
  });

  test('provider tek örnek döndürür', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      identical(
        container.read(dailyPlanRepositoryProvider),
        container.read(dailyPlanRepositoryProvider),
      ),
      isTrue,
    );
  });

  test('test sahtesi override ile enjekte edilebilir', () {
    final fake = _RecordingDailyPlanRepository();
    final container = ProviderContainer(
      overrides: [dailyPlanRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    expect(container.read(dailyPlanRepositoryProvider), same(fake));
  });

  test('container dispose edilince akış kapatılır (sızıntı yok)', () async {
    final container = ProviderContainer();
    final repo =
        container.read(dailyPlanRepositoryProvider)
            as SharedPrefsDailyPlanRepository;

    container.dispose();
    await Future<void>.delayed(Duration.zero);

    expect(repo.watchPlan(DayKey('2026-07-26')), emitsDone);
  });

  test('bootstrap plan OKUMAZ, YAZMAZ ve ÜRETMEZ', () async {
    final fake = _RecordingDailyPlanRepository();
    final container = ProviderContainer(
      overrides: [
        inMemoryAppDatabaseOverride(),
        ...testSessionOverrides(),
        dailyPlanRepositoryProvider.overrideWithValue(fake),
      ],
    );
    addTearDown(container.dispose);

    await initializeLocalPersistence(container);

    expect(fake.getPlanCalls, 0);
    expect(fake.savePlanCalls, 0);
    // TASK 083A: toplu yazma da bootstrap'tan tetiklenmez — ilk plan
    // kurulumu açık bir çağrı gerektirir.
    expect(fake.savePlansCalls, 0);
    expect(fake.getRangeCalls, 0);
    expect(fake.watchPlanCalls, 0);
  });
}

/// Çağrıları sayan sahte depo — bootstrap'ın plana dokunmadığını kanıtlar.
final class _RecordingDailyPlanRepository implements DailyPlanRepository {
  int getPlanCalls = 0;
  int savePlanCalls = 0;
  int savePlansCalls = 0;
  int getRangeCalls = 0;
  int watchPlanCalls = 0;

  @override
  ResultFuture<DailyPlan?> getPlan(DayKey dayKey) async {
    getPlanCalls++;
    return const Result.success(null);
  }

  @override
  ResultFuture<void> savePlan(DailyPlan plan) async {
    savePlanCalls++;
    return const Result.success(null);
  }

  @override
  ResultFuture<void> savePlans(List<DailyPlan> plans) async {
    savePlansCalls++;
    return const Result.success(null);
  }

  @override
  ResultFuture<List<DailyPlan>> getRange(DayKey from, DayKey to) async {
    getRangeCalls++;
    return const Result.success(<DailyPlan>[]);
  }

  @override
  Stream<DailyPlan?> watchPlan(DayKey dayKey) {
    watchPlanCalls++;
    return const Stream<DailyPlan?>.empty();
  }
}
