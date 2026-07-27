import 'dart:io';

import 'package:bismillah_app/app/app_bootstrap.dart';
import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_daily_pace.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/services/composite_daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/services/core_daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_generation_request.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_generator.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/services/learn_daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/services/prayer_daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/services/quran_daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/value_objects/daily_plan_profile_type.dart';
import 'package:bismillah_app/features/today/domain/value_objects/learn_daily_plan_catalog.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';
import '../../../helpers/test_session.dart';

/// Learn plan öğesi kaynağı ve tam çekirdek bileşim (TASK 082).
///
/// Üretilen Learn öğesi, yayınlanmış ve kaynak gövdesi doğrulanmış bir
/// makaleyi açma/sürdürme eylemidir: makale metni, başlığı, çevirisi veya
/// kaynak metni plana KOPYALANMAZ ve üretim sırasında hiçbir Learn
/// repository'si okunmaz.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const learnSource = LearnDailyPlanItemSource();
  const catalog = LearnDailyPlanCatalog.v1;
  const trackId = PrayerDailyPlanItemSource.trackDailyTemplateId;
  const onTimeId = PrayerDailyPlanItemSource.onTimeDailyTemplateId;
  const quranId = QuranDailyPlanItemSource.continueDailyTemplateId;

  String learnTemplateAt(int offset) => catalog.entries[offset].templateId;
  String learnArticleAt(int offset) => catalog.entries[offset].articleId;

  /// Onaylı çekirdek sıra: Prayer → Quran → Learn.
  const coreSource = CoreDailyPlanItemSource.approved;

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

  const allCoreGoals = {
    OnboardingFocusGoal.trackPrayers,
    OnboardingFocusGoal.prayOnTime,
    OnboardingFocusGoal.quranHabit,
    OnboardingFocusGoal.islamicKnowledge,
  };

  DailyPlanDayContext context({
    Set<OnboardingFocusGoal> goals = const {
      OnboardingFocusGoal.islamicKnowledge,
    },
    DailyPlanProfileType profileType = DailyPlanProfileType.learningFocused,
    OnboardingDailyPace dailyPace = OnboardingDailyPace.balanced,
    int sizeMinutes = 10,
    String dayKey = '2026-07-26',
    int dayOffset = 0,
    int? weekIndex,
  }) => DailyPlanDayContext(
    profileType: profileType,
    goals: OnboardingFocusGoal.values.where(goals.contains).toList(),
    dailyPace: dailyPace,
    sizeMinutes: sizeMinutes,
    dayKey: DayKey(dayKey),
    dayOffset: dayOffset,
    weekIndex: weekIndex ?? DailyPlanGenerator.weekIndexForOffset(dayOffset),
  );

  Future<List<PlanItemDraft>> draftsFrom(
    DailyPlanItemSource source,
    DailyPlanDayContext ctx,
  ) async {
    final result = await source.itemsFor(ctx);
    expect(result.isSuccess, isTrue, reason: 'geçerli bağlam başarılı olmalı');
    return result.valueOrNull!;
  }

  List<String> templateIds(List<PlanItemDraft> list) => [
    for (final draft in list) draft.templateId,
  ];

  DailyPlanGenerationRequest request({
    Set<OnboardingFocusGoal> goals = const {
      OnboardingFocusGoal.islamicKnowledge,
    },
    DailyPlanProfileType profileType = DailyPlanProfileType.learningFocused,
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
    DailyPlanItemSource source = coreSource,
  }) async {
    final result = await DailyPlanGenerator.generate(req, source: source);
    expect(result.isSuccess, isTrue);
    return result.valueOrNull!;
  }

  group('hedef seçimi', () {
    test('yalnız islamicKnowledge → tek taslak', () async {
      final list = await draftsFrom(
        learnSource,
        context(goals: const {OnboardingFocusGoal.islamicKnowledge}),
      );
      expect(templateIds(list), [learnTemplateAt(0)]);
    });

    test('islamicKnowledge + ilgisiz hedefler → yine tek taslak', () async {
      final list = await draftsFrom(
        learnSource,
        context(
          goals: const {
            OnboardingFocusGoal.islamicKnowledge,
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.dhikrRoutine,
          },
        ),
      );
      expect(templateIds(list), [learnTemplateAt(0)]);
    });

    test('tüm hedefler → tam olarak bir Learn taslağı', () async {
      final list = await draftsFrom(
        learnSource,
        context(goals: OnboardingFocusGoal.values.toSet()),
      );
      expect(list.length, 1);
      expect(templateIds(list), [learnTemplateAt(0)]);
    });

    test('islamicKnowledge yoksa boş liste (hata değil)', () async {
      final result = await learnSource.itemsFor(
        context(goals: const {OnboardingFocusGoal.trackPrayers}),
      );
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isEmpty);
    });

    test('ilgisiz hedeflerin hiçbiri Learn öğesi üretmez', () async {
      for (final goal in [
        OnboardingFocusGoal.trackPrayers,
        OnboardingFocusGoal.prayOnTime,
        OnboardingFocusGoal.quranHabit,
        OnboardingFocusGoal.dhikrRoutine,
      ]) {
        expect(await draftsFrom(learnSource, context(goals: {goal})), isEmpty);
      }
    });

    test('learning_focused profili TEK BAŞINA öğe üretmez', () async {
      final list = await draftsFrom(
        learnSource,
        context(
          goals: const {OnboardingFocusGoal.trackPrayers},
          profileType: DailyPlanProfileType.learningFocused,
        ),
      );
      expect(list, isEmpty, reason: 'öğe profilden değil HEDEFTEN gelir');
    });

    test('Set ekleme sırası sonucu DEĞİŞTİRMEZ', () async {
      final forward = await draftsFrom(
        learnSource,
        context(
          goals: {
            OnboardingFocusGoal.islamicKnowledge,
            OnboardingFocusGoal.quranHabit,
          },
        ),
      );
      final reverse = await draftsFrom(
        learnSource,
        context(
          goals: {
            OnboardingFocusGoal.quranHabit,
            OnboardingFocusGoal.islamicKnowledge,
          },
        ),
      );
      expect(templateIds(forward), templateIds(reverse));
    });

    test('boş hedef listesi boş katkı verir', () async {
      expect(await draftsFrom(learnSource, context(goals: const {})), isEmpty);
    });
  });

  group('gün ofseti eşlemesi', () {
    for (var offset = 0; offset < 30; offset++) {
      test('ofset $offset katalog girişi $offset\'i seçer', () async {
        final list = await draftsFrom(learnSource, context(dayOffset: offset));
        expect(list.single.targetRef, learnArticleAt(offset));
        expect(list.single.templateId, learnTemplateAt(offset));
      });
    }

    test('30 gün boyunca makale kimlikleri TEKİLDİR', () async {
      final refs = <String>[];
      for (var offset = 0; offset < 30; offset++) {
        final list = await draftsFrom(learnSource, context(dayOffset: offset));
        refs.add(list.single.targetRef!);
      }
      expect(refs.length, 30);
      expect(refs.toSet().length, 30, reason: 'hiçbir makale tekrarlanmaz');
    });

    test('modülo/döngü yoktur — ofset 0 ve 30 aynı sonucu VERMEZ', () async {
      final first = await draftsFrom(learnSource, context(dayOffset: 0));
      final beyond = await learnSource.itemsFor(context(dayOffset: 30));
      expect(first.single.targetRef, learnArticleAt(0));
      expect(beyond.isFailure, isTrue, reason: '30 sözleşme dışıdır');
    });

    test('negatif ofset tipli doğrulama hatası verir', () async {
      final result = await learnSource.itemsFor(context(dayOffset: -1));
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.valueOrNull, isNull);
    });

    test('katalog dışı ofset tipli doğrulama hatası verir', () async {
      for (final offset in [30, 31, 365]) {
        final result = await learnSource.itemsFor(context(dayOffset: offset));
        expect(
          result.failureOrNull,
          isA<ValidationFailure>(),
          reason: '$offset',
        );
      }
    });

    test('hedef yoksa geçersiz ofset bile hata ÜRETMEZ', () async {
      final result = await learnSource.itemsFor(
        context(goals: const {OnboardingFocusGoal.quranHabit}, dayOffset: 99),
      );
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isEmpty);
    });

    test('gün anahtarı seçimi ETKİLEMEZ (yalnız ofset)', () async {
      for (final day in ['2026-01-01', '2028-02-29', '2030-12-31']) {
        final list = await draftsFrom(
          learnSource,
          context(dayKey: day, dayOffset: 7),
        );
        expect(list.single.targetRef, learnArticleAt(7));
      }
    });

    test('tempo seçimi ETKİLEMEZ', () async {
      for (final pace in OnboardingDailyPace.values) {
        final list = await draftsFrom(
          learnSource,
          context(dailyPace: pace, dayOffset: 12, sizeMinutes: 30),
        );
        expect(list.single.targetRef, learnArticleAt(12));
      }
    });
  });

  group('PlanItem temsili', () {
    test('tip PlanItemType.lesson', () async {
      final list = await draftsFrom(learnSource, context());
      expect(list.single.type, PlanItemType.lesson);
    });

    test('targetRef stabil makale kimliğidir', () async {
      final list = await draftsFrom(learnSource, context(dayOffset: 3));
      expect(list.single.targetRef, 'art-kelime-i-sehadet');
    });

    test('sizeParam null kalır (miktar iddia edilmez)', () async {
      final list = await draftsFrom(learnSource, context());
      expect(list.single.sizeParam, isNull);
    });

    test('estimatedMinutes 1', () async {
      final list = await draftsFrom(learnSource, context());
      expect(list.single.estimatedMinutes, 1);
      expect(LearnDailyPlanItemSource.estimatedMinutes, 1);
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

    test('targetRef başlık/gövde/çeviri metni DEĞİLDİR', () async {
      for (var offset = 0; offset < 30; offset++) {
        final list = await draftsFrom(learnSource, context(dayOffset: offset));
        final ref = list.single.targetRef!;
        expect(ref, startsWith('art-'));
        expect(ref, isNot(contains(' ')));
        expect(ref, isNot(matches(RegExp(r'[çğıöşüÇĞİÖŞÜ؀-ۿ]'))));
      }
    });

    test('şablon kimliği seçilen makaleyi güvenle temsil eder', () async {
      final list = await draftsFrom(learnSource, context(dayOffset: 17));
      expect(list.single.templateId, 'learn_article_${list.single.targetRef}');
    });
  });

  group('profil bağımsızlığı', () {
    for (final entry in compatiblePace.entries) {
      test('${entry.key.id}: aynı ofset aynı makaleyi seçer', () async {
        final list = await draftsFrom(
          learnSource,
          context(
            profileType: entry.key,
            dailyPace: entry.value,
            dayOffset: 9,
            sizeMinutes: 30,
          ),
        );
        expect(list.single.targetRef, learnArticleAt(9));
        expect(list.single.templateId, learnTemplateAt(9));
        expect(list.single.type, PlanItemType.lesson);
        expect(list.single.estimatedMinutes, 1);
      });
    }

    test('HER profil kapsanmıştır (kapsam kilidi)', () {
      expect(compatiblePace.keys.toSet(), DailyPlanProfileType.values.toSet());
    });

    test('learning_focused EK makale ALMAZ', () async {
      final focused = await draftsFrom(
        learnSource,
        context(profileType: DailyPlanProfileType.learningFocused),
      );
      final beginner = await draftsFrom(
        learnSource,
        context(profileType: DailyPlanProfileType.beginner),
      );
      expect(focused.length, 1);
      expect(templateIds(focused), templateIds(beginner));
    });

    test('low_time azaltılmaz, advanced artırılmaz', () async {
      for (final profile in [
        DailyPlanProfileType.lowTime,
        DailyPlanProfileType.advanced,
      ]) {
        final plans = await generate(
          request(profileType: profile, dailyPace: compatiblePace[profile]!),
          source: learnSource,
        );
        expect(plans.every((p) => p.items.length == 1), isTrue);
      }
    });

    test('profil stabil kimliği değiştirilmez', () async {
      for (final entry in compatiblePace.entries) {
        final plans = await generate(
          request(profileType: entry.key, dailyPace: entry.value),
          source: learnSource,
        );
        expect(plans.every((p) => p.profileType == entry.key.id), isTrue);
      }
    });

    test('tüm profiller 30 gün boyunca AYNI makale dizisini alır', () async {
      List<String?> refsOf(List<DailyPlan> plans) => [
        for (final plan in plans) plan.items.single.targetRef,
      ];
      final baseline = refsOf(
        await generate(
          request(profileType: DailyPlanProfileType.beginner),
          source: learnSource,
        ),
      );
      for (final entry in compatiblePace.entries) {
        expect(
          refsOf(
            await generate(
              request(profileType: entry.key, dailyPace: entry.value),
              source: learnSource,
            ),
          ),
          baseline,
          reason: entry.key.id,
        );
      }
    });
  });

  group('ilerleme fazı bağımsızlığı', () {
    test('faz 0–3 aynı ofsette aynı öğeyi verir', () async {
      for (final weekIndex in [0, 1, 2, 3]) {
        final list = await draftsFrom(
          learnSource,
          context(dayOffset: 5, weekIndex: weekIndex),
        );
        expect(list.single.targetRef, learnArticleAt(5));
        expect(list.single.templateId, learnTemplateAt(5));
        expect(list.single.type, PlanItemType.lesson);
        expect(list.single.estimatedMinutes, 1);
        expect(list.single.sizeParam, isNull);
      }
    });

    test('faz sınırlarında makale yalnız ofsetle değişir', () async {
      for (final offset in [6, 7, 13, 14, 20, 21, 28, 29]) {
        final list = await draftsFrom(learnSource, context(dayOffset: offset));
        expect(list.single.targetRef, learnArticleAt(offset));
        expect(list.single.estimatedMinutes, 1);
      }
    });

    test('30 günün tamamında öğe sayısı ve maliyet sabittir', () async {
      final plans = await generate(request(), source: learnSource);
      expect(plans.every((p) => p.items.length == 1), isTrue);
      expect(plans.map((p) => p.weekIndex).toSet(), {0, 1, 2, 3});
    });
  });

  group('çekirdek bileşim sırası', () {
    test('Prayer → Quran → Learn sırası korunur', () async {
      final list = await draftsFrom(coreSource, context(goals: allCoreGoals));
      expect(templateIds(list), [
        trackId,
        onTimeId,
        quranId,
        learnTemplateAt(0),
      ]);
    });

    test('yalnız Learn hedefi → yalnız Learn', () async {
      final list = await draftsFrom(
        coreSource,
        context(goals: const {OnboardingFocusGoal.islamicKnowledge}),
      );
      expect(templateIds(list), [learnTemplateAt(0)]);
    });

    test('yalnız Prayer hedefleri → Learn yok', () async {
      final list = await draftsFrom(
        coreSource,
        context(
          goals: const {
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.prayOnTime,
          },
        ),
      );
      expect(templateIds(list), [trackId, onTimeId]);
    });

    test('yalnız Quran hedefi → Learn yok', () async {
      final list = await draftsFrom(
        coreSource,
        context(goals: const {OnboardingFocusGoal.quranHabit}),
      );
      expect(templateIds(list), [quranId]);
    });

    test('Prayer + Learn', () async {
      final list = await draftsFrom(
        coreSource,
        context(
          goals: const {
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.islamicKnowledge,
          },
        ),
      );
      expect(templateIds(list), [trackId, learnTemplateAt(0)]);
    });

    test('Quran + Learn', () async {
      final list = await draftsFrom(
        coreSource,
        context(
          goals: const {
            OnboardingFocusGoal.quranHabit,
            OnboardingFocusGoal.islamicKnowledge,
          },
        ),
      );
      expect(templateIds(list), [quranId, learnTemplateAt(0)]);
    });

    test('ilgili hedef yoksa boş', () async {
      final list = await draftsFrom(
        coreSource,
        context(goals: const {OnboardingFocusGoal.dhikrRoutine}),
      );
      expect(list, isEmpty);
    });

    test('yapıcı sırası belirleyicidir (ters sıra ters çıktı)', () async {
      const reversed = CompositeDailyPlanItemSource(
        sources: [
          LearnDailyPlanItemSource(),
          QuranDailyPlanItemSource(),
          PrayerDailyPlanItemSource(),
        ],
      );
      final list = await draftsFrom(reversed, context(goals: allCoreGoals));
      expect(templateIds(list), [
        learnTemplateAt(0),
        quranId,
        trackId,
        onTimeId,
      ]);
    });

    test('hedef Set sırası bileşim sırasını DEĞİŞTİRMEZ', () async {
      final forward = await draftsFrom(
        coreSource,
        context(
          goals: {
            OnboardingFocusGoal.islamicKnowledge,
            OnboardingFocusGoal.quranHabit,
            OnboardingFocusGoal.prayOnTime,
            OnboardingFocusGoal.trackPrayers,
          },
        ),
      );
      final reverse = await draftsFrom(
        coreSource,
        context(
          goals: {
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.prayOnTime,
            OnboardingFocusGoal.quranHabit,
            OnboardingFocusGoal.islamicKnowledge,
          },
        ),
      );
      expect(templateIds(forward), templateIds(reverse));
      expect(templateIds(forward), [
        trackId,
        onTimeId,
        quranId,
        learnTemplateAt(0),
      ]);
    });

    test('her çocuk gün başına bir kez çağrılır', () async {
      final counting = _CountingSource();
      final composite = CompositeDailyPlanItemSource(
        sources: [counting, learnSource],
      );
      await draftsFrom(composite, context());
      expect(counting.calls, 1);
    });

    test('tekrar denetimi aktiftir', () async {
      const duplicated = CompositeDailyPlanItemSource(
        sources: [LearnDailyPlanItemSource(), LearnDailyPlanItemSource()],
      );
      final result = await duplicated.itemsFor(context());
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.valueOrNull, isNull);
    });

    test('çocuk hatası kısmi katkı DÖNDÜRMEZ', () async {
      const composite = CompositeDailyPlanItemSource(
        sources: [
          PrayerDailyPlanItemSource(),
          QuranDailyPlanItemSource(),
          LearnDailyPlanItemSource(),
          _FailingSource(NetworkFailure()),
        ],
      );
      final result = await composite.itemsFor(context(goals: allCoreGoals));
      expect(result.failureOrNull, isA<NetworkFailure>());
      expect(result.valueOrNull, isNull);
    });

    test('withCatalog aynı sırayı kurar', () async {
      final list = await draftsFrom(
        CoreDailyPlanItemSource.withCatalog(catalog),
        context(goals: allCoreGoals),
      );
      expect(templateIds(list), [
        trackId,
        onTimeId,
        quranId,
        learnTemplateAt(0),
      ]);
    });

    test('withCatalog kontrollü katalog enjekte eder', () async {
      final injected = LearnDailyPlanCatalog(
        entries: [
          for (var i = 0; i < 30; i++) LearnPlanCatalogEntry('art-test-$i'),
        ],
      );
      final list = await draftsFrom(
        CoreDailyPlanItemSource.withCatalog(injected),
        context(goals: allCoreGoals, dayOffset: 4),
      );
      expect(list.last.targetRef, 'art-test-4');
      expect(list.last.templateId, 'learn_article_art-test-4');
    });
  });

  group('kimlik kararlılığı', () {
    test('nihai kimlik builder biçimini korur', () async {
      final plans = await generate(request(goals: allCoreGoals));
      expect(plans.first.items.map((i) => i.itemId.value).toList(), [
        'rule-engine-v1:2026-07-26:prayer_track_daily:0',
        'rule-engine-v1:2026-07-26:prayer_on_time_daily:1',
        'rule-engine-v1:2026-07-26:quran_continue_daily:2',
        'rule-engine-v1:2026-07-26:learn_article_art-islam-nedir:3',
      ]);
    });

    test('aynı istek aynı Learn kimliklerini verir', () async {
      final req = request(goals: allCoreGoals);
      final baseline = _learnIds(await generate(req));
      for (var i = 0; i < 20; i++) {
        expect(_learnIds(await generate(req)), baseline);
      }
    });

    test('farklı günler çakışmaz', () async {
      final plans = await generate(request(), source: learnSource);
      final ids = [for (final p in plans) p.items.single.itemId.value];
      expect(ids.toSet().length, 30);
    });

    test('aynı gün içinde Prayer/Quran/Learn çakışmaz', () async {
      final plans = await generate(request(goals: allCoreGoals));
      for (final plan in plans) {
        final ids = [for (final i in plan.items) i.itemId.value];
        expect(ids.toSet().length, 4);
      }
    });

    test('Learn eklenmesi Prayer/Quran kimliklerini DEĞİŞTİRMEZ', () async {
      const prayerAndQuran = CompositeDailyPlanItemSource(
        sources: [PrayerDailyPlanItemSource(), QuranDailyPlanItemSource()],
      );
      final without = await generate(
        request(goals: allCoreGoals),
        source: prayerAndQuran,
      );
      final withLearn = await generate(request(goals: allCoreGoals));

      for (var day = 0; day < 30; day++) {
        expect(
          withLearn[day].items.take(3).map((i) => i.itemId.value).toList(),
          without[day].items.map((i) => i.itemId.value).toList(),
          reason: 'gün $day',
        );
        expect(withLearn[day].items.length, 4);
      }
    });

    test('Learn nihai kimliği makale kimliğini taşır', () async {
      final plans = await generate(request(), source: learnSource);
      for (var day = 0; day < 30; day++) {
        expect(
          plans[day].items.single.itemId.value,
          contains(learnArticleAt(day)),
        );
      }
    });

    test('kimlik zaman/UUID/hashCode/locale/cihaz verisi taşımaz', () async {
      final plans = await generate(request(goals: allCoreGoals));
      final rendered = _project(plans).join('\n');
      expect(rendered, isNot(matches(RegExp(r'\d{13}'))));
      expect(
        rendered,
        isNot(matches(RegExp(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}'))),
      );
      for (final forbidden in ['uid', 'deviceId', 'locale', 'tz', 'random']) {
        expect(rendered, isNot(contains(forbidden)));
      }
    });
  });

  group('bütçe', () {
    Future<int> costOf(Set<OnboardingFocusGoal> goals) async {
      final list = await draftsFrom(coreSource, context(goals: goals));
      return list.fold<int>(0, (sum, d) => sum + d.estimatedMinutes);
    }

    test('yalnız Learn maliyeti 1', () async {
      expect(await costOf(const {OnboardingFocusGoal.islamicKnowledge}), 1);
    });

    test('Quran + Learn maliyeti 3', () async {
      expect(
        await costOf(const {
          OnboardingFocusGoal.quranHabit,
          OnboardingFocusGoal.islamicKnowledge,
        }),
        3,
      );
    });

    test('tek Prayer + Quran + Learn maliyeti 4', () async {
      expect(
        await costOf(const {
          OnboardingFocusGoal.trackPrayers,
          OnboardingFocusGoal.quranHabit,
          OnboardingFocusGoal.islamicKnowledge,
        }),
        4,
      );
    });

    test('iki Prayer + Quran + Learn maliyeti 5', () async {
      expect(await costOf(allCoreGoals), 5);
    });

    test('light (5 dk) tam çekirdeği TAM OLARAK taşır', () async {
      final plans = await generate(
        request(
          goals: allCoreGoals,
          profileType: DailyPlanProfileType.lowTime,
          dailyPace: OnboardingDailyPace.light,
        ),
      );
      expect(plans.first.sizeMinutes, 5);
      expect(plans.every((p) => p.items.length == 4), isTrue);
    });

    test('balanced/focused/advanced-focused bütçeleri de kabul eder', () async {
      final cases = <(DailyPlanProfileType, OnboardingDailyPace, int)>[
        (DailyPlanProfileType.beginner, OnboardingDailyPace.balanced, 10),
        (DailyPlanProfileType.beginner, OnboardingDailyPace.focused, 20),
        (DailyPlanProfileType.advanced, OnboardingDailyPace.focused, 30),
      ];
      for (final (profile, pace, expected) in cases) {
        final plans = await generate(
          request(goals: allCoreGoals, profileType: profile, dailyPace: pace),
        );
        expect(plans.first.sizeMinutes, expected);
        expect(plans.every((p) => p.items.length == 4), isTrue);
      }
    });

    test('tüm geçerli profil/tempo çiftleri dört öğeyi kabul eder', () async {
      for (final entry in compatiblePace.entries) {
        final plans = await generate(
          request(
            goals: allCoreGoals,
            profileType: entry.key,
            dailyPace: entry.value,
          ),
        );
        expect(plans.every((p) => p.items.length == 4), isTrue);
      }
    });

    test('tam çekirdek + 1 dk ek katkı light bütçesini AŞAR', () async {
      final result = await DailyPlanGenerator.generate(
        request(
          goals: allCoreGoals,
          profileType: DailyPlanProfileType.lowTime,
          dailyPace: OnboardingDailyPace.light,
        ),
        source: const CompositeDailyPlanItemSource(
          sources: [
            PrayerDailyPlanItemSource(),
            QuranDailyPlanItemSource(),
            LearnDailyPlanItemSource(),
            _OneMinuteSource('extra_minute_test'),
          ],
        ),
      );
      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull, reason: 'kısmi 30 gün dönmez');
    });

    test('bütçe toplamı TÜM çocuk kaynakları kapsar', () async {
      final list = await draftsFrom(coreSource, context(goals: allCoreGoals));
      expect(list.length, 4);
      expect(list.map((d) => d.estimatedMinutes).toList(), [1, 1, 2, 1]);
    });

    test('estimatedMinutes kalıcı plana YAZILMAZ', () async {
      final plans = await generate(request(goals: allCoreGoals));
      expect(plans.first.items.every((i) => i.sizeParam == null), isTrue);
      expect(
        plans.first.sizeMinutes,
        10,
        reason: 'gün bütçesi, öğe süresi değil',
      );
    });

    test('bütçe aşımında öğe sessizce ATILMAZ', () async {
      final result = await DailyPlanGenerator.generate(
        request(
          goals: allCoreGoals,
          profileType: DailyPlanProfileType.lowTime,
          dailyPace: OnboardingDailyPace.light,
        ),
        source: const CompositeDailyPlanItemSource(
          sources: [
            PrayerDailyPlanItemSource(),
            QuranDailyPlanItemSource(),
            LearnDailyPlanItemSource(),
            _OneMinuteSource('silent_drop_test'),
          ],
        ),
      );
      expect(result.isFailure, isTrue);
    });
  });

  group('bozuk katalog davranışı', () {
    test('eksik girişli katalog tipli hata verir', () async {
      const short = LearnDailyPlanItemSource(
        catalog: LearnDailyPlanCatalog(
          entries: [LearnPlanCatalogEntry('art-islam-nedir')],
        ),
      );
      final result = await short.itemsFor(context());
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.valueOrNull, isNull);
    });

    test('tekrar eden makale kimliği tipli hata verir', () async {
      final duplicated = LearnDailyPlanItemSource(
        catalog: LearnDailyPlanCatalog(
          entries: [
            for (var i = 0; i < 30; i++)
              LearnPlanCatalogEntry(i == 29 ? 'art-test-0' : 'art-test-$i'),
          ],
        ),
      );
      final result = await duplicated.itemsFor(context());
      expect(result.failureOrNull, isA<ValidationFailure>());
    });

    test('bozuk katalog 30 günlük üretimi TAMAMEN başarısız kılar', () async {
      final result = await DailyPlanGenerator.generate(
        request(),
        source: const LearnDailyPlanItemSource(
          catalog: LearnDailyPlanCatalog(entries: []),
        ),
      );
      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);
    });

    test('hata nesnesi katalog/makale/hedef/gün bilgisi taşımaz', () async {
      const short = LearnDailyPlanItemSource(
        catalog: LearnDailyPlanCatalog(entries: []),
      );
      final rendered = (await short.itemsFor(
        context(),
      )).failureOrNull.toString();
      for (final forbidden in [
        'LearnDailyPlanItemSource',
        'art-islam-nedir',
        'learn_article_',
        'islamicKnowledge',
        '2026-07-26',
        'assets/',
        'Exception',
        '#0',
      ]) {
        expect(rendered, isNot(contains(forbidden)));
      }
    });

    test('hata deterministiktir', () async {
      const short = LearnDailyPlanItemSource(
        catalog: LearnDailyPlanCatalog(entries: []),
      );
      for (var i = 0; i < 20; i++) {
        expect((await short.itemsFor(context())).isFailure, isTrue);
      }
    });
  });

  group('30 günlük entegrasyon', () {
    final scenarios = <String, (Set<OnboardingFocusGoal>, int, bool)>{
      'yalnız islamicKnowledge': (
        {OnboardingFocusGoal.islamicKnowledge},
        1,
        true,
      ),
      'Quran + Learn': (
        {OnboardingFocusGoal.quranHabit, OnboardingFocusGoal.islamicKnowledge},
        2,
        true,
      ),
      'Prayer + Learn': (
        {
          OnboardingFocusGoal.trackPrayers,
          OnboardingFocusGoal.prayOnTime,
          OnboardingFocusGoal.islamicKnowledge,
        },
        3,
        true,
      ),
      'Prayer + Quran + Learn': (allCoreGoals, 4, true),
      'tüm hedefler': (OnboardingFocusGoal.values.toSet(), 4, true),
      'Learn hedefi yok': (
        {OnboardingFocusGoal.trackPrayers, OnboardingFocusGoal.quranHabit},
        2,
        false,
      ),
    };

    for (final entry in scenarios.entries) {
      final (goals, itemCount, hasLearn) = entry.value;
      test('${entry.key}: 30 gün × $itemCount öğe', () async {
        final plans = await generate(request(goals: goals));

        expect(plans.length, 30);
        expect(plans.every((p) => p.items.length == itemCount), isTrue);
        expect(plans.map((p) => p.dayKey.value).toSet().length, 30);
        expect(plans.every((p) => p.profileType == 'learning_focused'), isTrue);
        expect(
          plans.every(
            (p) => p.items.every((i) => i.status == PlanItemStatus.pending),
          ),
          isTrue,
        );
        expect(
          plans.every((p) => p.sizeMinutes >= _costOfPlan(p)),
          isTrue,
          reason: 'bütçe aşılmadı',
        );

        final ids = [
          for (final plan in plans)
            for (final item in plan.items) item.itemId.value,
        ];
        expect(ids.toSet().length, ids.length, reason: 'nihai kimlik tekil');

        for (var day = 0; day < 30; day++) {
          final lessons = plans[day].items.where(
            (i) => i.type == PlanItemType.lesson,
          );
          if (hasLearn) {
            expect(lessons.single.targetRef, learnArticleAt(day));
            expect(
              lessons.single,
              plans[day].items.last,
              reason: 'Learn sonda',
            );
          } else {
            expect(lessons, isEmpty);
          }
        }
      });
    }

    test('gün anahtarları kesintisiz ve artan', () async {
      final plans = await generate(request(goals: allCoreGoals));
      for (var day = 0; day < 30; day++) {
        expect(
          plans[day].dayKey,
          DailyPlanGenerator.dayAt(DayKey('2026-07-26'), day),
        );
      }
    });

    test('50 tekrar aynı çıktıyı verir', () async {
      final req = request(goals: allCoreGoals);
      final baseline = _project(await generate(req));
      for (var i = 0; i < 50; i++) {
        expect(_project(await generate(req)), baseline);
      }
    });

    test('30 makale kimliğinin tamamı katalog sırasındadır', () async {
      final plans = await generate(request(), source: learnSource);
      expect(
        [for (final p in plans) p.items.single.targetRef],
        [for (final e in catalog.entries) e.articleId],
      );
    });
  });

  group('yan etki yokluğu', () {
    final sourceFiles = <String, String>{
      'learn_daily_plan_item_source.dart': File(
        'lib/features/today/domain/services/learn_daily_plan_item_source.dart',
      ).readAsStringSync(),
      'learn_daily_plan_catalog.dart': File(
        'lib/features/today/domain/value_objects/learn_daily_plan_catalog.dart',
      ).readAsStringSync(),
      'core_daily_plan_item_source.dart': File(
        'lib/features/today/domain/services/core_daily_plan_item_source.dart',
      ).readAsStringSync(),
    };

    test('üretim kaynağı yasaklı bağımlılık import ETMEZ', () {
      const forbiddenImports = [
        'features/learn/',
        'shared_preferences',
        'drift',
        'firebase',
        'cloud_firestore',
        'flutter_riverpod',
        'package:flutter/material.dart',
        'package:flutter/widgets.dart',
        'services/asset_bundle',
        'rootBundle',
        'dart:io',
        'dart:math',
        'daily_plan_repository',
      ];
      sourceFiles.forEach((name, content) {
        final imports = content
            .split('\n')
            .where((line) => line.trimLeft().startsWith('import '))
            .join('\n');
        for (final forbidden in forbiddenImports) {
          expect(
            imports,
            isNot(contains(forbidden)),
            reason: '$name: $forbidden',
          );
        }
      });
    });

    test('üretim kaynağı saat/locale/rastgelelik KULLANMAZ', () {
      const forbidden = [
        'DateTime.now',
        'Random(',
        'Localizations',
        'Intl.',
        'timeZone',
        'print(',
        'debugPrint',
      ];
      sourceFiles.forEach((name, content) {
        for (final token in forbidden) {
          expect(content, isNot(contains(token)), reason: '$name: $token');
        }
      });
    });

    test('kimlik türetiminde hashCode KULLANILMAZ', () {
      // Kaynak ve bileşim dosyalarında hashCode hiç geçmez.
      for (final name in [
        'learn_daily_plan_item_source.dart',
        'core_daily_plan_item_source.dart',
      ]) {
        expect(sourceFiles[name], isNot(contains('hashCode')), reason: name);
      }
      // Katalogda yalnız DEĞER EŞİTLİĞİ için geçer; şablon/makale kimliği
      // düz metin birleştirmedir.
      final catalogSource = sourceFiles['learn_daily_plan_catalog.dart']!;
      final catalogCodeLines = catalogSource
          .split('\n')
          .where((line) => !line.trimLeft().startsWith('//'))
          .where((line) => line.contains('hashCode'))
          .map((line) => line.trim())
          .toList();
      expect(
        catalogCodeLines,
        ['int get hashCode => articleId.hashCode;'],
        reason: 'yalnız operator == eşleniği olan hashCode override\'ı',
      );
      expect(
        catalogSource,
        contains('static String templateIdFor(String articleId) =>'),
      );
      for (final entry in catalog.entries) {
        expect(entry.templateId, 'learn_article_${entry.articleId}');
      }
    });

    test('kaynak eşit bağlam için daima aynı sonucu verir', () async {
      final ctx = context(dayOffset: 11);
      final baseline = templateIds(await draftsFrom(learnSource, ctx));
      for (var i = 0; i < 50; i++) {
        expect(templateIds(await draftsFrom(learnSource, ctx)), baseline);
      }
    });

    test('bootstrap Learn kaynağını/bileşimi/üreticiyi ÇALIŞTIRMAZ', () async {
      final counting = _CountingSource();
      final container = ProviderContainer(
        overrides: [inMemoryAppDatabaseOverride(), ...testSessionOverrides()],
      );
      addTearDown(container.dispose);

      await initializeLocalPersistence(container);

      // Hiçbiri provider'a bağlı DEĞİLDİR; bootstrap onlara ulaşamaz.
      expect(counting.calls, 0);
    });

    test('üretim hiçbir planı KAYDETMEZ', () async {
      final plans = await generate(request(goals: allCoreGoals));
      expect(plans.length, 30);
      // Üretici saf statiktir ve repository almaz; kalıcılık orkestrasyonu
      // sonraki görevin işidir.
      expect(
        File(
          'lib/features/today/domain/services/daily_plan_generator.dart',
        ).readAsStringSync(),
        isNot(contains('DailyPlanRepository')),
      );
    });
  });

  group('dinî güvenlik ve gizlilik', () {
    test('üretilen plan makale metni/başlığı taşımaz', () async {
      final plans = await generate(request(goals: allCoreGoals));
      final rendered = _project(plans).join('\n');
      for (final forbidden in [
        'İslam nedir',
        'Abdest',
        'بِسْمِ',
        'http',
        'diyanet',
        'sourceLocator',
        'evidenceSummary',
        'latitude',
        'uid',
        'deviceId',
      ]) {
        expect(rendered, isNot(contains(forbidden)));
      }
    });

    test('şablon kimliği ödül/ceza/hüküm ifadesi içermez', () {
      for (final entry in catalog.entries) {
        for (final forbidden in [
          'sin',
          'reward',
          'punish',
          'obligat',
          'wajib',
          'score',
          'rank',
          'quota',
          'must',
          'fatwa',
        ]) {
          expect(entry.templateId, isNot(contains(forbidden)));
        }
      }
    });

    test('öğrenme miktarı veya tamamlama kotası iddia edilmez', () async {
      final plans = await generate(request(), source: learnSource);
      expect(
        plans.every((p) => p.items.every((i) => i.sizeParam == null)),
        isTrue,
      );
    });

    test('makale geçmişi okunmaz — her gün tamamlanmamış başlar', () async {
      final first = await generate(request(), source: learnSource);
      final second = await generate(request(), source: learnSource);
      for (final plans in [first, second]) {
        expect(
          plans.every(
            (p) => p.items.every(
              (i) =>
                  i.status == PlanItemStatus.pending && i.completedAt == null,
            ),
          ),
          isTrue,
        );
      }
    });

    test('hedef kümesi ham olarak plana sızmaz', () async {
      final plans = await generate(request(goals: allCoreGoals));
      final rendered = _project(plans).join('\n');
      for (final goal in OnboardingFocusGoal.values) {
        expect(rendered, isNot(contains(goal.name)));
      }
    });
  });
}

/// Bir günün toplam tahmini maliyeti (öğe sayısı üzerinden alt sınır).
int _costOfPlan(DailyPlan plan) => plan.items.length;

/// Karşılaştırılabilir çıktı izdüşümü.
List<String> _project(List<DailyPlan> plans) => [
  for (final plan in plans)
    [
      plan.dayKey.value,
      plan.profileType,
      '${plan.sizeMinutes}',
      '${plan.weekIndex}',
      plan.items
          .map((i) => '${i.itemId.value}|${i.type.name}|${i.targetRef}')
          .join(','),
    ].join('#'),
];

/// Yalnız Learn öğelerinin nihai kimlikleri.
List<String> _learnIds(List<DailyPlan> plans) => [
  for (final plan in plans)
    for (final item in plan.items)
      if (item.type == PlanItemType.lesson) item.itemId.value,
];

/// Bir dakikalık nötr ek katkı üreten test kaynağı.
final class _OneMinuteSource implements DailyPlanItemSource {
  const _OneMinuteSource(this.templateId);

  final String templateId;

  @override
  ResultFuture<List<PlanItemDraft>> itemsFor(
    DailyPlanDayContext context,
  ) async => Result.success([
    PlanItemDraft(
      templateId: templateId,
      type: PlanItemType.reflection,
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
