import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Premium fayda kartı (03_DESIGN_SYSTEM §12.1).
///
/// Fayda diliyle yazılır ("ne kazanır") — eksiklik/mahrumiyet dili ve
/// "unlock"/kilit metaforu YASAKTIR (02_BRAND_GUIDELINES §26).
/// CTA bu kartta yoktur; kart yalnız faydayı anlatır.
class PremiumFeatureCard extends StatelessWidget {
  const PremiumFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;

  /// Fayda başlığı — localization'dan gelir.
  final String title;

  /// Tek satır açıklama — localization'dan gelir.
  final String description;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppSizes.iconMd, color: scheme.primary),
          const SizedBox(width: AppSpacing.s4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(title, token: AppTextStyleToken.h3),
                const SizedBox(height: AppSpacing.s1),
                AppText(
                  description,
                  token: AppTextStyleToken.bodySmall,
                  secondary: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
