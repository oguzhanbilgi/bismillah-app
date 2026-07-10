import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/shared/premium/bismillah_plus_badge.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bismillah+ paywall placeholder'ı (full-screen modal route).
///
/// Gerçek paywall (RevenueCat offering'leri, fiyat kartları, TrialInfoRow)
/// sonraki görevde. Kurallar şimdiden geçerli: kilit ikonu yok, "unlock"
/// dili yok, kapatma daima görünür, CTA altın DEĞİL
/// (03_DESIGN_SYSTEM §12.1; 08_BUSINESS_MODEL §9/§18).
class PremiumPlaceholderScreen extends StatelessWidget {
  const PremiumPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.premiumTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.s6),
          BismillahPlusBadge(label: l10n.premiumBadgeLabel),
          const SizedBox(height: AppSpacing.s4),
          AppText(l10n.premiumInviteLine, token: AppTextStyleToken.h2),
          const SizedBox(height: AppSpacing.s4),
          AppText(
            l10n.placeholderComingSoon,
            token: AppTextStyleToken.body,
            secondary: true,
          ),
          const Spacer(),
          Center(
            child: AppButton(
              label: l10n.commonClose,
              variant: AppButtonVariant.text,
              onPressed: () => context.pop(),
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
        ],
      ),
    );
  }
}
