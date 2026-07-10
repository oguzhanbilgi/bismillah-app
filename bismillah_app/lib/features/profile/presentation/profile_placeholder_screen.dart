import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Profile sekmesi placeholder'ı — istatistik/rozet/ayarlar sonraki
/// görevlerde. Abonelik yönetimine geçiş köprüsü şimdiden mevcut.
class ProfilePlaceholderScreen extends StatelessWidget {
  const ProfilePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.tabProfile,
      body: Column(
        children: [
          Expanded(
            child: AppEmptyState(
              message: l10n.placeholderComingSoon,
              icon: Icons.person_outline,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s6),
            child: AppButton(
              label: l10n.subscriptionSettingsTitle,
              variant: AppButtonVariant.text,
              onPressed: () => context.push(AppRoutes.subscriptionSettings),
            ),
          ),
        ],
      ),
    );
  }
}
