import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/value_objects/learn_daily_plan_catalog.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';

/// Learn plan öğesi kaynağı — TASK 079 sözleşmesinin üçüncü ve son onaylı
/// çekirdek implementasyonu (TASK 082).
///
/// ## Ne üretir
///
/// Kullanıcının mevcut `islamicKnowledge` onboarding hedefi seçiliyse, her
/// üretilen gün için **tek** bir öğrenme öğesi: o günün
/// [LearnDailyPlanCatalog] girişindeki **yayınlanmış ve kaynak gövdesi
/// doğrulanmış** makaleyi açma/sürdürme eylemi.
///
/// | Hedef | Şablon |
/// |---|---|
/// | `islamicKnowledge` | `learn_article_<articleId>` |
///
/// `islamicKnowledge` seçili değilse **boş liste** döner (hata değildir).
/// `trackPrayers`, `prayOnTime`, `quranHabit` ve `dhikrRoutine` bu kaynağın
/// çıktısını ETKİLEMEZ.
///
/// ## Ne YAPMAZ
///
/// Makale başlığı, özeti, gövdesi, çevirisi veya kaynak metni plana
/// **KOPYALANMAZ** — yalnız stabil makale kimliği `targetRef`'e yazılır.
/// Dinî nesir üretilmez, ayet/hadis/fetva gömülmez, okuma miktarı veya
/// tamamlama kotası atanmaz. Üretim sırasında **hiçbir Learn repository'si,
/// asset bundle'ı veya okuma geçmişi OKUNMAZ**: katalog derleme zamanı
/// sabitidir ve içerikle tutarlılığı testte kilitlenir.
///
/// ## Profil ve faz bağımsızlığı
///
/// Aynı hedef ve aynı gün ofseti için katkı sekiz profilde ve dört ilerleme
/// fazında (`weekIndex` 0–3) **aynıdır**. `learning_focused` profiline ek
/// makale, `low_time`'a eksik katalog, `advanced`'e artırılmış miktar veya
/// faza bağlı zorluk artışı YOKTUR. Makale günden güne yalnız
/// `dayOffset` ilerlediği için değişir.
///
/// ## Saflık
///
/// Riverpod, `BuildContext`, repository, SharedPreferences, Drift, Firebase,
/// ağ, saat, locale, timezone, rastgelelik KULLANILMAZ; log yazmaz, yan
/// etkisi yoktur. Aynı bağlam daima aynı sonucu verir.
final class LearnDailyPlanItemSource implements DailyPlanItemSource {
  const LearnDailyPlanItemSource({this.catalog = LearnDailyPlanCatalog.v1});

  /// Değişmez katalog; testler kontrollü bir katalog enjekte edebilir.
  final LearnDailyPlanCatalog catalog;

  /// Bu kaynağı tetikleyen tek hedef.
  static const OnboardingFocusGoal triggerGoal =
      OnboardingFocusGoal.islamicKnowledge;

  /// Bu katkının tahmini **uygulama içi etkileşim** bütçesi.
  ///
  /// Makaleyi açmak/sürdürmek için ayrılan asgari plan tahsisidir. Makaleyi
  /// tamamen okumak için gereken süre, dinî olarak yeterli bir çalışma
  /// süresi, zorunlu bir öğrenme miktarı, bir hüküm veya manevi değer
  /// DEĞİLDİR; yalnız TASK 079 bütçe denetimi için kullanılır ve kalıcı
  /// plana yazılmaz.
  static const int estimatedMinutes = 1;

  /// Bağlamdaki hedefe ve gün ofsetine göre Learn katkısını döndürür.
  ///
  /// Yapısal olarak bozuk bir katalog veya sözleşme dışı bir gün ofseti
  /// sessizce ONARILMAZ; tipli bir doğrulama hatası döner. Hata nesnesi
  /// makale kimliği, katalog içeriği, hedef kümesi, `DayKey`, istisna metni
  /// veya yığın izi TAŞIMAZ.
  @override
  ResultFuture<List<PlanItemDraft>> itemsFor(
    DailyPlanDayContext context,
  ) async {
    if (!context.goals.contains(triggerGoal)) {
      return const Result.success(<PlanItemDraft>[]);
    }
    if (!catalog.isValid) {
      return const Result.failure(
        ValidationFailure(messageKey: 'errorUnexpected'),
      );
    }
    final offset = context.dayOffset;
    if (offset < 0 || offset >= catalog.entries.length) {
      return const Result.failure(
        ValidationFailure(messageKey: 'errorUnexpected'),
      );
    }

    // Modülo, döngü, rastgelelik, faz veya profil ayarı YOKTUR: gün ofseti
    // doğrudan katalog indeksidir.
    final entry = catalog.entries[offset];
    return Result.success([
      PlanItemDraft(
        templateId: entry.templateId,
        type: PlanItemType.lesson,
        estimatedMinutes: estimatedMinutes,
        // Yalnız stabil makale kimliği; başlık veya gövde metni DEĞİL.
        targetRef: entry.articleId,
        // Okuma/tamamlama miktarı BİLİNÇLİ olarak yok.
      ),
    ]);
  }
}
