import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';

/// Namaz plan öğeleri kaynağı — TASK 079 sözleşmesinin ilk onaylı
/// implementasyonu (TASK 080).
///
/// ## Ne üretir
///
/// Yalnız **uygulama içi takip eylemleri**. Kullanıcının mevcut onboarding
/// hedefleri plana taşınır; yeni bir dinî talep, miktar veya yükümlülük
/// EKLENMEZ.
///
/// | Hedef | Şablon |
/// |---|---|
/// | `trackPrayers` | `prayer_track_daily` |
/// | `prayOnTime` | `prayer_on_time_daily` |
///
/// İkisi de seçiliyse **önce** `prayer_track_daily`, **sonra**
/// `prayer_on_time_daily` üretilir. Hiçbiri seçili değilse **boş liste**
/// döner (hata değildir). `quranHabit`, `dhikrRoutine` ve
/// `islamicKnowledge` bu kaynağın çıktısını ETKİLEMEZ.
///
/// ## Ne YAPMAZ
///
/// Namaz **vakti hesaplamaz**, konum okumaz, saat okumaz, sıradaki vakti
/// sorgulamaz, bir namazın vaktinde kılınıp kılınmadığına KARAR VERMEZ,
/// `PrayerLogDay` okumaz, tamamlanma çıkarımı yapmaz, alarm/bildirim
/// kurmaz. Öğeye vakit adı (`targetRef`) veya sayı (`sizeParam`)
/// İLİŞTİRİLMEZ — belirli bir namaz sayısı iddia edilmez.
///
/// ## Profil ve faz bağımsızlığı
///
/// Aynı hedefler için katkı sekiz profilde ve dört ilerleme fazında
/// (`weekIndex` 0–3) **aynıdır**. Kademeli artış, yeni başlayana indirim,
/// ileri seviyeye kota, telafi haftası veya faza özel hedef YOKTUR.
/// Kaynak profili değiştirmez ve onboarding cevaplarını yeniden eşlemez.
///
/// ## Saflık
///
/// Riverpod, `BuildContext`, repository, SharedPreferences, Drift,
/// Firebase, ağ, saat, locale, konum, namaz vakti motoru ve `PrayerLog`
/// KULLANILMAZ; log yazmaz, yan etkisi yoktur. Aynı bağlam daima aynı
/// sonucu verir.
final class PrayerDailyPlanItemSource implements DailyPlanItemSource {
  const PrayerDailyPlanItemSource();

  /// Günlük namaz takibi şablonu (yerelleştirilmiş metin DEĞİL).
  static const String trackDailyTemplateId = 'prayer_track_daily';

  /// Günlük vaktinde-namaz takibi şablonu.
  static const String onTimeDailyTemplateId = 'prayer_on_time_daily';

  /// Her namaz öğesinin tahmini **uygulama içi etkileşim** maliyeti.
  ///
  /// Bu değer bir namazın süresi, dinî bir asgari, bir hüküm, ibadet
  /// değeri veya manevi bir derece DEĞİLDİR; yalnız TASK 079 bütçe
  /// denetimi için kullanılan teknik bir tahmindir ve kalıcı plana
  /// yazılmaz.
  static const int estimatedMinutesPerItem = 1;

  /// Sabit katkı sırası.
  ///
  /// **Açık** bir listedir: `Set` yineleme sırasına, enum bildirim
  /// sırasına, harita ekleme sırasına veya yerelleştirilmiş etiket
  /// sıralamasına GÜVENİLMEZ.
  static const List<(OnboardingFocusGoal, String)> contributionOrder = [
    (OnboardingFocusGoal.trackPrayers, trackDailyTemplateId),
    (OnboardingFocusGoal.prayOnTime, onTimeDailyTemplateId),
  ];

  /// Bağlamdaki hedeflere göre sıralı namaz katkılarını döndürür.
  ///
  /// Her geçerli [DailyPlanDayContext] için **toplam**dır: şablon
  /// kimlikleri sabit ve tekil, tahmini süre sabit ve pozitiftir, bu
  /// yüzden taslak kurulumu başarısız olamaz ve tekrar eden şablon
  /// oluşamaz. Ulaşılamayan bir hata dalı bilinçli olarak eklenmemiştir.
  @override
  ResultFuture<List<PlanItemDraft>> itemsFor(
    DailyPlanDayContext context,
  ) async {
    final drafts = <PlanItemDraft>[];
    for (final (goal, templateId) in contributionOrder) {
      if (context.goals.contains(goal)) {
        drafts.add(
          PlanItemDraft(
            templateId: templateId,
            type: PlanItemType.prayer,
            estimatedMinutes: estimatedMinutesPerItem,
            // Vakit adı ve sayı BİLİNÇLİ olarak yok: belirli bir namaz
            // veya namaz sayısı iddia edilmez.
          ),
        );
      }
    }
    return Result.success(drafts);
  }
}
