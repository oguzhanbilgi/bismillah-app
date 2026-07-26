import 'dart:async';
import 'dart:collection';

import 'package:bismillah_app/app/app_bootstrap.dart';
import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/features/today/application/daily_plan_controller.dart';
import 'package:bismillah_app/features/today/application/daily_plan_state.dart';
import 'package:bismillah_app/features/today/data/shared_prefs_daily_plan_repository.dart';
import 'package:bismillah_app/features/today/data/today_data_providers.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/repositories/daily_plan_repository.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';
import '../../../helpers/test_session.dart';

/// Günlük plan durum makinesi (TASK 077): yükleme, izleme, tazeleme,
/// kaydetme; bayat sonuç koruması ve tipli hata eşlemesi.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final dayA = DayKey('2026-07-26');
  final dayB = DayKey('2026-07-27');

  DailyPlan planFor(DayKey dayKey, {int sizeMinutes = 20}) => DailyPlan(
    dayKey: dayKey,
    items: [
      PlanItem(
        itemId: EntityId('item-1'),
        type: PlanItemType.quran,
        status: PlanItemStatus.pending,
      ),
    ],
    profileType: 'reconnect',
    sizeMinutes: sizeMinutes,
    weekIndex: 0,
    generatedBy: 'rule-engine-v1',
  );

  late _FakeDailyPlanRepository repo;

  /// Controller'ı sahte depo ile kurar.
  (ProviderContainer, DailyPlanController) build() {
    final container = ProviderContainer(
      overrides: [dailyPlanRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    return (container, container.read(dailyPlanControllerProvider.notifier));
  }

  DailyPlanState? readState(ProviderContainer c) =>
      c.read(dailyPlanControllerProvider);

  setUp(() => repo = _FakeDailyPlanRepository());

  group('ilk yükleme', () {
    test('başlangıç durumu: gün seçilmemiş (null)', () {
      final (container, controller) = build();

      expect(readState(container), isNull);
      expect(controller.selectedDay, isNull);
    });

    test('mevcut gün → loading → available', () async {
      repo.plans[dayA] = planFor(dayA, sizeMinutes: 33);
      final (container, controller) = build();
      repo.holdNextGet();

      final pending = controller.loadDay(dayA);
      // Yükleme durumu SENKRON görünür (ilk await beklenmeden).
      expect(readState(container), isA<DailyPlanLoading>());
      expect(readState(container)!.dayKey, dayA);

      await _settle(); // okuma kapıya ulaşsın
      repo.releaseGet();
      await pending;

      final state = readState(container)! as DailyPlanAvailable;
      expect(state.plan.sizeMinutes, 33);
      expect(state.dayKey, dayA);
      expect(state.isSaving, isFalse);
    });

    test('plan yok → loading → empty', () async {
      final (container, controller) = build();
      repo.holdNextGet();

      final pending = controller.loadDay(dayA);
      expect(readState(container), isA<DailyPlanLoading>());

      await _settle();
      repo.releaseGet();
      await pending;

      expect(readState(container), isA<DailyPlanEmpty>());
      expect(readState(container)!.dayKey, dayA);
    });

    test('bozuk depo → corrupt', () async {
      repo.getFailure = const StorageCorruptionFailure();
      final (container, controller) = build();

      await controller.loadDay(dayA);

      final state = readState(container)! as DailyPlanCorrupt;
      expect(state.dayKey, dayA);
      expect(state.canRetry, isFalse);
    });

    test('sıradan okuma hatası → failure', () async {
      repo.getFailure = const StorageFailure();
      final (container, controller) = build();

      await controller.loadDay(dayA);

      final state = readState(container)! as DailyPlanFailure;
      expect(state.dayKey, dayA);
      expect(state.canRetry, isTrue);
    });

    test('diğer AppFailure türleri de failure durumuna eşlenir', () async {
      repo.getFailure = const UnexpectedFailure();
      final (container, controller) = build();

      await controller.loadDay(dayA);

      expect(readState(container), isA<DailyPlanFailure>());
    });

    test('her terminal durum istenen günü korur', () async {
      for (final failure in <AppFailure?>[
        null,
        const StorageFailure(),
        const StorageCorruptionFailure(),
      ]) {
        repo = _FakeDailyPlanRepository()..getFailure = failure;
        final (container, controller) = build();
        await controller.loadDay(dayB);
        expect(readState(container)!.dayKey, dayB);
      }
    });
  });

  group('tazeleme', () {
    test('available günü tazeler ve yeni değeri alır', () async {
      repo.plans[dayA] = planFor(dayA, sizeMinutes: 10);
      final (container, controller) = build();
      await controller.loadDay(dayA);

      repo.plans[dayA] = planFor(dayA, sizeMinutes: 55);
      await controller.refresh();

      expect(
        (readState(container)! as DailyPlanAvailable).plan.sizeMinutes,
        55,
      );
    });

    test('boş gün tazelenince plan ÜRETİLMEZ', () async {
      final (container, controller) = build();
      await controller.loadDay(dayA);

      await controller.refresh();

      expect(readState(container), isA<DailyPlanEmpty>());
      expect(repo.saveCalls, 0);
    });

    test('hatadan sonra tazeleme başarıyla toparlar', () async {
      repo.getFailure = const StorageFailure();
      final (container, controller) = build();
      await controller.loadDay(dayA);
      expect(readState(container), isA<DailyPlanFailure>());

      repo
        ..getFailure = null
        ..plans[dayA] = planFor(dayA);
      await controller.refresh();

      expect(readState(container), isA<DailyPlanAvailable>());
    });

    test('bozulmadan sonra tazeleme aynı sonucu verir', () async {
      repo.getFailure = const StorageCorruptionFailure();
      final (container, controller) = build();
      await controller.loadDay(dayA);

      await controller.refresh();

      expect(readState(container), isA<DailyPlanCorrupt>());
    });

    test('gün seçilmemişken tazeleme güvenli no-op', () async {
      final (container, controller) = build();

      await controller.refresh();

      expect(readState(container), isNull);
      expect(repo.getCalls, 0);
    });

    test('tazeleme seçili günü DEĞİŞTİRMEZ', () async {
      repo.plans[dayA] = planFor(dayA);
      final (_, controller) = build();
      await controller.loadDay(dayA);

      await controller.refresh();

      expect(controller.selectedDay, dayA);
    });
  });

  group('gün değiştirme', () {
    test('A sonra B: B aktif kalır', () async {
      repo
        ..plans[dayA] = planFor(dayA, sizeMinutes: 10)
        ..plans[dayB] = planFor(dayB, sizeMinutes: 20);
      final (container, controller) = build();

      await controller.loadDay(dayA);
      await controller.loadDay(dayB);

      final state = readState(container)! as DailyPlanAvailable;
      expect(state.dayKey, dayB);
      expect(state.plan.sizeMinutes, 20);
    });

    test('önceki abonelik iptal edilir (tek aktif watch)', () async {
      final (_, controller) = build();

      await controller.loadDay(dayA);
      expect(repo.cancelledWatches, 0);

      await controller.loadDay(dayB);

      expect(repo.cancelledWatches, 1);
      expect(repo.watchCalls, 2);
    });

    test('geç dönen A okuması B durumunu EZMEZ', () async {
      repo
        ..plans[dayA] = planFor(dayA, sizeMinutes: 10)
        ..plans[dayB] = planFor(dayB, sizeMinutes: 20);
      final (container, controller) = build();

      repo.holdNextGet();
      final pendingA = controller.loadDay(dayA);
      await _settle(); // A okuması kapıda beklesin
      await controller.loadDay(dayB);
      expect((readState(container)! as DailyPlanAvailable).dayKey, dayB);

      repo.releaseGet();
      await pendingA;

      final state = readState(container)! as DailyPlanAvailable;
      expect(state.dayKey, dayB);
      expect(state.plan.sizeMinutes, 20);
    });

    test('eski günün watch olayı aktif günü ETKİLEMEZ', () async {
      repo.plans[dayB] = planFor(dayB, sizeMinutes: 20);
      final (container, controller) = build();
      await controller.loadDay(dayA);
      await controller.loadDay(dayB);

      repo.emit(dayA, planFor(dayA, sizeMinutes: 99));
      await _settle();

      final state = readState(container)! as DailyPlanAvailable;
      expect(state.dayKey, dayB);
      expect(state.plan.sizeMinutes, 20);
    });

    test('aynı gün tekrar seçilirse yeniden okunur', () async {
      repo.plans[dayA] = planFor(dayA);
      final (_, controller) = build();

      await controller.loadDay(dayA);
      await controller.loadDay(dayA);

      expect(repo.getCalls, 2);
      expect(repo.cancelledWatches, 1);
    });
  });

  group('repository watch', () {
    test('aktif gün kaydı available durumu yayar', () async {
      final (container, controller) = build();
      await controller.loadDay(dayA);
      expect(readState(container), isA<DailyPlanEmpty>());

      repo.emit(dayA, planFor(dayA, sizeMinutes: 44));
      await _settle();

      expect(
        (readState(container)! as DailyPlanAvailable).plan.sizeMinutes,
        44,
      );
    });

    test('null yayını empty durumuna eşlenir', () async {
      repo.plans[dayA] = planFor(dayA);
      final (container, controller) = build();
      await controller.loadDay(dayA);

      repo.emit(dayA, null);
      await _settle();

      expect(readState(container), isA<DailyPlanEmpty>());
    });

    test('çok olayda en son değer korunur', () async {
      final (container, controller) = build();
      await controller.loadDay(dayA);

      repo
        ..emit(dayA, planFor(dayA, sizeMinutes: 1))
        ..emit(dayA, planFor(dayA, sizeMinutes: 2))
        ..emit(dayA, planFor(dayA, sizeMinutes: 3));
      await _settle();

      expect((readState(container)! as DailyPlanAvailable).plan.sizeMinutes, 3);
    });

    test('watch hatası son bilinen durumu DEVİRMEZ', () async {
      repo.plans[dayA] = planFor(dayA, sizeMinutes: 7);
      final (container, controller) = build();
      await controller.loadDay(dayA);

      repo.emitError(dayA, Exception('akış hatası'));
      await _settle();

      expect((readState(container)! as DailyPlanAvailable).plan.sizeMinutes, 7);
    });

    test('tek yükleme tek abonelik oluşturur', () async {
      final (_, controller) = build();

      await controller.loadDay(dayA);

      expect(repo.watchCalls, 1);
    });

    test('container dispose aboneliği kapatır', () async {
      final container = ProviderContainer(
        overrides: [dailyPlanRepositoryProvider.overrideWithValue(repo)],
      );
      final controller = container.read(dailyPlanControllerProvider.notifier);
      await controller.loadDay(dayA);

      container.dispose();
      await _settle();

      expect(repo.cancelledWatches, 1);
    });
  });

  group('kaydetme', () {
    test('geçerli plan kaydedilir ve available döner', () async {
      final (container, controller) = build();
      await controller.loadDay(dayA);

      await controller.savePlan(planFor(dayA, sizeMinutes: 25));

      expect(repo.saveCalls, 1);
      final state = readState(container)! as DailyPlanAvailable;
      expect(state.plan.sizeMinutes, 25);
      expect(state.isSaving, isFalse);
    });

    test('kaydetme sırasında isSaving açılır, plan gösterimde kalır', () async {
      repo.plans[dayA] = planFor(dayA, sizeMinutes: 10);
      final (container, controller) = build();
      await controller.loadDay(dayA);

      repo.holdNextSave();
      final pending = controller.savePlan(planFor(dayA, sizeMinutes: 60));

      final saving = readState(container)! as DailyPlanAvailable;
      expect(saving.isSaving, isTrue);
      expect(saving.plan.sizeMinutes, 10, reason: 'ekran zıplamaz');

      repo.releaseSave();
      await pending;

      final done = readState(container)! as DailyPlanAvailable;
      expect(done.isSaving, isFalse);
      expect(done.plan.sizeMinutes, 60);
    });

    test('yazma hatası güvenli failure durumu verir', () async {
      final (container, controller) = build();
      await controller.loadDay(dayA);

      repo.saveFailure = const StorageFailure();
      await controller.savePlan(planFor(dayA));

      expect(readState(container), isA<DailyPlanFailure>());
      expect(readState(container)!.dayKey, dayA);
    });

    test('bozuk depoya kaydetme corrupt durumu verir', () async {
      final (container, controller) = build();
      await controller.loadDay(dayA);

      repo.saveFailure = const StorageCorruptionFailure();
      await controller.savePlan(planFor(dayA));

      expect(readState(container), isA<DailyPlanCorrupt>());
    });

    test('başka güne ait plan REDDEDİLİR', () async {
      repo.plans[dayA] = planFor(dayA, sizeMinutes: 10);
      final (container, controller) = build();
      await controller.loadDay(dayA);

      await controller.savePlan(planFor(dayB, sizeMinutes: 99));

      expect(repo.saveCalls, 0);
      final state = readState(container)! as DailyPlanAvailable;
      expect(state.dayKey, dayA);
      expect(state.plan.sizeMinutes, 10);
    });

    test('gün seçilmemişken kaydetme reddedilir', () async {
      final (container, controller) = build();

      await controller.savePlan(planFor(dayA));

      expect(repo.saveCalls, 0);
      expect(readState(container), isNull);
    });

    test(
      'kaydetme plan ÜRETMEZ; yalnız repository savePlan çağrılır',
      () async {
        final (_, controller) = build();
        await controller.loadDay(dayA);

        await controller.savePlan(planFor(dayA));

        expect(repo.saveCalls, 1);
        expect(repo.rangeCalls, 0);
      },
    );

    test('dispose sonrası kaydetme hiçbir şey yayınlamaz', () async {
      final container = ProviderContainer(
        overrides: [dailyPlanRepositoryProvider.overrideWithValue(repo)],
      );
      final controller = container.read(dailyPlanControllerProvider.notifier);
      await controller.loadDay(dayA);
      container.dispose();

      await controller.savePlan(planFor(dayA));

      expect(repo.saveCalls, 0);
    });
  });

  group('yarış koşulları', () {
    test('daha yeni watch olayı daha eski get sonucunu YENER', () async {
      repo.plans[dayA] = planFor(dayA, sizeMinutes: 1);
      final (container, controller) = build();

      repo.holdNextGet();
      final pending = controller.loadDay(dayA);
      await _settle(); // abonelik kurulsun, okuma kapıda beklesin

      // Abonelik kurulduktan sonra daha yeni bir kayıt gelir.
      repo.emit(dayA, planFor(dayA, sizeMinutes: 99));
      await _settle();
      expect(
        (readState(container)! as DailyPlanAvailable).plan.sizeMinutes,
        99,
      );

      // Eski okuma şimdi tamamlanır — daha yeni durumu EZMEMELİ.
      repo.releaseGet();
      await pending;

      expect(
        (readState(container)! as DailyPlanAvailable).plan.sizeMinutes,
        99,
      );
    });

    test('daha yeni gün seçimi daha eski yükleme sonucunu YENER', () async {
      repo
        ..plans[dayA] = planFor(dayA, sizeMinutes: 1)
        ..plans[dayB] = planFor(dayB, sizeMinutes: 2);
      final (container, controller) = build();

      repo.holdNextGet();
      final pendingA = controller.loadDay(dayA);
      await _settle();
      await controller.loadDay(dayB);
      repo.releaseGet();
      await pendingA;

      expect(readState(container)!.dayKey, dayB);
    });

    test(
      'daha yeni kaydetme başarısı daha eski kaydetme hatasını YENER',
      () async {
        final (container, controller) = build();
        await controller.loadDay(dayA);

        repo
          ..saveFailure = const StorageFailure()
          ..holdNextSave();
        final failing = controller.savePlan(planFor(dayA, sizeMinutes: 1));

        repo.saveFailure = null;
        await controller.savePlan(planFor(dayA, sizeMinutes: 2));
        expect(
          (readState(container)! as DailyPlanAvailable).plan.sizeMinutes,
          2,
        );

        repo.releaseSave();
        await failing;

        final state = readState(container)! as DailyPlanAvailable;
        expect(
          state.plan.sizeMinutes,
          2,
          reason: 'eski hata yeni başarıyı ezemez',
        );
      },
    );

    test('kaydetme sürerken gün değişirse eski gün YAYINLANMAZ', () async {
      repo.plans[dayB] = planFor(dayB, sizeMinutes: 20);
      final (container, controller) = build();
      await controller.loadDay(dayA);

      repo.holdNextSave();
      final pendingSave = controller.savePlan(planFor(dayA, sizeMinutes: 5));
      await controller.loadDay(dayB);

      repo.releaseSave();
      await pendingSave;

      final state = readState(container)! as DailyPlanAvailable;
      expect(state.dayKey, dayB);
      expect(state.plan.sizeMinutes, 20);
    });

    test('hızlı çift kaydetmede en son geçerli sonuç kazanır', () async {
      final (container, controller) = build();
      await controller.loadDay(dayA);

      repo.holdNextSave();
      final first = controller.savePlan(planFor(dayA, sizeMinutes: 1));
      await controller.savePlan(planFor(dayA, sizeMinutes: 2));
      repo.releaseSave();
      await first;

      expect((readState(container)! as DailyPlanAvailable).plan.sizeMinutes, 2);
      expect(repo.saveCalls, 2);
    });

    test('tazeleme sonucu daha yeni watch durumunu EZEMEZ', () async {
      repo.plans[dayA] = planFor(dayA, sizeMinutes: 1);
      final (container, controller) = build();
      await controller.loadDay(dayA);

      repo.holdNextGet();
      final pending = controller.refresh();
      repo.emit(dayA, planFor(dayA, sizeMinutes: 77));
      await _settle();

      repo.releaseGet();
      await pending;

      expect(
        (readState(container)! as DailyPlanAvailable).plan.sizeMinutes,
        77,
      );
    });
  });

  group('provider ve yaşam döngüsü', () {
    test('üretim provider\'ı gerçek repository ile controller çözer', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(dailyPlanControllerProvider.notifier);

      expect(controller, isA<DailyPlanController>());
      expect(
        container.read(dailyPlanRepositoryProvider),
        isA<SharedPrefsDailyPlanRepository>(),
      );
      expect(container.read(dailyPlanControllerProvider), isNull);
    });

    test('repository override edilebilir', () async {
      final (_, controller) = build();

      await controller.loadDay(dayA);

      expect(repo.getCalls, 1);
    });

    test('bootstrap controller\'ı kurmaz ve plan okumaz', () async {
      final container = ProviderContainer(
        overrides: [
          inMemoryAppDatabaseOverride(),
          ...testSessionOverrides(),
          dailyPlanRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await initializeLocalPersistence(container);

      expect(repo.getCalls, 0);
      expect(repo.watchCalls, 0);
      expect(repo.saveCalls, 0);
      expect(repo.rangeCalls, 0);
    });
  });

  group('gizlilik', () {
    test('durum nesneleri yalnız gün ve plan taşır', () async {
      repo.plans[dayA] = planFor(dayA);
      final (container, controller) = build();
      await controller.loadDay(dayA);

      final rendered = readState(container).toString();
      for (final forbidden in [
        'bismillah.daily_plans',
        'FormatException',
        'Exception',
        '#0',
        'uid',
        'latitude',
        'firebase',
      ]) {
        expect(rendered, isNot(contains(forbidden)));
      }
    });

    test('bozulma/hata durumları ham hata içeriği TAŞIMAZ', () async {
      const marker = 'super-secret-storage-detail';
      repo.getFailure = const StorageCorruptionFailure();
      final (container, controller) = build();
      await controller.loadDay(dayA);

      final state = readState(container)!;
      expect(state, isA<DailyPlanCorrupt>());
      expect(state.toString(), isNot(contains(marker)));
      // Durum tipinde hata nesnesi, messageKey veya istisna alanı YOKTUR.
      expect(state.toString(), isNot(contains('errorStorage')));
    });
  });
}

/// Mikro görev kuyruğunu boşaltır (akış olaylarının teslimi için).
Future<void> _settle() => Future<void>.delayed(Duration.zero);

/// Denetlenebilir sahte depo: çağrı sayaçları, tipli hatalar ve
/// tamamlanmayı geciktirmek için kapılar (deterministik yarış testleri).
final class _FakeDailyPlanRepository implements DailyPlanRepository {
  final Map<DayKey, DailyPlan> plans = {};
  final Map<DayKey, StreamController<DailyPlan?>> _streams = {};

  /// Henüz bir çağrıya verilmemiş kapılar.
  final Queue<Completer<void>> _pendingGetGates = Queue();
  final Queue<Completer<void>> _pendingSaveGates = Queue();

  /// Bir çağrının beklediği kapılar (serbest bırakma sırası için).
  final List<Completer<void>> _issuedGetGates = [];
  final List<Completer<void>> _issuedSaveGates = [];

  AppFailure? getFailure;
  AppFailure? saveFailure;

  int getCalls = 0;
  int saveCalls = 0;
  int watchCalls = 0;
  int rangeCalls = 0;
  int cancelledWatches = 0;

  /// Bir sonraki `getPlan` çağrısını serbest bırakılana kadar askıya alır.
  /// Sonraki çağrılar etkilenmez — yalnız o tek çağrı gecikir.
  void holdNextGet() => _pendingGetGates.add(Completer<void>());

  void releaseGet() =>
      _issuedGetGates.firstWhere((gate) => !gate.isCompleted).complete();

  void holdNextSave() => _pendingSaveGates.add(Completer<void>());

  void releaseSave() =>
      _issuedSaveGates.firstWhere((gate) => !gate.isCompleted).complete();

  Completer<void>? _takeGate(
    Queue<Completer<void>> pending,
    List<Completer<void>> issued,
  ) {
    if (pending.isEmpty) {
      return null;
    }
    final gate = pending.removeFirst();
    issued.add(gate);
    return gate;
  }

  StreamController<DailyPlan?> _streamFor(DayKey dayKey) =>
      _streams.putIfAbsent(
        dayKey,
        () => StreamController<DailyPlan?>.broadcast(
          onCancel: () => cancelledWatches++,
        ),
      );

  void emit(DayKey dayKey, DailyPlan? plan) => _streamFor(dayKey).add(plan);

  void emitError(DayKey dayKey, Object error) =>
      _streamFor(dayKey).addError(error);

  @override
  Stream<DailyPlan?> watchPlan(DayKey dayKey) {
    watchCalls++;
    return _streamFor(dayKey).stream;
  }

  @override
  ResultFuture<DailyPlan?> getPlan(DayKey dayKey) async {
    getCalls++;
    // Hata ÇAĞRI ANINDA yakalanır: askıdayken yapılan yapılandırma
    // değişiklikleri bu çağrının sonucunu geriye dönük değiştirmez.
    final failure = getFailure;
    final gate = _takeGate(_pendingGetGates, _issuedGetGates);
    if (gate != null) {
      await gate.future;
    }
    if (failure != null) {
      return Result.failure(failure);
    }
    return Result.success(plans[dayKey]);
  }

  @override
  ResultFuture<void> savePlan(DailyPlan plan) async {
    saveCalls++;
    final failure = saveFailure;
    final gate = _takeGate(_pendingSaveGates, _issuedSaveGates);
    if (gate != null) {
      await gate.future;
    }
    if (failure != null) {
      return Result.failure(failure);
    }
    plans[plan.dayKey] = plan;
    return const Result.success(null);
  }

  @override
  ResultFuture<List<DailyPlan>> getRange(DayKey from, DayKey to) async {
    rangeCalls++;
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
