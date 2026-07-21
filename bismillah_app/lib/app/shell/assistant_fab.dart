import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Yüzen asistan düğmesi (03_DESIGN_SYSTEM §13; 05_IA §9).
///
/// Asistan bir sekme DEĞİLDİR — her ekrandan erişilen eşlikçi giriştir.
/// Görünürlüğü shell, route metadata'sından yönetir; kutsal/odak
/// yüzeylerde ve Assistant ekranı açıkken gizlenir. Kendiliğinden asla
/// açılmaz.
///
/// TASK 060 §4: baskın primary FAB yerine SAKİN tonal aksiyon — adaçayı
/// yüzey, İslami yeşil ikon, ince kenarlık, çok sınırlı gölge. 56dp boyut
/// minimum 48dp dokunma alanını karşılar; tooltip + semantics etiketlidir.
class AssistantFab extends StatelessWidget {
  const AssistantFab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = IslamicVisualTokens.of(context);

    return FloatingActionButton(
      tooltip: l10n.assistantFabLabel,
      onPressed: () => context.push(AppRoutes.assistant),
      backgroundColor: tokens.sageSurface,
      foregroundColor: tokens.spiritualGreenStrong,
      elevation: 1,
      focusElevation: 2,
      hoverElevation: 2,
      highlightElevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: tokens.surfaceBorder),
      ),
      child: const Icon(Icons.chat_bubble_outline_rounded),
    );
  }
}
