import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter_recitation.dart';
import 'package:bismillah_app/features/quran/domain/services/quran_verse_audio_player.dart';
import 'package:just_audio/just_audio.dart';

/// just_audio tabanlı ayet oynatıcısı (TASK 041).
///
/// Reader başına TEK [AudioPlayer]: aynı surede ayet değişimi yalnız
/// `setClip` ile yapılır (MP3 yeniden YÜKLENMEZ); sure değişince yeni
/// URL yüklenir. Ses oturumu konuşma odaklıdır; telefon araması/odak
/// kaybında oynatma duraklatılır. Mikrofon izni İSTENMEZ.
final class JustAudioQuranVerseAudioPlayer implements QuranVerseAudioPlayer {
  JustAudioQuranVerseAudioPlayer({AudioPlayer? player})
    : _player = player ?? AudioPlayer() {
    _configureSession();
  }

  final AudioPlayer _player;
  final List<StreamSubscription<Object?>> _subscriptions = [];

  int? _loadedChapterId;
  String? _loadedAudioUrl;

  Future<void> _configureSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
      _subscriptions.add(
        session.interruptionEventStream.listen((event) {
          // Arama/odak kaybı: sakin duraklatma (devam kararı kullanıcıda).
          if (event.begin) {
            _player.pause();
          }
        }),
      );
      _subscriptions.add(
        session.becomingNoisyEventStream.listen((_) => _player.pause()),
      );
    } on Exception {
      // Oturum yapılandırılamazsa oynatma yine denenir — crash yok.
    }
  }

  @override
  Future<void> loadChapter({
    required String audioUrl,
    required int chapterId,
  }) async {
    if (_loadedChapterId == chapterId && _loadedAudioUrl == audioUrl) {
      return; // aynı sure zaten yüklü — MP3 tekrar yüklenmez
    }
    await _player.setUrl(audioUrl);
    _loadedChapterId = chapterId;
    _loadedAudioUrl = audioUrl;
  }

  @override
  Future<void> playVerse(QuranVerseTiming timing) async {
    // Clip yalnız ilgili ayetin aralığıdır; bitince player "completed"
    // durumuna geçer (statusStream bunu completed olarak yayınlar).
    await _player.setClip(start: timing.start, end: timing.end);
    await _player.seek(Duration.zero);
    await _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() => _player.play();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _player.dispose();
  }

  @override
  Stream<QuranAudioPlaybackStatus> get statusStream =>
      _player.playerStateStream.map((state) {
        return switch (state.processingState) {
          ProcessingState.loading ||
          ProcessingState.buffering => QuranAudioPlaybackStatus.loading,
          ProcessingState.completed => QuranAudioPlaybackStatus.completed,
          ProcessingState.idle => QuranAudioPlaybackStatus.idle,
          ProcessingState.ready =>
            state.playing
                ? QuranAudioPlaybackStatus.playing
                : QuranAudioPlaybackStatus.paused,
        };
      }).distinct();
}
