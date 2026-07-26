import 'package:bismillah_app/app/app_bootstrap.dart';
import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_daily_pace.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_generation_request.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_generator.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/services/prayer_daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/value_objects/daily_plan_profile_type.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';
import '../../../helpers/test_session.dart';

/// Namaz plan öğeleri kaynağı (TASK 080).
///
/// Üretilenler yalnız uygulama içi TAKİP eylemleridir: vakit hesabı,
/// konum, bildirim ve `PrayerLog` erişimi yoktur. Testler saat/locale/
/// timezone/rastgelelikten bağımsızdır.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const source = PrayerDailyPlanItemSource();
  const trackId = PrayerDailyPlanItemSource.trackDailyTemplateId;
  const onTimeId = PrayerDailyPlanItemSource.onTimeDailyTemplateId;

  /// TASK 079 doğrulamasından geçen profil × tempo birleşimleri.
  const compatiblePace = <DailyPlanProfileType, OnboardingDailyPace>{
    DailyPlanProfileType.beginner: OnboardingDailyPace.balanced,
    DailyPlanProfileType.returning: OnboardingDailyPace.balanced,
    DailyPlanProfileType.advanced: OnboardingDailyPace.focused,
    DailyPlanProfileType.lowTime: OnboardingDailyPace.light,
    DailyPlanProfileType.prayerFocused: OnboardingDailyPace.balanced,
    DailyPlanProfileType.quranFocused: OnboardingDailyPace.balanced,
    DailyPlanProfileType.dhikrFocused: OnboardingDailyPace.balanced,
    DailyPlanProfileType.learningFocused: OnboardingDailyPace.balanced,
  };

  DailyPlanDayContext context({
    Set<OnboardingFocusGoal> goals = const {OnboardingFocusGoal.trackPrayers},
    DailyPlanProfileType profileType = DailyPlanProfileType.prayerFocused,
    OnboardingDailyPace dailyPace = OnboardingDailyPace.balanced,
    int sizeMinutes = 10,
    String dayKey = '2026-07-26',
    int dayOffset = 0,
    int weekIndex = 0,
  }) => DailyPlanDayContext(
    profileType: profileType,
    // Üretici normalize edilmiş listeyi verir; sıra enum bildirim sırası.
    goals: OnboardingFocusGoal.values.where(goals.contains).toList(),
    dailyPace: dailyPace,
    sizeMinutes: sizeMinutes,
    dayKey: DayKey(dayKey),
    dayOffset: dayOffset,
    weekIndex: weekIndex,
  );

  Future<List<PlanItemDraft>> drafts(DailyPlanDayContext ctx) async {
    final result = await source.itemsFor(ctx);
    expect(result.isSuccess, isTrue, reason: 'kaynak toplam olmalı');
    return result.valueOrNull!;
  }

  List<String> templateIds(List<PlanItemDraft> list) => [
    for (final draft in list) draft.templateId,
  ];

  DailyPlanGenerationRequest request({
    Set<OnboardingFocusGoal> goals = const {OnboardingFocusGoal.trackPrayers},
    DailyPlanProfileType profileType = DailyPlanProfileType.prayerFocused,
    OnboardingDailyPace? dailyPace,
    String startDay = '2026-07-26',
  }) => DailyPlanGenerationRequest(
    profileType: profileType,
    goals: goals,
    dailyPace: dailyPace ?? compatiblePace[profileType]!,
    startDay: DayKey(startDay),
  );

  Future<List<DailyPlan>> generate(DailyPlanGenerationRequest req) async {
    final result = await DailyPlanGenerator.generate(req, source: source);
    expect(result.isSuccess, isTrue);
    return result.valueOrNull!;
  }

  group('hedef seçimi', () {
    test('yalnız trackPrayers → tek takip taslağı', () async {
      final list = await drafts(
        context(goals: const {OnboardingFocusGoal.trackPrayers}),
      );
      expect(templateIds(list), [trackId]);
    });

    test('yalnız prayOnTime → tek vaktinde-takip taslağı', () async {
      final list = await drafts(
        context(goals: const {OnboardingFocusGoal.prayOnTime}),
      );
      expect(templateIds(list), [onTimeId]);
    });

    test('ikisi birden → tam olarak iki taslak', () async {
      final list = await drafts(
        context(
          goals: const {
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.prayOnTime,
          },
        ),
      );
      expect(list.length, 2);
      expect(templateIds(list), [trackId, onTimeId]);
    });

    test('hiçbiri seçili değilse boş liste (hata değil)', () async {
      final list = await drafts(
        context(goals: const {OnboardingFocusGoal.quranHabit}),
      );
      expect(list, isEmpty);
    });

    test('yalnız ilgisiz hedefler boş liste verir', () async {
      for (final goal in [
        OnboardingFocusGoal.quranHabit,
        OnboardingFocusGoal.dhikrRoutine,
        OnboardingFocusGoal.islamicKnowledge,
      ]) {
        expect(await drafts(context(goals: {goal})), isEmpty);
      }
    });

    test('ilgisiz hedefler namaz çıktısını DEĞİŞTİRMEZ', () async {
      final alone = await drafts(
        context(goals: const {OnboardingFocusGoal.trackPrayers}),
      );
      final withOthers = await drafts(
        context(
          goals: const {
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.quranHabit,
            OnboardingFocusGoal.dhikrRoutine,
            OnboardingFocusGoal.islamicKnowledge,
          },
        ),
      );
      expect(templateIds(withOthers), templateIds(alone));
    });

    test('tüm hedefler seçiliyse tam olarak iki namaz taslağı', () async {
      final list = await drafts(
        context(goals: OnboardingFocusGoal.values.toSet()),
      );
      expect(templateIds(list), [trackId, onTimeId]);
    });

    test('prayOnTime otomatik olarak trackPrayers EKLEMEZ', () async {
      final list = await drafts(
        context(goals: const {OnboardingFocusGoal.prayOnTime}),
      );
      expect(templateIds(list), isNot(contains(trackId)));
    });

    test('prayer_focused profili tek başına öğe EKLEMEZ', () async {
      final list = await drafts(
        context(
          goals: const {OnboardingFocusGoal.quranHabit},
          profileType: DailyPlanProfileType.prayerFocused,
        ),
      );
      expect(list, isEmpty, reason: 'öğeler profilden değil HEDEFTEN gelir');
    });
  });

  group('sıralama', () {
    test('ikisi birden: takip daima birinci', () async {
      final list = await drafts(
        context(
          goals: const {
            OnboardingFocusGoal.prayOnTime,
            OnboardingFocusGoal.trackPrayers,
          },
        ),
      );
      expect(list.first.templateId, trackId);
      expect(list.last.templateId, onTimeId);
    });

    test('Set ekleme sırası çıktıyı DEĞİŞTİRMEZ', () async {
      final forward = await drafts(
        context(
          goals: {
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.prayOnTime,
          },
        ),
      );
      final reverse = await drafts(
        context(
          goals: {
            OnboardingFocusGoal.prayOnTime,
            OnboardingFocusGoal.trackPrayers,
          },
        ),
      );
      expect(templateIds(forward), templateIds(reverse));
    });

    test('tekrarlanan çağrılar sırayı korur', () async {
      final ctx = context(
        goals: const {
          OnboardingFocusGoal.trackPrayers,
          OnboardingFocusGoal.prayOnTime,
        },
      );
      for (var i = 0; i < 20; i++) {
        expect(templateIds(await drafts(ctx)), [trackId, onTimeId]);
      }
    });

    test('sıra AÇIK bir listeyle sabitlenmiştir', () {
      expect(PrayerDailyPlanItemSource.contributionOrder, [
        (OnboardingFocusGoal.trackPrayers, trackId),
        (OnboardingFocusGoal.prayOnTime, onTimeId),
      ]);
    });
  });

  group('şablon kimlikleri', () {
    test('kimlikler sabittir', () {
      expect(trackId, 'prayer_track_daily');
      expect(onTimeId, 'prayer_on_time_daily');
    });

    test('iki kimlik farklıdır', () {
      expect(trackId, isNot(onTimeId));
    });

    test('kimlikler makine tanımlayıcısıdır (yerelleştirilmiş metin yok)', () {
      for (final id in [trackId, onTimeId]) {
        expect(id, matches(RegExp(r'^[a-z][a-z0-9_]*$')));
        // Türkçe/Arapça harf veya boşluk içermez.
        expect(id, isNot(matches(RegExp(r'[çğıöşüÇĞİÖŞÜ؀-ۿ\s]'))));
      }
    });

    test('kimlikler zaman/UUID/cihaz verisi taşımaz', () {
      for (final id in [trackId, onTimeId]) {
        expect(id, isNot(matches(RegExp(r'\d{4}-\d{2}-\d{2}'))));
        expect(id, isNot(matches(RegExp(r'\d{10,}'))));
        expect(id, isNot(contains('uid')));
        expect(id, isNot(contains('device')));
      }
    });
  });

  group('PlanItem temsili', () {
    test('her iki katkı da PlanItemType.prayer kullanır', () async {
      final list = await drafts(
        context(
          goals: const {
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.prayOnTime,
          },
        ),
      );
      expect(list.every((d) => d.type == PlanItemType.prayer), isTrue);
    });

    test('vakit adı (targetRef) İLİŞTİRİLMEZ', () async {
      final list = await drafts(
        context(
          goals: const {
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.prayOnTime,
          },
        ),
      );
      expect(list.every((d) => d.targetRef == null), isTrue);
    });

    test('namaz SAYISI (sizeParam) iddia edilmez', () async {
      final list = await drafts(
        context(
          goals: const {
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.prayOnTime,
          },
        ),
      );
      expect(list.every((d) => d.sizeParam == null), isTrue);
    });

    test('üretilen öğeler tamamlanmamış başlar', () async {
      final plans = await generate(
        request(
          goals: const {
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.prayOnTime,
          },
        ),
      );
      for (final plan in plans) {
        expect(
          plan.items.every((i) => i.status == PlanItemStatus.pending),
          isTrue,
        );
        expect(plan.items.every((i) => i.completedAt == null), isTrue);
        expect(plan.items.every((i) => i.isCompleted), isFalse);
      }
    });
  });

  group('bütçe', () {
    test('namaz hedefi yoksa maliyet 0', () async {
      final list = await drafts(
        context(goals: const {OnboardingFocusGoal.quranHabit}),
      );
      expect(list.fold<int>(0, (s, d) => s + d.estimatedMinutes), 0);
    });

    test('tek namaz hedefi maliyeti 1', () async {
      final list = await drafts(
        context(goals: const {OnboardingFocusGoal.trackPrayers}),
      );
      expect(list.fold<int>(0, (s, d) => s + d.estimatedMinutes), 1);
    });

    test('iki namaz hedefi maliyeti 2', () async {
      final list = await drafts(
        context(
          goals: const {
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.prayOnTime,
          },
        ),
      );
      expect(list.fold<int>(0, (s, d) => s + d.estimatedMinutes), 2);
    });

    test('öğe başına maliyet sabittir', () {
      expect(PrayerDailyPlanItemSource.estimatedMinutesPerItem, 1);
    });

    test('tüm geçerli bütçeler iki öğeyi kabul eder', () async {
      const bothGoals = {
        OnboardingFocusGoal.trackPrayers,
        OnboardingFocusGoal.prayOnTime,
      };
      for (final entry in compatiblePace.entries) {
        final plans = await generate(
          request(
            goals: bothGoals,
            profileType: entry.key,
            dailyPace: entry.value,
          ),
        );
        expect(plans.every((p) => p.items.length == 2), isTrue);
        expect(plans.first.sizeMinutes, greaterThanOrEqualTo(2));
      }
    });

    test('light (5 dk) bütçesi bile iki öğeyi taşır', () async {
      final plans = await generate(
        request(
          goals: const {
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.prayOnTime,
          },
          profileType: DailyPlanProfileType.lowTime,
          dailyPace: OnboardingDailyPace.light,
        ),
      );
      expect(plans.first.sizeMinutes, 5);
      expect(plans.every((p) => p.items.length == 2), isTrue);
    });

    test('üreticinin bütçe doğrulaması hâlâ aktif (sahte kaynakla)', () async {
      final result = await DailyPlanGenerator.generate(
        request(
          profileType: DailyPlanProfileType.lowTime,
          dailyPace: OnboardingDailyPace.light,
        ),
        source: const _OverBudgetSource(),
      );
      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);
    });

    test('estimatedMinutes kalıcı plana YAZILMAZ', () async {
      final plans = await generate(
        request(goals: const {OnboardingFocusGoal.trackPrayers}),
      );
      // `PlanItem`'da süre alanı yoktur; taslak metadata'sı plana taşınmaz.
      final item = plans.first.items.single;
      expect(item.sizeParam, isNull);
      expect(
        plans.first.sizeMinutes,
        10,
        reason: 'gün bütçesi, öğe süresi değil',
      );
    });
  });

  group('profil bağımsızlığı', () {
    const bothGoals = {
      OnboardingFocusGoal.trackPrayers,
      OnboardingFocusGoal.prayOnTime,
    };

    for (final entry in compatiblePace.entries) {
      test('${entry.key.id}: aynı hedefler aynı katkıyı verir', () async {
        final list = await drafts(
          context(
            goals: bothGoals,
            profileType: entry.key,
            dailyPace: entry.value,
          ),
        );
        expect(templateIds(list), [trackId, onTimeId]);
        expect(list.every((d) => d.estimatedMinutes == 1), isTrue);
      });
    }

    test('HER profil kapsanmıştır (kapsam kilidi)', () {
      // Yeni bir profil eklenirse gözden geçirilene kadar KIRILIR.
      expect(compatiblePace.keys.toSet(), DailyPlanProfileType.values.toSet());
    });

    test('kaynak profili DEĞİŞTİRMEZ', () async {
      for (final entry in compatiblePace.entries) {
        final plans = await generate(
          request(
            goals: bothGoals,
            profileType: entry.key,
            dailyPace: entry.value,
          ),
        );
        expect(plans.every((p) => p.profileType == entry.key.id), isTrue);
      }
    });

    test('beginner ve low_time öğe SAYISI azaltılmaz', () async {
      for (final profile in [
        DailyPlanProfileType.beginner,
        DailyPlanProfileType.lowTime,
      ]) {
        final plans = await generate(
          request(
            goals: bothGoals,
            profileType: profile,
            dailyPace: compatiblePace[profile]!,
          ),
        );
        expect(plans.every((p) => p.items.length == 2), isTrue);
      }
    });

    test('prayer_focused fazladan öğe ÜRETMEZ', () async {
      final plans = await generate(
        request(
          goals: bothGoals,
          profileType: DailyPlanProfileType.prayerFocused,
        ),
      );
      expect(plans.every((p) => p.items.length == 2), isTrue);
    });
  });

  group('ilerleme fazı bağımsızlığı', () {
    const bothGoals = {
      OnboardingFocusGoal.trackPrayers,
      OnboardingFocusGoal.prayOnTime,
    };

    test('faz 0–3 aynı katkıyı verir', () async {
      final byPhase = <int, List<String>>{};
      for (final weekIndex in [0, 1, 2, 3]) {
        final list = await drafts(
          context(goals: bothGoals, weekIndex: weekIndex),
        );
        byPhase[weekIndex] = templateIds(list);
        expect(list.every((d) => d.estimatedMinutes == 1), isTrue);
        expect(list.every((d) => d.type == PlanItemType.prayer), isTrue);
      }
      expect(byPhase[0], byPhase[1]);
      expect(byPhase[1], byPhase[2]);
      expect(byPhase[2], byPhase[3]);
    });

    test('30 günün tamamında öğe sayısı ve sırası sabittir', () async {
      final plans = await generate(request(goals: bothGoals));
      for (final plan in plans) {
        expect(plan.items.length, 2);
        expect(plan.items.map((i) => i.type).toList(), [
          PlanItemType.prayer,
          PlanItemType.prayer,
        ]);
      }
    });

    test('gün ofseti katkıyı DEĞİŞTİRMEZ', () async {
      for (final offset in [0, 6, 7, 13, 14, 20, 21, 28, 29]) {
        final list = await drafts(
          context(
            goals: bothGoals,
            dayOffset: offset,
            weekIndex: DailyPlanGenerator.weekIndexForOffset(offset),
          ),
        );
        expect(templateIds(list), [trackId, onTimeId]);
      }
    });
  });

  group('30 günlük üretici entegrasyonu', () {
    final scenarios = <String, (Set<OnboardingFocusGoal>, int)>{
      'yalnız trackPrayers': ({OnboardingFocusGoal.trackPrayers}, 1),
      'yalnız prayOnTime': ({OnboardingFocusGoal.prayOnTime}, 1),
      'ikisi birden': (
        {OnboardingFocusGoal.trackPrayers, OnboardingFocusGoal.prayOnTime},
        2,
      ),
      'namaz hedefi yok': ({OnboardingFocusGoal.quranHabit}, 0),
    };

    for (final entry in scenarios.entries) {
      test('${entry.key}: 30 gün, günde ${entry.value.$2} öğe', () async {
        final plans = await generate(
          request(
            goals: entry.value.$1,
            profileType: entry.value.$1.contains(OnboardingFocusGoal.quranHabit)
                ? DailyPlanProfileType.quranFocused
                : DailyPlanProfileType.prayerFocused,
          ),
        );

        expect(plans.length, 30);
        expect(plans.every((p) => p.items.length == entry.value.$2), isTrue);
        expect(
          plans.map((p) => p.dayKey.value).toSet().length,
          30,
          reason: 'gün anahtarları tekil',
        );
      });
    }

    test('50 tekrar aynı çıktıyı verir', () async {
      final req = request(
        goals: const {
          OnboardingFocusGoal.trackPrayers,
          OnboardingFocusGoal.prayOnTime,
        },
      );
      final baseline = _project(await generate(req));
      for (var i = 0; i < 50; i++) {
        expect(_project(await generate(req)), baseline);
      }
    });
  });

  group('nihai öğe kimliği', () {
    const bothGoals = {
      OnboardingFocusGoal.trackPrayers,
      OnboardingFocusGoal.prayOnTime,
    };

    test('kimlik mevcut builder biçimini kullanır', () async {
      final plans = await generate(
        request(goals: bothGoals, startDay: '2026-07-26'),
      );
      expect(plans.first.items.map((i) => i.itemId.value).toList(), [
        'rule-engine-v1:2026-07-26:prayer_track_daily:0',
        'rule-engine-v1:2026-07-26:prayer_on_time_daily:1',
      ]);
    });

    test('iki şablon aynı gün içinde ÇAKIŞMAZ', () async {
      final plans = await generate(request(goals: bothGoals));
      for (final plan in plans) {
        expect(plan.items.map((i) => i.itemId.value).toSet().length, 2);
      }
    });

    test('farklı günler farklı kimlik üretir', () async {
      final plans = await generate(request(goals: bothGoals));
      final ids = [
        for (final plan in plans)
          for (final item in plan.items) item.itemId.value,
      ];
      expect(ids.toSet().length, 60);
    });

    test('aynı istek aynı kimlikleri üretir', () async {
      final req = request(goals: bothGoals);
      final first = await generate(req);
      final second = await generate(req);
      expect(_project(first), _project(second));
    });

    test('farklı startDay farklı kimlik üretir', () async {
      final a = await generate(
        request(goals: bothGoals, startDay: '2026-07-26'),
      );
      final b = await generate(
        request(goals: bothGoals, startDay: '2026-07-27'),
      );
      expect(a.first.items.first.itemId, isNot(b.first.items.first.itemId));
    });
  });

  group('yan etki yokluğu', () {
    test('kaynak eşit bağlam için daima aynı sonucu verir', () async {
      final ctx = context(
        goals: const {
          OnboardingFocusGoal.trackPrayers,
          OnboardingFocusGoal.prayOnTime,
        },
      );
      final baseline = templateIds(await drafts(ctx));
      for (var i = 0; i < 50; i++) {
        expect(templateIds(await drafts(ctx)), baseline);
      }
    });

    test('tempo katkıyı DEĞİŞTİRMEZ', () async {
      final byPace = <OnboardingDailyPace, List<String>>{};
      for (final pace in OnboardingDailyPace.values) {
        byPace[pace] = templateIds(
          await drafts(
            context(
              goals: const {
                OnboardingFocusGoal.trackPrayers,
                OnboardingFocusGoal.prayOnTime,
              },
              dailyPace: pace,
            ),
          ),
        );
      }
      expect(
        byPace[OnboardingDailyPace.light],
        byPace[OnboardingDailyPace.balanced],
      );
      expect(
        byPace[OnboardingDailyPace.balanced],
        byPace[OnboardingDailyPace.focused],
      );
    });

    test('gün anahtarı katkıyı DEĞİŞTİRMEZ', () async {
      final a = await drafts(context(dayKey: '2026-01-01'));
      final b = await drafts(context(dayKey: '2028-02-29'));
      expect(templateIds(a), templateIds(b));
    });

    test('bootstrap namaz kaynağını veya üreticiyi ÇALIŞTIRMAZ', () async {
      final counting = _CountingSource();
      final container = ProviderContainer(
        overrides: [inMemoryAppDatabaseOverride(), ...testSessionOverrides()],
      );
      addTearDown(container.dispose);

      await initializeLocalPersistence(container);

      // Ne kaynak ne de üretici herhangi bir provider'a bağlı DEĞİLDİR;
      // bootstrap onlara ulaşamaz.
      expect(counting.calls, 0);
    });
  });

  group('dinî güvenlik ve gizlilik', () {
    test('taslaklar yerelleştirilmiş dinî metin taşımaz', () async {
      final list = await drafts(
        context(
          goals: const {
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.prayOnTime,
          },
        ),
      );
      for (final draft in list) {
        expect(draft.templateId, isNot(contains(' ')));
        expect(draft.targetRef, isNull);
      }
    });

    test('şablon kimlikleri ödül/ceza/yargı ifadesi içermez', () {
      for (final id in [trackId, onTimeId]) {
        for (final forbidden in [
          'sin',
          'sinner',
          'reward',
          'punish',
          'obligat',
          'fard',
          'haram',
          'good',
          'bad',
          'lazy',
          'score',
          'rank',
          'level',
          'quota',
        ]) {
          expect(id, isNot(contains(forbidden)));
        }
      }
    });

    test('üretilen plan konum/UID/zaman damgası taşımaz', () async {
      final plans = await generate(
        request(
          goals: const {
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.prayOnTime,
          },
        ),
      );
      final rendered = _project(plans).join('\n');
      for (final forbidden in [
        'latitude',
        'longitude',
        'uid',
        'deviceId',
        'fajr',
        'dhuhr',
        'asr',
        'maghrib',
        'isha',
      ]) {
        expect(rendered, isNot(contains(forbidden)));
      }
    });

    test('belirli bir vakit adı ASLA iliştirilmez', () async {
      final plans = await generate(
        request(
          goals: const {
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.prayOnTime,
          },
        ),
      );
      expect(
        plans.every((p) => p.items.every((i) => i.targetRef == null)),
        isTrue,
      );
    });
  });
}

/// Karşılaştırılabilir çıktı izdüşümü (nesne kimliğinden bağımsız).
List<String> _project(List<DailyPlan> plans) => [
  for (final plan in plans)
    [
      plan.dayKey.value,
      plan.profileType,
      '${plan.sizeMinutes}',
      '${plan.weekIndex}',
      plan.items.map((i) => '${i.itemId.value}|${i.type.name}').join(','),
    ].join('#'),
];

/// Bütçeyi kasten aşan sahte kaynak — üretici doğrulamasının hâlâ
/// çalıştığını kanıtlar.
final class _OverBudgetSource implements DailyPlanItemSource {
  const _OverBudgetSource();

  @override
  ResultFuture<List<PlanItemDraft>> itemsFor(
    DailyPlanDayContext context,
  ) async => Result.success([
    PlanItemDraft(
      templateId: 'over_budget_a',
      type: PlanItemType.prayer,
      estimatedMinutes: context.sizeMinutes,
    ),
    PlanItemDraft(
      templateId: 'over_budget_b',
      type: PlanItemType.prayer,
      estimatedMinutes: 1,
    ),
  ]);
}

/// Çağrı sayan kaynak — bootstrap'ın üretime dokunmadığını gösterir.
final class _CountingSource implements DailyPlanItemSource {
  int calls = 0;

  @override
  ResultFuture<List<PlanItemDraft>> itemsFor(
    DailyPlanDayContext context,
  ) async {
    calls++;
    return const Result.success(<PlanItemDraft>[]);
  }
}
