import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/features/quran/application/quran_verse_bookmarks_controller.dart';
import 'package:bismillah_app/features/today/application/today_daily_verse_provider.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_section_label.dart';
import 'package:bismillah_app/shared/islamic/referenced_verse_card.dart';
import 'package:bismillah_app/shared/sacred/sacred_content_source_badge.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Today "Bugünün Ayeti" bölümü (TASK 052).
///
/// Kaynak bütünlüğü: Arapça metin Tanzil, meal QuranEnc Rowad depolarından
/// gelir; referans ve kaynak etiketi her zaman gösterilir. Ayet SEÇİLMEZ —
/// gün, gözden geçirilmiş sabit listeden deterministik olarak belirlenir.
///
/// Yükleme/hata durumunda sakin fallback gösterilir; sahte veya boş ayet
/// ASLA render edilmez ve teknik hata kullanıcıya sızmaz.
class TodayDailyVerseCard extends ConsumerWidget {
  const TodayDailyVerseCard({super.key});

  /// Ayet ve meal kaynağının değişmez künyesi.
  static const String sourceLabel = 'Tanzil · QuranEnc Rowad';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(todayDailyVerseProvider);

    // Yüklenirken bölüm sessizce gizlenir: Today'e sonsuz spinner eklenmez
    // ve namaz içeriği görünür kalır.
    if (async.isLoading) {
      return const SizedBox.shrink();
    }

    final verse = async.value;
    return Column(
      children: [
        TodaySectionLabel(title: l10n.todayVerseSectionTitle),
        if (verse == null)
          // Sakin fallback — teknik hata/asset yolu gösterilmez.
          AppCard(
            child: AppText(
              l10n.todayVerseUnavailable,
              token: AppTextStyleToken.bodySmall,
              secondary: true,
            ),
          )
        else
          _VerseCard(verse: verse),
        const SizedBox(height: AppSpacing.s3),
      ],
    );
  }
}

class _VerseCard extends ConsumerWidget {
  const _VerseCard({required this.verse});

  final TodayDailyVerse verse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final ext = AppThemeExtension.of(context);
    final bookmarked =
        ref.watch(
          quranVerseBookmarksControllerProvider.select(
            (state) => state.value?.isBookmarked(verse.verseKey),
          ),
        ) ??
        false;

    return Semantics(
      button: true,
      label: l10n.todayVerseOpenReader,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.lgAll,
          // Mevcut reader route'u hedef ayetle açılır (TASK 048 helper'ı);
          // yeni route OLUŞTURULMAZ.
          onTap: () => context.go(
            AppRoutes.quranChapterVersePath(verse.chapterId, verse.verseNumber),
          ),
          child: ReferencedVerseCard(
            arabicText: verse.arabicText,
            reference: verse.reference,
            // Künye VERİSİ değişmedi ve hâlâ zorunlu; yalnız SUNUMU
            // kompaktlaştı (RDX-02B). Today kartı artık sağlayıcı adlarını
            // sürekli göstermez; künye sessiz bilgi eylemiyle TAM metniyle
            // açılır ve oradan tüm kaynaklar ekranına geçilebilir.
            sourceLabel: TodayDailyVerseCard.sourceLabel,
            sourceDisclosure: VerseSourceDisclosure.compact,
            onShowSource: () => _showSourceSheet(context),
            translation: verse.translationText.isEmpty
                ? null
                : verse.translationText,
            // RDX-01C3: kaydetme eylemi sessizleşti. Varsayılan `IconButton`
            // 8px dolgu + 24px ikonla ayeti bir "araç çubuğu" gibi
            // sonlandırıyordu; artık kart içeriğiyle aynı hizada başlar,
            // işaretli değilken üçüncül mürekkeple durur ve yalnız
            // işaretlendiğinde birincil renge geçer. Dokunma hedefi 48dp
            // olarak KORUNUR.
            actions: Align(
              alignment: AlignmentDirectional.centerStart,
              child: IconButton(
                tooltip: bookmarked
                    ? l10n.quranBookmarkSaved
                    : l10n.quranBookmarkAdd,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: AppSizes.touchTarget,
                  minHeight: AppSizes.touchTarget,
                ),
                iconSize: AppSizes.iconMd,
                color: bookmarked ? scheme.primary : ext.textTertiary,
                icon: Icon(
                  bookmarked ? Icons.bookmark : Icons.bookmark_outline,
                ),
                onPressed: () => ref
                    .read(quranVerseBookmarksControllerProvider.notifier)
                    .toggle(verse.verseKey),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Künye diyaloğu (RDX-02B) — mevcut `AlertDialog` diliyle, yeni bir bileşen
/// ailesi kurulmadan.
///
/// Atıf **kaldırılmadı, taşındı**: burada `sourceLabel`ın TAM metni gösterilir
/// ve kullanıcı oradan mevcut "İçerik kaynakları" ekranına geçebilir; o ekran
/// Tanzil ve QuranEnc — Rowad künyelerini kanonik adresleriyle birlikte
/// listeler. Sağlayıcı adı burada ÜRETİLMEZ, içerik verisinden gelir.
Future<void> _showSourceSheet(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final open = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.verseSourceTitle),
      content: const SingleChildScrollView(
        child: SacredContentSourceBadge(
          sourceLabel: TodayDailyVerseCard.sourceLabel,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.commonClose),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.verseSourceAllSources),
        ),
      ],
    ),
  );
  if (open ?? false) {
    if (!context.mounted) {
      return;
    }
    context.go(AppRoutes.profileSources);
  }
}
