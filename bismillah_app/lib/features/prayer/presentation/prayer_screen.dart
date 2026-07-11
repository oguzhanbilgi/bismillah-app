import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/features/prayer/application/prayer_log_controller.dart';
import 'package:bismillah_app/features/prayer/application/prayer_log_state.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:bismillah_app/features/prayer/presentation/widgets/prayer_entry_tile.dart';
import 'package:bismillah_app/shared/widgets/app_badge.dart';
import 'package:bismillah_app/shared/widgets/app_error_state.dart';
import 'package:bismillah_app/shared/widgets/app_loading.dart';
import 'package:bismillah_app/shared/widgets/app_section_header.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Namaz sekmesi — ilk gerçek dikey dilim (TASK 016).
///
/// Yalnız application provider'ını okur; Drift/sync kuyruğu görmez.
/// Görsel dil sakindir: boş gün bir eksiklik olarak sunulmaz, hata
/// durumları yumuşak metinlerle düşer (CLAUDE.md ton kuralları).
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final controller = ref.read(prayerLogControllerProvider.notifier);

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
        const SizedBox(height: AppSpacing.s5),
        for (final name in PrayerName.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s3),
            child: PrayerEntryTile(
              label: _label(l10n, name),
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
