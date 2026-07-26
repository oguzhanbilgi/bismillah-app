import 'dart:convert';

import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/settings/data/shared_prefs_local_data_reset_repository.dart';
import 'package:bismillah_app/features/today/data/shared_prefs_daily_plan_repository.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Günlük plan yerel deposu (TASK 076): kanonik gün-başına sözleşmenin
/// geçici SharedPreferences implementasyonu.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const key = SharedPrefsDailyPlanRepository.storageKey;

  DayKey day(String value) => DayKey(value);

  PlanItem item(
    String id, {
    PlanItemType type = PlanItemType.quran,
    PlanItemStatus status = PlanItemStatus.pending,
    String? targetRef,
    int? sizeParam,
    UtcDateTime? completedAt,
  }) => PlanItem(
    itemId: EntityId(id),
    type: type,
    status: status,
    targetRef: targetRef,
    sizeParam: sizeParam,
    completedAt: completedAt,
  );

  DailyPlan plan(
    String dayValue, {
    List<PlanItem>? items,
    String profileType = 'reconnect',
    int sizeMinutes = 20,
    int weekIndex = 0,
    String generatedBy = 'rule-engine-v1',
  }) => DailyPlan(
    dayKey: day(dayValue),
    items: items ?? [item('item-1')],
    profileType: profileType,
    sizeMinutes: sizeMinutes,
    weekIndex: weekIndex,
    generatedBy: generatedBy,
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('getPlan', () {
    test('depo boşken plan yok döner (hata değil)', () async {
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);

      final result = await repo.getPlan(day('2026-07-26'));

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isNull);
    });

    test('kaydedilen gün aynen okunur', () async {
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);
      final saved = plan(
        '2026-07-26',
        sizeMinutes: 35,
        weekIndex: 2,
        items: [item('a', targetRef: 'surah-2', sizeParam: 5)],
      );

      await repo.savePlan(saved);
      final loaded = (await repo.getPlan(day('2026-07-26'))).valueOrNull!;

      expect(loaded.dayKey, saved.dayKey);
      expect(loaded.sizeMinutes, 35);
      expect(loaded.weekIndex, 2);
      expect(loaded.items.single.targetRef, 'surah-2');
    });

    test('istenmeyen başka bir günü ASLA döndürmez', () async {
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);

      await repo.savePlan(plan('2026-07-26'));
      final other = await repo.getPlan(day('2026-07-27'));

      expect(other.valueOrNull, isNull);
    });

    test('zarf bozuksa tipli hata döner (çökme yok)', () async {
      SharedPreferences.setMockInitialValues({key: '{bozuk'});
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);

      final result = await repo.getPlan(day('2026-07-26'));

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<StorageFailure>());
    });

    test('desteklenmeyen sürüm tipli hata döner', () async {
      SharedPreferences.setMockInitialValues({
        key: json.encode({'v': 99, 'plans': <String, Object?>{}}),
      });
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);

      final result = await repo.getPlan(day('2026-07-26'));

      expect(result.failureOrNull, isA<StorageFailure>());
    });

    test('anahtar String değilse tipli hata döner', () async {
      SharedPreferences.setMockInitialValues({key: 42});
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);

      expect((await repo.getPlan(day('2026-07-26'))).isFailure, isTrue);
    });

    test('hata çıktısı ham yükü taşımaz', () async {
      const marker = 'surah-super-secret-marker';
      SharedPreferences.setMockInitialValues({key: '{"v":1,"x":"$marker"'});
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);

      final failure = (await repo.getPlan(day('2026-07-26'))).failureOrNull!;

      expect(failure.toString(), isNot(contains(marker)));
      expect(failure.messageKey, 'errorStorage');
    });
  });

  group('savePlan', () {
    test('ikinci günü eklemek ilk günü korur', () async {
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);

      await repo.savePlan(plan('2026-07-26', sizeMinutes: 10));
      await repo.savePlan(plan('2026-07-27', sizeMinutes: 20));

      expect(
        (await repo.getPlan(day('2026-07-26'))).valueOrNull!.sizeMinutes,
        10,
      );
      expect(
        (await repo.getPlan(day('2026-07-27'))).valueOrNull!.sizeMinutes,
        20,
      );
    });

    test('aynı DayKey yalnız o günü değiştirir', () async {
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);

      await repo.savePlan(plan('2026-07-26', sizeMinutes: 10));
      await repo.savePlan(plan('2026-07-27', sizeMinutes: 20));
      await repo.savePlan(plan('2026-07-26', sizeMinutes: 99));

      expect(
        (await repo.getPlan(day('2026-07-26'))).valueOrNull!.sizeMinutes,
        99,
      );
      expect(
        (await repo.getPlan(day('2026-07-27'))).valueOrNull!.sizeMinutes,
        20,
      );
    });

    test('tamamlanma durumu kalıcıdır', () async {
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);
      final completedAt = UtcDateTime(DateTime.utc(2026, 7, 26, 9));

      await repo.savePlan(
        plan(
          '2026-07-26',
          items: [
            item(
              'done',
              status: PlanItemStatus.completed,
              completedAt: completedAt,
            ),
          ],
        ),
      );

      final loaded = (await repo.getPlan(day('2026-07-26'))).valueOrNull!;
      expect(loaded.items.single.isCompleted, isTrue);
      expect(loaded.items.single.completedAt, completedAt);
    });

    test('bozuk depoyu SESSİZCE EZMEZ; tipli hata döner', () async {
      SharedPreferences.setMockInitialValues({key: '{bozuk'});
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);

      final result = await repo.savePlan(plan('2026-07-26'));

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<StorageFailure>());

      // Bozuk içerik yerinde durur — otomatik silme/yeniden üretim yok.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(key), '{bozuk');
    });

    test('ilgisiz tercih anahtarlarına dokunmaz', () async {
      SharedPreferences.setMockInitialValues({
        'bismillah.app_locale': 'tr',
        'bismillah.learn_completed_ids': <String>['a'],
      });
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);

      await repo.savePlan(plan('2026-07-26'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('bismillah.app_locale'), 'tr');
      expect(prefs.getStringList('bismillah.learn_completed_ids'), ['a']);
    });

    test(
      'tüm planlar TEK anahtarda tutulur (parçalı çok-anahtar yok)',
      () async {
        final repo = SharedPrefsDailyPlanRepository();
        addTearDown(repo.dispose);

        await repo.savePlan(plan('2026-07-26'));
        await repo.savePlan(plan('2026-07-27'));

        final prefs = await SharedPreferences.getInstance();
        final planKeys = prefs
            .getKeys()
            .where((k) => k.contains('daily_plan'))
            .toList();

        expect(planKeys, [key]);
      },
    );
  });

  group('getRange', () {
    Future<SharedPrefsDailyPlanRepository> seeded() async {
      final repo = SharedPrefsDailyPlanRepository();
      for (final value in [
        '2026-07-28',
        '2026-07-26',
        '2026-07-30',
        '2026-07-27',
      ]) {
        await repo.savePlan(plan(value));
      }
      return repo;
    }

    test('aralık deterministik DayKey sırasında döner', () async {
      final repo = await seeded();
      addTearDown(repo.dispose);

      final range = (await repo.getRange(
        day('2026-07-26'),
        day('2026-07-30'),
      )).valueOrNull!;

      expect(range.map((p) => p.dayKey.value).toList(), [
        '2026-07-26',
        '2026-07-27',
        '2026-07-28',
        '2026-07-30',
      ]);
    });

    test('aralık dışındaki günleri hariç tutar (iki uç dahil)', () async {
      final repo = await seeded();
      addTearDown(repo.dispose);

      final range = (await repo.getRange(
        day('2026-07-27'),
        day('2026-07-28'),
      )).valueOrNull!;

      expect(range.map((p) => p.dayKey.value).toList(), [
        '2026-07-27',
        '2026-07-28',
      ]);
    });

    test('eşleşme yoksa boş liste döner', () async {
      final repo = await seeded();
      addTearDown(repo.dispose);

      final range = (await repo.getRange(
        day('2026-08-01'),
        day('2026-08-10'),
      )).valueOrNull!;

      expect(range, isEmpty);
    });

    test('ters aralık tipli hata döner', () async {
      final repo = await seeded();
      addTearDown(repo.dispose);

      final result = await repo.getRange(day('2026-07-30'), day('2026-07-26'));

      expect(result.failureOrNull, isA<StorageFailure>());
    });

    test('bozuk zarf tipli hata döner', () async {
      SharedPreferences.setMockInitialValues({key: '{bozuk'});
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);

      final result = await repo.getRange(day('2026-07-26'), day('2026-07-30'));

      expect(result.failureOrNull, isA<StorageFailure>());
    });

    test('30 günlük çatı 30 ayrı günden okunur', () async {
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);
      for (var d = 1; d <= 30; d++) {
        final value = '2026-07-${d.toString().padLeft(2, '0')}';
        await repo.savePlan(plan(value, weekIndex: (d - 1) ~/ 7));
      }

      final range = (await repo.getRange(
        day('2026-07-01'),
        day('2026-07-30'),
      )).valueOrNull!;

      expect(range.length, 30);
      expect(range.first.weekIndex, 0);
      expect(range.last.weekIndex, 4);
    });
  });

  group('yeniden oluşturma kalıcılığı', () {
    test('yeni repository örneği önceki planları okur', () async {
      // Not: bu, adaptör yeniden oluşturma kanıtıdır — gerçek OS
      // process ölümü testi DEĞİLDİR.
      final repoA = SharedPrefsDailyPlanRepository();
      await repoA.savePlan(plan('2026-07-26', sizeMinutes: 11));
      await repoA.savePlan(plan('2026-07-27', sizeMinutes: 22));
      await repoA.dispose();

      final repoB = SharedPrefsDailyPlanRepository();
      addTearDown(repoB.dispose);

      final range = (await repoB.getRange(
        day('2026-07-26'),
        day('2026-07-27'),
      )).valueOrNull!;

      expect(range.map((p) => p.sizeMinutes).toList(), [11, 22]);
    });
  });

  group('watchPlan', () {
    test(
      'abone olurken mevcut değeri YAYINLAMAZ (belgelenmiş sözleşme)',
      () async {
        final repo = SharedPrefsDailyPlanRepository();
        addTearDown(repo.dispose);
        await repo.savePlan(plan('2026-07-26'));

        final emissions = <DailyPlan?>[];
        final sub = repo.watchPlan(day('2026-07-26')).listen(emissions.add);
        addTearDown(sub.cancel);
        await Future<void>.delayed(Duration.zero);

        expect(emissions, isEmpty);
      },
    );

    test('izlenen gün kaydedilince yayar', () async {
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);

      final emissions = <DailyPlan?>[];
      final sub = repo.watchPlan(day('2026-07-26')).listen(emissions.add);
      addTearDown(sub.cancel);

      await repo.savePlan(plan('2026-07-26', sizeMinutes: 15));
      await Future<void>.delayed(Duration.zero);

      expect(emissions.single!.sizeMinutes, 15);
    });

    test('değiştirme güncel değeri yayar', () async {
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);

      final emissions = <DailyPlan?>[];
      final sub = repo.watchPlan(day('2026-07-26')).listen(emissions.add);
      addTearDown(sub.cancel);

      await repo.savePlan(plan('2026-07-26', sizeMinutes: 10));
      await repo.savePlan(plan('2026-07-26', sizeMinutes: 40));
      await Future<void>.delayed(Duration.zero);

      expect(emissions.map((p) => p!.sizeMinutes).toList(), [10, 40]);
    });

    test('başka gün izlenen akışa SIZMAZ', () async {
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);

      final emissions = <DailyPlan?>[];
      final sub = repo.watchPlan(day('2026-07-26')).listen(emissions.add);
      addTearDown(sub.cancel);

      await repo.savePlan(plan('2026-07-27'));
      await Future<void>.delayed(Duration.zero);

      expect(emissions, isEmpty);
    });

    test('çok dinleyici aynı yayını alır', () async {
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);

      final first = <DailyPlan?>[];
      final second = <DailyPlan?>[];
      final subA = repo.watchPlan(day('2026-07-26')).listen(first.add);
      final subB = repo.watchPlan(day('2026-07-26')).listen(second.add);
      addTearDown(subA.cancel);
      addTearDown(subB.cancel);

      await repo.savePlan(plan('2026-07-26', sizeMinutes: 7));
      await Future<void>.delayed(Duration.zero);

      expect(first.single!.sizeMinutes, 7);
      expect(second.single!.sizeMinutes, 7);
    });

    test('iptal sonrası kayıt güvenlidir', () async {
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);

      final emissions = <DailyPlan?>[];
      final sub = repo.watchPlan(day('2026-07-26')).listen(emissions.add);
      await sub.cancel();

      final result = await repo.savePlan(plan('2026-07-26'));
      await Future<void>.delayed(Duration.zero);

      expect(result.isSuccess, isTrue);
      expect(emissions, isEmpty);
    });

    test('dispose iki kez çağrılabilir ve akışı kapatır', () async {
      final repo = SharedPrefsDailyPlanRepository();
      await repo.dispose();
      await repo.dispose();

      expect(repo.watchPlan(day('2026-07-26')), emitsDone);
    });

    test('bozuk depo kaydı yayın üretmez (kayıt hatası)', () async {
      SharedPreferences.setMockInitialValues({key: '{bozuk'});
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);

      final emissions = <DailyPlan?>[];
      final sub = repo.watchPlan(day('2026-07-26')).listen(emissions.add);
      addTearDown(sub.cancel);

      final result = await repo.savePlan(plan('2026-07-26'));
      await Future<void>.delayed(Duration.zero);

      expect(result.isFailure, isTrue);
      expect(emissions, isEmpty);
    });
  });

  group('yerel sıfırlama', () {
    test('tam sıfırlama plan zarfını da siler', () async {
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);
      await repo.savePlan(plan('2026-07-26'));

      // Plan anahtarı `bismillah.` ailesindedir; mevcut sıfırlama akışı
      // ek bir liste güncellemesi GEREKTİRMEDEN onu kapsar.
      const reset = SharedPrefsLocalDataResetRepository();
      await reset.clearAllExceptLocale();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(key), isNull);
      expect((await repo.getPlan(day('2026-07-26'))).valueOrNull, isNull);
    });

    test('sıfırlama sonrası dil korunur', () async {
      SharedPreferences.setMockInitialValues({'bismillah.app_locale': 'tr'});
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);
      await repo.savePlan(plan('2026-07-26'));

      const reset = SharedPrefsLocalDataResetRepository();
      await reset.clearAllExceptLocale();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('bismillah.app_locale'), 'tr');
      expect(prefs.getString(key), isNull);
    });
  });

  group('gizlilik', () {
    test('kalıcı yük yalnız kanonik plan alanlarını içerir', () async {
      final repo = SharedPrefsDailyPlanRepository();
      addTearDown(repo.dispose);

      await repo.savePlan(
        plan(
          '2026-07-26',
          items: [item('a', targetRef: 'surah-2', sizeParam: 5)],
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(key)!;
      final envelope = json.decode(stored) as Map<String, Object?>;
      final storedPlan =
          (envelope['plans']! as Map<String, Object?>)['2026-07-26']!
              as Map<String, Object?>;

      expect(storedPlan.keys.toSet(), {
        'dayKey',
        'profileType',
        'sizeMinutes',
        'weekIndex',
        'generatedBy',
        'items',
      });
      // Kimlik/konum/bildirim/abonelik alanları ASLA yazılmaz.
      for (final forbidden in [
        'uid',
        'userId',
        'deviceId',
        'latitude',
        'longitude',
        'prayerTimes',
        'notification',
        'subscription',
        'entitlement',
        'analytics',
      ]) {
        expect(stored, isNot(contains(forbidden)));
      }
    });

    test('depolama anahtarı kimlik taşımaz', () {
      expect(key, 'bismillah.daily_plans');
      expect(key, isNot(contains('uid')));
      expect(key, isNot(contains('device')));
    });
  });
}
