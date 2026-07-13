import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/features/quran/application/quran_chapter_reader_providers.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_verse.dart';
import 'package:bismillah_app/shared/sacred/quran_text_block.dart';
import 'package:bismillah_app/shared/widgets/app_badge.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_error_state.dart';
import 'package:bismillah_app/shared/widgets/app_loading.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sure okuyucu (TASK 035) — SALT-OKUNUR, doğrulanmış Uthmani Arapça
/// metin (Tanzil 1.1; kaynak atfı ekran sonunda ve her ayet bloğunda).
/// Meal/ses/yer imi/ilerleme kaydı YOK; işlevsiz buton YOK. Geçersiz
/// chapterId sakin hata durumudur — ekran kontrolsüz exception ile
/// KAPANMAZ, AppBar geri oku her durumda çalışır.
class QuranChapterReaderScreen extends ConsumerWidget {
  const QuranChapterReaderScreen({super.key, required this.chapterId});

  /// Route parametresinden çözülen sure numarası; `null` = bozuk parametre.
  final int? chapterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = chapterId;
    if (id == null) {
      return AppScaffold(
        title: l10n.tabQuran,
        body: Center(
          child: AppText(
            l10n.quranReaderLoadIssue,
            token: AppTextStyleToken.bodySmall,
            secondary: true,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final chapterAsync = ref.watch(quranChapterProvider(id));
    final versesAsync = ref.watch(quranChapterVersesProvider(id));

    final chapter = chapterAsync.value;
    return AppScaffold(
      title: chapter?.transliteratedName ?? l10n.tabQuran,
      body: switch ((chapterAsync, versesAsync)) {
        // Tanınmayan sure numarası: sakin durum + AppBar geri dönüşü.
        (AsyncData(value: null), _) => Center(
          child: AppText(
            l10n.quranReaderLoadIssue,
            token: AppTextStyleToken.bodySmall,
            secondary: true,
            textAlign: TextAlign.center,
          ),
        ),
        (AsyncData(value: final QuranChapter chapter), AsyncData()) =>
          _ReaderBody(chapter: chapter, verses: versesAsync.value!),
        (AsyncError(), _) || (_, AsyncError()) => AppErrorState(
          message: l10n.quranReaderLoadIssue,
          retryLabel: l10n.commonRetry,
          onRetry: () {
            ref.invalidate(quranChapterProvider(id));
            ref.invalidate(quranChapterVersesProvider(id));
          },
        ),
        _ => AppLoading(label: l10n.commonLoading),
      },
    );
  }
}

final class _ReaderBody extends StatelessWidget {
  const _ReaderBody({required this.chapter, required this.verses});

  final QuranChapter chapter;
  final List<QuranVerse> verses;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Header (0) + ayetler (1..n) + kaynak atfı (n+1); liste lazy kurulur.
    return ListView.builder(
      itemCount: verses.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _ChapterHeader(chapter: chapter);
        }
        if (index == verses.length + 1) {
          return _SourceAttribution(l10n: l10n);
        }
        final verse = verses[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s4),
          // QuranTextBlock: RTL, geniş satır yüksekliği, kırpılamaz metin,
          // zorunlu kaynak rozeti (no source, no render).
          child: QuranTextBlock(
            arabicText: verse.textUthmani,
            sourceLabel: '${verse.verseKey} · Tanzil',
          ),
        );
      },
    );
  }
}

final class _ChapterHeader extends StatelessWidget {
  const _ChapterHeader({required this.chapter});

  final QuranChapter chapter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final placeLabel = switch (chapter.revelationPlace) {
      QuranRevelationPlace.meccan => l10n.quranRevelationMeccan,
      QuranRevelationPlace.medinan => l10n.quranRevelationMedinan,
    };

    return Column(
      children: [
        const SizedBox(height: AppSpacing.s3),
        AppCard(
          child: Row(
            children: [
              AppBadge(label: '${chapter.id}'),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      chapter.transliteratedName,
                      token: AppTextStyleToken.h3,
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    AppText(
                      '${l10n.quranAyahCount(chapter.verseCount)}'
                      ' · $placeLabel',
                      token: AppTextStyleToken.caption,
                      secondary: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s3),
              AppText(chapter.arabicName, token: AppTextStyleToken.h2),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s5),
      ],
    );
  }
}

/// Ekran sonunda sakin kaynak atfı (02_BRAND — güven; link paketi YOK).
final class _SourceAttribution extends StatelessWidget {
  const _SourceAttribution({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.s2,
        bottom: AppSpacing.s6,
      ),
      child: Column(
        children: [
          AppText(
            '${l10n.quranTextSourceLabel}: Tanzil Project',
            token: AppTextStyleToken.caption,
            secondary: true,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s1),
          const AppText(
            'tanzil.net',
            token: AppTextStyleToken.caption,
            secondary: true,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
