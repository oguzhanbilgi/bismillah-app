import 'package:bismillah_app/features/today/domain/services/composite_daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/services/learn_daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/services/prayer_daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/services/quran_daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/value_objects/learn_daily_plan_catalog.dart';

/// Onaylı **çekirdek** plan öğesi bileşimi (TASK 082).
///
/// Sıra **Prayer → Quran → Learn**'dür ve yapıcıya verilen açık liste
/// sırasından gelir. Bu deterministik bir ürün/gösterim kuralıdır; dinî bir
/// sıralama, öncelik veya üstünlük DEĞİLDİR.
///
/// Üç çekirdek kaynağın tamamı TASK 080/081/082 ile onaylanmıştır; bu tip
/// yalnız onları tek yerde, tek doğru sırayla toplar.
///
/// ## Sınırlar
///
/// Bu bir Riverpod provider'ı, uygulama genelinde eager kurulan bir
/// singleton veya bootstrap bağlantısı DEĞİLDİR: `const` bir derleme zamanı
/// değeridir ve hiçbir yerden otomatik çağrılmaz. Onboarding tamamlanması,
/// kalıcılık ve Today UI bağlantısı sonraki görevlerin işidir. Çağıran
/// isterse kendi bileşimini kurabilir — [withCatalog] test veya ileri
/// kişiselleştirme için kontrollü bir katalog enjekte eder.
abstract final class CoreDailyPlanItemSource {
  /// Üretim varsayılanı: Prayer → Quran → Learn (sürüm 1 kataloğu).
  static const CompositeDailyPlanItemSource approved =
      CompositeDailyPlanItemSource(
        sources: [
          PrayerDailyPlanItemSource(),
          QuranDailyPlanItemSource(),
          LearnDailyPlanItemSource(),
        ],
      );

  /// Aynı sırayı verilen Learn kataloğuyla kurar — saf ve yan etkisiz.
  static CompositeDailyPlanItemSource withCatalog(
    LearnDailyPlanCatalog catalog,
  ) => CompositeDailyPlanItemSource(
    sources: [
      const PrayerDailyPlanItemSource(),
      const QuranDailyPlanItemSource(),
      LearnDailyPlanItemSource(catalog: catalog),
    ],
  );
}
