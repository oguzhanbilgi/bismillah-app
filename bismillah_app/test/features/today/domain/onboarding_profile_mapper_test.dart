import 'package:bismillah_app/features/onboarding/domain/entities/onboarding_preferences.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_daily_pace.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_journey_stage.dart';
import 'package:bismillah_app/features/today/domain/services/onboarding_profile_mapper.dart';
import 'package:bismillah_app/features/today/domain/value_objects/daily_plan_profile_type.dart';
import 'package:flutter_test/flutter_test.dart';

/// Onboarding → kanonik plan profili eşlemesi (TASK 078).
///
/// Girdi, bugün gerçekten toplanan üç eksenli [OnboardingPreferences]
/// modelidir. Testler saat/locale/timezone/rastgelelikten bağımsızdır.
void main() {
  OnboardingPreferences prefs({
    Set<OnboardingFocusGoal> goals = const {OnboardingFocusGoal.trackPrayers},
    OnboardingJourneyStage journeyStage =
        OnboardingJourneyStage.strengtheningRoutine,
    OnboardingDailyPace dailyPace = OnboardingDailyPace.balanced,
    DateTime? completedAtUtc,
  }) => OnboardingPreferences(
    goals: goals,
    journeyStage: journeyStage,
    dailyPace: dailyPace,
    completedAtUtc: completedAtUtc ?? DateTime.utc(2026, 7, 26, 12),
  );

  DailyPlanProfileType profileOf(OnboardingPreferences p) =>
      (OnboardingProfileMapper.map(p) as ProfileMapped).profile;

  String ruleOf(OnboardingPreferences p) =>
      (OnboardingProfileMapper.map(p) as ProfileMapped).ruleId;

  group('sekiz profil erişilebilirliği', () {
    final fixtures = <DailyPlanProfileType, OnboardingPreferences>{
      DailyPlanProfileType.beginner: prefs(
        journeyStage: OnboardingJourneyStage.justBeginning,
      ),
      DailyPlanProfileType.returning: prefs(
        journeyStage: OnboardingJourneyStage.rebuildingRoutine,
      ),
      DailyPlanProfileType.advanced: prefs(
        journeyStage: OnboardingJourneyStage.strengtheningRoutine,
        dailyPace: OnboardingDailyPace.focused,
      ),
      DailyPlanProfileType.lowTime: prefs(
        journeyStage: OnboardingJourneyStage.strengtheningRoutine,
        dailyPace: OnboardingDailyPace.light,
      ),
      DailyPlanProfileType.prayerFocused: prefs(
        goals: const {OnboardingFocusGoal.trackPrayers},
      ),
      DailyPlanProfileType.quranFocused: prefs(
        goals: const {OnboardingFocusGoal.quranHabit},
      ),
      DailyPlanProfileType.dhikrFocused: prefs(
        goals: const {OnboardingFocusGoal.dhikrRoutine},
      ),
      DailyPlanProfileType.learningFocused: prefs(
        goals: const {OnboardingFocusGoal.islamicKnowledge},
      ),
    };

    for (final entry in fixtures.entries) {
      test('${entry.key.id} erişilebilir', () {
        expect(profileOf(entry.value), entry.key);
      });
    }

    test('HER kanonik profilin fixture\'ı vardır (kapsam kilidi)', () {
      // Yeni bir profil enum'a eklenirse bu test eşlenene kadar KIRILIR.
      expect(
        fixtures.keys.toSet(),
        DailyPlanProfileType.values.toSet(),
        reason: 'eşlenmemiş profil kaldı',
      );
      expect(DailyPlanProfileType.values.length, 8, reason: 'dokuzuncu yok');
    });

    test('stabil kimlikler sabittir', () {
      expect(DailyPlanProfileType.values.map((p) => p.id).toList(), [
        'beginner',
        'returning',
        'prayer_focused',
        'quran_focused',
        'dhikr_focused',
        'learning_focused',
        'advanced',
        'low_time',
      ]);
    });
  });

  group('Kural 1 — beginner tempo ve hedefleri ezer', () {
    for (final goal in OnboardingFocusGoal.values) {
      for (final pace in OnboardingDailyPace.values) {
        test('justBeginning + ${pace.name} + ${goal.name} → beginner', () {
          final p = prefs(
            goals: {goal},
            journeyStage: OnboardingJourneyStage.justBeginning,
            dailyPace: pace,
          );
          expect(profileOf(p), DailyPlanProfileType.beginner);
          expect(ruleOf(p), ProfileMappingRule.journeyBeginner);
        });
      }
    }

    test('hafif tempolu yeni başlayan low_time OLMAZ', () {
      expect(
        profileOf(
          prefs(
            journeyStage: OnboardingJourneyStage.justBeginning,
            dailyPace: OnboardingDailyPace.light,
          ),
        ),
        DailyPlanProfileType.beginner,
      );
    });
  });

  group('Kural 2 — returning tempo ve hedefleri ezer', () {
    for (final goal in OnboardingFocusGoal.values) {
      for (final pace in OnboardingDailyPace.values) {
        test('rebuildingRoutine + ${pace.name} + ${goal.name} → returning', () {
          final p = prefs(
            goals: {goal},
            journeyStage: OnboardingJourneyStage.rebuildingRoutine,
            dailyPace: pace,
          );
          expect(profileOf(p), DailyPlanProfileType.returning);
          expect(ruleOf(p), ProfileMappingRule.journeyReturning);
        });
      }
    }
  });

  group('Kural 3 — advanced yalnız aşama + tempo', () {
    for (final goal in OnboardingFocusGoal.values) {
      test('strengthening + focused + ${goal.name} → advanced', () {
        final p = prefs(
          goals: {goal},
          journeyStage: OnboardingJourneyStage.strengtheningRoutine,
          dailyPace: OnboardingDailyPace.focused,
        );
        expect(profileOf(p), DailyPlanProfileType.advanced);
        expect(ruleOf(p), ProfileMappingRule.journeyAdvanced);
      });
    }

    test('advanced hedeflerden ÇIKARILMAZ (focused tempo şart)', () {
      expect(
        profileOf(
          prefs(
            goals: const {OnboardingFocusGoal.trackPrayers},
            journeyStage: OnboardingJourneyStage.strengtheningRoutine,
            dailyPace: OnboardingDailyPace.balanced,
          ),
        ),
        DailyPlanProfileType.prayerFocused,
      );
    });
  });

  group('Kural 4 — low_time', () {
    for (final goal in OnboardingFocusGoal.values) {
      test('strengthening + light + ${goal.name} → low_time', () {
        final p = prefs(
          goals: {goal},
          journeyStage: OnboardingJourneyStage.strengtheningRoutine,
          dailyPace: OnboardingDailyPace.light,
        );
        expect(profileOf(p), DailyPlanProfileType.lowTime);
        expect(ruleOf(p), ProfileMappingRule.paceLowTime);
      });
    }
  });

  group('Kural 5 — hedef eşlemesi', () {
    final singleGoal = <OnboardingFocusGoal, DailyPlanProfileType>{
      OnboardingFocusGoal.trackPrayers: DailyPlanProfileType.prayerFocused,
      OnboardingFocusGoal.prayOnTime: DailyPlanProfileType.prayerFocused,
      OnboardingFocusGoal.quranHabit: DailyPlanProfileType.quranFocused,
      OnboardingFocusGoal.dhikrRoutine: DailyPlanProfileType.dhikrFocused,
      OnboardingFocusGoal.islamicKnowledge:
          DailyPlanProfileType.learningFocused,
    };

    for (final entry in singleGoal.entries) {
      test('${entry.key.name} → ${entry.value.id}', () {
        expect(profileOf(prefs(goals: {entry.key})), entry.value);
      });
    }

    test('her hedef değeri eşlenmiştir (kapsam kilidi)', () {
      expect(singleGoal.keys.toSet(), OnboardingFocusGoal.values.toSet());
    });
  });

  group('çoklu hedef öncelik sırası', () {
    test('prayer + quran → prayer_focused', () {
      expect(
        profileOf(
          prefs(
            goals: const {
              OnboardingFocusGoal.quranHabit,
              OnboardingFocusGoal.trackPrayers,
            },
          ),
        ),
        DailyPlanProfileType.prayerFocused,
      );
    });

    test('quran + dhikr → quran_focused', () {
      expect(
        profileOf(
          prefs(
            goals: const {
              OnboardingFocusGoal.dhikrRoutine,
              OnboardingFocusGoal.quranHabit,
            },
          ),
        ),
        DailyPlanProfileType.quranFocused,
      );
    });

    test('dhikr + learning → dhikr_focused', () {
      expect(
        profileOf(
          prefs(
            goals: const {
              OnboardingFocusGoal.islamicKnowledge,
              OnboardingFocusGoal.dhikrRoutine,
            },
          ),
        ),
        DailyPlanProfileType.dhikrFocused,
      );
    });

    test('yalnız learning → learning_focused', () {
      expect(
        profileOf(prefs(goals: const {OnboardingFocusGoal.islamicKnowledge})),
        DailyPlanProfileType.learningFocused,
      );
    });

    test('prayOnTime da prayer önceliğini taşır', () {
      expect(
        profileOf(
          prefs(
            goals: const {
              OnboardingFocusGoal.islamicKnowledge,
              OnboardingFocusGoal.prayOnTime,
            },
          ),
        ),
        DailyPlanProfileType.prayerFocused,
      );
    });

    test('tüm hedefler seçiliyse prayer kazanır', () {
      expect(
        profileOf(prefs(goals: OnboardingFocusGoal.values.toSet())),
        DailyPlanProfileType.prayerFocused,
      );
    });
  });

  group('determinizm', () {
    test('aynı girdi tekrar tekrar aynı sonucu verir', () {
      final p = prefs(
        goals: const {
          OnboardingFocusGoal.dhikrRoutine,
          OnboardingFocusGoal.quranHabit,
        },
      );
      final first = OnboardingProfileMapper.map(p);
      for (var i = 0; i < 50; i++) {
        expect(OnboardingProfileMapper.map(p), first);
      }
    });

    test('hedef kümesi ekleme sırası sonucu DEĞİŞTİRMEZ', () {
      final forward = prefs(
        goals: {
          OnboardingFocusGoal.islamicKnowledge,
          OnboardingFocusGoal.dhikrRoutine,
          OnboardingFocusGoal.quranHabit,
        },
      );
      final reverse = prefs(
        goals: {
          OnboardingFocusGoal.quranHabit,
          OnboardingFocusGoal.dhikrRoutine,
          OnboardingFocusGoal.islamicKnowledge,
        },
      );
      expect(
        OnboardingProfileMapper.map(forward),
        OnboardingProfileMapper.map(reverse),
      );
    });

    test('completedAtUtc sınıflandırmayı ETKİLEMEZ', () {
      expect(
        OnboardingProfileMapper.map(prefs(completedAtUtc: DateTime.utc(2020))),
        OnboardingProfileMapper.map(
          prefs(completedAtUtc: DateTime.utc(2031, 12, 31, 23, 59)),
        ),
      );
    });

    test('yerel saat dilimi kayması sonucu DEĞİŞTİRMEZ', () {
      // Aynı an, farklı ofsetlerle ifade edilir.
      final utc = DateTime.utc(2026, 7, 26, 0, 30);
      expect(
        OnboardingProfileMapper.map(prefs(completedAtUtc: utc)),
        OnboardingProfileMapper.map(
          prefs(completedAtUtc: utc.add(const Duration(hours: 14))),
        ),
      );
    });

    test('eşleme her profil için tek çıktı üretir', () {
      for (final stage in OnboardingJourneyStage.values) {
        for (final pace in OnboardingDailyPace.values) {
          for (final goal in OnboardingFocusGoal.values) {
            final p = prefs(
              goals: {goal},
              journeyStage: stage,
              dailyPace: pace,
            );
            final results = {
              for (var i = 0; i < 5; i++) OnboardingProfileMapper.map(p),
            };
            expect(results.length, 1);
          }
        }
      }
    });
  });

  group('eksik girdi', () {
    test('boş hedef kümesi profil çözmez', () {
      // Yapıcı değişmezi ZAYIFLATILMADAN test edilir: kural 5'in saf
      // çözümleyicisi doğrudan çağrılır.
      expect(OnboardingProfileMapper.resolveFocusProfile(const {}), isNull);
    });

    test('boş hedef sessizce bir varsayılana DÜŞMEZ', () {
      final resolved = OnboardingProfileMapper.resolveFocusProfile(const {});
      expect(resolved?.profile, isNot(DailyPlanProfileType.prayerFocused));
      expect(resolved?.profile, isNot(DailyPlanProfileType.learningFocused));
    });

    test('eksik sonuç yalnız alan KİMLİĞİ taşır', () {
      const incomplete = ProfileIncomplete(
        missingField: ProfileMappingMissingField.focusGoals,
      );
      expect(incomplete.missingField, 'focus_goals');
      expect(incomplete, isA<ProfileMappingResult>());
    });

    test('yapıcı boş hedefi engeller (mevcut değişmez korunur)', () {
      expect(
        () => OnboardingPreferences(
          goals: const {},
          journeyStage: OnboardingJourneyStage.strengtheningRoutine,
          dailyPace: OnboardingDailyPace.balanced,
          completedAtUtc: DateTime.utc(2026),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('kural kimlikleri', () {
    test('stabil, nötr ve yerelleştirilmemiştir', () {
      const ids = [
        ProfileMappingRule.journeyBeginner,
        ProfileMappingRule.journeyReturning,
        ProfileMappingRule.journeyAdvanced,
        ProfileMappingRule.paceLowTime,
        ProfileMappingRule.focusPrayer,
        ProfileMappingRule.focusQuran,
        ProfileMappingRule.focusDhikr,
        ProfileMappingRule.focusLearning,
      ];
      expect(ids.toSet().length, ids.length, reason: 'kimlikler tekil');
      for (final id in ids) {
        expect(id, matches(RegExp(r'^[a-z][a-z0-9_]*$')));
      }
    });

    test('her kural kimliği gerçekten üretilebilir', () {
      final produced = <String>{};
      for (final stage in OnboardingJourneyStage.values) {
        for (final pace in OnboardingDailyPace.values) {
          for (final goal in OnboardingFocusGoal.values) {
            produced.add(
              ruleOf(
                prefs(goals: {goal}, journeyStage: stage, dailyPace: pace),
              ),
            );
          }
        }
      }
      expect(produced, {
        ProfileMappingRule.journeyBeginner,
        ProfileMappingRule.journeyReturning,
        ProfileMappingRule.journeyAdvanced,
        ProfileMappingRule.paceLowTime,
        ProfileMappingRule.focusPrayer,
        ProfileMappingRule.focusQuran,
        ProfileMappingRule.focusDhikr,
        ProfileMappingRule.focusLearning,
      });
    });
  });

  group('gizlilik ve etik', () {
    test('sonuç nesnesi ham cevapları veya kimlik taşımaz', () {
      final rendered = OnboardingProfileMapper.map(
        prefs(
          goals: const {
            OnboardingFocusGoal.dhikrRoutine,
            OnboardingFocusGoal.islamicKnowledge,
          },
          journeyStage: OnboardingJourneyStage.strengtheningRoutine,
        ),
      ).toString();

      for (final forbidden in [
        'dhikrRoutine',
        'islamicKnowledge',
        'strengtheningRoutine',
        'completedAt',
        'uid',
        'latitude',
        'deviceId',
        'Exception',
        '#0',
      ]) {
        expect(rendered, isNot(contains(forbidden)));
      }
    });

    test('profil kimlikleri nötrdür — takva/üstünlük ifade etmez', () {
      for (final profile in DailyPlanProfileType.values) {
        for (final judgmental in [
          'good',
          'bad',
          'weak',
          'strong',
          'pious',
          'sinner',
          'lazy',
          'better',
          'worse',
          'score',
          'rank',
          'level',
        ]) {
          expect(profile.id, isNot(contains(judgmental)));
        }
      }
    });

    test('profil tipinde puan/sıra alanı yoktur', () {
      // Enum yalnız stabil kimlik taşır; sayısal takva ölçüsü YOKTUR.
      expect(DailyPlanProfileType.beginner.id, 'beginner');
      expect(DailyPlanProfileType.beginner.index, isA<int>());
      expect(DailyPlanProfileType.values.length, 8);
    });
  });
}
