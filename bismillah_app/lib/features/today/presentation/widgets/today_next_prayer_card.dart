import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:bismillah_app/features/prayer_times/application/prayer_times_controller.dart';
import 'package:bismillah_app/features/prayer_times/application/prayer_times_state.dart';
import 'package:bismillah_app/features/prayer_times/domain/daily_prayer_times.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Today panosundaki "Sıradaki namaz" kartı — SALT-OKUNUR.
///
/// TASK 021 vakit motorunu ve konum durumunu yeniden kullanır (yeni hesap
/// sistemi kurmaz). Yalnız BEŞ vakit arasından sıradakini seçer — Güneş
/// namaz değildir, seçilmez. Canlı saniye sayacı / timer YOKTUR: an,
/// `clockProvider` üzerinden bir kez okunur. Today konum izni İSTEMEZ —
/// eksik izinde yalnız Namaz sekmesine sakin bir davet gösterir.
class TodayNextPrayerCard extends ConsumerWidget {
  const TodayNextPrayerCard({super.key, required this.onGoToPrayers});

  /// CTA: Namaz sekmesine geçiş (navigasyon kararı ekranın işidir).
  final VoidCallback onGoToPrayers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final timesAsync = ref.watch(prayerTimesControllerProvider);
    final state = timesAsync.value;

    if (timesAsync.isLoading && state == null) {
      // ListView içinde sınırsız yükseklik istememek için kompakt gösterge.
      return _card(
        title: l10n.todayNextPrayerTitle,
        child: const SizedBox(
          height: AppSizes.iconMd,
          width: AppSizes.iconMd,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return switch (state) {
      PrayerTimesReady(:final times) => _ready(ref, l10n, times),
      // Today izin İSTEMEZ: Namaz sekmesine sakin davet.
      PrayerTimesNeedsPermission() => _message(
        l10n,
        l10n.todayNextPrayerLocationCta,
      ),
      PrayerTimesUnavailable() => _message(
        l10n,
        l10n.todayNextPrayerUnavailable,
      ),
      null => const SizedBox.shrink(),
    };
  }

  Widget _ready(WidgetRef ref, AppLocalizations l10n, DailyPrayerTimes times) {
    final next = times.nextPrayerAfter(ref.read(clockProvider).nowUtc());
    if (next == null) {
      // Beş vakit de geçti — sakin bitiş mesajı (yarın hesaplanmaz).
      return _message(l10n, l10n.todayNextPrayerAllDone);
    }
    // TASK 054: saat ve vakit adı tek bir güçlü hiyerarşide birleşir.
    // RDX-01C1: referanstaki okuma sırası uygulanır — önce hangi vakit
    // (ad), sonra saat en büyük öğe olarak. Kart başlığı artık bir
    // "eyebrow"dur (küçük, sönük), böylece büyük saatle yarışmaz.
    return _card(
      title: l10n.todayNextPrayerTitle,
      variant: AppCardVariant.sand,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            _prayerLabel(l10n, next.name),
            token: AppTextStyleToken.h3,
            maxLines: 1,
          ),
          AppText(
            _formatLocal(next.instant),
            token: AppTextStyleToken.statLarge,
          ),
          const SizedBox(height: AppSpacing.s5),
          AppButton(
            label: l10n.todayGoToPrayers,
            variant: AppButtonVariant.secondary,
            onPressed: onGoToPrayers,
          ),
        ],
      ),
    );
  }

  /// Sakin tek-satır durum + Namaz sekmesine CTA (izin/uygun değil/bitti).
  Widget _message(AppLocalizations l10n, String message) => _card(
    title: l10n.todayNextPrayerTitle,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(message, token: AppTextStyleToken.bodySmall, secondary: true),
        const SizedBox(height: AppSpacing.s4),
        AppButton(
          label: l10n.todayGoToPrayers,
          variant: AppButtonVariant.secondary,
          onPressed: onGoToPrayers,
        ),
      ],
    ),
  );

  Widget _card({
    required String title,
    Widget? trailing,
    required Widget child,
    AppCardVariant variant = AppCardVariant.elevated,
  }) {
    return AppCard(
      variant: variant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Eyebrow: küçük ve sönük — kartın içeriği (vakit ve saat)
              // görsel ağırlığı taşır.
              Expanded(
                child: AppText(
                  title,
                  token: AppTextStyleToken.caption,
                  tone: AppTextTone.secondary,
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: AppSpacing.s2),
          child,
        ],
      ),
    );
  }
}

/// UTC instant → yerel cihaz saatinde "HH:mm" (sabit UTC+3 EKLENMEZ;
/// `.toLocal()` cihaz timezone'unu kullanır — TASK 021 zaman kuralı).
String _formatLocal(DateTime utc) {
  final local = utc.toLocal();
  final h = local.hour.toString().padLeft(2, '0');
  final m = local.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

/// Vakit adının yerelleştirilmiş etiketi.
String _prayerLabel(AppLocalizations l10n, PrayerName name) => switch (name) {
  PrayerName.fajr => l10n.prayerNameFajr,
  PrayerName.dhuhr => l10n.prayerNameDhuhr,
  PrayerName.asr => l10n.prayerNameAsr,
  PrayerName.maghrib => l10n.prayerNameMaghrib,
  PrayerName.isha => l10n.prayerNameIsha,
};
