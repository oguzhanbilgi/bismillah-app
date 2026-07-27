import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/features/today/application/daily_plan_state.dart';
import 'package:bismillah_app/features/today/domain/value_objects/missed_day_recovery.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Ara verdikten sonra sakin dönüş notu (TASK 084).
///
/// ## Ton kuralları
///
/// Kaçırılan gün **sayısı gösterilmez**. Kırmızı/uyarı rengi, ünlem,
/// "kaçırdın", "serin kırıldı", ceza, günah, puan, rozet, rütbe veya
/// manevi değerlendirme dili YOKTUR. Uygulamada bir kutucuğu
/// işaretlemenin ibadetin yerine geçtiği iddia EDİLMEZ.
///
/// Not görevleri **engellemez**: planın üstünde durur, hiçbir görevi
/// gizlemez, sırayı değiştirmez ve modal açmaz. Animasyon yoktur —
/// azaltılmış hareket tercihiyle uyumludur.
class TodayRecoveryNote extends StatelessWidget {
  const TodayRecoveryNote({super.key, required this.recovery});

  final MissedDayRecovery recovery;

  /// Not gösterilmeli mi? — saf, test edilebilir kural.
  ///
  /// Kaçırılmış gün yoksa gösterilmez. Bugün **herhangi bir görev**
  /// işaretlendiyse not doğal olarak kaybolur; bunun için yeni bir
  /// kalıcılık anahtarı EKLENMEZ, karar tamamen mevcut plan durumundan
  /// türetilir.
  static bool shouldShow(MissedDayRecovery recovery, DailyPlanState? state) {
    if (!recovery.hasMissedDays) {
      return false;
    }
    if (state is DailyPlanAvailable && state.plan.completedCount > 0) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    // Uzun aradan sonra daha sade bir dönüş cümlesi; ikisi de nötrdür ve
    // hiçbir gün sayısı içermez.
    final message = recovery.isExtendedAbsence
        ? l10n.todayRecoveryExtendedBody
        : l10n.todayRecoveryGentleBody;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s4),
      child: Semantics(
        label: '${l10n.todayRecoveryTitle}. $message',
        excludeSemantics: true,
        child: AppCard(
          variant: AppCardVariant.sand,
          padding: const EdgeInsets.all(AppSpacing.s4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nötr ikon — uyarı/hata ikonu KULLANILMAZ.
              Icon(
                Icons.wb_sunny_outlined,
                size: AppSizes.iconMd,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSpacing.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      l10n.todayRecoveryTitle,
                      token: AppTextStyleToken.bodySmall,
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    AppText(
                      message,
                      token: AppTextStyleToken.caption,
                      secondary: true,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
