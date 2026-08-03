import 'package:bismillah_app/features/quran/domain/services/quran_audio_queue.dart';

/// Oynatıcının ham durumu (TASK 095A) — paket bağımsız.
enum QuranAudioPlayerPhase { idle, loading, buffering, ready, completed }

/// Oynatıcının tek bir andaki tam görüntüsü.
///
/// Sistem bildirimi ve reader durumu bu tek yapıdan türetilir; ikinci bir
/// "gerçek durum" kaynağı yoktur.
final class QuranAudioPlayerSnapshot {
  const QuranAudioPlayerSnapshot({
    this.phase = QuranAudioPlayerPhase.idle,
    this.playing = false,
    this.currentIndex,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.speed = 1,
  });

  final QuranAudioPlayerPhase phase;
  final bool playing;

  /// Sıradaki aktif parçanın konumu; sıra yokken `null`.
  final int? currentIndex;

  final Duration position;
  final Duration bufferedPosition;
  final double speed;
}

/// Sıra tabanlı oynatıcı sözleşmesi (TASK 095A).
///
/// Uygulama katmanı `just_audio` GÖRMEZ. Sözleşmenin tek işi şudur:
/// **bütün sırayı bir kez al, kendi içinde ilerlet**. Parça başına yeni
/// yükleme isteği kurulmaz; bir sonraki ayetin hazırlanması oynatıcının
/// sorumluluğundadır.
///
/// Testler bu arayüzü belirlenimci bir sahte ile doldurur; gerçek ağ veya
/// platform zamanlaması widget testinde ÖLÇÜLMEZ.
abstract interface class QuranAudioQueuePlayer {
  /// Tüm sırayı hazırlar ve [initialIndex] parçasını etkin yapar.
  ///
  /// Oynatma başlamadan önce YALNIZ BİR KEZ çağrılır; ayet geçişlerinde
  /// tekrar çağrılmaz.
  Future<void> setQueue(
    List<QuranAudioClip> clips, {
    required int initialIndex,
  });

  Future<void> play();

  Future<void> pause();

  /// Oynatmayı durdurur ve sırayı boşaltır.
  Future<void> stop();

  /// Sıradaki başka bir parçaya geçer (önceki/sonraki ayet).
  Future<void> seekToIndex(int index);

  /// Anlık durum.
  QuranAudioPlayerSnapshot get snapshot;

  /// Durum akışı (broadcast).
  Stream<QuranAudioPlayerSnapshot> get snapshots;

  /// Kalıcı oynatma hatası akışı; ham hata metni UI'a TAŞINMAZ.
  Stream<Object> get errors;

  Future<void> dispose();
}
