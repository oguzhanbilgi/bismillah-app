import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/shared/widgets/app_badge.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Onboarding karşılama ekranı (TASK 026 — 04_ONBOARDING §2 ton kuralları).
///
/// Bu ekranda ASLA olmayanlar: login, bildirim/konum izni, paywall,
/// abonelik mesajı, korku/suçluluk dili. Startup yönlendirmesi HENÜZ
/// buraya bağlı değildir (TASK 028); route manuel açılır.
class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final ext = AppThemeExtension.of(context);

    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sade dekoratif form — yeni asset gerektirmez; Besmele
                // logosu DEĞİLDİR (02_BRAND §7 kutsal hat kuralları).
                Container(
                  width: AppSizes.progressRingLarge,
                  height: AppSizes.progressRingLarge,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ext.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mosque_outlined,
                    size: AppSizes.iconLg,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s7),
                AppBadge(label: l10n.onboardingWelcomeEyebrow, emphasized: true),
                const SizedBox(height: AppSpacing.s4),
                AppText(l10n.onboardingWelcomeTitle, token: AppTextStyleToken.h1),
                const SizedBox(height: AppSpacing.s4),
                AppText(
                  l10n.onboardingWelcomeSupport,
                  token: AppTextStyleToken.body,
                  secondary: true,
                ),
              ],
            ),
          ),
          AppButton(
            label: l10n.onboardingWelcomeCta,
            onPressed: () => context.push(AppRoutes.onboardingGoals),
          ),
          const SizedBox(height: AppSpacing.s3),
          Center(
            child: AppText(
              l10n.onboardingWelcomeNote,
              token: AppTextStyleToken.caption,
              secondary: true,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.s7),
        ],
      ),
    );
  }
}
