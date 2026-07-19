import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/features/learn/application/learn_providers.dart';
import 'package:bismillah_app/features/learn/domain/entities/knowledge_source.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_article.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_progress.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';
import 'package:bismillah_app/features/learn/presentation/widgets/learn_article_row.dart';
import 'package:bismillah_app/features/learn/presentation/widgets/learn_section_view.dart';
import 'package:bismillah_app/features/learn/presentation/widgets/learn_source_card.dart';
import 'package:bismillah_app/shared/islamic/gentle_empty_state.dart';
import 'package:bismillah_app/shared/widgets/app_badge.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_error_state.dart';
import 'package:bismillah_app/shared/widgets/app_loading.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// İçerik detay ekranı (TASK 056 §10).
///
/// Okuma alanı SADEDİR: uzun metin arkasına illüstrasyon veya yoğun motif
/// konmaz. İçerik türü, kaynak künyeleri ve (varsa) görüş farkı her zaman
/// görünürdür — genel öğretici özet ile resmî fetva karıştırılamaz.
class LearnArticleScreen extends ConsumerStatefulWidget {
  const LearnArticleScreen({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<LearnArticleScreen> createState() => _LearnArticleScreenState();
}

class _LearnArticleScreenState extends ConsumerState<LearnArticleScreen> {
  bool _notedOpen = false;

  /// "Kaldığın yerden devam" için son açılan içeriği bir kez kaydeder.
  void _noteOpenedOnce(LearningArticle article) {
    if (_notedOpen) {
      return;
    }
    _notedOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(learnProgressProvider.notifier).noteOpened(article.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final articleAsync = ref.watch(learnArticleBySlugProvider(widget.slug));

    return switch (articleAsync) {
      AsyncData(:final value) =>
        value == null
            // Bilinmeyen/yayında olmayan slug: sakin durum, crash yok.
            ? AppScaffold(
                title: l10n.tabLearn,
                body: GentleEmptyState(
                  title: l10n.learnCategoryEmptyTitle,
                  message: l10n.learnCategoryPreparing,
                ),
              )
            : _ArticleContent(
                article: value,
                onOpened: () => _noteOpenedOnce(value),
              ),
      AsyncError() => AppScaffold(
        title: l10n.tabLearn,
        body: AppErrorState(
          message: l10n.learnLoadIssue,
          retryLabel: l10n.commonRetry,
          onRetry: () =>
              ref.invalidate(learnArticleBySlugProvider(widget.slug)),
        ),
      ),
      _ => AppScaffold(
        title: l10n.tabLearn,
        body: AppLoading(label: l10n.commonLoading),
      ),
    };
  }
}

class _ArticleContent extends ConsumerWidget {
  const _ArticleContent({required this.article, required this.onOpened});

  final LearningArticle article;
  final VoidCallback onOpened;

  Future<void> _openSource(
    BuildContext context,
    WidgetRef ref,
    KnowledgeSource source,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final opened = await ref
        .read(externalLinkServiceProvider)
        .openOfficialSource(source.canonicalUrl);
    if (opened) {
      return;
    }
    // Açılamadı: CRASH YOK. Bilgi mesajı ÖNCE gösterilir — panoya kopyalama
    // platformda başarısız olsa bile kullanıcı adresi görür.
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('${l10n.learnLinkUnavailable} ${source.canonicalUrl}'),
        ),
      );
    // Kolaylık olsun diye panoya da kopyalanır; başarısızlığı yutulur.
    try {
      await Clipboard.setData(ClipboardData(text: source.canonicalUrl));
    } on Exception {
      // Pano kullanılamıyorsa sessizce geçilir — adres mesajda görünür.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final progress =
        ref.watch(learnProgressProvider).value ?? LearningProgress.empty;
    final sources =
        ref.watch(learnArticleSourcesProvider(article)).value ??
        const <KnowledgeSource>[];
    final related =
        ref
            .watch(learnArticlesByIdsProvider(article.relatedArticleIds))
            .value ??
        const <LearningArticle>[];

    onOpened();

    final isBookmarked = progress.isBookmarked(article.id);
    final isCompleted = progress.isCompleted(article.id);

    return AppScaffold(
      title: article.title,
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.s4),
          _MetaRow(article: article),
          const SizedBox(height: AppSpacing.s4),
          AppText(article.summary, token: AppTextStyleToken.body),
          const SizedBox(height: AppSpacing.s5),

          // Resmî olmayan açıklayıcı çeviri uyarısı (TASK 056 §6):
          // İngilizce/Arapça metin resmî fetva gibi SUNULMAZ.
          if (article.translationStatus ==
              LearningTranslationStatus.explanatoryTranslation) ...[
            _TranslationNotice(message: l10n.learnTranslationDisclaimer),
            const SizedBox(height: AppSpacing.s5),
          ],

          // İçerik bölümleri — tip güvenli render.
          for (final section in article.sections)
            LearnSectionView(section: section),

          // Görüş farkı GİZLENMEZ.
          if (article.differenceNote case final String note) ...[
            const SizedBox(height: AppSpacing.s2),
            _NoteCard(
              title: l10n.learnDifferenceNoteTitle,
              body: note,
              icon: Icons.balance_outlined,
            ),
            const SizedBox(height: AppSpacing.s4),
          ],

          // Kişisel duruma özel hüküm gerektiren konularda yetkili mercie
          // yönlendirme — uygulama fetva ÜRETMEZ.
          if (article.requiresQualifiedGuidance &&
              article.guidanceMessage != null) ...[
            _NoteCard(
              title: l10n.learnGuidanceTitle,
              body: article.guidanceMessage!,
              icon: Icons.support_agent_outlined,
            ),
            const SizedBox(height: AppSpacing.s4),
          ],

          const SizedBox(height: AppSpacing.s2),
          _ProgressActions(
            article: article,
            isBookmarked: isBookmarked,
            isCompleted: isCompleted,
          ),
          const SizedBox(height: AppSpacing.s6),

          // Kaynak kartları — "no source, no render" kuralının UI ayağı.
          if (sources.isNotEmpty) ...[
            AppText(l10n.learnSourcesSection, token: AppTextStyleToken.h3),
            const SizedBox(height: AppSpacing.s3),
            for (final source in sources)
              LearnSourceCard(
                source: source,
                onOpen: (s) => _openSource(context, ref, s),
              ),
            const SizedBox(height: AppSpacing.s4),
          ],

          // Asistan HENÜZ yok: çalışmayan gerçek buton bırakılmaz, açıkça
          // "yakında" olarak ve devre dışı gösterilir.
          _AssistantSoonNotice(label: l10n.learnAskAssistantSoon),

          if (related.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s6),
            AppText(l10n.learnRelatedSection, token: AppTextStyleToken.h3),
            const SizedBox(height: AppSpacing.s3),
            for (final item in related)
              LearnArticleRow(
                article: item,
                isBookmarked: progress.isBookmarked(item.id),
                isCompleted: progress.isCompleted(item.id),
              ),
          ],
          const SizedBox(height: AppSpacing.s7),
        ],
      ),
    );
  }
}

/// İçerik künyesi: tür, zorluk, süre ve son kaynak kontrol tarihi.
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.article});

  final LearningArticle article;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.s2,
          runSpacing: AppSpacing.s2,
          children: [
            // İçerik TÜRÜ her zaman görünür (TASK 056 §13).
            AppBadge(
              label: learnContentTypeLabel(l10n, article.contentType),
              emphasized: true,
            ),
            AppBadge(label: learnDifficultyLabel(l10n, article.difficulty)),
            AppBadge(label: l10n.learnReadingMinutes(article.estimatedMinutes)),
          ],
        ),
        if (article.reviewedAt case final String reviewedAt) ...[
          const SizedBox(height: AppSpacing.s3),
          AppText(
            '${l10n.learnLastVerified}: $reviewedAt',
            token: AppTextStyleToken.caption,
            secondary: true,
          ),
        ],
      ],
    );
  }
}

class _TranslationNotice extends StatelessWidget {
  const _TranslationNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.sectionSurface,
        borderRadius: AppRadius.lgAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.translate_outlined,
              size: 20,
              color: tokens.spiritualGreenStrong,
            ),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: AppText(
                message,
                token: AppTextStyleToken.caption,
                secondary: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    return AppCard(
      variant: AppCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: tokens.spiritualGreenStrong),
              const SizedBox(width: AppSpacing.s2),
              Expanded(child: AppText(title, token: AppTextStyleToken.h3)),
            ],
          ),
          const SizedBox(height: AppSpacing.s2),
          AppText(body, token: AppTextStyleToken.bodySmall, secondary: true),
        ],
      ),
    );
  }
}

/// Kaydet + tamamlandı aksiyonları. Dinî puan/seviye YOKTUR; tamamlanmamış
/// içerik için suçluluk dili kullanılmaz.
class _ProgressActions extends ConsumerWidget {
  const _ProgressActions({
    required this.article,
    required this.isBookmarked,
    required this.isCompleted,
  });

  final LearningArticle article;
  final bool isBookmarked;
  final bool isCompleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(learnProgressProvider.notifier);

    return Wrap(
      spacing: AppSpacing.s3,
      runSpacing: AppSpacing.s3,
      children: [
        AppButton(
          label: isBookmarked ? l10n.learnSaved : l10n.learnSave,
          variant: AppButtonVariant.secondary,
          onPressed: () => controller.toggleBookmark(article.id),
        ),
        AppButton(
          label: isCompleted ? l10n.learnCompleted : l10n.learnMarkCompleted,
          variant: AppButtonVariant.secondary,
          onPressed: () => controller.toggleCompleted(article.id),
        ),
      ],
    );
  }
}

/// Asistan yakında — bilinçli olarak DEVRE DIŞI, yanıltıcı değil.
class _AssistantSoonNotice extends StatelessWidget {
  const _AssistantSoonNotice({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: AppButton(
        label: label,
        variant: AppButtonVariant.text,
        // onPressed null → buton görünür ama tıklanamaz; "yakında" olduğu
        // etiketten de anlaşılır.
        onPressed: null,
      ),
    );
  }
}
