import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/shared/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';

/// Asistan placeholder'ı — gerçek sohbet (AI proxy üzerinden) sonraki
/// görevlerde. AI provider SDK'sı client'a ASLA eklenmez; çağrılar Cloud
/// Functions proxy'sinden geçer (07_FIREBASE_ARCHITECTURE §17).
class AssistantPlaceholderScreen extends StatelessWidget {
  const AssistantPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.assistantTitle,
      body: AppEmptyState(
        message: l10n.placeholderComingSoon,
        icon: Icons.spa_outlined,
      ),
    );
  }
}
