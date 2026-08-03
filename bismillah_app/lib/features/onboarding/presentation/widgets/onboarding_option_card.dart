import 'package:bismillah_app/app/theme/app_motion.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_motion_switcher.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Onboarding seçenek kartı (TASK 026/027 ortak) — çoklu ve tekli seçim
/// ekranlarında aynı görsel dil. Seçili durumda zemin `primarySoft`a
/// yumuşar (AppCard.completed) ve zümrüt onay ikonu görünür;
/// kırmızı/uyarı/yargı durumu YOKTUR.
class OnboardingOptionCard extends StatelessWidget {
  const OnboardingOptionCard({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.description,
  });

  final String label;

  /// Opsiyonel kısa açıklama (ör. tempo seçeneklerinin alt satırı).
  final String? description;

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ext = AppThemeExtension.of(context);

    return Semantics(
      selected: selected,
      button: true,
      child: AppCard(
        onTap: onTap,
        completed: selected,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(label),
                  if (description != null) ...[
                    const SizedBox(height: AppSpacing.s1),
                    AppText(
                      description!,
                      token: AppTextStyleToken.bodySmall,
                      secondary: true,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s3),
            // TASK 094A: seçim işareti sakin bir geçişle değişir; zemin
            // yumuşaması AppCard'da aynı seçim süresiyle olur, böylece
            // ikon ve yüzey tek bir hareket gibi okunur.
            //
            // Metinler TEK TEK animasyonlanmaz — sayfa açılışında etiket
            // ve açıklama hareketsizdir; hareket yalnız seçimi anlatır.
            AppMotionSwitcher(
              duration: AppMotion.selection,
              curve: AppMotion.selectionCurve,
              child: Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                key: ValueKey<bool>(selected),
                size: AppSizes.iconMd,
                color: selected ? scheme.primary : ext.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
