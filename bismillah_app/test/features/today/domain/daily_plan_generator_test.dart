import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_daily_pace.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_generation_request.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_generator.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/value_objects/daily_plan_profile_type.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';
import 'package:flutter_test/flutter_test.dart';

/// Deterministik 30 günlük plan üreticisi (TASK 079).
///
/// TASK 079 içerik ÜRETMEZ: varsayılan kaynak boştur, bu yüzden geçerli
/// çıktı 30 gün × boş `items`'tır. Testler saat/locale/timezone/
/// rastgelelikten bağımsızdır.
void main() {
  /// TASK 078 kurallarıyla üretilebilir profil × tempo birleşimleri.
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

  DailyPlanGenerationRequest request({
    DailyPlanProfileType profileType = DailyPlanProfileType.prayerFocused,
    Set<OnboardingFocusGoal> goals = const {OnboardingFocusGoal.trackPrayers},
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
    DailyPlanItemSource source = const EmptyDailyPlanItemSource(),
  }) async {
    final result = await DailyPlanGenerator.generate(req, source: source);
    expect(result.isSuccess, isTrue, reason: 'üretim başarılı olmalı');
    return result.valueOrNull!;
  }

  group('istek doğrulama', () {
    test('geçerli istek kabul edilir', () {
      expect(request().validate(), isNull);
      expect(request().isValid, isTrue);
    });

    test('her profil kendi uyumlu tempolarıyla geçerlidir', () {
      for (final entry in compatiblePace.entries) {
        expect(
          request(profileType: entry.key, dailyPace: entry.value).validate(),
          isNull,
          reason: '${entry.key.id} + ${entry.value.name} geçerli olmalı',
        );
      }
    });

    test('beginner ve returning HER tempoyla geçerlidir', () {
      for (final profile in [
        DailyPlanProfileType.beginner,
        DailyPlanProfileType.returning,
      ]) {
        for (final pace in OnboardingDailyPace.values) {
          expect(
            request(profileType: profile, dailyPace: pace).validate(),
            isNull,
          );
        }
      }
    });

    test('advanced yalnız focused ile geçerlidir', () {
      for (final pace in [
        OnboardingDailyPace.light,
        OnboardingDailyPace.balanced,
      ]) {
        expect(
          request(
            profileType: DailyPlanProfileType.advanced,
            dailyPace: pace,
          ).validate(),
          GenerationRequestIssue.profilePaceMismatch,
        );
      }
    });

    test('low_time yalnız light ile geçerlidir', () {
      for (final pace in [
        OnboardingDailyPace.balanced,
        OnboardingDailyPace.focused,
      ]) {
        expect(
          request(
            profileType: DailyPlanProfileType.lowTime,
            dailyPace: pace,
          ).validate(),
          GenerationRequestIssue.profilePaceMismatch,
        );
      }
    });

    test('odak profilleri light ile geçersizdir', () {
      for (final profile in [
        DailyPlanProfileType.prayerFocused,
        DailyPlanProfileType.quranFocused,
        DailyPlanProfileType.dhikrFocused,
        DailyPlanProfileType.learningFocused,
      ]) {
        expect(
          request(
            profileType: profile,
            dailyPace: OnboardingDailyPace.light,
          ).validate(),
          GenerationRequestIssue.profilePaceMismatch,
        );
      }
    });

    test('boş hedef kümesi geçersizdir', () {
      expect(
        request(goals: const {}).validate(),
        GenerationRequestIssue.emptyGoals,
      );
    });

    test('geçersiz istek tipli hata döner ve KISMİ çıktı vermez', () async {
      final result = await DailyPlanGenerator.generate(
        request(
          profileType: DailyPlanProfileType.advanced,
          dailyPace: OnboardingDailyPace.light,
        ),
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.valueOrNull, isNull);
    });

    test('tutarsız girdi SESSİZCE onarılmaz', () async {
      final result = await DailyPlanGenerator.generate(
        request(
          profileType: DailyPlanProfileType.lowTime,
          dailyPace: OnboardingDailyPace.focused,
        ),
      );
      expect(result.isFailure, isTrue);
    });
  });

  group('30 günlük yapı', () {
    test('tam olarak 30 kayıt üretir', () async {
      expect((await generate(request())).length, 30);
    });

    test('ilk gün startDay, son gün 29 gün sonrasıdır', () async {
      final plans = await generate(request(startDay: '2026-07-26'));
      expect(plans.first.dayKey.value, '2026-07-26');
      expect(plans.last.dayKey.value, '2026-08-24');
    });

    test('günler sürekli, tekil ve artan sıradadır', () async {
      final plans = await generate(request(startDay: '2026-03-15'));
      final keys = plans.map((p) => p.dayKey.value).toList();

      expect(keys.toSet().length, 30, reason: 'tekrar eden gün yok');
      expect(keys, orderedEquals(List.of(keys)..sort()));
      for (var i = 1; i < plans.length; i++) {
        expect(
          plans[i].dayKey,
          DailyPlanGenerator.dayAt(DayKey('2026-03-15'), i),
        );
      }
    });

    test('ay geçişi doğru', () async {
      final plans = await generate(request(startDay: '2026-01-20'));
      expect(plans.last.dayKey.value, '2026-02-18');
    });

    test('yıl geçişi doğru', () async {
      final plans = await generate(request(startDay: '2026-12-20'));
      expect(plans[11].dayKey.value, '2026-12-31');
      expect(plans[12].dayKey.value, '2027-01-01');
      expect(plans.last.dayKey.value, '2027-01-18');
    });

    test('artık gün (2028) doğru geçilir', () async {
      final plans = await generate(request(startDay: '2028-02-01'));
      final keys = plans.map((p) => p.dayKey.value).toList();
      expect(keys, contains('2028-02-29'));
      expect(keys, contains('2028-03-01'));
      expect(plans.last.dayKey.value, '2028-03-01');
    });

    test('artık olmayan yılda 29 Şubat ÜRETİLMEZ', () async {
      final plans = await generate(request(startDay: '2027-02-01'));
      final keys = plans.map((p) => p.dayKey.value).toList();
      expect(keys, isNot(contains('2027-02-29')));
      expect(keys, contains('2027-03-01'));
    });

    test('yaz saati geçişi gün ilerlemesini KAYDIRMAZ', () async {
      // Avrupa yaz saati geçişi 2026-03-29; gün anahtarları etkilenmez.
      final plans = await generate(request(startDay: '2026-03-25'));
      final keys = plans.map((p) => p.dayKey.value).toList();
      expect(keys.sublist(0, 8), [
        '2026-03-25',
        '2026-03-26',
        '2026-03-27',
        '2026-03-28',
        '2026-03-29',
        '2026-03-30',
        '2026-03-31',
        '2026-04-01',
      ]);
    });
  });

  group('dört fazlı ilerleme', () {
    test('faz sınırları onaylı kurala uyar', () {
      const expected = <int, int>{
        0: 0, // 1. gün
        6: 0, // 1. faz sonu
        7: 1, // 2. faz başı
        13: 1, // 2. faz sonu
        14: 2, // 3. faz başı
        20: 2, // 3. faz sonu
        21: 3, // 4. faz başı
        28: 3, // 29. gün
        29: 3, // 30. gün
      };
      for (final entry in expected.entries) {
        expect(
          DailyPlanGenerator.weekIndexForOffset(entry.key),
          entry.value,
          reason: 'ofset ${entry.key}',
        );
      }
    });

    test('weekIndex 4 ASLA üretilmez', () async {
      final plans = await generate(request());
      final indexes = plans.map((p) => p.weekIndex).toSet();
      expect(indexes, {0, 1, 2, 3});
      expect(indexes, isNot(contains(4)));
    });

    test('faz başına gün sayısı 7/7/7/9', () async {
      final plans = await generate(request());
      final counts = <int, int>{};
      for (final plan in plans) {
        counts[plan.weekIndex] = (counts[plan.weekIndex] ?? 0) + 1;
      }
      expect(counts, {0: 7, 1: 7, 2: 7, 3: 9});
    });
  });

  group('tempo ve zaman bütçesi', () {
    test('light 5, balanced 10, focused 20 dakikadır', () {
      expect(
        request(
          profileType: DailyPlanProfileType.lowTime,
          dailyPace: OnboardingDailyPace.light,
        ).sizeMinutes,
        5,
      );
      expect(
        request(
          profileType: DailyPlanProfileType.beginner,
          dailyPace: OnboardingDailyPace.balanced,
        ).sizeMinutes,
        10,
      );
      expect(
        request(
          profileType: DailyPlanProfileType.quranFocused,
          dailyPace: OnboardingDailyPace.focused,
        ).sizeMinutes,
        20,
      );
    });

    test('advanced + focused TEK profil-özel istisnadır → 30', () {
      expect(
        request(
          profileType: DailyPlanProfileType.advanced,
          dailyPace: OnboardingDailyPace.focused,
        ).sizeMinutes,
        30,
      );
      // Aynı tempo başka profilde 20 kalır — istisna genelleşmez.
      expect(
        request(
          profileType: DailyPlanProfileType.beginner,
          dailyPace: OnboardingDailyPace.focused,
        ).sizeMinutes,
        20,
      );
    });

    test('15 dakika ASLA üretilmez', () {
      for (final entry in compatiblePace.entries) {
        expect(
          request(profileType: entry.key, dailyPace: entry.value).sizeMinutes,
          isNot(15),
        );
      }
    });

    test('sizeMinutes 30 günün tamamına yazılır', () async {
      final plans = await generate(
        request(
          profileType: DailyPlanProfileType.advanced,
          dailyPace: OnboardingDailyPace.focused,
        ),
      );
      expect(plans.every((p) => p.sizeMinutes == 30), isTrue);
    });

    test('bütçeyi aşan kaynak çıktısı reddedilir (kısmi plan yok)', () async {
      final result = await DailyPlanGenerator.generate(
        request(
          profileType: DailyPlanProfileType.lowTime,
          dailyPace: OnboardingDailyPace.light,
        ),
        source: _FixedDraftSource([
          PlanItemDraft(
            templateId: 'tmpl-a',
            type: PlanItemType.reflection,
            estimatedMinutes: 4,
          ),
          PlanItemDraft(
            templateId: 'tmpl-b',
            type: PlanItemType.reflection,
            estimatedMinutes: 4,
          ),
        ]),
      );

      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);
    });

    test('bütçeye tam oturan kaynak kabul edilir', () async {
      final plans = await generate(
        request(
          profileType: DailyPlanProfileType.lowTime,
          dailyPace: OnboardingDailyPace.light,
        ),
        source: _FixedDraftSource([
          PlanItemDraft(
            templateId: 'tmpl-a',
            type: PlanItemType.reflection,
            estimatedMinutes: 5,
          ),
        ]),
      );
      expect(plans.every((p) => p.items.length == 1), isTrue);
    });
  });

  group('sekiz profil', () {
    for (final entry in compatiblePace.entries) {
      test('${entry.key.id} geçerli 30 günlük çıktı üretir', () async {
        final plans = await generate(
          request(profileType: entry.key, dailyPace: entry.value),
        );

        expect(plans.length, 30);
        expect(plans.every((p) => p.profileType == entry.key.id), isTrue);
        expect(plans.every((p) => p.generatedBy == 'rule-engine-v1'), isTrue);
      });
    }

    test('HER kanonik profil kapsanmıştır (kapsam kilidi)', () {
      // Yeni bir profil eklenirse üretim kuralı verilene kadar KIRILIR.
      expect(compatiblePace.keys.toSet(), DailyPlanProfileType.values.toSet());
    });

    test('profileType stabil kimlik yazar, toString DEĞİL', () async {
      final plans = await generate(
        request(profileType: DailyPlanProfileType.quranFocused),
      );
      expect(plans.first.profileType, 'quran_focused');
      expect(plans.first.profileType, isNot(contains('DailyPlanProfileType')));
    });
  });

  group('hedefler', () {
    test('hedef ekleme sırası çıktıyı DEĞİŞTİRMEZ', () async {
      final forward = await generate(
        request(
          goals: {
            OnboardingFocusGoal.islamicKnowledge,
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.quranHabit,
          },
        ),
      );
      final reverse = await generate(
        request(
          goals: {
            OnboardingFocusGoal.quranHabit,
            OnboardingFocusGoal.trackPrayers,
            OnboardingFocusGoal.islamicKnowledge,
          },
        ),
      );

      expect(_project(forward), _project(reverse));
    });

    test('hedefler deterministik sıraya normalize edilir', () {
      final req = request(
        goals: {
          OnboardingFocusGoal.islamicKnowledge,
          OnboardingFocusGoal.trackPrayers,
        },
      );
      expect(req.normalizedGoals, [
        OnboardingFocusGoal.trackPrayers,
        OnboardingFocusGoal.islamicKnowledge,
      ]);
    });

    test('kaynağa verilen hedefler normalize edilmiştir', () async {
      final source = _ContextCapturingSource();
      await generate(
        request(
          goals: {
            OnboardingFocusGoal.dhikrRoutine,
            OnboardingFocusGoal.trackPrayers,
          },
        ),
        source: source,
      );

      expect(source.contexts.first.goals, [
        OnboardingFocusGoal.trackPrayers,
        OnboardingFocusGoal.dhikrRoutine,
      ]);
    });

    test('üretici profil eşlemesini TEKRAR ÇALIŞTIRMAZ', () async {
      // Hedefler prayer'a işaret etse de istekteki profil otoriter kalır.
      final plans = await generate(
        request(
          profileType: DailyPlanProfileType.learningFocused,
          goals: const {OnboardingFocusGoal.trackPrayers},
        ),
      );
      expect(plans.first.profileType, 'learning_focused');
    });
  });

  group('boş kaynak', () {
    test('varsayılan kaynakla 30 gün boş items üretir', () async {
      final plans = await generate(request());

      expect(plans.length, 30);
      expect(plans.every((p) => p.items.isEmpty), isTrue);
    });

    test('boş öğe listesi HATA değildir', () async {
      final result = await DailyPlanGenerator.generate(request());
      expect(result.isSuccess, isTrue);
    });

    test('boş kaynak eşit girdi için aynı sonucu verir', () async {
      const source = EmptyDailyPlanItemSource();
      final a = await source.itemsFor(_context());
      final b = await source.itemsFor(_context());
      expect(a.valueOrNull, b.valueOrNull);
    });
  });

  group('kaynak sözleşmesi', () {
    test('kaynak her gün için bir kez çağrılır', () async {
      final source = _ContextCapturingSource();
      await generate(request(), source: source);
      expect(source.contexts.length, 30);
    });

    test('bağlam gün ofseti ve fazı doğru taşır', () async {
      final source = _ContextCapturingSource();
      await generate(request(startDay: '2026-07-26'), source: source);

      expect(source.contexts.first.dayOffset, 0);
      expect(source.contexts.first.weekIndex, 0);
      expect(source.contexts.first.dayKey.value, '2026-07-26');
      expect(source.contexts.last.dayOffset, 29);
      expect(source.contexts.last.weekIndex, 3);
    });

    test('bağlam bütçe ve profil taşır', () async {
      final source = _ContextCapturingSource();
      await generate(
        request(
          profileType: DailyPlanProfileType.advanced,
          dailyPace: OnboardingDailyPace.focused,
        ),
        source: source,
      );

      expect(source.contexts.first.sizeMinutes, 30);
      expect(source.contexts.first.profileType, DailyPlanProfileType.advanced);
    });

    test('kaynak hatası aynen taşınır ve kısmi çıktı vermez', () async {
      final result = await DailyPlanGenerator.generate(
        request(),
        source: const _FailingSource(NetworkFailure()),
      );

      expect(result.failureOrNull, isA<NetworkFailure>());
      expect(result.valueOrNull, isNull);
    });

    test('kaynak sırası korunur', () async {
      final plans = await generate(
        request(
          profileType: DailyPlanProfileType.advanced,
          dailyPace: OnboardingDailyPace.focused,
        ),
        source: _FixedDraftSource([
          PlanItemDraft(
            templateId: 'tmpl-c',
            type: PlanItemType.lesson,
            estimatedMinutes: 1,
          ),
          PlanItemDraft(
            templateId: 'tmpl-a',
            type: PlanItemType.quran,
            estimatedMinutes: 1,
          ),
          PlanItemDraft(
            templateId: 'tmpl-b',
            type: PlanItemType.prayer,
            estimatedMinutes: 1,
          ),
        ]),
      );

      expect(plans.first.items.map((i) => i.type).toList(), [
        PlanItemType.lesson,
        PlanItemType.quran,
        PlanItemType.prayer,
      ]);
    });

    test('taslak boş şablon kimliğini reddeder', () {
      expect(
        () => PlanItemDraft(
          templateId: '  ',
          type: PlanItemType.quran,
          estimatedMinutes: 1,
        ),
        throwsArgumentError,
      );
    });

    test('taslak negatif süreyi reddeder', () {
      expect(
        () => PlanItemDraft(
          templateId: 'tmpl-a',
          type: PlanItemType.quran,
          estimatedMinutes: -1,
        ),
        throwsArgumentError,
      );
    });
  });

  group('stabil öğe kimliği', () {
    test('aynı istek aynı kimlikleri üretir', () async {
      final source = _FixedDraftSource([
        PlanItemDraft(
          templateId: 'tmpl-a',
          type: PlanItemType.quran,
          estimatedMinutes: 1,
        ),
      ]);
      final first = await generate(request(), source: source);
      final second = await generate(request(), source: source);

      expect(_itemIds(first), _itemIds(second));
    });

    test('farklı günler çakışmaz', () async {
      final plans = await generate(
        request(),
        source: _FixedDraftSource([
          PlanItemDraft(
            templateId: 'tmpl-a',
            type: PlanItemType.quran,
            estimatedMinutes: 1,
          ),
        ]),
      );
      expect(_itemIds(plans).toSet().length, 30);
    });

    test('aynı gün içinde iki öğe çakışmaz', () async {
      final plans = await generate(
        request(
          profileType: DailyPlanProfileType.advanced,
          dailyPace: OnboardingDailyPace.focused,
        ),
        source: _FixedDraftSource([
          PlanItemDraft(
            templateId: 'tmpl-a',
            type: PlanItemType.quran,
            estimatedMinutes: 1,
          ),
          // Aynı şablon iki kez: slot ayrımı çakışmayı önler.
          PlanItemDraft(
            templateId: 'tmpl-a',
            type: PlanItemType.dhikr,
            estimatedMinutes: 1,
          ),
        ]),
      );

      final ids = plans.first.items.map((i) => i.itemId.value).toList();
      expect(ids.toSet().length, 2);
    });

    test('kimlik üretici sürümü, gün, şablon ve slot içerir', () {
      final id = DailyPlanItemIdBuilder.build(
        generatorVersion: 'rule-engine-v1',
        dayKey: DayKey('2026-07-26'),
        templateId: 'tmpl-a',
        slot: 2,
      );
      expect(id.value, 'rule-engine-v1:2026-07-26:tmpl-a:2');
    });

    test('kimlik rastgelelik/zaman damgası içermez', () async {
      final plans = await generate(
        request(),
        source: _FixedDraftSource([
          PlanItemDraft(
            templateId: 'tmpl-a',
            type: PlanItemType.quran,
            estimatedMinutes: 1,
          ),
        ]),
      );
      final id = plans.first.items.single.itemId.value;
      expect(id, 'rule-engine-v1:2026-07-26:tmpl-a:0');
      expect(id, isNot(matches(RegExp(r'\d{13}')))); // epoch ms yok
    });

    test('negatif slot reddedilir', () {
      expect(
        () => DailyPlanItemIdBuilder.build(
          generatorVersion: 'rule-engine-v1',
          dayKey: DayKey('2026-07-26'),
          templateId: 'tmpl-a',
          slot: -1,
        ),
        throwsArgumentError,
      );
    });
  });

  group('determinizm', () {
    test('50 tekrar aynı çıktıyı verir', () async {
      final req = request();
      final baseline = _project(await generate(req));
      for (var i = 0; i < 50; i++) {
        expect(_project(await generate(req)), baseline);
      }
    });

    test('eşdeğer ayrı istek nesneleri aynı çıktıyı verir', () async {
      expect(
        _project(await generate(request())),
        _project(await generate(request())),
      );
    });

    test('her profil için tekrar kararlıdır', () async {
      for (final entry in compatiblePace.entries) {
        final req = request(profileType: entry.key, dailyPace: entry.value);
        expect(_project(await generate(req)), _project(await generate(req)));
      }
    });

    test('üretilen öğe durumu daima pending başlar', () async {
      final plans = await generate(
        request(),
        source: _FixedDraftSource([
          PlanItemDraft(
            templateId: 'tmpl-a',
            type: PlanItemType.quran,
            estimatedMinutes: 1,
          ),
        ]),
      );
      expect(
        plans.every(
          (p) => p.items.every((i) => i.status == PlanItemStatus.pending),
        ),
        isTrue,
      );
      expect(
        plans.every((p) => p.items.every((i) => i.completedAt == null)),
        isTrue,
      );
    });
  });

  group('gizlilik ve içerik sınırı', () {
    test('hata nesnesi ham istek/hedef bilgisi taşımaz', () async {
      final result = await DailyPlanGenerator.generate(
        request(
          profileType: DailyPlanProfileType.advanced,
          dailyPace: OnboardingDailyPace.light,
          goals: const {OnboardingFocusGoal.dhikrRoutine},
        ),
      );
      final rendered = result.failureOrNull.toString();

      for (final forbidden in [
        'dhikrRoutine',
        '2026-07-26',
        'advanced',
        'uid',
        'latitude',
        'Exception',
        '#0',
      ]) {
        expect(rendered, isNot(contains(forbidden)));
      }
    });

    test('TASK 079 hiçbir dinî içerik üretmez', () async {
      final plans = await generate(request());
      expect(plans.every((p) => p.items.isEmpty), isTrue);
      for (final plan in plans) {
        expect(plan.items, isEmpty, reason: 'içerik TASK 080-082 işidir');
      }
    });

    test('üretici sürümü stabil kimliktir', () {
      expect(DailyPlanGenerator.generatorVersion, 'rule-engine-v1');
    });
  });
}

/// Karşılaştırılabilir, nesne kimliğinden bağımsız çıktı izdüşümü.
List<String> _project(List<DailyPlan> plans) => [
  for (final plan in plans)
    [
      plan.dayKey.value,
      plan.profileType,
      '${plan.sizeMinutes}',
      '${plan.weekIndex}',
      plan.generatedBy,
      plan.items.map((i) => '${i.itemId.value}|${i.type.name}').join(','),
    ].join('#'),
];

List<String> _itemIds(List<DailyPlan> plans) => [
  for (final plan in plans)
    for (final item in plan.items) item.itemId.value,
];

DailyPlanDayContext _context() => DailyPlanDayContext(
  profileType: DailyPlanProfileType.beginner,
  goals: const [OnboardingFocusGoal.trackPrayers],
  dailyPace: OnboardingDailyPace.balanced,
  sizeMinutes: 10,
  dayKey: DayKey('2026-07-26'),
  dayOffset: 0,
  weekIndex: 0,
);

/// Her gün aynı taslakları döndüren test kaynağı.
final class _FixedDraftSource implements DailyPlanItemSource {
  const _FixedDraftSource(this.drafts);

  final List<PlanItemDraft> drafts;

  @override
  ResultFuture<List<PlanItemDraft>> itemsFor(
    DailyPlanDayContext context,
  ) async => Result.success(drafts);
}

/// Verilen bağlamları kaydeden test kaynağı.
final class _ContextCapturingSource implements DailyPlanItemSource {
  final List<DailyPlanDayContext> contexts = [];

  @override
  ResultFuture<List<PlanItemDraft>> itemsFor(
    DailyPlanDayContext context,
  ) async {
    contexts.add(context);
    return const Result.success(<PlanItemDraft>[]);
  }
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
