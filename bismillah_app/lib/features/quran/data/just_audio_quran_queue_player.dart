import 'dart:async';

import 'package:bismillah_app/features/quran/domain/services/quran_audio_queue.dart';
import 'package:bismillah_app/features/quran/domain/services/quran_audio_queue_player.dart';
import 'package:just_audio/just_audio.dart';

/// `just_audio` üzerinde sıra tabanlı oynatıcı (TASK 095A).
///
/// ## Neden `setClip` bırakıldı
///
/// `AudioPlayer.setClip`, paketin kendi kaynağında görüldüğü üzere her
/// çağrıda **tek parçalık yeni bir çalma listesi kurup baştan `_load()`
/// eder**. Yani her ayet geçişinde medya kaynağı yeniden hazırlanır ve
/// tampon yeniden dolar; ayetler arasındaki gözle görülür boşluğun
/// uygulama tarafındaki sebebi buydu.
///
/// Bunun yerine sure, aynı MP3'e bakan bir [ClippingAudioSource] listesi
/// olarak **bir kez** kurulur. `just_audio` sıradaki bir sonraki parçayı
/// mevcut parça çalarken hazırlar; geçişte uygulama hiçbir şey yapmaz.
///
/// Bindirme (overlap) ve crossfade YOKTUR: parçalar sırayla çalar ve
/// kesme sınırları doğrulanmış timing'den birebir gelir.
final class JustAudioQuranQueuePlayer implements QuranAudioQueuePlayer {
  JustAudioQuranQueuePlayer({AudioPlayer? player})
    : _player = player ?? AudioPlayer() {
    _subscriptions.add(_player.playerStateStream.listen((_) => _emit()));
    _subscriptions.add(_player.currentIndexStream.listen((_) => _emit()));
    _subscriptions.add(
      _player.playbackEventStream.listen(
        (_) => _emit(),
        onError: (Object error, StackTrace _) => _errors.add(error),
      ),
    );
  }

  final AudioPlayer _player;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  final StreamController<QuranAudioPlayerSnapshot> _snapshots =
      StreamController<QuranAudioPlayerSnapshot>.broadcast();
  final StreamController<Object> _errors = StreamController<Object>.broadcast();

  QuranAudioPlayerSnapshot _snapshot = const QuranAudioPlayerSnapshot();

  @override
  QuranAudioPlayerSnapshot get snapshot => _snapshot;

  @override
  Stream<QuranAudioPlayerSnapshot> get snapshots => _snapshots.stream;

  @override
  Stream<Object> get errors => _errors.stream;

  @override
  Future<void> setQueue(
    List<QuranAudioClip> clips, {
    required int initialIndex,
  }) async {
    if (clips.isEmpty) {
      return;
    }
    // Tek bir `setAudioSources` çağrısı: tüm sure hazırlanır, sonraki
    // ayetler için ikinci bir yükleme isteği kurulmaz.
    await _player.setAudioSources(
      [
        for (final clip in clips)
          ClippingAudioSource(
            child: AudioSource.uri(Uri.parse(clip.url)),
            start: clip.start,
            end: clip.end,
          ),
      ],
      initialIndex: initialIndex,
      initialPosition: Duration.zero,
    );
    // Sıra bitince kendiliğinden başa dönmez — oturum düzgün sonlanır.
    await _player.setLoopMode(LoopMode.off);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seekToIndex(int index) =>
      _player.seek(Duration.zero, index: index);

  @override
  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    await _snapshots.close();
    await _errors.close();
    await _player.dispose();
  }

  void _emit() {
    _snapshot = QuranAudioPlayerSnapshot(
      phase: switch (_player.processingState) {
        ProcessingState.idle => QuranAudioPlayerPhase.idle,
        ProcessingState.loading => QuranAudioPlayerPhase.loading,
        ProcessingState.buffering => QuranAudioPlayerPhase.buffering,
        ProcessingState.ready => QuranAudioPlayerPhase.ready,
        ProcessingState.completed => QuranAudioPlayerPhase.completed,
      },
      playing: _player.playing,
      currentIndex: _player.currentIndex,
      position: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    );
    if (!_snapshots.isClosed) {
      _snapshots.add(_snapshot);
    }
  }
}
