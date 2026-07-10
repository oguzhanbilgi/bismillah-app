import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/shared/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';

/// Prayer sekmesi placeholder'ı — vakitler/takip/zikir/dua sonraki görevlerde.
class PrayerPlaceholderScreen extends StatelessWidget {
  const PrayerPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.tabPrayer,
      body: AppEmptyState(
        message: l10n.placeholderComingSoon,
        icon: Icons.explore_outlined,
      ),
    );
  }
}
