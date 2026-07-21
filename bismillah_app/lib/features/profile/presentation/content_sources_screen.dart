import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/features/profile/application/profile_providers.dart';
import 'package:bismillah_app/features/profile/domain/app_source_reference.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// İçerik kaynakları ve doğrulama politikası (TASK 058 §5).
///
/// Uygulamanın dayandığı resmî/altyapı kaynaklarını künyeleriyle listeler;
/// her bağlantı sistem tarayıcısında açılır, açma başarısızsa adres panoya
/// kopyalanır. Doğrulanmamış lisans/izin iddiası YOKTUR — politika bloğu
/// içeriğin nasıl üretildiğini dürüstçe söyler.
class ContentSourcesScreen extends ConsumerWidget {
  const ContentSourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.sourcesTitle,
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.s4),
          AppText(
            l10n.sourcesIntro,
            token: AppTextStyleToken.bodySmall,
            secondary: true,
          ),
          const SizedBox(height: AppSpacing.s4),
          for (final source in kAppSourceReferences) ...[
            _SourceCard(source: source),
            const SizedBox(height: AppSpacing.s3),
          ],
          const SizedBox(height: AppSpacing.s3),
          const _ContentPolicyBlock(),
          const SizedBox(height: AppSpacing.s6),
        ],
      ),
    );
  }
}

class _SourceCard extends ConsumerWidget {
  const _SourceCard({required this.source});

  final AppSourceReference source;

  String _purposeText(AppLocalizations l10n) => switch (source.purpose) {
    AppSourcePurpose.tanzil => l10n.sourcePurposeTanzil,
    AppSourcePurpose.quranenc => l10n.sourcePurposeQuranenc,
    AppSourcePurpose.mp3quran => l10n.sourcePurposeMp3quran,
    AppSourcePurpose.ilmihal => l10n.sourcePurposeIlmihal,
    AppSourcePurpose.portal => l10n.sourcePurposePortal,
    AppSourcePurpose.hadis => l10n.sourcePurposeHadis,
    AppSourcePurpose.kurul => l10n.sourcePurposeKurul,
  };

  String _languageLabel(AppLocalizations l10n) =>
      source.originalLanguage == 'ar'
      ? l10n.sourcesLangArabic
      : l10n.sourcesLangTurkish;

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final opened = await ref
        .read(appSourceLinkServiceProvider)
        .openSource(source.canonicalUrl);
    if (opened) {
      return;
    }
    // Copy fallback: tarayıcı açılamadı → adres panoya kopyalanır.
    await Clipboard.setData(ClipboardData(text: source.canonicalUrl));
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l10n.sourcesOpenFailed)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kaynak adı özel isimdir: her zaman LTR yazılır (Arapça arayüzde
          // de latin künye ters dönmez).
          Directionality(
            textDirection: TextDirection.ltr,
            child: AppText(source.name, token: AppTextStyleToken.h3),
          ),
          const SizedBox(height: AppSpacing.s1),
          AppText(_purposeText(l10n), token: AppTextStyleToken.bodySmall),
          const SizedBox(height: AppSpacing.s2),
          AppText(
            '${l10n.sourcesOriginalLanguageLabel}: ${_languageLabel(l10n)}',
            token: AppTextStyleToken.caption,
            secondary: true,
          ),
          const SizedBox(height: AppSpacing.s4),
          AppButton(
            label: l10n.learnOpenOfficialPage,
            variant: AppButtonVariant.secondary,
            onPressed: () => _open(context, ref),
          ),
        ],
      ),
    );
  }
}

/// İçerik politikası — doğrulama ve çeviri yaklaşımını dürüstçe anlatır.
class _ContentPolicyBlock extends StatelessWidget {
  const _ContentPolicyBlock();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = IslamicVisualTokens.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.sacredSurfaceMuted,
        borderRadius: AppRadius.lgAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(l10n.sourcesPolicyTitle, token: AppTextStyleToken.h3),
            const SizedBox(height: AppSpacing.s3),
            for (final line in [
              l10n.sourcesPolicyLocator,
              l10n.sourcesPolicyTurkishSummary,
              l10n.sourcesPolicyTranslation,
              l10n.sourcesPolicyNoEndorsement,
              l10n.sourcesPolicyPending,
              l10n.sourcesPolicyFatwa,
            ]) ...[
              _PolicyLine(text: line),
              const SizedBox(height: AppSpacing.s2),
            ],
          ],
        ),
      ),
    );
  }
}

class _PolicyLine extends StatelessWidget {
  const _PolicyLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.s1),
          child: Icon(
            Icons.check_circle_outline,
            size: AppSizes.iconSm,
            color: tokens.spiritualGreenStrong,
          ),
        ),
        const SizedBox(width: AppSpacing.s2),
        Expanded(
          child: AppText(
            text,
            token: AppTextStyleToken.bodySmall,
            secondary: true,
          ),
        ),
      ],
    );
  }
}
