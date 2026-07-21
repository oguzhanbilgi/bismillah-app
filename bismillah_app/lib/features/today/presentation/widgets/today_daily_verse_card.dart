import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/features/quran/application/quran_verse_bookmarks_controller.dart';
import 'package:bismillah_app/features/today/application/today_daily_verse_provider.dart';
import 'package:bismillah_app/shared/islamic/referenced_verse_card.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_section_header.dart';
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
        AppSectionHeader(title: l10n.todayVerseSectionTitle),
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
        const SizedBox(height: AppSpacing.s4),
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
            sourceLabel: TodayDailyVerseCard.sourceLabel,
            translation: verse.translationText.isEmpty
                ? null
                : verse.translationText,
            actions: Align(
              alignment: AlignmentDirectional.centerStart,
              child: IconButton(
                tooltip: bookmarked
                    ? l10n.quranBookmarkSaved
                    : l10n.quranBookmarkAdd,
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
