import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_item_source.dart';

/// Birden çok plan öğesi kaynağını **açık sırayla** birleştiren saf kaynak
/// (TASK 081).
///
/// TASK 079 üreticisi tek bir [DailyPlanItemSource] alır; bu bileşik kaynak
/// o sözleşmeyi bozmadan çoklu kaynağı mümkün kılar.
///
/// ## Sıra
///
/// Çocuk sırası **yapıcıya verilen liste sırasıdır**. Çalışma zamanı tipine,
/// sınıf adına, `Set` saklamasına veya harita yineleme sırasına
/// GÜVENİLMEZ.
///
/// Onaylı genel sıra: **Prayer → Quran → Learn**. Bu deterministik bir ürün
/// kararıdır; dinî bir sıralama/üstünlük DEĞİLDİR. Learn (TASK 082) sona
/// eklendiğinde mevcut Prayer ve Quran öğelerinin slot'ları — ve dolayısıyla
/// nihai kimlikleri — DEĞİŞMEZ.
///
/// ## Davranış
///
/// - Her çocuk gün başına **bir kez** çağrılır.
/// - Başarılı katkılar kaynak sırasında birleştirilir.
/// - İlk tipli çocuk hatası aynen yukarı taşınır ve **kısmi liste
///   DÖNDÜRÜLMEZ** — daha önce toplanan katkılar atılır.
/// - **Kaynaklar ARASINDA** tekrar eden şablon kimliği tipli doğrulama
///   hatasıyla reddedilir (iki farklı kaynağın aynı eylemi iddia etmesi bir
///   yapılandırma hatasıdır). Bir kaynağın kendi içinde aynı şablonu
///   tekrarlaması bu kaynağın kararıdır ve TASK 079'un slot mekanizması
///   nihai kimliği zaten ayırır.
/// - Boş çocuk listesi → boş başarılı katkı listesi.
///
/// ## Saflık
///
/// Repository, kalıcılık, ağ, saat, locale, global singleton ve log YOKTUR;
/// eşdeğer sıralı kaynak listeleri için deterministiktir. Hata nesnesi çocuk
/// sınıf adı, ham katkı yükü, hedef kümesi, `DayKey`, istisna metni veya
/// yığın izi TAŞIMAZ.
///
/// Uygulama genelinde **eager varsayılan değildir** — çağıran açıkça kurar:
///
/// ```dart
/// const CompositeDailyPlanItemSource(
///   sources: [
///     PrayerDailyPlanItemSource(),
///     QuranDailyPlanItemSource(),
///   ],
/// )
/// ```
final class CompositeDailyPlanItemSource implements DailyPlanItemSource {
  const CompositeDailyPlanItemSource({required this.sources});

  /// Açık sıralı çocuk kaynaklar; sıra anlamlıdır.
  final List<DailyPlanItemSource> sources;

  @override
  ResultFuture<List<PlanItemDraft>> itemsFor(
    DailyPlanDayContext context,
  ) async {
    final combined = <PlanItemDraft>[];
    // Yalnız ÖNCEKİ kaynaklardan gelen şablonlar; kaynak-içi tekrarlar
    // bilinçli olarak serbesttir.
    final templatesFromEarlierSources = <String>{};

    for (final source in sources) {
      final result = await source.itemsFor(context);

      final failure = result.failureOrNull;
      if (failure != null) {
        // Kısmi katkı DÖNDÜRÜLMEZ — daha önce toplananlar atılır.
        return Result.failure(failure);
      }

      final drafts = result.valueOrNull!;
      for (final draft in drafts) {
        if (templatesFromEarlierSources.contains(draft.templateId)) {
          // İki kaynak aynı eylemi iddia ediyor — yapılandırma hatası.
          return const Result.failure(
            ValidationFailure(messageKey: 'errorUnexpected'),
          );
        }
      }

      combined.addAll(drafts);
      templatesFromEarlierSources.addAll(
        drafts.map((draft) => draft.templateId),
      );
    }

    return Result.success(List.unmodifiable(combined));
  }
}
