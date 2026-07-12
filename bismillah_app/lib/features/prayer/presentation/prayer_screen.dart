import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/features/prayer/application/prayer_log_controller.dart';
import 'package:bismillah_app/features/prayer/application/prayer_log_state.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:bismillah_app/features/prayer/presentation/widgets/prayer_entry_tile.dart';
import 'package:bismillah_app/features/prayer_times/application/prayer_times_controller.dart';
import 'package:bismillah_app/features/prayer_times/application/prayer_times_state.dart';
import 'package:bismillah_app/features/prayer_times/domain/daily_prayer_times.dart';
import 'package:bismillah_app/shared/widgets/app_badge.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_error_state.dart';
import 'package:bismillah_app/shared/widgets/app_loading.dart';
import 'package:bismillah_app/shared/widgets/app_section_header.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Namaz sekmesi — namaz kaydı (TASK 016) + hesaplanmış vakitler (TASK 021).
///
/// Vakit hesabı KAYITTAN BAĞIMSIZDIR: konum reddedilse bile işaretleme/geri
/// alma çalışır (tiles time olmadan render edilir). Görsel dil sakindir.
class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncState = ref.watch(prayerLogControllerProvider);

    return AppScaffold(
      title: l10n.tabPrayer,
      body: switch (asyncState) {
        AsyncData(:final value) => _PrayerLogView(state: value),
        AsyncError() => AppErrorState(
          message: l10n.prayerLoadIssue,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(prayerLogControllerProvider),
        ),
        _ => AppLoading(label: l10n.commonLoading),
      },
    );
  }
}

/// UTC instant → yerel cihaz saatinde "HH:mm" (sabit UTC+3 EKLENMEZ;
/// `.toLocal()` cihaz timezone'unu kullanır — dakika hassasiyeti korunur).
String _formatLocal(DateTime utc) {
  final local = utc.toLocal();
  final h = local.hour.toString().padLeft(2, '0');
  final m = local.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

final class _PrayerLogView extends ConsumerWidget {
  const _PrayerLogView({required this.state});

  final PrayerLogState state;

  static String _label(AppLocalizations l10n, PrayerName name) {
    return switch (name) {
      PrayerName.fajr => l10n.prayerNameFajr,
      PrayerName.dhuhr => l10n.prayerNameDhuhr,
      PrayerName.asr => l10n.prayerNameAsr,
      PrayerName.maghrib => l10n.prayerNameMaghrib,
      PrayerName.isha => l10n.prayerNameIsha,
    };
  }

  static DateTime? _timeFor(DailyPrayerTimes? t, PrayerName name) {
    if (t == null) {
      return null;
    }
    return switch (name) {
      PrayerName.fajr => t.fajr,
      PrayerName.dhuhr => t.dhuhr,
      PrayerName.asr => t.asr,
      PrayerName.maghrib => t.maghrib,
      PrayerName.isha => t.isha,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final controller = ref.read(prayerLogControllerProvider.notifier);
    final timesAsync = ref.watch(prayerTimesControllerProvider);
    final timesState = timesAsync.value;
    final DailyPrayerTimes? times = timesState is PrayerTimesReady
        ? timesState.times
        : null;

    return ListView(
      children: [
        AppSectionHeader(
          title: l10n.prayerTodaySubtitle,
          trailing: AppBadge(label: state.dayKey.value),
        ),
        AppText(
          l10n.prayerGentleLine,
          token: AppTextStyleToken.bodySmall,
          secondary: true,
        ),
        if (state.saveIssue) ...[
          const SizedBox(height: AppSpacing.s4),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: AppSizes.iconSm,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSpacing.s2),
              Expanded(
                child: AppText(
                  l10n.prayerSaveIssue,
                  token: AppTextStyleToken.caption,
                  secondary: true,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.s4),
        _PrayerTimesSection(timesAsync: timesAsync),
        const SizedBox(height: AppSpacing.s5),
        for (final name in PrayerName.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s3),
            child: PrayerEntryTile(
              label: _label(l10n, name),
              time: switch (_timeFor(times, name)) {
                final t? => _formatLocal(t),
                _ => null,
              },
              completed: state.isCompleted(name),
              completedLabel: l10n.prayerCompleted,
              actionLabel: state.isCompleted(name)
                  ? l10n.prayerUndo
                  : l10n.prayerMark,
              onToggle: () => controller.toggle(name),
            ),
          ),
        const SizedBox(height: AppSpacing.s5),
        Center(
          child: AppText(
            l10n.prayerLocalNote,
            token: AppTextStyleToken.caption,
            secondary: true,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.s7),
      ],
    );
  }
}

/// Vakit üst bilgisi: yöntem etiketi + Güneş; ya da konum daveti / sakin
/// hata durumu. Ham koordinat ASLA gösterilmez (yalnız durum metni).
final class _PrayerTimesSection extends ConsumerWidget {
  const _PrayerTimesSection({required this.timesAsync});

  final AsyncValue<PrayerTimesState> timesAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(prayerTimesControllerProvider.notifier);

    final state = timesAsync.value;
    if (timesAsync.isLoading && state == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.s3),
        child: AppLoading(),
      );
    }

    return switch (state) {
      PrayerTimesReady(:final times, :final approximateLocation) => AppCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    l10n.prayerTimesMethodLabel,
                    token: AppTextStyleToken.caption,
                    secondary: true,
                  ),
                  const SizedBox(height: AppSpacing.s1),
                  Row(
                    children: [
                      AppText(l10n.prayerTimesSunrise),
                      const SizedBox(width: AppSpacing.s2),
                      AppText(
                        _formatLocal(times.sunrise),
                        token: AppTextStyleToken.stat,
                      ),
                    ],
                  ),
                  if (approximateLocation) ...[
                    const SizedBox(height: AppSpacing.s1),
                    AppText(
                      l10n.prayerTimesApproximate,
                      token: AppTextStyleToken.caption,
                      secondary: true,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      PrayerTimesNeedsPermission(:final permanentlyDenied) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              permanentlyDenied
                  ? l10n.prayerTimesLocationDeniedForever
                  : l10n.prayerTimesLocationInvite,
              token: AppTextStyleToken.bodySmall,
              secondary: true,
            ),
            const SizedBox(height: AppSpacing.s3),
            AppButton(
              label: permanentlyDenied
                  ? l10n.prayerTimesOpenSettings
                  : l10n.prayerTimesUseLocation,
              variant: AppButtonVariant.secondary,
              onPressed: permanentlyDenied
                  ? controller.openSettings
                  : controller.useLocation,
            ),
          ],
        ),
      ),
      PrayerTimesUnavailable() => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              l10n.prayerTimesUnavailable,
              token: AppTextStyleToken.bodySmall,
              secondary: true,
            ),
            const SizedBox(height: AppSpacing.s3),
            AppButton(
              label: l10n.commonRetry,
              variant: AppButtonVariant.secondary,
              onPressed: controller.useLocation,
            ),
          ],
        ),
      ),
      null => const SizedBox.shrink(),
    };
  }
}
