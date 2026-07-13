import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/features/quran/application/quran_reader_text_size_controller.dart';
import 'package:bismillah_app/features/quran/application/quran_saved_verses_provider.dart';
import 'package:bismillah_app/features/quran/application/quran_verse_bookmarks_controller.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_arabic_text_size.dart';
import 'package:bismillah_app/shared/sacred/quran_text_block.dart';
import 'package:bismillah_app/shared/widgets/app_badge.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_error_state.dart';
import 'package:bismillah_app/shared/widgets/app_loading.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Kaydedilen ayetler ekranı (TASK 038) — SALT-OKUNUR liste + kayıt
/// kaldırma. Aynı bookmark controller'ı kullanılır (ikinci sistem YOK);
/// meal/ses/not YOK, sahte içerik YOK.
class QuranSavedVersesScreen extends ConsumerWidget {
  const QuranSavedVersesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(quranSavedVersesProvider);

    // Kaldırma hatası: kayıt geri gelir (controller geri alır) + sakin mesaj.
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

    return AppScaffold(
      title: l10n.quranSavedVersesTitle,
      body: switch (async) {
        AsyncData(:final value) => value.isEmpty
            ? const _SavedVersesEmptyState()
            : _SavedVersesList(saved: value),
        AsyncError() => AppErrorState(
          message: l10n.quranSavedVersesLoadIssue,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(quranSavedVersesProvider),
        ),
        _ => AppLoading(label: l10n.commonLoading),
      },
    );
  }
}

final class _SavedVersesList extends ConsumerWidget {
  const _SavedVersesList({required this.saved});

  final List<QuranSavedVerse> saved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ayet metni kullanıcının TASK 037 boyut tercihiyle render edilir.
    final textSize =
        ref.watch(quranReaderTextSizeControllerProvider).value ??
        QuranArabicTextSize.medium;
    final blockSize = switch (textSize) {
      QuranArabicTextSize.small => QuranTextBlockSize.small,
      QuranArabicTextSize.medium => QuranTextBlockSize.medium,
      QuranArabicTextSize.large => QuranTextBlockSize.large,
    };

    return ListView.builder(
      itemCount: saved.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const SizedBox(height: AppSpacing.s3);
        }
        final item = saved[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s4),
          child: _SavedVerseCard(item: item, blockSize: blockSize),
        );
      },
    );
  }
}

final class _SavedVerseCard extends ConsumerWidget {
  const _SavedVerseCard({required this.item, required this.blockSize});

  final QuranSavedVerse item;
  final QuranTextBlockSize blockSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final verse = item.verse;
    final chapter = item.chapter;

    // Karta dokunma ilgili surenin okuyucusunu açar; okuyucu mevcut
    // kayıtlı konum davranışını korur (ayete otomatik kaydırma yok).
    return AppCard(
      onTap: () => context.push(AppRoutes.quranChapterPath(chapter.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppBadge(label: verse.verseKey),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: AppText(
                  chapter.transliteratedName,
                  token: AppTextStyleToken.h3,
                ),
              ),
              const SizedBox(width: AppSpacing.s3),
              AppText(chapter.arabicName, token: AppTextStyleToken.h3),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          QuranTextBlock(
            arabicText: verse.textUthmani,
            sourceLabel: '${verse.verseKey} · Tanzil',
            size: blockSize,
            footerAction: Semantics(
              button: true,
              label: l10n.quranBookmarkRemove,
              child: Tooltip(
                message: l10n.quranBookmarkRemove,
                child: TextButton.icon(
                  // Aynı controller: iyimser kaldırma, in-flight koruması
                  // hızlı çift dokunuşu engeller; hata geri getirir.
                  onPressed: () => ref
                      .read(quranVerseBookmarksControllerProvider.notifier)
                      .toggle(verse.verseKey),
                  icon: const Icon(Icons.bookmark_remove_outlined,
                      size: AppSizes.iconSm),
                  label: Text(l10n.quranBookmarkRemove),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sakin boş durum — sahte ayet/örnek dini içerik YOK.
final class _SavedVersesEmptyState extends StatelessWidget {
  const _SavedVersesEmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      children: [
        const SizedBox(height: AppSpacing.s5),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                l10n.quranSavedVersesEmptyTitle,
                token: AppTextStyleToken.h3,
              ),
              const SizedBox(height: AppSpacing.s2),
              AppText(
                l10n.quranSavedVersesEmptyBody,
                token: AppTextStyleToken.bodySmall,
                secondary: true,
              ),
              const SizedBox(height: AppSpacing.s5),
              AppButton(
                label: l10n.quranGoToReading,
                variant: AppButtonVariant.secondary,
                onPressed: () => context.go(AppRoutes.quran),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
