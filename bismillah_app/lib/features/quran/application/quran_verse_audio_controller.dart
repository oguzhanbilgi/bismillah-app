import 'dart:async';

import 'package:bismillah_app/features/quran/data/just_audio_quran_verse_audio_player.dart';
import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter_recitation.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_verse.dart';
import 'package:bismillah_app/features/quran/domain/services/quran_verse_audio_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ayet sesi ekran durumu (TASK 041/042).
enum QuranVerseAudioStatus { idle, loading, playing, paused, error }

/// Oynatma modu (TASK 042): tek ayet veya kesintisiz sure.
enum QuranAudioPlaybackMode { singleVerse, continuousChapter }

final class QuranVerseAudioState {
  const QuranVerseAudioState({
    this.activeVerseKey,
    this.activeVerseNumber,
    this.playbackMode,
    this.status = QuranVerseAudioStatus.idle,
    this.errorVerseKey,
    this.chapterAudioFailed = false,
    this.sourceReady = false,
    this.totalVerseCount,
  });

  /// Şu an yüklenen/çalan/duraklatılan ayet.
  final String? activeVerseKey;
  final int? activeVerseNumber;

  /// Aktif oynatmanın modu; boşta `null`.
  final QuranAudioPlaybackMode? playbackMode;

  final QuranVerseAudioStatus status;

  /// Son hata alan ayet — sakin hata YALNIZ bu ayette gösterilir.
  final String? errorVerseKey;

  /// "Sureyi dinle" akışı hata aldı (panel sakin hata + tekrar dene).
  final bool chapterAudioFailed;

  /// En az bir ses başarıyla hazırlandı mı (kaynak etiketi görünürlüğü).
  final bool sourceReady;

  /// Yüklü surenin ayet sayısı (panel "Ayet X / Y" ve sınırlar için).
  final int? totalVerseCount;

  bool get hasPrevious => activeVerseNumber != null && activeVerseNumber! > 1;

  bool get hasNext =>
      activeVerseNumber != null &&
      totalVerseCount != null &&
      activeVerseNumber! < totalVerseCount!;
}

/// Reader başına TEK oynatıcı: reader kapanınca (dinleyici kalmayınca)
/// otomatik dispose edilir — ses durur.
final quranVerseAudioPlayerProvider =
    Provider.autoDispose<QuranVerseAudioPlayer>((ref) {
      final player = JustAudioQuranVerseAudioPlayer();
      ref.onDispose(() => unawaited(player.dispose()));
      return player;
    });

/// Ayet sesi controller'ı (TASK 041/042).
///
/// Tek ayet: boş→yükle+oynat, çalan→duraklat, duraklatılan→devam, başka
/// ayet→öncekini durdur (continuous mod da SONLANIR). Kesintisiz sure:
/// ilk ayetten başlar, clip bitince otomatik sıradakine geçer, son
/// ayette durur. `_busy` kilidi hızlı dokunuşlarda yarış/iki ses
/// üretmez. Ses hatası reader'ı ETKİLEMEZ.
final quranVerseAudioControllerProvider =
    NotifierProvider.autoDispose<
      QuranVerseAudioController,
      QuranVerseAudioState
    >(QuranVerseAudioController.new);

final class QuranVerseAudioController extends Notifier<QuranVerseAudioState> {
  bool _busy = false;
  QuranChapterRecitation? _recitation;

  @override
  QuranVerseAudioState build() {
    final player = ref.watch(quranVerseAudioPlayerProvider);
    final subscription = player.statusStream.listen((playbackStatus) {
      final current = state;
      switch (playbackStatus) {
        case QuranAudioPlaybackStatus.completed:
          if (current.status != QuranVerseAudioStatus.playing &&
              current.status != QuranVerseAudioStatus.paused) {
            break;
          }
          // Kesintisiz modda sıradaki ayete otomatik geçiş (TASK 042);
          // son ayette veya tek ayet modunda boşa dönülür.
          final next = (current.activeVerseNumber ?? 0) + 1;
          if (current.playbackMode ==
                  QuranAudioPlaybackMode.continuousChapter &&
              _recitation?.timingFor(next) != null &&
              !_busy) {
            unawaited(
              _playVerseNumber(
                next,
                mode: QuranAudioPlaybackMode.continuousChapter,
              ),
            );
          } else {
            state = QuranVerseAudioState(sourceReady: current.sourceReady);
          }
        case QuranAudioPlaybackStatus.paused:
          // Telefon araması / ses odağı kaybı: sakin duraklatma.
          if (!_busy && current.status == QuranVerseAudioStatus.playing) {
            state = _copyWithStatus(current, QuranVerseAudioStatus.paused);
          }
        case QuranAudioPlaybackStatus.idle ||
            QuranAudioPlaybackStatus.loading ||
            QuranAudioPlaybackStatus.playing:
          break; // geçişleri controller aksiyonları yönetir
      }
    });
    ref.onDispose(subscription.cancel);
    return const QuranVerseAudioState();
  }

  static QuranVerseAudioState _copyWithStatus(
    QuranVerseAudioState current,
    QuranVerseAudioStatus status,
  ) => QuranVerseAudioState(
    activeVerseKey: current.activeVerseKey,
    activeVerseNumber: current.activeVerseNumber,
    playbackMode: current.playbackMode,
    status: status,
    sourceReady: current.sourceReady,
    totalVerseCount: current.totalVerseCount,
  );

  /// Yüklü sureden bir ayeti verilen modda oynatır (recitation hazır
  /// olmalı). `_busy` kilidini kendi alır.
  Future<void> _playVerseNumber(
    int verseNumber, {
    required QuranAudioPlaybackMode mode,
  }) async {
    final recitation = _recitation;
    final timing = recitation?.timingFor(verseNumber);
    if (recitation == null || timing == null || _busy) {
      return;
    }
    _busy = true;
    try {
      await ref.read(quranVerseAudioPlayerProvider).playVerse(timing);
      state = QuranVerseAudioState(
        activeVerseKey: '${recitation.chapterId}:$verseNumber',
        activeVerseNumber: verseNumber,
        playbackMode: mode,
        status: QuranVerseAudioStatus.playing,
        sourceReady: true,
        totalVerseCount: state.totalVerseCount,
      );
    } on Exception {
      state = QuranVerseAudioState(
        status: QuranVerseAudioStatus.error,
        errorVerseKey: '${recitation.chapterId}:$verseNumber',
        sourceReady: state.sourceReady,
        totalVerseCount: state.totalVerseCount,
      );
    } finally {
      _busy = false;
    }
  }

  /// Sureyi hazırlar (recitation + MP3) ve verilen ayetten oynatır.
  /// `_busy` kilidini TÜM akış boyunca tutar — hızlı art arda dokunuşlar
  /// iki ses/yarış üretmez.
  Future<void> _loadAndPlay({
    required int chapterId,
    required int expectedVerseCount,
    required int verseNumber,
    required QuranAudioPlaybackMode mode,
    required bool failAsChapter,
  }) async {
    if (_busy) {
      return;
    }
    _busy = true;
    try {
      await _loadAndPlayLocked(
        chapterId: chapterId,
        expectedVerseCount: expectedVerseCount,
        verseNumber: verseNumber,
        mode: mode,
        failAsChapter: failAsChapter,
      );
    } finally {
      _busy = false;
    }
  }

  Future<void> _loadAndPlayLocked({
    required int chapterId,
    required int expectedVerseCount,
    required int verseNumber,
    required QuranAudioPlaybackMode mode,
    required bool failAsChapter,
  }) async {
    final current = state;
    state = QuranVerseAudioState(
      activeVerseKey: '$chapterId:$verseNumber',
      activeVerseNumber: verseNumber,
      playbackMode: mode,
      status: QuranVerseAudioStatus.loading,
      sourceReady: current.sourceReady,
      totalVerseCount: expectedVerseCount,
    );
    final result = await ref
        .read(quranAudioRepositoryProvider)
        .getChapterRecitation(chapterId, expectedVerseCount);
    final recitation = result.fold(
      onSuccess: (recitation) => recitation,
      onFailure: (_) => null,
    );
    final timing = recitation?.timingFor(verseNumber);
    if (recitation == null || timing == null) {
      state = QuranVerseAudioState(
        status: QuranVerseAudioStatus.error,
        errorVerseKey: failAsChapter ? null : '$chapterId:$verseNumber',
        chapterAudioFailed: failAsChapter,
        sourceReady: current.sourceReady,
      );
      return;
    }
    try {
      final player = ref.read(quranVerseAudioPlayerProvider);
      await player.stop();
      await player.loadChapter(
        audioUrl: recitation.audioUrl,
        chapterId: chapterId,
      );
      _recitation = recitation;
      await player.playVerse(timing);
      state = QuranVerseAudioState(
        activeVerseKey: '$chapterId:$verseNumber',
        activeVerseNumber: verseNumber,
        playbackMode: mode,
        status: QuranVerseAudioStatus.playing,
        sourceReady: true,
        totalVerseCount: expectedVerseCount,
      );
    } on Exception {
      state = QuranVerseAudioState(
        status: QuranVerseAudioStatus.error,
        errorVerseKey: failAsChapter ? null : '$chapterId:$verseNumber',
        chapterAudioFailed: failAsChapter,
        sourceReady: current.sourceReady,
      );
    }
  }

  /// Ayet aksiyonunun giriş noktası (TASK 041 davranışı korunur):
  /// tek ayet modu; sure oynarken başka ayete basılırsa continuous mod
  /// sonlanır ve seçilen ayet çalar.
  Future<void> toggleVerse(
    QuranVerse verse, {
    required int expectedVerseCount,
  }) async {
    if (_busy) {
      return; // hızlı çift dokunuş — önceki işlem bitmeden yenisi açılmaz
    }
    _busy = true;
    try {
      final key = verse.verseKey;
      final player = ref.read(quranVerseAudioPlayerProvider);
      final current = state;

      if (current.activeVerseKey == key &&
          current.status == QuranVerseAudioStatus.playing) {
        await player.pause();
        state = _copyWithStatus(current, QuranVerseAudioStatus.paused);
        return;
      }
      if (current.activeVerseKey == key &&
          current.status == QuranVerseAudioStatus.paused) {
        await player.resume();
        state = _copyWithStatus(current, QuranVerseAudioStatus.playing);
        return;
      }
    } finally {
      _busy = false;
    }
    await _loadAndPlay(
      chapterId: verse.chapterId,
      expectedVerseCount: expectedVerseCount,
      verseNumber: verse.verseNumber,
      mode: QuranAudioPlaybackMode.singleVerse,
      failAsChapter: false,
    );
  }

  /// "Sureyi dinle": ilk ayetten kesintisiz oynatma (TASK 042).
  Future<void> playChapter({
    required int chapterId,
    required int expectedVerseCount,
  }) async {
    if (_busy) {
      return;
    }
    await _loadAndPlay(
      chapterId: chapterId,
      expectedVerseCount: expectedVerseCount,
      verseNumber: 1,
      mode: QuranAudioPlaybackMode.continuousChapter,
      failAsChapter: true,
    );
  }

  /// Panel tekrar dene: yalnız ilgili sure cache'i düşürülüp yeniden denenir.
  Future<void> retryChapter({
    required int chapterId,
    required int expectedVerseCount,
  }) async {
    ref.read(quranAudioRepositoryProvider).invalidateChapter(chapterId);
    _recitation = null;
    await playChapter(
      chapterId: chapterId,
      expectedVerseCount: expectedVerseCount,
    );
  }

  /// Panel duraklat/devam (her iki modda çalışır).
  Future<void> togglePauseResume() async {
    if (_busy) {
      return;
    }
    _busy = true;
    try {
      final current = state;
      final player = ref.read(quranVerseAudioPlayerProvider);
      if (current.status == QuranVerseAudioStatus.playing) {
        await player.pause();
        state = _copyWithStatus(current, QuranVerseAudioStatus.paused);
      } else if (current.status == QuranVerseAudioStatus.paused) {
        await player.resume();
        state = _copyWithStatus(current, QuranVerseAudioStatus.playing);
      }
    } finally {
      _busy = false;
    }
  }

  /// Oynatmayı tamamen durdurur (panel).
  Future<void> stopPlayback() async {
    if (_busy) {
      return;
    }
    _busy = true;
    try {
      await ref.read(quranVerseAudioPlayerProvider).stop();
      state = QuranVerseAudioState(sourceReady: state.sourceReady);
    } finally {
      _busy = false;
    }
  }

  /// Önceki/sonraki ayet (TASK 042): sınırlar dışında yok sayılır,
  /// mevcut clip durdurulup yeni clip oynatılır, mod korunur.
  Future<void> skipToAdjacentVerse({required bool forward}) async {
    final current = state;
    final verseNumber = current.activeVerseNumber;
    if (verseNumber == null ||
        (forward && !current.hasNext) ||
        (!forward && !current.hasPrevious)) {
      return;
    }
    await _playVerseNumber(
      forward ? verseNumber + 1 : verseNumber - 1,
      mode: current.playbackMode ?? QuranAudioPlaybackMode.continuousChapter,
    );
  }
}
