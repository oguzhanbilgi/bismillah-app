import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/shared/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';

/// Quran sekmesi placeholder'ı — takip/hedef ekranları sonraki görevlerde.
class QuranPlaceholderScreen extends StatelessWidget {
  const QuranPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.tabQuran,
      body: AppEmptyState(
        message: l10n.placeholderComingSoon,
        icon: Icons.auto_stories_outlined,
      ),
    );
  }
}
