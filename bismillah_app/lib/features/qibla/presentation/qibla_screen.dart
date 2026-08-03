import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/features/qibla/application/qibla_controller.dart';
import 'package:bismillah_app/features/qibla/application/qibla_state.dart';
import 'package:bismillah_app/features/qibla/presentation/widgets/qibla_dial.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_loading.dart';
import 'package:bismillah_app/shared/widgets/app_motion_switcher.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kıble ekranı (TASK 095).
///
/// Ton sakin ve dürüsttür: telefon sensörünün verdiği yön **yaklaşıktır**,
/// ölçüm garantisi ya da dinî hüküm olarak sunulmaz. Pusula yoksa ekran
/// bozulmaz — kuzeyden ölçülen sabit kıble açısı gösterilmeye devam eder.
class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(qiblaControllerProvider);
    final state = async.value;

    if (async.isLoading && state == null) {
      return AppScaffold(
        title: l10n.qiblaTitle,
        body: AppLoading(label: l10n.commonLoading),
      );
    }

    return AppScaffold(
      title: l10n.qiblaTitle,
      body: switch (state) {
        QiblaReady() => _QiblaReadyView(state: state),
        QiblaLocationPermissionNeeded(:final permanentlyDenied) =>
          _QiblaMessageView(
            message: permanentlyDenied
                ? l10n.qiblaLocationDeniedForever
                : l10n.qiblaLocationInvite,
            actionLabel: permanentlyDenied
                ? l10n.prayerTimesOpenSettings
                : l10n.qiblaUseLocation,
            onAction: permanentlyDenied
                ? ref.read(qiblaControllerProvider.notifier).openSettings
                : ref.read(qiblaControllerProvider.notifier).useLocation,
          ),
        QiblaLocationServiceDisabledState() => _QiblaMessageView(
          message: l10n.qiblaLocationServiceDisabled,
          actionLabel: l10n.commonRetry,
          onAction: ref.read(qiblaControllerProvider.notifier).retry,
        ),
        QiblaLocationUnavailableState() => _QiblaMessageView(
          message: l10n.qiblaLocationUnavailable,
          actionLabel: l10n.commonRetry,
          onAction: ref.read(qiblaControllerProvider.notifier).retry,
        ),
        QiblaBearingFailed() => _QiblaMessageView(
          message: l10n.qiblaCalculationError,
          actionLabel: l10n.commonRetry,
          onAction: ref.read(qiblaControllerProvider.notifier).retry,
        ),
        null => AppLoading(label: l10n.commonLoading),
      },
    );
  }
}

/// Konum/hesap engellerinin ortak sakin yüzeyi: ne olduğu + tek eylem.
/// Ham koordinat, hata metni veya teknik terim GÖSTERİLMEZ.
final class _QiblaMessageView extends StatelessWidget {
  const _QiblaMessageView({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: AppSpacing.s5),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                message,
                token: AppTextStyleToken.bodySmall,
                secondary: true,
              ),
              const SizedBox(height: AppSpacing.s4),
              AppButton(
                label: actionLabel,
                variant: AppButtonVariant.secondary,
                onPressed: onAction,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s5),
        const _QiblaGuidanceCard(),
        const SizedBox(height: AppSpacing.s7),
      ],
    );
  }
}

final class _QiblaReadyView extends StatelessWidget {
  const _QiblaReadyView({required this.state});

  final QiblaReady state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final compass = state.compass;
    final active = compass is QiblaCompassActiveStatus ? compass : null;
    final degrees = state.bearingDegrees.round() % 360;

    return ListView(
      children: [
        const SizedBox(height: AppSpacing.s5),
        Semantics(
          container: true,
          label: active == null
              ? l10n.qiblaSemanticsBearing(degrees)
              : '${l10n.qiblaSemanticsBearing(degrees)} '
                    '${active.aligned ? l10n.qiblaAligned : l10n.qiblaTurnHint}',
          child: Center(
            child: QiblaDial(
              qiblaBearingDegrees: state.bearingDegrees,
              headingDegrees: active?.headingDegrees,
              aligned: active?.aligned ?? false,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s5),
        Center(
          child: Column(
            children: [
              AppText(
                l10n.qiblaBearingLabel,
                token: AppTextStyleToken.caption,
                secondary: true,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s1),
              // Derece okuması SABİTTİR — kadranla birlikte dönmez.
              AppText(
                l10n.qiblaDegrees(degrees),
                token: AppTextStyleToken.stat,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        // Durum satırı: aynı yerde duran, anlamı değişen küçük bir öğe —
        // TASK 094A hareket sistemiyle yalnız sakin bir çapraz geçiş.
        AppMotionSwitcher(
          child: _QiblaStatusLine(
            key: ValueKey<String>(_statusKeyOf(compass)),
            compass: compass,
          ),
        ),
        if (state.approximateLocation) ...[
          const SizedBox(height: AppSpacing.s3),
          AppText(
            l10n.qiblaApproximateLocationNote,
            token: AppTextStyleToken.caption,
            secondary: true,
          ),
        ],
        const SizedBox(height: AppSpacing.s5),
        const _QiblaGuidanceCard(),
        const SizedBox(height: AppSpacing.s7),
      ],
    );
  }

  /// Geçişin tetiklenmesi için durum kimliği; derece değişimi geçiş
  /// BAŞLATMAZ (yoksa ibre her karede yanıp sönerdi).
  static String _statusKeyOf(QiblaCompassStatus compass) => switch (compass) {
    QiblaCompassActiveStatus(:final aligned, :final isLowConfidence) =>
      'active-$aligned-$isLowConfidence',
    QiblaCompassWaitingStatus() => 'waiting',
    QiblaCompassInterruptedStatus() => 'interrupted',
    QiblaCompassUnsupportedStatus() => 'unsupported',
  };
}

/// Pusula durumunun tek satırlık dürüst özeti.
final class _QiblaStatusLine extends StatelessWidget {
  const _QiblaStatusLine({super.key, required this.compass});

  final QiblaCompassStatus compass;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final (String message, String? note, IconData icon) = switch (compass) {
      QiblaCompassActiveStatus(:final aligned, :final isLowConfidence) => (
        aligned ? l10n.qiblaAligned : l10n.qiblaTurnHint,
        isLowConfidence ? l10n.qiblaLowConfidence : null,
        aligned ? Icons.check_circle_outline : Icons.rotate_right,
      ),
      QiblaCompassWaitingStatus() => (
        l10n.qiblaCompassWaiting,
        null,
        Icons.explore_outlined,
      ),
      QiblaCompassInterruptedStatus() => (
        l10n.qiblaCompassInterrupted,
        l10n.qiblaStaticBearingNote,
        Icons.explore_off_outlined,
      ),
      QiblaCompassUnsupportedStatus() => (
        l10n.qiblaCompassUnsupported,
        l10n.qiblaStaticBearingNote,
        Icons.explore_off_outlined,
      ),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppSizes.iconSm, color: scheme.primary),
        const SizedBox(width: AppSpacing.s2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(message, token: AppTextStyleToken.bodySmall),
              if (note != null) ...[
                const SizedBox(height: AppSpacing.s1),
                AppText(
                  note,
                  token: AppTextStyleToken.caption,
                  secondary: true,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Kısa kullanım ipuçları + dürüstlük notu. Her durumda görünür.
final class _QiblaGuidanceCard extends StatelessWidget {
  const _QiblaGuidanceCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppCard(
      variant: AppCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(l10n.qiblaGuidanceTitle, token: AppTextStyleToken.h3),
          const SizedBox(height: AppSpacing.s3),
          for (final line in [
            l10n.qiblaGuidanceFlat,
            l10n.qiblaGuidanceMetal,
            l10n.qiblaGuidanceCalibrate,
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.circle,
                    size: AppSpacing.s1,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.s2),
                  Expanded(
                    child: AppText(
                      line,
                      token: AppTextStyleToken.bodySmall,
                      secondary: true,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.s2),
          AppText(
            l10n.qiblaHonestyNote,
            token: AppTextStyleToken.caption,
            secondary: true,
          ),
        ],
      ),
    );
  }
}
