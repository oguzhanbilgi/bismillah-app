import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/utils/date_key.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_generation_request.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';

/// Deterministik 30 günlük plan üreticisi (TASK 079).
///
/// Kanonik çatı **30 ayrı gün-başına `DailyPlan` kaydıdır** (10_DATA_MODEL
/// §4); tek bir toplu (aggregate) nesne üretilmez.
///
/// ## Saflık
///
/// Riverpod, `BuildContext`, repository, SharedPreferences, Drift,
/// Firebase, ağ, sistem saati, locale, timezone, rastgelelik, analytics
/// ve bildirim KULLANILMAZ. Değişken her girdi
/// [DailyPlanGenerationRequest] ile açıkça verilir.
///
/// **Üretilen planlar KAYDEDİLMEZ** — kalıcılık orkestrasyonu sonraki bir
/// görevin işidir.
///
/// ## İçerik sınırı
///
/// TASK 079 hiçbir dinî içerik üretmez. Öğeler yalnız kayıtlı bir
/// [DailyPlanItemSource]'tan gelir; varsayılan
/// [EmptyDailyPlanItemSource] ile 30 gün **boş `items` listesiyle** ve
/// tamamen geçerli olarak üretilir. Onaylı kaynaklar TASK 080 (Prayer),
/// TASK 081 (Quran) ve TASK 082 (Learn) ile gelir.
abstract final class DailyPlanGenerator {
  /// Üretim izlenebilirliği için kural motoru sürümü
  /// (`10_DATA_MODEL` §4 — `generatedBy(rule-engine ver.)`).
  static const String generatorVersion = 'rule-engine-v1';

  /// İlerleme fazı sınırları — **onaylı TASK 079 ürün kararı**.
  ///
  /// `weekIndex` takvim haftası SAYISI değil, sıfır tabanlı ilerleme
  /// fazıdır: 0–6 → 0 · 7–13 → 1 · 14–20 → 2 · 21–29 → 3. Son iki gün
  /// (29 ve 30) faz 3'te kalır; **`weekIndex` 4 üretilmez**. Fazlara
  /// uydurulmuş dinî anlam yüklenmez.
  static int weekIndexForOffset(int offset) {
    if (offset < 7) {
      return 0;
    }
    if (offset < 14) {
      return 1;
    }
    if (offset < 21) {
      return 2;
    }
    return 3;
  }

  /// Başlangıç gününden `offset` gün sonrasının anahtarı.
  ///
  /// Yerel takvim aritmetiği kullanılır (`DateTime(y, m, d + offset)`
  /// taşmayı normalize eder); UTC dönüşümü ve `Duration(hours: 24)`
  /// varsayımı YOKTUR, bu yüzden yaz saati geçişleri günü kaydırmaz.
  static DayKey dayAt(DayKey startDay, int offset) {
    final year = int.parse(startDay.value.substring(0, 4));
    final month = int.parse(startDay.value.substring(5, 7));
    final day = int.parse(startDay.value.substring(8, 10));
    return DayKey(DateKey.fromLocal(DateTime(year, month, day + offset)));
  }

  /// İsteği 30 gün-başına plana çevirir.
  ///
  /// Başarısızlıkta **kısmi çıktı dönmez**; tipli `AppFailure` döner.
  static ResultFuture<List<DailyPlan>> generate(
    DailyPlanGenerationRequest request, {
    DailyPlanItemSource source = const EmptyDailyPlanItemSource(),
  }) async {
    if (!request.isValid) {
      // Tutarsız girdi sessizce ONARILMAZ. Sebep tipli
      // `GenerationRequestIssue` ile `request.validate()` üzerinden
      // okunur; hata nesnesi ham girdi taşımaz.
      return const Result.failure(
        ValidationFailure(messageKey: 'errorUnexpected'),
      );
    }

    final sizeMinutes = request.sizeMinutes;
    final plans = <DailyPlan>[];

    for (
      var offset = 0;
      offset < DailyPlanGenerationRequest.planLengthDays;
      offset++
    ) {
      final dayKey = dayAt(request.startDay, offset);
      final weekIndex = weekIndexForOffset(offset);

      final drafts = await source.itemsFor(
        DailyPlanDayContext(
          profileType: request.profileType,
          goals: request.normalizedGoals,
          dailyPace: request.dailyPace,
          sizeMinutes: sizeMinutes,
          dayKey: dayKey,
          dayOffset: offset,
          weekIndex: weekIndex,
        ),
      );

      final failure = drafts.failureOrNull;
      if (failure != null) {
        // Kaynak hatası aynen yukarı taşınır — yarım plan ÜRETİLMEZ.
        return Result.failure(failure);
      }

      final items = <PlanItem>[];
      var spentMinutes = 0;
      var slot = 0;
      for (final draft in drafts.valueOrNull!) {
        spentMinutes += draft.estimatedMinutes;
        if (spentMinutes > sizeMinutes) {
          // Zaman bütçesi kutsaldır (04 §9-2).
          return const Result.failure(UnexpectedFailure());
        }
        items.add(
          PlanItem(
            itemId: DailyPlanItemIdBuilder.build(
              generatorVersion: generatorVersion,
              dayKey: dayKey,
              templateId: draft.templateId,
              slot: slot,
            ),
            type: draft.type,
            status: PlanItemStatus.pending,
            targetRef: draft.targetRef,
            sizeParam: draft.sizeParam,
          ),
        );
        slot++;
      }

      final DailyPlan plan;
      try {
        plan = DailyPlan(
          dayKey: dayKey,
          items: items,
          // TASK 078 tipli profili, mevcut `String` alanına stabil
          // kimliğiyle yazılır; `toString()` veya yerelleştirilmiş etiket
          // KULLANILMAZ ve ikinci bir profil temsili eklenmez.
          profileType: request.profileType.id,
          sizeMinutes: sizeMinutes,
          weekIndex: weekIndex,
          generatedBy: generatorVersion,
        );
      } on ArgumentError {
        return const Result.failure(UnexpectedFailure());
      }
      plans.add(plan);
    }

    final invariantFailure = _validateOutput(request, plans);
    if (invariantFailure != null) {
      return Result.failure(invariantFailure);
    }
    return Result.success(List.unmodifiable(plans));
  }

  /// Çıktı değişmezleri — ihlalde başarı DÖNÜLMEZ.
  static AppFailure? _validateOutput(
    DailyPlanGenerationRequest request,
    List<DailyPlan> plans,
  ) {
    if (plans.length != DailyPlanGenerationRequest.planLengthDays) {
      return const UnexpectedFailure();
    }
    final seenDays = <String>{};
    for (var i = 0; i < plans.length; i++) {
      final plan = plans[i];
      if (plan.dayKey != dayAt(request.startDay, i)) {
        return const UnexpectedFailure(); // süreklilik/sıra bozuldu
      }
      if (!seenDays.add(plan.dayKey.value)) {
        return const UnexpectedFailure(); // tekrar eden gün
      }
      if (plan.profileType != request.profileType.id ||
          plan.sizeMinutes != request.sizeMinutes ||
          plan.weekIndex != weekIndexForOffset(i) ||
          plan.generatedBy != generatorVersion) {
        return const UnexpectedFailure();
      }
      final seenItems = <String>{};
      for (final item in plan.items) {
        if (!seenItems.add(item.itemId.value)) {
          return const UnexpectedFailure(); // gün içinde tekrar eden kimlik
        }
      }
    }
    return null;
  }
}
