import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/theme/app_motion.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/features/quran/application/quran_audio_session_controller.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Uygulama geneli kompakt Kur'an mini oynatıcısı (TASK 046).
///
/// Shell'de, içerik ile alt navigasyon arasında yaşar; yalnız gerçek bir
/// ses oturumu (loading/playing/paused veya sakin hata) varken görünür.
/// Tek gerçek kaynak global oturum durumudur — burada ikinci state
/// makinesi YOKTUR. Yalnız presentation sorumluluğu taşır: durdurma/
/// duraklatma komutları application controller'a, reader'a dönüş
/// [onOpenReader] callback'ine gider; audio_service/just_audio/HTTP
/// İTHAL ETMEZ.
class QuranAudioMiniPlayer extends ConsumerWidget {
  const QuranAudioMiniPlayer({super.key, required this.onOpenReader});

  /// Gövde dokunuşu: aktif surenin okuyucusuna götürür (oynatma sürer).
  final void Function(int chapterId) onOpenReader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quranAudioSessionControllerProvider);
    // idle = oturum yok/stop sonrası; serviceUnavailable hatası reader
    // panelinde açıklanır — mini oynatıcı boş/ölü durumda GÖRÜNMEZ.
    final visible =
        state.status != QuranVerseAudioStatus.idle &&
        !state.serviceUnavailable &&
        state.activeChapterId != null;
    return AnimatedSize(
      duration: AppMotion.quick,
      curve: AppMotion.quickCurve,
      alignment: Alignment.topCenter,
      child: visible
          ? _MiniPlayerBar(state: state, onOpenReader: onOpenReader)
          : const SizedBox(width: double.infinity),
    );
  }
}

final class _MiniPlayerBar extends ConsumerWidget {
  const _MiniPlayerBar({required this.state, required this.onOpenReader});

  final QuranVerseAudioState state;
  final void Function(int chapterId) onOpenReader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(quranAudioSessionControllerProvider.notifier);
    final isLoading = state.status == QuranVerseAudioStatus.loading;
    final isError = state.status == QuranVerseAudioStatus.error;
    final isPlaying = state.status == QuranVerseAudioStatus.playing;
    final continuous =
        state.playbackMode == QuranAudioPlaybackMode.continuousChapter;

    // Kâri adı GLOBAL ses durumundan gelir (TASK 049) — mini player
    // katalog çağrısı yapmaz; ad yoksa doğrulanmış varsayılan etiket.
    final reciterName = state.activeReciterName ?? l10n.quranReciterName;
    final infoLine = isError
        ? l10n.quranAudioLoadIssue
        : isLoading
        ? l10n.quranAudioLoading
        : (state.activeVerseNumber != null && state.totalVerseCount != null)
        ? '${l10n.quranAudioVerseOf(state.activeVerseNumber!, state.totalVerseCount!)}'
              ' · $reciterName'
        : reciterName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s3,
        0,
        AppSpacing.s3,
        AppSpacing.s2,
      ),
      child: Center(
        child: ConstrainedBox(
          // Geniş ekran/tablette bar tüm genişliği kaplamaz.
          constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
          child: Semantics(
            button: true,
            label: l10n.quranMiniPlayerOpen,
            child: Tooltip(
              message: l10n.quranMiniPlayerOpen,
              child: AppCard(
                padding: const EdgeInsetsDirectional.only(
                  start: AppSpacing.s4,
                  top: AppSpacing.s2,
                  bottom: AppSpacing.s2,
                  end: AppSpacing.s1,
                ),
                onTap: () => onOpenReader(state.activeChapterId!),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            state.activeChapterName ?? l10n.tabQuran,
                            token: AppTextStyleToken.bodySmall,
                            maxLines: 1,
                          ),
                          const SizedBox(height: AppSpacing.s1),
                          AppText(
                            infoLine,
                            token: AppTextStyleToken.caption,
                            secondary: true,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s1),
                    // Hatada oturum zaten sonlanmıştır: yalnız kapat kalır —
                    // sonsuz spinner/ölü kontrol yok.
                    if (!isError) ...[
                      if (continuous)
                        IconButton(
                          tooltip: l10n.quranAudioPrevVerse,
                          icon: const Icon(Icons.skip_previous),
                          onPressed: !isLoading && state.hasPrevious
                              ? () => controller.skipToAdjacentVerse(
                                  forward: false,
                                )
                              : null,
                        ),
                      if (isLoading)
                        // Oynat/duraklat yuvasıyla aynı ayak izi: durum
                        // geçişlerinde bar genişliği zıplamaz.
                        Semantics(
                          label: l10n.quranAudioLoading,
                          child: const SizedBox(
                            width: AppSizes.touchTarget,
                            height: AppSizes.touchTarget,
                            child: Center(
                              child: SizedBox(
                                width: AppSizes.iconSm,
                                height: AppSizes.iconSm,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        IconButton(
                          tooltip: isPlaying
                              ? l10n.quranAudioPause
                              : l10n.quranAudioResume,
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                          ),
                          onPressed: controller.togglePauseResume,
                        ),
                      if (continuous)
                        IconButton(
                          tooltip: l10n.quranAudioNextVerse,
                          icon: const Icon(Icons.skip_next),
                          onPressed: !isLoading && state.hasNext
                              ? () => controller.skipToAdjacentVerse(
                                  forward: true,
                                )
                              : null,
                        ),
                    ],
                    IconButton(
                      tooltip: l10n.quranChapterAudioStop,
                      icon: const Icon(Icons.close),
                      onPressed: controller.stopPlayback,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
