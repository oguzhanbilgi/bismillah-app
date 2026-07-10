import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Yüzen asistan düğmesi (03_DESIGN_SYSTEM §13; 05_IA §9).
///
/// Asistan bir sekme DEĞİLDİR — her ekrandan erişilen eşlikçi giriştir.
/// Görünürlüğü shell, route metadata'sından yönetir; kutsal/odak
/// yüzeylerde gizlenir. Kendiliğinden asla açılmaz.
class AssistantFab extends StatelessWidget {
  const AssistantFab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FloatingActionButton(
      tooltip: l10n.assistantFabLabel,
      onPressed: () => context.push(AppRoutes.assistant),
      child: const Icon(Icons.spa_outlined),
    );
  }
}
