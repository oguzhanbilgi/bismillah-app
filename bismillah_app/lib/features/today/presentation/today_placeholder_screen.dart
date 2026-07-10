import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/shared/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';

/// Today sekmesi placeholder'ı — gerçek pano TASK 013+ kapsamında.
class TodayPlaceholderScreen extends StatelessWidget {
  const TodayPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.tabToday,
      body: AppEmptyState(message: l10n.placeholderComingSoon),
    );
  }
}
