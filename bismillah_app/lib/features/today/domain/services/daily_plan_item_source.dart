import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_daily_pace.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/today/domain/value_objects/daily_plan_profile_type.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';

/// Tek bir günün üretim bağlamı — kaynaklara verilen **salt-okunur** girdi.
///
/// Kimlik, konum, saat, locale, timezone veya kalıcılık referansı TAŞIMAZ.
final class DailyPlanDayContext {
  DailyPlanDayContext({
    required this.profileType,
    required List<OnboardingFocusGoal> goals,
    required this.dailyPace,
    required this.sizeMinutes,
    required this.dayKey,
    required this.dayOffset,
    required this.weekIndex,
  }) : goals = List.unmodifiable(goals);

  final DailyPlanProfileType profileType;

  /// Deterministik sıralanmış hedefler.
  final List<OnboardingFocusGoal> goals;

  final OnboardingDailyPace dailyPace;

  /// Günün toplam dakika bütçesi — kaynak bunu AŞAMAZ.
  final int sizeMinutes;

  final DayKey dayKey;

  /// 0–29 arası sıfır tabanlı gün ofseti.
  final int dayOffset;

  /// 0–3 arası ilerleme fazı.
  final int weekIndex;
}

/// Bir kaynağın önerdiği plan öğesi taslağı.
///
/// `PlanItem`'ın süre alanı yoktur; bütçe denetimi bu taslaktaki
/// [estimatedMinutes] üzerinden yapılır ve alan kalıcı plana YAZILMAZ.
///
/// **Dinî içerik taşımaz:** yalnız stabil şablon/hedef KİMLİKLERİ tutar
/// (`targetRef` = içerik ID'si / vakit adı kodu). Kullanıcıya görünen
/// metin localization katmanındadır.
final class PlanItemDraft {
  PlanItemDraft({
    required this.templateId,
    required this.type,
    required this.estimatedMinutes,
    this.targetRef,
    this.sizeParam,
  }) {
    if (templateId.trim().isEmpty) {
      throw ArgumentError.value(
        templateId,
        'templateId',
        'Stabil şablon kimliği zorunlu (üretim izlenebilirliği)',
      );
    }
    if (estimatedMinutes < 0) {
      throw ArgumentError.value(
        estimatedMinutes,
        'estimatedMinutes',
        'Negatif olamaz',
      );
    }
  }

  /// Onaylı katalogdaki stabil şablon kimliği (yerelleştirilmiş metin DEĞİL).
  final String templateId;

  final PlanItemType type;

  /// Bütçe denetimi için tahmini süre; `PlanItem`'a yazılmaz.
  final int estimatedMinutes;

  /// İçerik/vakit referansı (ör. ders ID'si) — ham dinî metin DEĞİL.
  final String? targetRef;

  /// Boyut parametresi (ayet sayısı, tekrar adedi…).
  final int? sizeParam;
}

/// Bir güne plan öğesi öneren kaynak sözleşmesi.
///
/// **TASK 079 hiçbir dinî içerik sağlamaz.** Onaylı kaynaklar sonraki
/// görevlerde gelir:
///
/// - **TASK 080** — Prayer plan items
/// - **TASK 081** — Quran plan items
/// - **TASK 082** — Learn plan items
///
/// Kaynak, sırası anlamlı bir liste döndürür; üretici sırayı korur.
/// Hata durumunda tipli `AppFailure` döner ve üretim **kısmi çıktı
/// vermez**.
abstract interface class DailyPlanItemSource {
  ResultFuture<List<PlanItemDraft>> itemsFor(DailyPlanDayContext context);
}

/// İçerik sağlamayan varsayılan kaynak (TASK 079).
///
/// Yan etkisi yoktur: repository, asset, saat veya ağ okumaz, log yazmaz
/// ve eşit girdi için daima aynı sonucu döner. Boş öğe listesi bir hata
/// DEĞİLDİR — `DailyPlan` boş `items` listesini açıkça kabul eder.
final class EmptyDailyPlanItemSource implements DailyPlanItemSource {
  const EmptyDailyPlanItemSource();

  @override
  ResultFuture<List<PlanItemDraft>> itemsFor(
    DailyPlanDayContext context,
  ) async => const Result.success(<PlanItemDraft>[]);
}

/// Üretilen plan öğeleri için deterministik stabil kimlik üreteci.
///
/// Kimlik yalnız kalıcı kanonik girdilerden türer: üretici sürümü, gün
/// anahtarı, şablon kimliği ve gün içi slot. Rastgelelik, zaman damgası,
/// `hashCode`, süreç durumu, cihaz kimliği veya locale'e duyarlı metin
/// KULLANILMAZ; aynı istek daima aynı kimlikleri verir.
abstract final class DailyPlanItemIdBuilder {
  static const String separator = ':';

  static EntityId build({
    required String generatorVersion,
    required DayKey dayKey,
    required String templateId,
    required int slot,
  }) {
    if (slot < 0) {
      throw ArgumentError.value(slot, 'slot', 'Negatif olamaz');
    }
    return EntityId(
      [generatorVersion, dayKey.value, templateId, '$slot'].join(separator),
    );
  }
}
