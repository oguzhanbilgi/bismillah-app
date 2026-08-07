import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/features/today/application/today_prayer_summary_state.dart';
import 'package:bismillah_app/features/today/presentation/today_date_format.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_progress_bar.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Today panosundaki namaz özeti kartı — SALT-OKUNUR.
///
/// İlerleme sakin sunulur: 0/5 bile utandırmaz (AppProgressBar'ın boş
/// rayı estetiktir, 03_DESIGN_SYSTEM §20); kırmızı/uyarı durumu yoktur.
class TodayPrayerSummaryCard extends StatelessWidget {
  const TodayPrayerSummaryCard({
    super.key,
    required this.state,
    required this.onGoToPrayers,
  });

  final TodayPrayerSummaryState state;

  /// CTA: Namaz sekmesine geçiş (navigasyon kararı ekranın işidir).
  final VoidCallback onGoToPrayers;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // TASK 054: sıradaki namaz kartı (kum, dolu yüzey) ana odaktır; bu özet
    // onu DESTEKLER — gölgesiz border'lı varyantla bir adım geri çekilir ve
    // iki kart art arda aynı beyaz kutu gibi görünmez. Ton baskı kurmaz.
    return AppCard(
      variant: AppCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // RDX-01C2: başlık solda, ilerleme SAĞDA aynı satırda — referansın
          // kompakt özet düzeni. Sayı artık kendi satırını kaplamaz, kart
          // belirgin biçimde kısalır.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      l10n.todayPrayerCardTitle,
                      token: AppTextStyleToken.h3,
                      maxLines: 1,
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    // Ham `2026-08-07` yerine cihazın dilinde okunabilir
                    // tarih; ay adı elle yazılmaz.
                    AppText(
                      formatDayKeyForDisplay(context, state.dayKey),
                      token: AppTextStyleToken.caption,
                      tone: AppTextTone.tertiary,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s3),
              AppText(
                l10n.todayPrayerProgress(
                  state.completedCount,
                  TodayPrayerSummaryState.totalCount,
                ),
                token: AppTextStyleToken.bodySmall,
                tone: AppTextTone.secondary,
                maxLines: 1,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          AppProgressBar(
            value: state.progress,
            semanticLabel: l10n.todayPrayerCardTitle,
          ),
          // Baskın pill yerine sessiz metin eylemi — kart bir "CTA kutusu"
          // gibi okunmaz; eylem hâlâ tam dokunma hedefindedir.
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppButton(
              label: l10n.todayGoToPrayers,
              variant: AppButtonVariant.text,
              onPressed: onGoToPrayers,
            ),
          ),
        ],
      ),
    );
  }
}
