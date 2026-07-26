import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';

/// Kur'an plan öğesi kaynağı — TASK 079 sözleşmesinin ikinci onaylı
/// implementasyonu (TASK 081).
///
/// ## Ne üretir
///
/// Kullanıcının mevcut `quranHabit` onboarding hedefi seçiliyse **tek** bir
/// nötr *devam/takip* eylemi. Yeni bir dinî talep, miktar veya yükümlülük
/// EKLENMEZ.
///
/// | Hedef | Şablon |
/// |---|---|
/// | `quranHabit` | `quran_continue_daily` |
///
/// `quranHabit` seçili değilse **boş liste** döner (hata değildir).
/// `trackPrayers`, `prayOnTime`, `dhikrRoutine` ve `islamicKnowledge` bu
/// kaynağın çıktısını ETKİLEMEZ.
///
/// ## Ne YAPMAZ
///
/// Sure, ayet, ayet aralığı, cüz, sayfa, meal metni, kâri veya ses adresi
/// **ATAMAZ**; okuma/dinleme miktarı belirlemez. Kur'an metni veya meali
/// gömmez. Okuma ilerlemesini, son okunan ayeti, kayıtlı ayetleri ve ses
/// ilerlemesini **OKUMAZ** — hiçbir Kur'an repository'sine bağlı değildir.
/// Somut bir okuma konumu/hedefi çözmek sonraki bir orkestrasyon/içerik
/// kararıdır.
///
/// ## Profil ve faz bağımsızlığı
///
/// Aynı hedefler için katkı sekiz profilde ve dört ilerleme fazında
/// (`weekIndex` 0–3) **aynıdır**. Yeni başlayana kota, ileri seviyeye
/// miktar, faza bağlı ayet artışı veya profile özel okuma miktarı YOKTUR.
/// Kaynak profili değiştirmez ve onboarding cevaplarını yeniden eşlemez.
///
/// ## Saflık
///
/// Riverpod, `BuildContext`, repository, SharedPreferences, Drift,
/// Firebase, ağ, saat, locale, timezone KULLANILMAZ; log yazmaz, yan etkisi
/// yoktur. Aynı bağlam daima aynı sonucu verir.
final class QuranDailyPlanItemSource implements DailyPlanItemSource {
  const QuranDailyPlanItemSource();

  /// Günlük Kur'an alışkanlığı devam/takip şablonu.
  ///
  /// Yerelleştirilmiş metin, Kur'an içerik kimliği, sure/ayet referansı
  /// DEĞİLDİR; zaman, UID veya cihaz verisinden türetilmez.
  static const String continueDailyTemplateId = 'quran_continue_daily';

  /// Bu katkının tahmini **uygulama içi etkileşim** bütçesi.
  ///
  /// Gerekli Kur'an okuma süresi, dinî bir asgari miktar, bir hüküm,
  /// manevi değer, ödül veya ceza DEĞİLDİR; yalnız TASK 079 bütçe
  /// denetimi için kullanılan teknik bir tahmindir ve kalıcı plana
  /// yazılmaz.
  static const int estimatedMinutes = 2;

  /// Bu kaynağı tetikleyen tek hedef.
  static const OnboardingFocusGoal triggerGoal = OnboardingFocusGoal.quranHabit;

  /// Bağlamdaki hedeflere göre Kur'an katkısını döndürür.
  ///
  /// Her geçerli [DailyPlanDayContext] için **toplam**dır: şablon kimliği
  /// sabit, tahmini süre sabit ve pozitiftir, bu yüzden taslak kurulumu
  /// başarısız olamaz. Ulaşılamayan bir hata dalı bilinçli olarak
  /// eklenmemiştir.
  @override
  ResultFuture<List<PlanItemDraft>> itemsFor(
    DailyPlanDayContext context,
  ) async {
    if (!context.goals.contains(triggerGoal)) {
      return const Result.success(<PlanItemDraft>[]);
    }
    return Result.success([
      PlanItemDraft(
        templateId: continueDailyTemplateId,
        type: PlanItemType.quran,
        estimatedMinutes: estimatedMinutes,
        // Sure/ayet referansı ve miktar BİLİNÇLİ olarak yok: belirli bir
        // pasaj veya okuma miktarı iddia edilmez.
      ),
    ]);
  }
}
