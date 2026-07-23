import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/features/prayer/application/prayer_log_controller.dart';
import 'package:bismillah_app/features/prayer/application/prayer_log_state.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:bismillah_app/features/prayer/presentation/widgets/prayer_entry_tile.dart';
import 'package:bismillah_app/features/prayer_reminders/application/prayer_reminder_controller.dart';
import 'package:bismillah_app/features/prayer_reminders/application/prayer_reminder_scheduler.dart';
import 'package:bismillah_app/features/prayer_reminders/application/prayer_reminder_state.dart';
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
import 'package:go_router/go_router.dart';

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

/// Vakit adının yerelleştirilmiş etiketi (tile + bildirim metni ortak).
String _prayerLabel(AppLocalizations l10n, PrayerName name) => switch (name) {
  PrayerName.fajr => l10n.prayerNameFajr,
  PrayerName.dhuhr => l10n.prayerNameDhuhr,
  PrayerName.asr => l10n.prayerNameAsr,
  PrayerName.maghrib => l10n.prayerNameMaghrib,
  PrayerName.isha => l10n.prayerNameIsha,
};

/// Bildirim metinlerini localization'dan scheduler'a taşır (BuildContext'siz
/// katmanlar için).
PrayerReminderCopy _reminderCopy(AppLocalizations l10n) => PrayerReminderCopy(
  title: l10n.reminderNotificationTitle,
  bodyFor: (name) => l10n.reminderNotificationBody(_prayerLabel(l10n, name)),
);

final class _PrayerLogView extends ConsumerWidget {
  const _PrayerLogView({required this.state});

  final PrayerLogState state;

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
              label: _prayerLabel(l10n, name),
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
        const SizedBox(height: AppSpacing.s3),
        const _PrayerReminderCard(),
        const SizedBox(height: AppSpacing.s4),
        AppButton(
          label: l10n.prayerHistoryTitle,
          variant: AppButtonVariant.secondary,
          onPressed: () => context.go(AppRoutes.prayerHistory),
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

/// Namaz hatırlatıcıları kartı — sakin aç/kapat. Namaz kaydından bağımsız;
/// izin reddedilse bile işaretleme çalışır (kart yalnız hatırlatıcıyı yönetir).
final class _PrayerReminderCard extends ConsumerWidget {
  const _PrayerReminderCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(prayerReminderControllerProvider.notifier);
    final async = ref.watch(prayerReminderControllerProvider);
    final state = async.value;

    Widget card(Widget child) => AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(l10n.reminderCardTitle, token: AppTextStyleToken.h3),
          const SizedBox(height: AppSpacing.s3),
          child,
        ],
      ),
    );

    Widget action(String label, VoidCallback onTap) => AppButton(
      label: label,
      variant: AppButtonVariant.secondary,
      onPressed: onTap,
    );

    if (async.isLoading && state == null) {
      // Sınırlı boyutlu gösterge — ListView içinde `Center` sınırsız yükseklik
      // isteyeceği için AppLoading burada KULLANILMAZ.
      return card(
        const SizedBox(
          height: AppSizes.iconMd,
          width: AppSizes.iconMd,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return switch (state) {
      ReminderEnabled(:final exact) => card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              l10n.reminderEnabledState,
              token: AppTextStyleToken.bodySmall,
              secondary: true,
            ),
            if (!exact) ...[
              const SizedBox(height: AppSpacing.s1),
              AppText(
                l10n.reminderInexactNote,
                token: AppTextStyleToken.caption,
                secondary: true,
              ),
              const SizedBox(height: AppSpacing.s3),
              // Kullanıcının AÇIK isteğiyle: kesin-alarm özel-erişim ekranına
              // götürür (açılışta/otomatik gösterilmez).
              action(
                l10n.reminderExactAction,
                () => _promptExactTiming(context, ref, l10n),
              ),
            ],
            const SizedBox(height: AppSpacing.s3),
            action(l10n.reminderDisable, controller.disable),
          ],
        ),
      ),
      ReminderPermissionBlocked(:final permanentlyDenied) => card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              l10n.reminderPermissionNeeded,
              token: AppTextStyleToken.bodySmall,
              secondary: true,
            ),
            const SizedBox(height: AppSpacing.s3),
            action(
              permanentlyDenied
                  ? l10n.prayerTimesOpenSettings
                  : l10n.reminderEnable,
              permanentlyDenied
                  ? controller.openSettings
                  : () => _onEnablePressed(context, ref, l10n),
            ),
          ],
        ),
      ),
      ReminderLocationNeeded() => card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              l10n.reminderLocationNeeded,
              token: AppTextStyleToken.bodySmall,
              secondary: true,
            ),
            const SizedBox(height: AppSpacing.s3),
            action(
              l10n.reminderEnable,
              () => _onEnablePressed(context, ref, l10n),
            ),
          ],
        ),
      ),
      _ => card(
        action(l10n.reminderEnable, () => _onEnablePressed(context, ref, l10n)),
      ),
    };
  }

  /// "Hatırlatıcıları aç" dokunuşu: etkinleştirir; sonuç açık ama INEXACT ise
  /// (kesin-alarm erişimi yok) kullanıcıya kesin-zamanlama açıklamasını gösterir.
  /// Açıklama YALNIZ bu açık kullanıcı eyleminden sonra çıkar (açılışta değil).
  Future<void> _onEnablePressed(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    await ref
        .read(prayerReminderControllerProvider.notifier)
        .enable(_reminderCopy(l10n));
    if (!context.mounted) {
      return;
    }
    final state = ref.read(prayerReminderControllerProvider).value;
    if (state is ReminderEnabled && !state.exact) {
      await _promptExactTiming(context, ref, l10n);
    }
  }

  /// Kesin-zamanlama açıklaması + "İzin ekranını aç" / "Şimdi değil". Onaylanırsa
  /// özel-erişim ekranı açılır, dönüşte yeniden kontrol edilir; sonuç dürüstçe
  /// snackbar ile bildirilir. Ayar ekranını açmak başarı SAYILMAZ.
  Future<void> _promptExactTiming(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final open = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.reminderExactTitle),
        content: Text(l10n.reminderExactBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.reminderExactNotNow),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.reminderExactOpenSettings),
          ),
        ],
      ),
    );
    if (open != true) {
      return; // "Şimdi değil" → ekran açılmaz, inexact fallback korunur.
    }
    final granted = await ref
        .read(prayerReminderControllerProvider.notifier)
        .requestExactTiming(_reminderCopy(l10n));
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            granted ? l10n.reminderExactGranted : l10n.reminderExactNotGranted,
          ),
        ),
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
