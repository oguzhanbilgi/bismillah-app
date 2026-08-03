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
///
/// ## Yeniden çizim sınırı
///
/// Sensör saniyede birkaç kez okuma üretir. Ekranın tamamı bu hızda
/// yeniden kurulmaz: her bölüm durumun YALNIZ kendi ilgilendiği kısmını
/// `select` ile dinler. Yön değeri sadece [_QiblaDialSection]'a girer;
/// başlık, açı okuması, ipuçları ve durum satırı okuma değiştikçe
/// yeniden inşa EDİLMEZ.
class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final model = ref.watch(qiblaControllerProvider.select(_viewModelOf));

    return AppScaffold(
      title: l10n.qiblaTitle,
      body: switch (model.kind) {
        _QiblaViewKind.loading => AppLoading(label: l10n.commonLoading),
        _QiblaViewKind.ready => _QiblaReadyView(
          bearingDegrees: model.bearingDegrees,
          approximateLocation: model.approximateLocation,
        ),
        _QiblaViewKind.permissionNeeded => _QiblaMessageView(
          message: l10n.qiblaLocationInvite,
          actionLabel: l10n.qiblaUseLocation,
          onAction: ref.read(qiblaControllerProvider.notifier).useLocation,
        ),
        _QiblaViewKind.permissionBlocked => _QiblaMessageView(
          message: l10n.qiblaLocationDeniedForever,
          actionLabel: l10n.prayerTimesOpenSettings,
          onAction: ref.read(qiblaControllerProvider.notifier).openSettings,
        ),
        _QiblaViewKind.serviceDisabled => _QiblaMessageView(
          message: l10n.qiblaLocationServiceDisabled,
          actionLabel: l10n.commonRetry,
          onAction: ref.read(qiblaControllerProvider.notifier).retry,
        ),
        _QiblaViewKind.locationUnavailable => _QiblaMessageView(
          message: l10n.qiblaLocationUnavailable,
          actionLabel: l10n.commonRetry,
          onAction: ref.read(qiblaControllerProvider.notifier).retry,
        ),
        _QiblaViewKind.bearingFailed => _QiblaMessageView(
          message: l10n.qiblaCalculationError,
          actionLabel: l10n.commonRetry,
          onAction: ref.read(qiblaControllerProvider.notifier).retry,
        ),
      },
    );
  }
}

/// Ekranın hangi yüzeyi göstereceği.
enum _QiblaViewKind {
  loading,
  ready,
  permissionNeeded,
  permissionBlocked,
  serviceDisabled,
  locationUnavailable,
  bearingFailed,
}

/// Yön okumasını **içermeyen** kabuk modeli. Kayıt tipi olduğu için değer
/// eşitliği vardır: pusula okuması değişse de bu model aynı kalır ve
/// `select` yeniden inşa tetiklemez.
typedef _QiblaViewModel = ({
  _QiblaViewKind kind,
  double bearingDegrees,
  bool approximateLocation,
});

_QiblaViewModel _viewModelOf(AsyncValue<QiblaState> async) {
  final state = async.value;
  if (async.isLoading && state == null) {
    return (
      kind: _QiblaViewKind.loading,
      bearingDegrees: 0,
      approximateLocation: false,
    );
  }
  return switch (state) {
    QiblaReady(:final bearingDegrees, :final approximateLocation) => (
      kind: _QiblaViewKind.ready,
      bearingDegrees: bearingDegrees,
      approximateLocation: approximateLocation,
    ),
    QiblaLocationPermissionNeeded(:final permanentlyDenied) => (
      kind: permanentlyDenied
          ? _QiblaViewKind.permissionBlocked
          : _QiblaViewKind.permissionNeeded,
      bearingDegrees: 0,
      approximateLocation: false,
    ),
    QiblaLocationServiceDisabledState() => (
      kind: _QiblaViewKind.serviceDisabled,
      bearingDegrees: 0,
      approximateLocation: false,
    ),
    QiblaLocationUnavailableState() => (
      kind: _QiblaViewKind.locationUnavailable,
      bearingDegrees: 0,
      approximateLocation: false,
    ),
    QiblaBearingFailed() => (
      kind: _QiblaViewKind.bearingFailed,
      bearingDegrees: 0,
      approximateLocation: false,
    ),
    null => (
      kind: _QiblaViewKind.loading,
      bearingDegrees: 0,
      approximateLocation: false,
    ),
  };
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
  const _QiblaReadyView({
    required this.bearingDegrees,
    required this.approximateLocation,
  });

  final double bearingDegrees;
  final bool approximateLocation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final degrees = bearingDegrees.round() % 360;

    return ListView(
      children: [
        const SizedBox(height: AppSpacing.s5),
        Center(child: _QiblaDialSection(bearingDegrees: bearingDegrees)),
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
              // Derece okuması SABİTTİR — kadranla birlikte dönmez ve
              // pusula örneklerinde yeniden inşa edilmez.
              AppText(
                l10n.qiblaDegrees(degrees),
                token: AppTextStyleToken.stat,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        const _QiblaStatusSection(),
        if (approximateLocation) ...[
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
}

/// Yön okumasını dinleyen **tek** bölüm: sensör örneği geldiğinde yalnız
/// burası yeniden inşa edilir ve yalnız kadran katmanları yeniden boyanır.
final class _QiblaDialSection extends ConsumerWidget {
  const _QiblaDialSection({required this.bearingDegrees});

  final double bearingDegrees;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reading = ref.watch(
      qiblaControllerProvider.select(_readingOf),
    );
    final degrees = bearingDegrees.round() % 360;

    return Semantics(
      container: true,
      label: reading.heading == null
          ? l10n.qiblaSemanticsBearing(degrees)
          : '${l10n.qiblaSemanticsBearing(degrees)} '
                '${reading.aligned ? l10n.qiblaAligned : l10n.qiblaTurnHint}',
      child: QiblaDial(
        qiblaBearingDegrees: bearingDegrees,
        headingDegrees: reading.heading,
        aligned: reading.aligned,
      ),
    );
  }
}

typedef _QiblaReading = ({double? heading, bool aligned});

_QiblaReading _readingOf(AsyncValue<QiblaState> async) {
  final state = async.value;
  if (state is! QiblaReady) {
    return (heading: null, aligned: false);
  }
  final compass = state.compass;
  return compass is QiblaCompassActiveStatus
      ? (heading: compass.headingDegrees, aligned: compass.aligned)
      : (heading: null, aligned: false);
}

/// Pusula durumunun tek satırlık dürüst özeti.
///
/// Yalnız **durum sınıfını** dinler; derece değişimi burayı yeniden inşa
/// etmez, yoksa satır her karede çapraz geçişe girerdi.
final class _QiblaStatusSection extends ConsumerWidget {
  const _QiblaStatusSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final status = ref.watch(qiblaControllerProvider.select(_statusOf));

    final (String message, String? note, IconData icon) = switch (status.kind) {
      _QiblaStatusKind.aligned => (
        l10n.qiblaAligned,
        status.lowConfidence ? l10n.qiblaLowConfidence : null,
        Icons.check_circle_outline,
      ),
      _QiblaStatusKind.searching => (
        l10n.qiblaTurnHint,
        status.lowConfidence ? l10n.qiblaLowConfidence : null,
        Icons.rotate_right,
      ),
      _QiblaStatusKind.waiting => (
        l10n.qiblaCompassWaiting,
        null,
        Icons.explore_outlined,
      ),
      _QiblaStatusKind.interrupted => (
        l10n.qiblaCompassInterrupted,
        l10n.qiblaStaticBearingNote,
        Icons.explore_off_outlined,
      ),
      _QiblaStatusKind.unsupported => (
        l10n.qiblaCompassUnsupported,
        l10n.qiblaStaticBearingNote,
        Icons.explore_off_outlined,
      ),
    };

    return AppMotionSwitcher(
      child: Row(
        key: ValueKey<String>('${status.kind}-${status.lowConfidence}'),
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
      ),
    );
  }
}

enum _QiblaStatusKind { aligned, searching, waiting, interrupted, unsupported }

typedef _QiblaStatus = ({_QiblaStatusKind kind, bool lowConfidence});

_QiblaStatus _statusOf(AsyncValue<QiblaState> async) {
  final state = async.value;
  if (state is! QiblaReady) {
    return (kind: _QiblaStatusKind.waiting, lowConfidence: false);
  }
  return switch (state.compass) {
    QiblaCompassActiveStatus(:final aligned, :final isLowConfidence) => (
      kind: aligned ? _QiblaStatusKind.aligned : _QiblaStatusKind.searching,
      lowConfidence: isLowConfidence,
    ),
    QiblaCompassWaitingStatus() => (
      kind: _QiblaStatusKind.waiting,
      lowConfidence: false,
    ),
    QiblaCompassInterruptedStatus() => (
      kind: _QiblaStatusKind.interrupted,
      lowConfidence: false,
    ),
    QiblaCompassUnsupportedStatus() => (
      kind: _QiblaStatusKind.unsupported,
      lowConfidence: false,
    ),
  };
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
