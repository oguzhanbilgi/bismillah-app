import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/presentation/today_plan_item_presentation.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_motion_switcher.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Tek bir günlük plan görevi kartı (TASK 083).
///
/// ## Ton
///
/// Tamamlanmamış görev bir **başarısızlık değildir**: kırmızı renk, uyarı
/// ikonu, "kaçırdın" dili, seri (streak) kaybı, puan veya sıralama YOKTUR.
/// Tamamlanan görev yalnız yumuşak bir yüzey ve onay ikonu alır.
///
/// İşaretleme uygulama içi bir **takip** eylemidir; ibadetin yerine
/// getirildiği, kabul edildiği veya manevi bir derece kazanıldığı iddiası
/// DEĞİLDİR.
class TodayPlanTaskCard extends StatelessWidget {
  const TodayPlanTaskCard({
    super.key,
    required this.item,
    required this.presentation,
    this.onToggle,
  });

  final PlanItem item;
  final TodayPlanItemPresentation presentation;

  /// Tamamlanma durumunu çevirir; `null` ise kart salt-okunurdur
  /// (ör. kaydetme sürerken).
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final ext = AppThemeExtension.of(context);
    final completed = item.isCompleted;

    final statusLabel = completed
        ? l10n.todayPlanItemCompleted
        : l10n.todayPlanItemPending;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s3),
      child: Semantics(
        button: onToggle != null,
        // Ekran okuyucu tek cümlede görevi ve durumunu duyar.
        label: '${presentation.title}, $statusLabel',
        toggled: completed,
        excludeSemantics: true,
        child: AppCard(
          variant: AppCardVariant.outlined,
          completed: completed,
          onTap: onToggle,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
            vertical: AppSpacing.s3,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.touchTarget),
            child: Row(
              children: [
                Icon(
                  presentation.icon,
                  size: AppSizes.iconMd,
                  color: scheme.primary,
                ),
                const SizedBox(width: AppSpacing.s4),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Uzun/çok dilli başlıklar dar ekranda taşmaz.
                      AppText(presentation.title, maxLines: 2),
                      const SizedBox(height: AppSpacing.s1),
                      AppText(
                        statusLabel,
                        token: AppTextStyleToken.caption,
                        secondary: true,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s3),
                // Onay göstergesi: tamamlanmamışta nötr boş halka —
                // uyarı/hata rengi KULLANILMAZ.
                //
                // TASK 094A: işaret sert biçimde yer değiştirmez, sakin bir
                // çapraz geçişle belirir. Kutlama, konfeti, zıplama, puan
                // ve seri dili YOKTUR; geçiş yalnız "değişti" der.
                AppMotionSwitcher(
                  child: Icon(
                    completed
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    key: ValueKey<bool>(completed),
                    size: AppSizes.iconMd,
                    color: completed ? scheme.primary : ext.surfaceAlt,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
