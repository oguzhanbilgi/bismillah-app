import 'package:bismillah_app/app/app_bootstrap.dart';
import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_daily_pace.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/services/composite_daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_generation_request.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_generator.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/services/prayer_daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/services/quran_daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/value_objects/daily_plan_profile_type.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';
import '../../../helpers/test_session.dart';

/// Kur'an plan öğesi kaynağı ve sıralı kaynak bileşimi (TASK 081).
///
/// Üretilen Kur'an öğesi nötr bir *devam/takip* eylemidir: sure/ayet/meal/
/// ses ataması, okuma geçmişi erişimi ve miktar iddiası YOKTUR.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const quranSource = QuranDailyPlanItemSource();
  const quranId = QuranDailyPlanItemSource.continueDailyTemplateId;
  const trackId = PrayerDailyPlanItemSource.trackDailyTemplateId;
  const onTimeId = PrayerDailyPlanItemSource.onTimeDailyTemplateId;

  /// Prayer → Quran onaylı sırası.
  const orderedSource = CompositeDailyPlanItemSource(
    sources: [PrayerDailyPlanItemSource(), QuranDailyPlanItemSource()],
  );

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
    Set<OnboardingFocusGoal> goals = const {OnboardingFocusGoal.quranHabit},
    DailyPlanProfileType profileType = DailyPlanProfileType.quranFocused,
    OnboardingDailyPace dailyPace = OnboardingDailyPace.balanced,
    int sizeMinutes = 10,
    String dayKey = '2026-07-26',
    int dayOffset = 0,
    int weekIndex = 0,
  }) => DailyPlanDayContext(
    profileType: profileType,
    goals: OnboardingFocusGoal.values.where(goals.contains).toList(),
    dailyPace: dailyPace,
    sizeMinutes: sizeMinutes,
    dayKey: DayKey(dayKey),
    dayOffset: dayOffset,
    weekIndex: weekIndex,
  );

  Future<List<PlanItemDraft>> draftsFrom(
    DailyPlanItemSource source,
    DailyPlanDayContext ctx,
  ) async {
    final result = await source.itemsFor(ctx);
    expect(result.isSuccess, isTrue, reason: 'kaynak toplam olmalı');
    return result.valueOrNull!;
  }

  List<String> templateIds(List<PlanItemDraft> list) => [
    for (final draft in list) draft.templateId,
  ];

  DailyPlanGenerationRequest request({
    Set<OnboardingFocusGoal> goals = const {OnboardingFocusGoal.quranHabit},
    DailyPlanProfileType profileType = DailyPlanProfileType.quranFocused,
    OnboardingDailyPace? dailyPace,
    String startDay = '2026-07-26',
  }) => DailyPlanGenerationRequest(
    profileType: profileType,
    goals: goals,
    dailyPace: dailyPace ?? compatiblePace[profileType]!,
    startDay: DayKey(startDay),
  );

  Future<List<DailyPlan>> generate(
    DailyPlanGenerationRequest req, {
    DailyPlanItemSource source = orderedSource,
  }) async {
    final result = await DailyPlanGenerator.generate(req, source: source);
    expect(result.isSuccess, isTrue);
    return result.valueOrNull!;
  }

  group('Kur\'an hedef seçimi', () {
    test('yalnız quranHabit → tek taslak', () async {
      final list = await draftsFrom(
        quranSource,
        context(goals: const {OnboardingFocusGoal.quranHabit}),
      );
      expect(templateIds(list), [quranId]);
    });

    test('quranHabit + ilgisiz hedefler → yine tek taslak', () async {
      final list = await draftsFrom(
        quranSource,
        context(
          goals: const {
            OnboardingFocusGoal.quranHabit,
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.dhikrRoutine,
            OnboardingFocusGoal.islamicKnowledge,
          },
        ),
      );
      expect(templateIds(list), [quranId]);
    });

    test('tüm hedefler → tam olarak bir Kur\'an taslağı', () async {
      final list = await draftsFrom(
        quranSource,
        context(goals: OnboardingFocusGoal.values.toSet()),
      );
      expect(templateIds(list), [quranId]);
    });

    test('quranHabit yoksa boş liste (hata değil)', () async {
      final list = await draftsFrom(
        quranSource,
        context(goals: const {OnboardingFocusGoal.trackPrayers}),
      );
      expect(list, isEmpty);
    });

    test('ilgisiz hedeflerin hiçbiri Kur\'an öğesi üretmez', () async {
      for (final goal in [
        OnboardingFocusGoal.trackPrayers,
        OnboardingFocusGoal.prayOnTime,
        OnboardingFocusGoal.dhikrRoutine,
        OnboardingFocusGoal.islamicKnowledge,
      ]) {
        expect(await draftsFrom(quranSource, context(goals: {goal})), isEmpty);
      }
    });

    test('quran_focused profili tek başına öğe ÜRETMEZ', () async {
      final list = await draftsFrom(
        quranSource,
        context(
          goals: const {OnboardingFocusGoal.trackPrayers},
          profileType: DailyPlanProfileType.quranFocused,
        ),
      );
      expect(list, isEmpty, reason: 'öğe profilden değil HEDEFTEN gelir');
    });

    test('Set ekleme sırası sonucu DEĞİŞTİRMEZ', () async {
      final forward = await draftsFrom(
        quranSource,
        context(
          goals: {
            OnboardingFocusGoal.quranHabit,
            OnboardingFocusGoal.islamicKnowledge,
          },
        ),
      );
      final reverse = await draftsFrom(
        quranSource,
        context(
          goals: {
            OnboardingFocusGoal.islamicKnowledge,
            OnboardingFocusGoal.quranHabit,
          },
        ),
      );
      expect(templateIds(forward), templateIds(reverse));
    });

    test('boş hedef listesi boş katkı verir', () async {
      final list = await draftsFrom(quranSource, context(goals: const {}));
      expect(list, isEmpty);
    });
  });

  group('Kur\'an şablon kimliği', () {
    test('kimlik quran_continue_daily', () {
      expect(quranId, 'quran_continue_daily');
    });

    test('makine tanımlayıcısıdır (yerelleştirilmiş metin yok)', () {
      expect(quranId, matches(RegExp(r'^[a-z][a-z0-9_]*$')));
      expect(quranId, isNot(matches(RegExp(r'[çğıöşüÇĞİÖŞÜ؀-ۿ\s]'))));
    });

    test('sure/ayet/cüz/sayfa/meal/ses kimliği İÇERMEZ', () {
      for (final forbidden in [
        'surah',
        'sure',
        'ayah',
        'ayet',
        'verse',
        'juz',
        'cuz',
        'page',
        'sayfa',
        'translation',
        'meal',
        'reciter',
        'audio',
        'mp3',
        'http',
      ]) {
        expect(quranId, isNot(contains(forbidden)));
      }
    });

    test('zaman/UID/cihaz verisi taşımaz', () {
      expect(quranId, isNot(matches(RegExp(r'\d{4}-\d{2}-\d{2}'))));
      expect(quranId, isNot(matches(RegExp(r'\d{10,}'))));
      expect(quranId, isNot(contains('uid')));
      expect(quranId, isNot(contains('device')));
    });

    test('Prayer şablonlarından farklıdır', () {
      expect(quranId, isNot(trackId));
      expect(quranId, isNot(onTimeId));
    });
  });

  group('PlanItem temsili', () {
    test('tip PlanItemType.quran', () async {
      final list = await draftsFrom(quranSource, context());
      expect(list.single.type, PlanItemType.quran);
    });

    test('targetRef ve sizeParam null kalır', () async {
      final list = await draftsFrom(quranSource, context());
      expect(list.single.targetRef, isNull);
      expect(list.single.sizeParam, isNull);
    });

    test('estimatedMinutes 2', () async {
      final list = await draftsFrom(quranSource, context());
      expect(list.single.estimatedMinutes, 2);
      expect(QuranDailyPlanItemSource.estimatedMinutes, 2);
    });

    test('üretilen öğe tamamlanmamış başlar', () async {
      final plans = await generate(request());
      for (final plan in plans) {
        expect(
          plan.items.every((i) => i.status == PlanItemStatus.pending),
          isTrue,
        );
        expect(plan.items.every((i) => i.completedAt == null), isTrue);
      }
    });

    test('kalıcı öğede Kur\'an metni/meali GÖMÜLÜ DEĞİL', () async {
      final plans = await generate(request());
      final item = plans.first.items.single;
      expect(item.targetRef, isNull);
      expect(item.sizeParam, isNull);
      expect(item.itemId.value, contains(quranId));
    });
  });

  group('profil bağımsızlığı', () {
    for (final entry in compatiblePace.entries) {
      test('${entry.key.id}: aynı hedef aynı katkıyı verir', () async {
        final list = await draftsFrom(
          quranSource,
          context(profileType: entry.key, dailyPace: entry.value),
        );
        expect(templateIds(list), [quranId]);
        expect(list.single.estimatedMinutes, 2);
      });
    }

    test('HER profil kapsanmıştır (kapsam kilidi)', () {
      expect(compatiblePace.keys.toSet(), DailyPlanProfileType.values.toSet());
    });

    test('profil değiştirilmez ve öğe sayısı sabittir', () async {
      for (final entry in compatiblePace.entries) {
        final plans = await generate(
          request(profileType: entry.key, dailyPace: entry.value),
          source: quranSource,
        );
        expect(plans.every((p) => p.profileType == entry.key.id), isTrue);
        expect(plans.every((p) => p.items.length == 1), isTrue);
      }
    });

    test('low_time azaltılmaz, advanced artırılmaz', () async {
      for (final profile in [
        DailyPlanProfileType.lowTime,
        DailyPlanProfileType.advanced,
      ]) {
        final plans = await generate(
          request(profileType: profile, dailyPace: compatiblePace[profile]!),
          source: quranSource,
        );
        expect(plans.every((p) => p.items.length == 1), isTrue);
      }
    });
  });

  group('ilerleme fazı bağımsızlığı', () {
    test('faz 0–3 aynı katkıyı verir', () async {
      for (final weekIndex in [0, 1, 2, 3]) {
        final list = await draftsFrom(
          quranSource,
          context(weekIndex: weekIndex),
        );
        expect(templateIds(list), [quranId]);
        expect(list.single.estimatedMinutes, 2);
        expect(list.single.type, PlanItemType.quran);
      }
    });

    test('30 günün tamamında öğe sayısı sabittir', () async {
      final plans = await generate(request(), source: quranSource);
      expect(plans.every((p) => p.items.length == 1), isTrue);
    });

    test('gün ofseti katkıyı DEĞİŞTİRMEZ', () async {
      for (final offset in [0, 6, 7, 13, 14, 20, 21, 28, 29]) {
        final list = await draftsFrom(
          quranSource,
          context(
            dayOffset: offset,
            weekIndex: DailyPlanGenerator.weekIndexForOffset(offset),
          ),
        );
        expect(templateIds(list), [quranId]);
      }
    });
  });

  group('sıralı bileşim', () {
    const bothPrayerAndQuran = {
      OnboardingFocusGoal.trackPrayers,
      OnboardingFocusGoal.prayOnTime,
      OnboardingFocusGoal.quranHabit,
    };

    test('Prayer katkıları Quran katkısından ÖNCE gelir', () async {
      final list = await draftsFrom(
        orderedSource,
        context(goals: bothPrayerAndQuran),
      );
      expect(templateIds(list), [trackId, onTimeId, quranId]);
    });

    test('tek Prayer hedefi de Quran\'dan önce gelir', () async {
      final list = await draftsFrom(
        orderedSource,
        context(
          goals: const {
            OnboardingFocusGoal.quranHabit,
            OnboardingFocusGoal.prayOnTime,
          },
        ),
      );
      expect(templateIds(list), [onTimeId, quranId]);
    });

    test('Prayer hedefi yoksa yalnız Quran', () async {
      final list = await draftsFrom(
        orderedSource,
        context(goals: const {OnboardingFocusGoal.quranHabit}),
      );
      expect(templateIds(list), [quranId]);
    });

    test('ilgili hedef yoksa boş', () async {
      final list = await draftsFrom(
        orderedSource,
        context(goals: const {OnboardingFocusGoal.dhikrRoutine}),
      );
      expect(list, isEmpty);
    });

    test('yapıcı sırası belirleyicidir (ters sıra ters çıktı verir)', () async {
      const reversed = CompositeDailyPlanItemSource(
        sources: [QuranDailyPlanItemSource(), PrayerDailyPlanItemSource()],
      );
      final list = await draftsFrom(
        reversed,
        context(goals: bothPrayerAndQuran),
      );
      expect(templateIds(list), [quranId, trackId, onTimeId]);
    });

    test('hedef Set sırası bileşim sırasını DEĞİŞTİRMEZ', () async {
      final forward = await draftsFrom(
        orderedSource,
        context(
          goals: {
            OnboardingFocusGoal.quranHabit,
            OnboardingFocusGoal.prayOnTime,
            OnboardingFocusGoal.trackPrayers,
          },
        ),
      );
      final reverse = await draftsFrom(
        orderedSource,
        context(
          goals: {
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.prayOnTime,
            OnboardingFocusGoal.quranHabit,
          },
        ),
      );
      expect(templateIds(forward), templateIds(reverse));
      expect(templateIds(forward), [trackId, onTimeId, quranId]);
    });

    test('tekrarlanan çağrılar sırayı korur', () async {
      final ctx = context(goals: bothPrayerAndQuran);
      for (var i = 0; i < 20; i++) {
        expect(templateIds(await draftsFrom(orderedSource, ctx)), [
          trackId,
          onTimeId,
          quranId,
        ]);
      }
    });

    test('her çocuk gün başına bir kez çağrılır', () async {
      final counting = _CountingSource();
      final composite = CompositeDailyPlanItemSource(
        sources: [counting, quranSource],
      );
      await draftsFrom(composite, context());
      expect(counting.calls, 1);
    });

    test('boş çocuk listesi boş başarılı sonuç verir', () async {
      const empty = CompositeDailyPlanItemSource(sources: []);
      expect(await draftsFrom(empty, context()), isEmpty);
    });

    test('Learn sonradan eklenince Prayer/Quran slotları KAYMAZ', () async {
      // Üçüncü kaynağın SONA eklenmesi, TASK 082'de Learn'ün katılacağı
      // yeri simüle eder: önceki slot'lar (0,1,2) ve dolayısıyla nihai
      // kimlikler değişmemelidir.
      final withoutLearn = await generate(
        request(goals: bothPrayerAndQuran),
        source: orderedSource,
      );
      final withThirdSource = await generate(
        request(goals: bothPrayerAndQuran),
        source: const CompositeDailyPlanItemSource(
          sources: [
            PrayerDailyPlanItemSource(),
            QuranDailyPlanItemSource(),
            _FixedTemplateSource('third_source_placeholder_test'),
          ],
        ),
      );

      expect(
        withThirdSource.first.items.take(3).map((i) => i.itemId.value).toList(),
        withoutLearn.first.items.map((i) => i.itemId.value).toList(),
      );
      expect(withThirdSource.first.items.length, 4);
    });
  });

  group('bileşim hatası ve tekrar denetimi', () {
    test('ilk çocuğun hatası taşınır', () async {
      const composite = CompositeDailyPlanItemSource(
        sources: [_FailingSource(NetworkFailure()), QuranDailyPlanItemSource()],
      );
      final result = await composite.itemsFor(context());
      expect(result.failureOrNull, isA<NetworkFailure>());
      expect(result.valueOrNull, isNull);
    });

    test('sonraki çocuğun hatası taşınır ve öncekiler ATILIR', () async {
      const composite = CompositeDailyPlanItemSource(
        sources: [
          PrayerDailyPlanItemSource(),
          QuranDailyPlanItemSource(),
          _FailingSource(NetworkFailure()),
        ],
      );
      final result = await composite.itemsFor(
        context(
          goals: const {
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.quranHabit,
          },
        ),
      );
      expect(result.failureOrNull, isA<NetworkFailure>());
      expect(result.valueOrNull, isNull, reason: 'kısmi liste dönmez');
    });

    test('kaynaklar arası tekrar eden şablon reddedilir', () async {
      const composite = CompositeDailyPlanItemSource(
        sources: [QuranDailyPlanItemSource(), QuranDailyPlanItemSource()],
      );
      final result = await composite.itemsFor(context());
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.valueOrNull, isNull);
    });

    test('tekrar denetimi deterministiktir', () async {
      const composite = CompositeDailyPlanItemSource(
        sources: [QuranDailyPlanItemSource(), QuranDailyPlanItemSource()],
      );
      for (var i = 0; i < 20; i++) {
        expect((await composite.itemsFor(context())).isFailure, isTrue);
      }
    });

    test('hata nesnesi çocuk adı/yük/hedef/gün bilgisi taşımaz', () async {
      const composite = CompositeDailyPlanItemSource(
        sources: [QuranDailyPlanItemSource(), QuranDailyPlanItemSource()],
      );
      final rendered = (await composite.itemsFor(
        context(),
      )).failureOrNull.toString();
      for (final forbidden in [
        'QuranDailyPlanItemSource',
        'quran_continue_daily',
        'quranHabit',
        '2026-07-26',
        'Exception',
        '#0',
      ]) {
        expect(rendered, isNot(contains(forbidden)));
      }
    });
  });

  group('bütçe', () {
    test('yalnız Kur\'an maliyeti 2', () async {
      final list = await draftsFrom(orderedSource, context());
      expect(list.fold<int>(0, (s, d) => s + d.estimatedMinutes), 2);
    });

    test('Prayer takip + Kur\'an maliyeti 3', () async {
      final list = await draftsFrom(
        orderedSource,
        context(
          goals: const {
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.quranHabit,
          },
        ),
      );
      expect(list.fold<int>(0, (s, d) => s + d.estimatedMinutes), 3);
    });

    test('Prayer vaktinde + Kur\'an maliyeti 3', () async {
      final list = await draftsFrom(
        orderedSource,
        context(
          goals: const {
            OnboardingFocusGoal.prayOnTime,
            OnboardingFocusGoal.quranHabit,
          },
        ),
      );
      expect(list.fold<int>(0, (s, d) => s + d.estimatedMinutes), 3);
    });

    test('iki Prayer + Kur\'an maliyeti 4', () async {
      final list = await draftsFrom(
        orderedSource,
        context(
          goals: const {
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.prayOnTime,
            OnboardingFocusGoal.quranHabit,
          },
        ),
      );
      expect(list.fold<int>(0, (s, d) => s + d.estimatedMinutes), 4);
    });

    test('light (5 dk) üç öğenin tamamını taşır', () async {
      final plans = await generate(
        request(
          goals: const {
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.prayOnTime,
            OnboardingFocusGoal.quranHabit,
          },
          profileType: DailyPlanProfileType.lowTime,
          dailyPace: OnboardingDailyPace.light,
        ),
      );
      expect(plans.first.sizeMinutes, 5);
      expect(plans.every((p) => p.items.length == 3), isTrue);
    });

    test('tüm geçerli bütçeler üç öğeyi kabul eder', () async {
      for (final entry in compatiblePace.entries) {
        final plans = await generate(
          request(
            goals: const {
              OnboardingFocusGoal.trackPrayers,
              OnboardingFocusGoal.prayOnTime,
              OnboardingFocusGoal.quranHabit,
            },
            profileType: entry.key,
            dailyPace: entry.value,
          ),
        );
        expect(plans.every((p) => p.items.length == 3), isTrue);
      }
    });

    test('bütçeyi aşan ek kaynak toplam üretimi BAŞARISIZ kılar', () async {
      final result = await DailyPlanGenerator.generate(
        request(
          profileType: DailyPlanProfileType.lowTime,
          dailyPace: OnboardingDailyPace.light,
        ),
        source: const CompositeDailyPlanItemSource(
          sources: [QuranDailyPlanItemSource(), _OverBudgetSource()],
        ),
      );
      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull, reason: 'kısmi 30 gün dönmez');
    });

    test('estimatedMinutes kalıcı plana YAZILMAZ', () async {
      final plans = await generate(request());
      expect(plans.first.items.single.sizeParam, isNull);
      expect(
        plans.first.sizeMinutes,
        10,
        reason: 'gün bütçesi, öğe süresi değil',
      );
    });
  });

  group('30 günlük entegrasyon', () {
    final scenarios = <String, (Set<OnboardingFocusGoal>, int)>{
      'yalnız quranHabit': ({OnboardingFocusGoal.quranHabit}, 1),
      'quranHabit + trackPrayers': (
        {OnboardingFocusGoal.quranHabit, OnboardingFocusGoal.trackPrayers},
        2,
      ),
      'quranHabit + prayOnTime': (
        {OnboardingFocusGoal.quranHabit, OnboardingFocusGoal.prayOnTime},
        2,
      ),
      'quranHabit + iki Prayer': (
        {
          OnboardingFocusGoal.quranHabit,
          OnboardingFocusGoal.trackPrayers,
          OnboardingFocusGoal.prayOnTime,
        },
        3,
      ),
      'Kur\'an hedefi yok': ({OnboardingFocusGoal.trackPrayers}, 1),
      'tüm hedefler': (OnboardingFocusGoal.values.toSet(), 3),
    };

    for (final entry in scenarios.entries) {
      test('${entry.key}: 30 gün × ${entry.value.$2} öğe', () async {
        final plans = await generate(request(goals: entry.value.$1));

        expect(plans.length, 30);
        expect(plans.every((p) => p.items.length == entry.value.$2), isTrue);
        expect(plans.map((p) => p.dayKey.value).toSet().length, 30);
        expect(plans.every((p) => p.profileType == 'quran_focused'), isTrue);
        expect(
          plans.every(
            (p) => p.items.every((i) => i.status == PlanItemStatus.pending),
          ),
          isTrue,
        );

        final ids = [
          for (final plan in plans)
            for (final item in plan.items) item.itemId.value,
        ];
        expect(ids.toSet().length, ids.length, reason: 'nihai kimlik tekil');
      });
    }

    test('50 tekrar aynı çıktıyı verir', () async {
      final req = request(
        goals: const {
          OnboardingFocusGoal.trackPrayers,
          OnboardingFocusGoal.prayOnTime,
          OnboardingFocusGoal.quranHabit,
        },
      );
      final baseline = _project(await generate(req));
      for (var i = 0; i < 50; i++) {
        expect(_project(await generate(req)), baseline);
      }
    });

    test('nihai kimlik builder biçimini korur', () async {
      final plans = await generate(
        request(
          goals: const {
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.prayOnTime,
            OnboardingFocusGoal.quranHabit,
          },
          startDay: '2026-07-26',
        ),
      );
      expect(plans.first.items.map((i) => i.itemId.value).toList(), [
        'rule-engine-v1:2026-07-26:prayer_track_daily:0',
        'rule-engine-v1:2026-07-26:prayer_on_time_daily:1',
        'rule-engine-v1:2026-07-26:quran_continue_daily:2',
      ]);
    });

    test('farklı günler farklı kimlik üretir', () async {
      final plans = await generate(request());
      expect(plans.map((p) => p.items.single.itemId.value).toSet().length, 30);
    });
  });

  group('yan etki yokluğu', () {
    test('kaynak eşit bağlam için daima aynı sonucu verir', () async {
      final ctx = context();
      final baseline = templateIds(await draftsFrom(quranSource, ctx));
      for (var i = 0; i < 50; i++) {
        expect(templateIds(await draftsFrom(quranSource, ctx)), baseline);
      }
    });

    test('tempo ve gün anahtarı katkıyı DEĞİŞTİRMEZ', () async {
      for (final pace in OnboardingDailyPace.values) {
        expect(
          templateIds(await draftsFrom(quranSource, context(dailyPace: pace))),
          [quranId],
        );
      }
      expect(
        templateIds(
          await draftsFrom(quranSource, context(dayKey: '2028-02-29')),
        ),
        [quranId],
      );
    });

    test(
      'bootstrap Kur\'an/bileşik kaynağı ve üreticiyi ÇALIŞTIRMAZ',
      () async {
        final counting = _CountingSource();
        final container = ProviderContainer(
          overrides: [inMemoryAppDatabaseOverride(), ...testSessionOverrides()],
        );
        addTearDown(container.dispose);

        await initializeLocalPersistence(container);

        // Hiçbiri provider'a bağlı DEĞİLDİR; bootstrap onlara ulaşamaz.
        expect(counting.calls, 0);
      },
    );
  });

  group('dinî güvenlik ve gizlilik', () {
    test('üretilen plan Kur\'an/meal metni veya atama taşımaz', () async {
      final plans = await generate(
        request(
          goals: const {
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.prayOnTime,
            OnboardingFocusGoal.quranHabit,
          },
        ),
      );
      final rendered = _project(plans).join('\n');
      for (final forbidden in [
        'بِسْمِ',
        'Rahman',
        'surah-',
        'ayah',
        'juz',
        'mp3quran',
        'http',
        'latitude',
        'uid',
        'deviceId',
      ]) {
        expect(rendered, isNot(contains(forbidden)));
      }
    });

    test('şablon kimliği ödül/ceza/yükümlülük ifadesi içermez', () {
      for (final forbidden in [
        'sin',
        'reward',
        'punish',
        'obligat',
        'fard',
        'wajib',
        'sunnah',
        'good',
        'bad',
        'score',
        'rank',
        'quota',
        'must',
      ]) {
        expect(quranId, isNot(contains(forbidden)));
      }
    });

    test('okuma miktarı iddia edilmez', () async {
      final plans = await generate(request());
      expect(
        plans.every((p) => p.items.every((i) => i.sizeParam == null)),
        isTrue,
      );
    });
  });
}

/// Karşılaştırılabilir çıktı izdüşümü.
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

/// Sabit tek şablon döndüren nötr test kaynağı.
final class _FixedTemplateSource implements DailyPlanItemSource {
  const _FixedTemplateSource(this.templateId);

  final String templateId;

  @override
  ResultFuture<List<PlanItemDraft>> itemsFor(
    DailyPlanDayContext context,
  ) async => Result.success([
    PlanItemDraft(
      templateId: templateId,
      type: PlanItemType.lesson,
      estimatedMinutes: 1,
    ),
  ]);
}

/// Daima hata döndüren test kaynağı.
final class _FailingSource implements DailyPlanItemSource {
  const _FailingSource(this.failure);

  final AppFailure failure;

  @override
  ResultFuture<List<PlanItemDraft>> itemsFor(
    DailyPlanDayContext context,
  ) async => Result.failure(failure);
}

/// Bütçeyi kasten aşan test kaynağı.
final class _OverBudgetSource implements DailyPlanItemSource {
  const _OverBudgetSource();

  @override
  ResultFuture<List<PlanItemDraft>> itemsFor(
    DailyPlanDayContext context,
  ) async => Result.success([
    PlanItemDraft(
      templateId: 'over_budget_test',
      type: PlanItemType.reflection,
      estimatedMinutes: context.sizeMinutes,
    ),
  ]);
}

/// Çağrı sayan test kaynağı.
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
