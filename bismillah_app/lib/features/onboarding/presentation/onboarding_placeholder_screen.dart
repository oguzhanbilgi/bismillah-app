import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/shared/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';

/// Onboarding placeholder'ı — gerçek 16 soruluk akış TASK 013+ kapsamında
/// (04_ONBOARDING_FLOW). Bu akışta paywall, fiyat veya satış mesajı
/// HİÇBİR ZAMAN yer almaz (08_BUSINESS_MODEL §9).
class OnboardingPlaceholderScreen extends StatelessWidget {
  const OnboardingPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.onboardingTitle,
      body: AppEmptyState(message: l10n.placeholderComingSoon),
    );
  }
}
