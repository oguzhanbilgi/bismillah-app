import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_generator.dart';
import 'package:bismillah_app/features/today/domain/value_objects/missed_day_recovery.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';
import 'package:flutter_test/flutter_test.dart';

/// Kaçırılmış gün hesabı (TASK 084) — saf, kalıcılıksız, seri (streak)
/// modeli DEĞİL.
void main() {
  final today = DayKey('2026-07-27');

  DayKey back(int days) => DailyPlanGenerator.dayAt(today, -days);

  PlanItem item(String id, {bool completed = false}) => PlanItem(
    itemId: EntityId(id),
    type: PlanItemType.prayer,
    status: completed ? PlanItemStatus.completed : PlanItemStatus.pending,
    completedAt: completed ? UtcDateTime(DateTime.utc(2026, 7, 20)) : null,
  );

  DailyPlan plan(DayKey dayKey, {int itemCount = 2, int completedCount = 0}) =>
      DailyPlan(
        dayKey: dayKey,
        items: [
          for (var i = 0; i < itemCount; i++)
            item('${dayKey.value}-$i', completed: i < completedCount),
        ],
        profileType: 'beginner',
        sizeMinutes: 10,
        weekIndex: 0,
        generatedBy: 'rule-engine-v1',
      );

  MissedDayRecovery evaluate(List<DailyPlan> plans) =>
      MissedDayCalculator.evaluate(previousPlans: plans, today: today);

  group('kaçırılmış gün tanımı', () {
    test('geçmiş plan yoksa kaçırılmış gün iddiası YOKTUR', () {
      expect(evaluate(const []), MissedDayRecovery.none);
      expect(evaluate(const []).hasMissedDays, isFalse);
    });

    test('tamamen bekleyen önceki gün kaçırılmıştır', () {
      expect(evaluate([plan(back(1))]).consecutiveMissedDays, 1);
    });

    test('kısmen tamamlanmış önceki gün kaçırılmış SAYILMAZ', () {
      expect(
        evaluate([plan(back(1), completedCount: 1)]),
        MissedDayRecovery.none,
      );
    });

    test('tamamen tamamlanmış önceki gün kaçırılmış SAYILMAZ', () {
      expect(
        evaluate([plan(back(1), itemCount: 2, completedCount: 2)]),
        MissedDayRecovery.none,
      );
    });

    test('boş plan kullanıcı kusuru DEĞİLDİR', () {
      expect(evaluate([plan(back(1), itemCount: 0)]), MissedDayRecovery.none);
    });

    test('kayıt bulunmayan gün kaçırılmış SAYILMAZ', () {
      // Dünün kaydı yok, önceki gün bekliyor → zincir dünde kopar.
      expect(evaluate([plan(back(2))]), MissedDayRecovery.none);
    });

    test('bugünün kendisi ASLA sayılmaz', () {
      expect(evaluate([plan(today)]), MissedDayRecovery.none);
    });

    test('gelecek günler yok sayılır', () {
      expect(
        evaluate([plan(DailyPlanGenerator.dayAt(today, 3))]),
        MissedDayRecovery.none,
      );
    });

    test('bugün bekliyor olsa bile geçmiş sayımı etkilenmez', () {
      final result = evaluate([plan(today), plan(back(1)), plan(back(2))]);
      expect(result.consecutiveMissedDays, 2);
    });
  });

  group('kesintisiz sayım', () {
    final cases = <String, (int, int)>{
      'tek gün': (1, 1),
      'iki gün': (2, 2),
      'üç gün': (3, 3),
      'yedi gün': (7, 7),
      'otuz gün': (30, 30),
    };

    for (final entry in cases.entries) {
      test('${entry.key} kesintisiz kaçırılmış', () {
        final (seeded, expected) = entry.value;
        final plans = [for (var d = 1; d <= seeded; d++) plan(back(d))];
        expect(evaluate(plans).consecutiveMissedDays, expected);
      });
    }

    test('araya giren tamamlanmış gün zinciri KESER', () {
      final plans = [
        plan(back(1)),
        plan(back(2)),
        plan(back(3), completedCount: 1),
        plan(back(4)),
        plan(back(5)),
      ];
      expect(evaluate(plans).consecutiveMissedDays, 2);
    });

    test('araya giren eksik kayıt zinciri KESER', () {
      final plans = [plan(back(1)), plan(back(2)), plan(back(4))];
      expect(evaluate(plans).consecutiveMissedDays, 2);
    });

    test('geriye bakış 30 günle sınırlıdır', () {
      expect(MissedDayCalculator.lookbackDays, 30);
      final plans = [for (var d = 1; d <= 40; d++) plan(back(d))];
      expect(evaluate(plans).consecutiveMissedDays, 30);
    });

    test('giriş sırası sonucu DEĞİŞTİRMEZ', () {
      final ascending = [plan(back(1)), plan(back(2)), plan(back(3))];
      final descending = ascending.reversed.toList();
      expect(evaluate(ascending), evaluate(descending));
    });

    test('tekrarlı çağrı aynı sonucu verir (saf)', () {
      final plans = [plan(back(1)), plan(back(2))];
      final baseline = evaluate(plans);
      for (var i = 0; i < 20; i++) {
        expect(evaluate(plans), baseline);
      }
    });
  });

  group('uzun ara eşiği', () {
    final cases = <int, bool>{0: false, 1: false, 2: false, 3: true, 9: true};

    for (final entry in cases.entries) {
      test('${entry.key} gün → uzun ara = ${entry.value}', () {
        expect(
          MissedDayRecovery(consecutiveMissedDays: entry.key).isExtendedAbsence,
          entry.value,
        );
      });
    }

    test('eşik üçtür', () {
      expect(MissedDayRecovery.extendedAbsenceThreshold, 3);
    });
  });

  group('değer nesnesi', () {
    test('none sıfır gündür', () {
      expect(MissedDayRecovery.none.consecutiveMissedDays, 0);
      expect(MissedDayRecovery.none.hasMissedDays, isFalse);
    });

    test('eşit gün sayısı eşit değerdir', () {
      expect(
        const MissedDayRecovery(consecutiveMissedDays: 4),
        const MissedDayRecovery(consecutiveMissedDays: 4),
      );
    });

    test('negatif gün sayısı reddedilir', () {
      expect(
        () => MissedDayRecovery(consecutiveMissedDays: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('metin gösterimi kullanıcı verisi taşımaz', () {
      final rendered = const MissedDayRecovery(
        consecutiveMissedDays: 3,
      ).toString();
      for (final forbidden in ['2026-', 'uid', 'streak', 'seri', 'prayer_']) {
        expect(rendered, isNot(contains(forbidden)));
      }
    });
  });

  group('geçmiş bütünlüğü', () {
    test('hesap hiçbir planı DEĞİŞTİRMEZ', () {
      final plans = [plan(back(1)), plan(back(2), completedCount: 1)];
      final before = [
        for (final p in plans)
          '${p.dayKey.value}|${p.completedCount}|${p.items.length}|'
              '${p.generatedBy}|${p.profileType}',
      ];

      evaluate(plans);

      final after = [
        for (final p in plans)
          '${p.dayKey.value}|${p.completedCount}|${p.items.length}|'
              '${p.generatedBy}|${p.profileType}',
      ];
      expect(after, before);
      expect(plans[1].items.first.completedAt, isNotNull);
    });
  });
}
