import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/shared/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';

/// Learn sekmesi placeholder'ı — dersler/günlük hadis sonraki görevlerde.
class LearnPlaceholderScreen extends StatelessWidget {
  const LearnPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.tabLearn,
      body: AppEmptyState(
        message: l10n.placeholderComingSoon,
        icon: Icons.school_outlined,
      ),
    );
  }
}
