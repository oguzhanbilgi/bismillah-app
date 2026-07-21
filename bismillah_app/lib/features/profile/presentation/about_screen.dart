import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/features/profile/application/app_info_provider.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hakkında ekranı (TASK 058 §8).
///
/// Uygulama adı, sürüm/build, alpha durumu ve Flutter atfını gösterir;
/// açık kaynak lisansları Flutter'ın standart [showLicensePage] ekranına
/// bağlanır. Yerel yol, commit hash veya özel Firebase bilgisi GÖSTERİLMEZ.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final infoAsync = ref.watch(appInfoProvider);

    final versionLine = infoAsync.when(
      data: (info) =>
          '${l10n.aboutVersionLabel} ${info.version}  ·  '
          '${l10n.aboutBuildLabel} ${info.buildNumber}',
      loading: () => l10n.commonLoading,
      error: (_, _) => l10n.aboutVersionUnavailable,
    );

    return AppScaffold(
      title: l10n.aboutTitle,
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.s5),
          AppCard(
            variant: AppCardVariant.sand,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(l10n.appTitle, token: AppTextStyleToken.h2),
                const SizedBox(height: AppSpacing.s1),
                AppText(
                  l10n.aboutTagline,
                  token: AppTextStyleToken.bodySmall,
                  secondary: true,
                ),
                const SizedBox(height: AppSpacing.s4),
                AppText(versionLine, token: AppTextStyleToken.body),
                const SizedBox(height: AppSpacing.s2),
                AppText(
                  l10n.aboutStageAlpha,
                  token: AppTextStyleToken.caption,
                  secondary: true,
                ),
                const SizedBox(height: AppSpacing.s1),
                AppText(
                  l10n.aboutBuiltWithFlutter,
                  token: AppTextStyleToken.caption,
                  secondary: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s5),
          AppButton(
            label: l10n.aboutLicensesButton,
            variant: AppButtonVariant.secondary,
            onPressed: () => showLicensePage(
              context: context,
              applicationName: l10n.appTitle,
              applicationVersion: infoAsync.asData?.value.version,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
        ],
      ),
    );
  }
}
