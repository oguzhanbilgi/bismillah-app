import 'dart:async';

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/onboarding/presentation/widgets/onboarding_option_card.dart';
import 'package:bismillah_app/features/quran/application/quran_chapter_reader_providers.dart';
import 'package:bismillah_app/features/quran/application/quran_reader_text_size_controller.dart';
import 'package:bismillah_app/features/quran/application/quran_reading_position_providers.dart';
import 'package:bismillah_app/features/quran/application/quran_verse_bookmarks_controller.dart';
import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_reading_position.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_verse.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_arabic_text_size.dart';
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
    // Kayıtlı konum içerikle BİRLİKTE beklenir ki liste doğru offset'le
    // kurulsun; konum okuma hatası reader'ı BLOKLAMAZ (baştan açılır).
    final positionAsync = ref.watch(quranReadingPositionProvider);

    final chapter = chapterAsync.value;
    return AppScaffold(
      title: chapter?.transliteratedName ?? l10n.tabQuran,
      actions: [
        // Okuma ayarları (TASK 037): işlevsel tek aksiyon — metin boyutu.
        IconButton(
          tooltip: l10n.quranReaderSettings,
          icon: const Icon(Icons.text_fields),
          onPressed: () => _showReaderSettings(context),
        ),
      ],
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
        (AsyncData(value: final QuranChapter chapter), AsyncData())
            when !positionAsync.isLoading =>
          _ReaderBody(
            chapter: chapter,
            verses: versesAsync.value!,
            // Kayıt başka sureye aitse baştan açılır (TASK 036).
            initialScrollOffset: switch (positionAsync.value) {
              final QuranReadingPosition saved when saved.chapterId == id =>
                saved.scrollOffset,
              _ => 0,
            },
          ),
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

final class _ReaderBody extends ConsumerStatefulWidget {
  const _ReaderBody({
    required this.chapter,
    required this.verses,
    required this.initialScrollOffset,
  });

  final QuranChapter chapter;
  final List<QuranVerse> verses;
  final double initialScrollOffset;

  @override
  ConsumerState<_ReaderBody> createState() => _ReaderBodyState();
}

final class _ReaderBodyState extends ConsumerState<_ReaderBody> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: widget.initialScrollOffset,
    );
    // Kayıtlı offset içerikten uzunsa (farklı ekran boyutu vb.) ilk
    // frame'den sonra güvenle maksimuma çekilir — crash yok.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      final max = _scrollController.position.maxScrollExtent;
      if (_scrollController.offset > max) {
        _scrollController.jumpTo(max);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Kaydırma BİTİNCE konumu kaydeder (her frame'de DEĞİL). Kayıt hatası
  /// sessizce yok sayılır — okuma deneyimi kesintiye uğramaz.
  void _savePosition(ScrollMetrics metrics) {
    final offset = metrics.pixels
        .clamp(0.0, metrics.maxScrollExtent)
        .toDouble();
    unawaited(
      ref.read(quranReadingPositionRepositoryProvider).save(
        QuranReadingPosition(
          chapterId: widget.chapter.id,
          scrollOffset: offset,
          updatedAtUtc: ref.read(clockProvider).nowUtc(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final verses = widget.verses;

    // Metin boyutu tercihi tüm ayetlere ANINDA uygulanır (TASK 037);
    // yalnız Arapça metin ölçeklenir, rozet/etiketler sabit kalır.
    final textSize =
        ref.watch(quranReaderTextSizeControllerProvider).value ??
        QuranArabicTextSize.medium;
    final blockSize = switch (textSize) {
      QuranArabicTextSize.small => QuranTextBlockSize.small,
      QuranArabicTextSize.medium => QuranTextBlockSize.medium,
      QuranArabicTextSize.large => QuranTextBlockSize.large,
    };

    final bookmarks =
        ref.watch(quranVerseBookmarksControllerProvider).value ??
        const QuranVerseBookmarksState(bookmarkedKeys: {});
    // Kayıt hatası: kısa, sakin mesaj — reader kapanmaz, durum geri alınır.
    ref.listen(quranVerseBookmarksControllerProvider, (previous, next) {
      final failure = next.value?.lastFailure;
      if (failure != null && previous?.value?.lastFailure == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(switch (failure) {
              QuranBookmarkFailure.save => l10n.quranBookmarkSaveIssue,
              QuranBookmarkFailure.remove => l10n.quranBookmarkRemoveIssue,
            }),
          ),
        );
      }
    });

    // Header (0) + ayetler (1..n) + kaynak atfı (n+1); liste lazy kurulur.
    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        _savePosition(notification.metrics);
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: verses.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _ChapterHeader(chapter: widget.chapter);
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
              size: blockSize,
              footerAction: _VerseBookmarkAction(
                bookmarked: bookmarks.isBookmarked(verse.verseKey),
                onTap: () => ref
                    .read(quranVerseBookmarksControllerProvider.notifier)
                    .toggle(verse.verseKey),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Ayet alt bilgi satırındaki sakin kaydetme aksiyonu (TASK 037).
/// Seçili durum yeterlidir — başarı snackbar'ı gösterilmez.
final class _VerseBookmarkAction extends StatelessWidget {
  const _VerseBookmarkAction({required this.bookmarked, required this.onTap});

  final bool bookmarked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = bookmarked ? l10n.quranBookmarkSaved : l10n.quranBookmarkAdd;
    return Semantics(
      button: true,
      selected: bookmarked,
      label: label,
      child: Tooltip(
        message: label,
        child: TextButton.icon(
          onPressed: onTap,
          icon: Icon(
            bookmarked ? Icons.bookmark : Icons.bookmark_border,
            size: AppSizes.iconSm,
          ),
          label: Text(label),
        ),
      ),
    );
  }
}

/// Okuma ayarları paneli (TASK 037): yalnız Arapça metin boyutu.
void _showReaderSettings(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s5,
            AppSpacing.s2,
            AppSpacing.s5,
            AppSpacing.s6,
          ),
          child: Consumer(
            builder: (context, ref, _) {
              final selected =
                  ref.watch(quranReaderTextSizeControllerProvider).value ??
                  QuranArabicTextSize.medium;
              String sizeLabel(QuranArabicTextSize size) => switch (size) {
                QuranArabicTextSize.small => l10n.quranTextSizeSmall,
                QuranArabicTextSize.medium => l10n.quranTextSizeMedium,
                QuranArabicTextSize.large => l10n.quranTextSizeLarge,
              };
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    l10n.quranReaderViewTitle,
                    token: AppTextStyleToken.h3,
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  AppText(
                    l10n.quranArabicTextSizeLabel,
                    token: AppTextStyleToken.caption,
                    secondary: true,
                  ),
                  const SizedBox(height: AppSpacing.s3),
                  for (final size in QuranArabicTextSize.values) ...[
                    OnboardingOptionCard(
                      label: sizeLabel(size),
                      selected: selected == size,
                      onTap: () => ref
                          .read(quranReaderTextSizeControllerProvider.notifier)
                          .select(size),
                    ),
                    const SizedBox(height: AppSpacing.s3),
                  ],
                ],
              );
            },
          ),
        ),
      );
    },
  );
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
