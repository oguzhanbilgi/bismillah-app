import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/services/prayer_daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/services/quran_daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/value_objects/learn_daily_plan_catalog.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';
import 'package:flutter/material.dart';

/// Plan öğesinin kullanıcıya görünen **nötr** sunumu (TASK 083).
///
/// Saf ve senkron bir eşlemedir: repository, asset, saat, ağ veya
/// rastgelelik KULLANMAZ. Görünen her metin localization katmanından gelir;
/// şablon kimliği veya `targetRef` ekrana ham yazılmaz.
///
/// ## Dinî sınırlar
///
/// Namaz kotası, ayet/sure ataması, süre iddiası, ödül/ceza, günah dili,
/// manevi puan veya sıralama ÜRETİLMEZ. Bir öğenin işaretlenmesi
/// uygulama içi bir takip eylemidir; ibadetin yerine getirildiği veya
/// kabul edildiği iddiası DEĞİLDİR.
///
/// ## Bilinmeyen şablon
///
/// Tanınmayan bir şablon için uydurma başlık üretilmez: öğe tipine göre
/// nötr bir kategori etiketi kullanılır. Ekran hiçbir durumda çökmez.
@immutable
final class TodayPlanItemPresentation {
  const TodayPlanItemPresentation({
    required this.title,
    required this.icon,
    this.isResolving = false,
  });

  /// Yerelleştirilmiş, nötr başlık.
  final String title;

  /// Kategori ikonu (dekoratif; anlam başlıkta taşınır).
  final IconData icon;

  /// Learn başlığı henüz çözülüyor mu?
  final bool isResolving;

  /// Namaz/Kur'an şablonları ve tip bazlı yedekler için senkron çözüm.
  ///
  /// Learn öğelerinde `learnTitle` verilirse kullanılır; `null` ise nötr
  /// bir kategori etiketine düşülür — **uydurma makale başlığı üretilmez**.
  static TodayPlanItemPresentation of(
    AppLocalizations l10n,
    PlanItem item, {
    String? learnTitle,
    bool isResolvingLearnTitle = false,
  }) {
    final templateId = templateIdOf(item);

    if (templateId == PrayerDailyPlanItemSource.trackDailyTemplateId) {
      return TodayPlanItemPresentation(
        title: l10n.todayPlanItemPrayerTrack,
        icon: Icons.mosque_outlined,
      );
    }
    if (templateId == PrayerDailyPlanItemSource.onTimeDailyTemplateId) {
      return TodayPlanItemPresentation(
        title: l10n.todayPlanItemPrayerOnTime,
        icon: Icons.schedule_outlined,
      );
    }
    if (templateId == QuranDailyPlanItemSource.continueDailyTemplateId) {
      return TodayPlanItemPresentation(
        title: l10n.todayPlanItemQuranContinue,
        icon: Icons.menu_book_outlined,
      );
    }
    if (item.type == PlanItemType.lesson) {
      return TodayPlanItemPresentation(
        // Çözülmüş başlık DOĞRULANMIŞ Learn içerik katmanından gelir;
        // çözülemezse nötr kategori etiketi kullanılır.
        title: learnTitle ?? l10n.todayPlanItemLessonFallback,
        icon: Icons.school_outlined,
        isResolving: learnTitle == null && isResolvingLearnTitle,
      );
    }
    return TodayPlanItemPresentation(
      title: _typeFallback(l10n, item.type),
      icon: _typeIcon(item.type),
    );
  }

  /// Nihai öğe kimliğinden şablon parçasını okur.
  ///
  /// Kimlik biçimi `rule-engine-v1:<dayKey>:<templateId>:<slot>`
  /// (TASK 079). Beklenmeyen bir biçimde `null` döner ve çağıran tip
  /// bazlı yedeğe düşer — istisna FIRLATILMAZ.
  static String? templateIdOf(PlanItem item) {
    final parts = item.itemId.value.split(
      LearnDailyPlanCatalog.reservedIdSeparator,
    );
    if (parts.length != 4) {
      return null;
    }
    final templateId = parts[2];
    return templateId.isEmpty ? null : templateId;
  }

  static String _typeFallback(AppLocalizations l10n, PlanItemType type) =>
      switch (type) {
        PlanItemType.prayer => l10n.todayPlanItemPrayerFallback,
        PlanItemType.quran => l10n.todayPlanItemQuranFallback,
        PlanItemType.lesson => l10n.todayPlanItemLessonFallback,
        PlanItemType.dhikr => l10n.todayPlanItemDhikrFallback,
        PlanItemType.dua => l10n.todayPlanItemDuaFallback,
        PlanItemType.reflection => l10n.todayPlanItemReflectionFallback,
      };

  static IconData _typeIcon(PlanItemType type) => switch (type) {
    PlanItemType.prayer => Icons.mosque_outlined,
    PlanItemType.quran => Icons.menu_book_outlined,
    PlanItemType.lesson => Icons.school_outlined,
    PlanItemType.dhikr => Icons.self_improvement_outlined,
    PlanItemType.dua => Icons.favorite_border,
    PlanItemType.reflection => Icons.lightbulb_outline,
  };
}
