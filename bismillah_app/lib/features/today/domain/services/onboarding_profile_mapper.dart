import 'package:bismillah_app/features/onboarding/domain/entities/onboarding_preferences.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_daily_pace.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_journey_stage.dart';
import 'package:bismillah_app/features/today/domain/value_objects/daily_plan_profile_type.dart';

/// Onboarding tercihlerinden kanonik plan profiline **saf** eşleme
/// (TASK 078). Profil türetimi kanonik mimaride plan feature'ının işidir
/// (`06_FLUTTER_ARCHITECTURE` §648 — `DeriveProfile`).
///
/// ## Girdi: bugün GERÇEKTEN toplanan model
///
/// Kaynak yalnız [OnboardingPreferences]'tır: `goals` (çoklu seçim),
/// `journeyStage`, `dailyPace`. `completedAtUtc` sınıflandırmayı
/// ETKİLEMEZ.
///
/// `OnboardingAnswers`, `OnboardingGoal` ve `PersonalizationProfile`
/// **KULLANILMAYAN / GELECEKTEKİ GENİŞLETİLMİŞ ONBOARDING İSKELESİDİR**
/// (16 soruluk model); üretimde hiçbir yerde kurulmaz, kaydedilmez ve
/// burada girdi olarak KULLANILMAZ.
///
/// ## Saflık
///
/// Riverpod, SharedPreferences, Drift, Firebase, `BuildContext`, saat,
/// locale, timezone, cihaz durumu, ağ veya rastgelelik OKUNMAZ. Aynı
/// girdi daima aynı çıktıyı verir.
///
/// ## Öncelik sırası — TASK 078 ÜRÜN KARARI
///
/// Aşağıdaki sıra **TASK 078'de onaylanan bir ürün kararıdır**; eski
/// onboarding spesifikasyonunda bu haliyle YER ALMIYORDU. Kaynak
/// dokümanların verdiği şey profil ADLARI (§10) ve mevcut üç eksenli
/// girdi modelidir; eksenler arası öncelik ve çoklu-hedef sıralaması bu
/// görevde karara bağlanmıştır.
///
/// 1. `justBeginning` → [DailyPlanProfileType.beginner] (tempo ve
///    hedefleri EZER — yeni başlayan, hafif tempoda da yeni başlayandır)
/// 2. `rebuildingRoutine` → [DailyPlanProfileType.returning] (tempo ve
///    hedefleri EZER)
/// 3. `strengtheningRoutine` + `focused` → [DailyPlanProfileType.advanced]
///    (Advanced yalnız buradan gelir; hedeflerden ÇIKARILMAZ)
/// 4. `light` (1–3 eşleşmediyse) → [DailyPlanProfileType.lowTime]
///    — baskın ürün kısıtı sınırlı zamandır; dinî bir yargı DEĞİLDİR
/// 5. Aksi hâlde hedeflerden sabit öncelikle: prayer → quran → dhikr →
///    learning
///
/// ## Atlama (skip) kuralı notu
///
/// "Yeni başlıyorum seçilince namaz-sıklığı sorusu atlanır" kuralı
/// **uygulanmamış genişletilmiş onboarding spesifikasyonuna** aittir;
/// mevcut üç ekranlı akışta namaz-sıklığı sorusu YOKTUR, dolayısıyla
/// atlanacak bağımlı cevap ve bayat-cevap durumu da yoktur. Mevcut
/// modelde `justBeginning` doğrudan `beginner`'a eşlenir; hedefler ve
/// tempo mevcut kalabilir ama Kural 1'i EZEMEZ.
abstract final class OnboardingProfileMapper {
  /// Hedef kovalarının sabit öncelik listesi.
  ///
  /// Bilinçli olarak açık bir liste: `Set` yineleme sırasına, enum
  /// bildirim sırasına veya yerelleştirilmiş metin sıralamasına
  /// GÜVENİLMEZ.
  static const List<(OnboardingFocusGoal, DailyPlanProfileType, String)>
  focusPrecedence = [
    (
      OnboardingFocusGoal.trackPrayers,
      DailyPlanProfileType.prayerFocused,
      ProfileMappingRule.focusPrayer,
    ),
    (
      OnboardingFocusGoal.prayOnTime,
      DailyPlanProfileType.prayerFocused,
      ProfileMappingRule.focusPrayer,
    ),
    (
      OnboardingFocusGoal.quranHabit,
      DailyPlanProfileType.quranFocused,
      ProfileMappingRule.focusQuran,
    ),
    (
      OnboardingFocusGoal.dhikrRoutine,
      DailyPlanProfileType.dhikrFocused,
      ProfileMappingRule.focusDhikr,
    ),
    (
      OnboardingFocusGoal.islamicKnowledge,
      DailyPlanProfileType.learningFocused,
      ProfileMappingRule.focusLearning,
    ),
  ];

  /// Onboarding tercihlerini kanonik profile eşler.
  static ProfileMappingResult map(OnboardingPreferences preferences) {
    // Kural 1 — yeni başlayan; tempo ve hedeflerden bağımsızdır.
    if (preferences.journeyStage == OnboardingJourneyStage.justBeginning) {
      return const ProfileMapped(
        profile: DailyPlanProfileType.beginner,
        ruleId: ProfileMappingRule.journeyBeginner,
      );
    }

    // Kural 2 — geri dönen; tempo ve hedeflerden bağımsızdır.
    if (preferences.journeyStage == OnboardingJourneyStage.rebuildingRoutine) {
      return const ProfileMapped(
        profile: DailyPlanProfileType.returning,
        ruleId: ProfileMappingRule.journeyReturning,
      );
    }

    // Kural 3 — ileri seviye YALNIZ aşama + tempo birlikteliğinden.
    if (preferences.journeyStage ==
            OnboardingJourneyStage.strengtheningRoutine &&
        preferences.dailyPace == OnboardingDailyPace.focused) {
      return const ProfileMapped(
        profile: DailyPlanProfileType.advanced,
        ruleId: ProfileMappingRule.journeyAdvanced,
      );
    }

    // Kural 4 — sınırlı zaman baskın kısıttır.
    if (preferences.dailyPace == OnboardingDailyPace.light) {
      return const ProfileMapped(
        profile: DailyPlanProfileType.lowTime,
        ruleId: ProfileMappingRule.paceLowTime,
      );
    }

    // Kural 5 — hedeflerden sabit öncelikle.
    final focus = resolveFocusProfile(preferences.goals);
    if (focus == null) {
      // Hedef kümesi boş: [OnboardingPreferences] yapıcısı bunu `assert`
      // ile engeller (debug) ve depo boş listeyi tamamlanmış SAYMAZ,
      // ama release'te temsil edilebilir bir durumdur. Sessizce bir
      // varsayılan profile DÜŞMEK yerine dürüstçe eksik bildirilir.
      return const ProfileIncomplete(
        missingField: ProfileMappingMissingField.focusGoals,
      );
    }
    return focus;
  }

  /// Hedef kümesinden sabit öncelikli profil çözümü.
  ///
  /// Eşleşme yoksa `null` döner (boş hedef kümesi). Ayrı ve açık
  /// olmasının sebebi, boş küme davranışının yapıcı değişmezini
  /// zayıflatmadan doğrudan test edilebilmesidir.
  static ProfileMapped? resolveFocusProfile(Set<OnboardingFocusGoal> goals) {
    for (final (goal, profile, ruleId) in focusPrecedence) {
      if (goals.contains(goal)) {
        return ProfileMapped(profile: profile, ruleId: ruleId);
      }
    }
    return null;
  }
}

/// Eşlemeyi üreten kuralın stabil kimliği.
///
/// Nötr ve yerelleştirilmemiştir; teşhis/test içindir, kullanıcıya
/// gösterilmez ve hiçbir dinî değerlendirme ifade etmez.
abstract final class ProfileMappingRule {
  static const String journeyBeginner = 'journey_beginner';
  static const String journeyReturning = 'journey_returning';
  static const String journeyAdvanced = 'journey_advanced';
  static const String paceLowTime = 'pace_low_time';
  static const String focusPrayer = 'focus_prayer';
  static const String focusQuran = 'focus_quran';
  static const String focusDhikr = 'focus_dhikr';
  static const String focusLearning = 'focus_learning';
}

/// Eksik girdi alanının stabil kimliği (cevap İÇERİĞİ taşımaz).
abstract final class ProfileMappingMissingField {
  static const String focusGoals = 'focus_goals';
}

/// Eşleme sonucu.
///
/// Yalnız gerçekten temsil edilebilen sonuçlar tanımlıdır:
///
/// - **Invalid yoktur** — üç girdinin tamamı enum'dur; tip sistemi
///   geçersiz değeri engeller ve depo tanınmayan eski değeri zaten
///   "tamamlanmamış" sayar, bu yüzden geçersiz bir değer mapper'a
///   ULAŞAMAZ.
/// - **Contradictory yoktur** — çoklu hedef, aşama+tempo ve aşama+hedef
///   birliktelikleri mevcut modelde MEŞRUDUR ve öncelik kurallarıyla
///   çözülür; çelişki değildirler. Ulaşılamayan varyant uydurulmaz.
sealed class ProfileMappingResult {
  const ProfileMappingResult();
}

/// Profil belirlendi.
final class ProfileMapped extends ProfileMappingResult {
  const ProfileMapped({required this.profile, required this.ruleId});

  final DailyPlanProfileType profile;

  /// Kararı veren kuralın stabil kimliği ([ProfileMappingRule]).
  final String ruleId;

  @override
  bool operator ==(Object other) =>
      other is ProfileMapped &&
      other.profile == profile &&
      other.ruleId == ruleId;

  @override
  int get hashCode => Object.hash(profile, ruleId);
}

/// Mevcut girdi profil belirlemeye yetmiyor.
///
/// Yalnız **alan kimliği** taşır; kullanıcının cevap içeriği, ham yük,
/// yerelleştirilmiş soru metni veya istisna bilgisi TAŞIMAZ.
final class ProfileIncomplete extends ProfileMappingResult {
  const ProfileIncomplete({required this.missingField});

  /// [ProfileMappingMissingField] sabitlerinden biri.
  final String missingField;

  @override
  bool operator ==(Object other) =>
      other is ProfileIncomplete && other.missingField == missingField;

  @override
  int get hashCode => missingField.hashCode;
}
