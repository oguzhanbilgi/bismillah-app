import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/features/profile/domain/support_contact.dart';
import 'package:bismillah_app/features/profile/presentation/support_contact_action.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Gizlilik politikasının TAMAMI (ALPHA-R3A).
///
/// [PrivacyDataScreen] özet + veri sıfırlama ekranıdır; bu ekran onun
/// AYNI politikasının tam metnidir — ikinci bir gizlilik sistemi DEĞİLDİR ve
/// ona ait bir satır burada tekrar tanımlanmaz.
///
/// Metin `docs/legal/PRIVACY_POLICY.md` ile aynı içeriği taşır; Türkçe
/// kanonik, İngilizce ve Arapça sadık çeviridir.
class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.privacyPolicyTitle,
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.s4),
          AppText(
            l10n.privacyPolicyUpdated,
            token: AppTextStyleToken.caption,
            secondary: true,
          ),
          const SizedBox(height: AppSpacing.s4),
          _PolicySection(
            title: l10n.privacyPolicySummaryTitle,
            body: l10n.privacyPolicySummaryBody,
          ),
          _PolicySection(
            title: l10n.privacyPolicyStoredTitle,
            body: l10n.privacyPolicyStoredBody,
          ),
          _PolicySection(
            title: l10n.privacyPolicyAssistantTitle,
            body: l10n.privacyPolicyAssistantBody,
          ),
          _PolicySection(
            title: l10n.privacyPolicyCloudTitle,
            body: l10n.privacyPolicyCloudBody,
          ),
          _PolicySection(
            title: l10n.privacyPolicyPermissionsTitle,
            body: l10n.privacyPolicyPermissionsBody,
          ),
          _PolicySection(
            title: l10n.privacyPolicyNetworkTitle,
            body: l10n.privacyPolicyNetworkBody,
          ),
          _PolicySection(
            title: l10n.privacyPolicyNoTrackingTitle,
            body: l10n.privacyPolicyNoTrackingBody,
          ),
          _PolicySection(
            title: l10n.privacyPolicyChildrenTitle,
            body: l10n.privacyPolicyChildrenBody,
          ),
          _PolicySection(
            title: l10n.privacyPolicyControlTitle,
            body: l10n.privacyPolicyControlBody,
          ),
          AppCard(
            variant: AppCardVariant.outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  l10n.privacyPolicyContactTitle,
                  token: AppTextStyleToken.h3,
                ),
                const SizedBox(height: AppSpacing.s2),
                AppText(
                  l10n.privacyPolicyContactBody,
                  token: AppTextStyleToken.bodySmall,
                  secondary: true,
                ),
                const SizedBox(height: AppSpacing.s2),
                // Adres LTR kalır: Arapça sayfada da doğru okunmalıdır.
                const Directionality(
                  textDirection: TextDirection.ltr,
                  child: AppText(
                    SupportContact.email,
                    token: AppTextStyleToken.body,
                  ),
                ),
                const SizedBox(height: AppSpacing.s3),
                AppButton(
                  label: l10n.supportContactAction,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => openSupportContact(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(title, token: AppTextStyleToken.h3),
          const SizedBox(height: AppSpacing.s2),
          AppText(body, token: AppTextStyleToken.bodySmall, secondary: true),
        ],
      ),
    );
  }
}
