import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/shared/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';

/// Abonelik yönetimi placeholder'ı (`/settings/subscription`, push route).
///
/// Gerçek içerik (durum, restore purchases, store yönetim köprüsü)
/// RevenueCat entegrasyon görevinde gelir (05_IA §15; 08 §10).
class SubscriptionSettingsPlaceholderScreen extends StatelessWidget {
  const SubscriptionSettingsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.subscriptionSettingsTitle,
      body: AppEmptyState(
        message: l10n.placeholderComingSoon,
        icon: Icons.card_membership_outlined,
      ),
    );
  }
}
