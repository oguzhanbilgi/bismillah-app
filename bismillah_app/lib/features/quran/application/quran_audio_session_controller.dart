import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/domain/services/quran_audio_session_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:bismillah_app/features/quran/domain/services/quran_audio_session_service.dart'
    show QuranAudioPlaybackMode, QuranVerseAudioState, QuranVerseAudioStatus;

/// Global ses oturumu durumunun shell seviyesi görünümü (TASK 046).
///
/// İkinci state makinesi DEĞİLDİR: durum birebir
/// [QuranAudioSessionService.watchState]'ten yansıtılır; burada yalnız
/// mini oynatıcı komutları için `_busy` kilidi (hızlı çift dokunuşlarda
/// çift komut zinciri engeli) vardır. Reader'ın kendi controller'ından
/// farkı yoktur, yalnız overlay/yükleme sorumluluğu taşımaz. autoDispose
/// DEĞİL — mini oynatıcı shell yaşadıkça durumu izler.
final quranAudioSessionControllerProvider =
    NotifierProvider<QuranAudioSessionController, QuranVerseAudioState>(
      QuranAudioSessionController.new,
    );

final class QuranAudioSessionController extends Notifier<QuranVerseAudioState> {
  bool _busy = false;

  @override
  QuranVerseAudioState build() {
    final service = ref.watch(quranAudioSessionServiceProvider);
    final subscription = service.watchState().listen(
      (serviceState) => state = serviceState,
    );
    ref.onDispose(subscription.cancel);
    // Devam eden oturum (arka plan dahil) ilk kareden doğru yansır.
    return service.currentState;
  }

  QuranAudioSessionService get _service =>
      ref.read(quranAudioSessionServiceProvider);

  /// Mini oynatıcı oynat/duraklat: yalnız gerçek playing/paused durumunda
  /// çalışır — loading sırasında komut yarışı başlatmaz.
  Future<void> togglePauseResume() async {
    switch (state.status) {
      case QuranVerseAudioStatus.playing:
        return _guarded(_service.pause);
      case QuranVerseAudioStatus.paused:
        return _guarded(_service.resume);
      case QuranVerseAudioStatus.idle ||
          QuranVerseAudioStatus.loading ||
          QuranVerseAudioStatus.error:
        return;
    }
  }

  /// Durdur/kapat: ses tamamen durur, oturum ve sistem bildirimi
  /// temizlenir — mini oynatıcı yalnız görsel olarak GİZLENMEZ.
  Future<void> stopPlayback() => _guarded(_service.stop);

  /// Önceki/sonraki ayet: sınır dışı istek yok sayılır; geçiş yarışlarını
  /// servisin komut jetonu yönetir.
  Future<void> skipToAdjacentVerse({required bool forward}) async {
    final current = state;
    if (current.activeVerseNumber == null ||
        (forward && !current.hasNext) ||
        (!forward && !current.hasPrevious)) {
      return;
    }
    return _guarded(forward ? _service.skipToNext : _service.skipToPrevious);
  }

  Future<void> _guarded(Future<void> Function() action) async {
    if (_busy) {
      return;
    }
    _busy = true;
    try {
      await action();
    } finally {
      _busy = false;
    }
  }
}
