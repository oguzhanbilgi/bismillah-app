import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_article.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// İçerik türünün kullanıcıya görünen etiketi (TASK 056 §13).
///
/// Genel öğretici özet ile resmî fetva ASLA karıştırılmaz — her içerikte
/// tür açıkça yazılır.
String learnContentTypeLabel(
  AppLocalizations l10n,
  LearningContentType type,
) => switch (type) {
  LearningContentType.generalTeaching => l10n.learnTypeGeneralTeaching,
  LearningContentType.quranExplanation => l10n.learnTypeQuranExplanation,
  LearningContentType.hadithBased => l10n.learnTypeHadithBased,
  LearningContentType.ilmihalKnowledge => l10n.learnTypeIlmihalKnowledge,
  LearningContentType.officialFatwa => l10n.learnTypeOfficialFatwa,
};

String learnDifficultyLabel(
  AppLocalizations l10n,
  LearningDifficulty difficulty,
) => switch (difficulty) {
  LearningDifficulty.beginner => l10n.learnDifficultyBeginner,
  LearningDifficulty.basic => l10n.learnDifficultyBasic,
  LearningDifficulty.deep => l10n.learnDifficultyDeep,
};

/// Tek içerik satırı (TASK 056 §12).
///
/// Her içerik AĞIR bir kart değildir: gölgesiz, ince ayraçlı satır olarak
/// yaşar — uzun listelerde görsel gürültü birikmez. Dokunma alanı korunur.
class LearnArticleRow extends StatelessWidget {
  const LearnArticleRow({
    super.key,
    required this.article,
    this.isCompleted = false,
    this.isBookmarked = false,
    this.showDivider = true,
  });

  final LearningArticle article;
  final bool isCompleted;
  final bool isBookmarked;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = IslamicVisualTokens.of(context);

    return Semantics(
      button: true,
      label: article.title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(AppRoutes.learnArticlePath(article.slug)),
          child: ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: showDivider
                    ? Border(
                        bottom: BorderSide(color: tokens.surfaceBorder),
                      )
                    : null,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s2,
                    vertical: AppSpacing.s3,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              article.title,
                              token: AppTextStyleToken.h3,
                            ),
                            const SizedBox(height: AppSpacing.s1),
                            AppText(
                              article.summary,
                              token: AppTextStyleToken.caption,
                              secondary: true,
                              maxLines: 2,
                            ),
                            const SizedBox(height: AppSpacing.s1),
                            AppText(
                              '${learnContentTypeLabel(l10n, article.contentType)}'
                              ' · ${l10n.learnReadingMinutes(article.estimatedMinutes)}',
                              token: AppTextStyleToken.caption,
                              secondary: true,
                            ),
                          ],
                        ),
                      ),
                      // Durum işaretleri sakin ve küçüktür; suçluluk veya
                      // rekabet hissi ÜRETMEZ.
                      if (isBookmarked)
                        Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.s2),
                          child: Icon(
                            Icons.bookmark,
                            size: 18,
                            color: tokens.spiritualGreenStrong,
                          ),
                        ),
                      if (isCompleted)
                        Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.s2),
                          child: Icon(
                            Icons.check_circle,
                            size: 18,
                            color: tokens.spiritualGreenStrong,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
