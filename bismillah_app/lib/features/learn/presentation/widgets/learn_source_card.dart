import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/features/learn/domain/entities/knowledge_source.dart';
import 'package:bismillah_app/shared/widgets/app_badge.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Resmî kaynak künyesi kartı (TASK 056 §10).
///
/// Kurum, eser/sayfa başlığı, kaynak türü, orijinal dil ve son doğrulama
/// tarihi GÖRÜNÜR. "Resmî sayfayı aç" aksiyonu, alan adı doğrulamasından
/// geçmeyen hiçbir adresi AÇMAZ.
class LearnSourceCard extends StatelessWidget {
  const LearnSourceCard({
    super.key,
    required this.source,
    required this.onOpen,
  });

  final KnowledgeSource source;

  /// Bağlantı açma isteği — ekran katmanı sistem tarayıcısını kullanır
  /// (WebView YOKTUR) ve hata durumunu sakin biçimde bildirir.
  final void Function(KnowledgeSource source) onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = IslamicVisualTokens.of(context);
    // Alan adı doğrulaması BURADA da yapılır: veri bozulsa bile
    // kullanıcıya resmî olmayan bir adres için aksiyon SUNULMAZ.
    final isTrusted = OfficialSourceDomains.isAllowed(source.canonicalUrl);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s3),
      child: AppCard(
        variant: AppCardVariant.outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (source.isOfficial && isTrusted)
              AppBadge(label: source.institution, emphasized: true),
            const SizedBox(height: AppSpacing.s3),
            AppText(source.title, token: AppTextStyleToken.h3),
            const SizedBox(height: AppSpacing.s2),
            if (source.publicationInfo case final String info) ...[
              AppText(
                info,
                token: AppTextStyleToken.caption,
                secondary: true,
              ),
              const SizedBox(height: AppSpacing.s1),
            ],
            // Orijinal kaynak dilinin Türkçe olduğu her zaman görünür
            // (TASK 056 §6) — çeviri uyarısının dayanağıdır.
            AppText(
              l10n.learnOriginalLanguageTr,
              token: AppTextStyleToken.caption,
              secondary: true,
            ),
            const SizedBox(height: AppSpacing.s1),
            AppText(
              '${l10n.learnLastVerified}: ${source.lastVerifiedAt}',
              token: AppTextStyleToken.caption,
              secondary: true,
            ),
            const SizedBox(height: AppSpacing.s2),
            AppText(
              source.usageNotes,
              token: AppTextStyleToken.caption,
              secondary: true,
            ),
            if (isTrusted) ...[
              const SizedBox(height: AppSpacing.s3),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Semantics(
                  button: true,
                  label: '${l10n.learnOpenOfficialPage}: ${source.title}',
                  child: ExcludeSemantics(
                    child: TextButton.icon(
                      onPressed: () => onOpen(source),
                      icon: Icon(
                        Icons.open_in_new,
                        size: 18,
                        color: tokens.spiritualGreenStrong,
                      ),
                      label: Text(l10n.learnOpenOfficialPage),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
