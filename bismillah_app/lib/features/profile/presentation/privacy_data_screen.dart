import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/features/settings/application/local_data_reset_controller.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Gizlilik ve yerel veriler + veri sıfırlama (TASK 058 §6/§7).
///
/// Verinin nerede tutulduğunu (yerel, cihazda hesaplanan, ağ) dürüstçe
/// gösterir; mutlak "hiçbir zaman internete gitmez" ifadesi KULLANILMAZ.
/// Sıfırlama işlemleri en altta ve geri alınamaz uyarısıyla verilir.
class PrivacyDataScreen extends ConsumerWidget {
  const PrivacyDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.privacyTitle,
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.s4),
          AppText(
            l10n.privacyIntro,
            token: AppTextStyleToken.bodySmall,
            secondary: true,
          ),
          const SizedBox(height: AppSpacing.s4),
          _DataGroup(
            icon: Icons.smartphone_outlined,
            title: l10n.privacyLocalTitle,
            lines: [
              l10n.privacyLocalOnboarding,
              l10n.privacyLocalPrayerHistory,
              l10n.privacyLocalQuran,
              l10n.privacyLocalQuranPrefs,
              l10n.privacyLocalLearn,
              l10n.privacyLocalAppPrefs,
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          _DataGroup(
            icon: Icons.calculate_outlined,
            title: l10n.privacyComputedTitle,
            lines: [
              l10n.privacyComputedPrayerTimes,
              l10n.privacyComputedProgress,
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          _DataGroup(
            icon: Icons.cloud_outlined,
            title: l10n.privacyNetworkTitle,
            lines: [l10n.privacyNetworkAudio, l10n.privacyNetworkLinks],
          ),
          const SizedBox(height: AppSpacing.s4),
          AppText(
            l10n.privacyNote,
            token: AppTextStyleToken.caption,
            secondary: true,
          ),
          const SizedBox(height: AppSpacing.s6),
          // Destructive işlemler en altta (TASK 058 §9).
          const _ResetSection(),
          const SizedBox(height: AppSpacing.s6),
        ],
      ),
    );
  }
}

class _DataGroup extends StatelessWidget {
  const _DataGroup({
    required this.icon,
    required this.title,
    required this.lines,
  });

  final IconData icon;
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.sectionSurface,
        borderRadius: AppRadius.lgAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: tokens.spiritualGreenStrong),
                const SizedBox(width: AppSpacing.s2),
                Expanded(child: AppText(title, token: AppTextStyleToken.h3)),
              ],
            ),
            const SizedBox(height: AppSpacing.s3),
            for (final line in lines) ...[
              _BulletLine(text: line),
              const SizedBox(height: AppSpacing.s2),
            ],
          ],
        ),
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.s1),
          child: Icon(
            Icons.circle,
            size: AppSpacing.s2,
            color: tokens.spiritualGreen,
          ),
        ),
        const SizedBox(width: AppSpacing.s3),
        Expanded(child: AppText(text, token: AppTextStyleToken.bodySmall)),
      ],
    );
  }
}

/// Veri sıfırlama alanı — Learn-only ve tüm yerel veri (iki aşamalı onay).
class _ResetSection extends ConsumerWidget {
  const _ResetSection();

  Future<void> _resetLearning(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetLearningConfirmTitle),
        content: Text(l10n.resetLearningConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.resetLearningTitle),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(localDataResetControllerProvider).resetLearningData();
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l10n.resetLearningDone)));
  }

  Future<void> _resetAll(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final router = GoRouter.of(context);

    // Aşama 1: silinecek veri türleri açıkça gösterilir.
    final step1 = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetAllStep1Title),
        content: Text(l10n.resetAllStep1Body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.resetAllStep1Continue),
          ),
        ],
      ),
    );
    if (step1 != true || !context.mounted) {
      return;
    }

    // Aşama 2: geri alınamaz onay — tek dokunuşla silme OLMAZ.
    final step2 = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetAllStep2Title),
        content: Text(
          '${l10n.resetAllStep2Body}\n\n${l10n.resetKeepsLanguage}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: scheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.resetAllConfirm),
          ),
        ],
      ),
    );
    if (step2 != true) {
      return;
    }

    await ref.read(localDataResetControllerProvider).resetAllLocalData();
    // Kapı kapandı → uygulama güvenli biçimde onboarding'e döner.
    router.go(AppRoutes.onboardingWelcome);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(l10n.resetSectionTitle, token: AppTextStyleToken.h3),
        const SizedBox(height: AppSpacing.s3),
        _ResetRow(
          icon: Icons.school_outlined,
          title: l10n.resetLearningTitle,
          subtitle: l10n.resetLearningSubtitle,
          onTap: () => _resetLearning(context, ref),
        ),
        const SizedBox(height: AppSpacing.s3),
        _ResetRow(
          icon: Icons.delete_outline,
          title: l10n.resetAllTitle,
          subtitle: l10n.resetAllSubtitle,
          color: scheme.error,
          onTap: () => _resetAll(context, ref),
        ),
      ],
    );
  }
}

/// Sıfırlama satırı — ikon + başlık + kısa açıklama, dokunma aksiyonu
/// ekran okuyucuya buton olarak bildirilir.
class _ResetRow extends StatelessWidget {
  const _ResetRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    final foreground = color ?? tokens.spiritualGreenStrong;

    return Semantics(
      button: true,
      label: '$title, $subtitle',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgAll,
          child: ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.sectionSurface,
                borderRadius: AppRadius.lgAll,
                border: Border.all(color: tokens.surfaceBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s4),
                child: Row(
                  children: [
                    Icon(icon, color: foreground, size: AppSizes.iconMd),
                    const SizedBox(width: AppSpacing.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            title,
                            token: AppTextStyleToken.body,
                            color: color,
                          ),
                          const SizedBox(height: AppSpacing.s1),
                          AppText(
                            subtitle,
                            token: AppTextStyleToken.caption,
                            secondary: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
