import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_verse.dart';
import 'package:bismillah_app/features/quran/domain/services/quran_audio_session_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:bismillah_app/features/quran/domain/services/quran_audio_session_service.dart'
    show
        QuranAudioDisplayInfo,
        QuranAudioPlaybackMode,
        QuranVerseAudioState,
        QuranVerseAudioStatus;

/// Ayet sesi controller'ı (TASK 041/042/045).
///
/// TASK 045: controller artık player SAHİBİ DEĞİLDİR — global
/// [QuranAudioSessionService] oturumunu kullanır ve durumunu reader UI'a
/// yansıtır. Reader kapanınca yalnız abonelik kapanır; oynatma, otomatik
/// ayet ilerletme ve ses odağı yönetimi global serviste sürer. Aynı sure
/// tekrar açıldığında aktif ayet/mod/durum servisten geri gelir.
///
/// Controller'da kalan sorumluluklar: recitation'ı depodan yükleme, yükleme
/// aşaması için anlık loading/hata durumu (TASK 044 geri bildirimi) ve
/// `_busy` kilidiyle hızlı dokunuşlarda çift istek engeli.
final quranVerseAudioControllerProvider =
    NotifierProvider.autoDispose<
      QuranVerseAudioController,
      QuranVerseAudioState
    >(QuranVerseAudioController.new);

final class QuranVerseAudioController extends Notifier<QuranVerseAudioState> {
  bool _busy = false;

  /// Depo yükleme aşamasının geçici durumu ekranda: aktifken servis
  /// yayınları durumu EZMEZ (tek gerçek kaynak yine servistir; overlay
  /// yalnız servis devralana veya hata gösterilene kadar yaşar).
  bool _overlayActive = false;

  @override
  QuranVerseAudioState build() {
    final service = ref.watch(quranAudioSessionServiceProvider);
    final subscription = service.watchState().listen((serviceState) {
      if (!_overlayActive) {
        state = serviceState;
      }
    });
    // Reader kapanınca YALNIZ abonelik kapanır — servis/oynatma durmaz.
    ref.onDispose(subscription.cancel);
    // Devam eden oturum (başka reader'dan/arka plandan) anında yansır.
    return service.currentState;
  }

  QuranAudioSessionService get _service =>
      ref.read(quranAudioSessionServiceProvider);

  void _setOverlay(QuranVerseAudioState overlay) {
    _overlayActive = true;
    state = overlay;
  }

  /// Ayet aksiyonunun giriş noktası (TASK 041 davranışı korunur):
  /// tek ayet modu; sure oynarken başka ayete basılırsa continuous mod
  /// sonlanır ve seçilen ayet çalar.
  Future<void> toggleVerse(
    QuranVerse verse, {
    required int expectedVerseCount,
    required QuranAudioDisplayInfo display,
  }) async {
    if (_busy) {
      return; // hızlı çift dokunuş — önceki işlem bitmeden yenisi açılmaz
    }
    final current = state;
    if (current.activeVerseKey == verse.verseKey) {
      switch (current.status) {
        case QuranVerseAudioStatus.loading:
          return; // aynı ayet zaten yükleniyor — çift dokunuş yok sayılır
        case QuranVerseAudioStatus.playing:
          return _guarded(_service.pause);
        case QuranVerseAudioStatus.paused:
          return _guarded(_service.resume);
        case QuranVerseAudioStatus.idle || QuranVerseAudioStatus.error:
          break; // yeniden başlat
      }
    }
    _busy = true;
    // ANLIK GERİ BİLDİRİM (TASK 044): loading durumu HİÇBİR await
    // tamamlanmadan — dokunmayla aynı event döngüsünde — yayınlanır.
    _setOverlay(
      QuranVerseAudioState(
        activeChapterId: verse.chapterId,
        activeVerseKey: verse.verseKey,
        activeVerseNumber: verse.verseNumber,
        playbackMode: QuranAudioPlaybackMode.singleVerse,
        status: QuranVerseAudioStatus.loading,
        sourceReady: current.sourceReady,
        totalVerseCount: expectedVerseCount,
      ),
    );
    try {
      await _loadAndPlayLocked(
        chapterId: verse.chapterId,
        expectedVerseCount: expectedVerseCount,
        verseNumber: verse.verseNumber,
        mode: QuranAudioPlaybackMode.singleVerse,
        display: display,
      );
    } finally {
      _busy = false;
    }
  }

  /// "Sureyi dinle": ilk ayetten kesintisiz oynatma (TASK 042).
  Future<void> playChapter({
    required int chapterId,
    required int expectedVerseCount,
    required QuranAudioDisplayInfo display,
  }) async {
    if (_busy) {
      return;
    }
    _busy = true;
    _setOverlay(
      QuranVerseAudioState(
        activeChapterId: chapterId,
        activeVerseKey: '$chapterId:1',
        activeVerseNumber: 1,
        playbackMode: QuranAudioPlaybackMode.continuousChapter,
        status: QuranVerseAudioStatus.loading,
        sourceReady: state.sourceReady,
        totalVerseCount: expectedVerseCount,
      ),
    );
    try {
      await _loadAndPlayLocked(
        chapterId: chapterId,
        expectedVerseCount: expectedVerseCount,
        verseNumber: 1,
        mode: QuranAudioPlaybackMode.continuousChapter,
        display: display,
      );
    } finally {
      _busy = false;
    }
  }

  /// Panel tekrar dene: yalnız ilgili sure cache'i düşürülüp yeniden denenir.
  Future<void> retryChapter({
    required int chapterId,
    required int expectedVerseCount,
    required QuranAudioDisplayInfo display,
  }) async {
    ref.read(quranAudioRepositoryProvider).invalidateChapter(chapterId);
    await playChapter(
      chapterId: chapterId,
      expectedVerseCount: expectedVerseCount,
      display: display,
    );
  }

  /// Panel duraklat/devam (her iki modda çalışır).
  Future<void> togglePauseResume() async {
    if (_busy) {
      return;
    }
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

  /// Oynatmayı tamamen durdurur (panel) — sistem bildirimi de temizlenir.
  Future<void> stopPlayback() async {
    if (_busy) {
      return;
    }
    _busy = true;
    try {
      _overlayActive = false;
      await _service.stop();
      state = _service.currentState;
    } finally {
      _busy = false;
    }
  }

  /// Önceki/sonraki ayet (TASK 042): sınırlar dışında yok sayılır, mod
  /// korunur; geçiş yarışlarını servisin komut jetonu yönetir.
  Future<void> skipToAdjacentVerse({required bool forward}) async {
    final current = state;
    if (current.activeVerseNumber == null ||
        (forward && !current.hasNext) ||
        (!forward && !current.hasPrevious)) {
      return;
    }
    await (forward ? _service.skipToNext() : _service.skipToPrevious());
  }

  Future<void> _guarded(Future<void> Function() action) async {
    _busy = true;
    try {
      await action();
    } finally {
      _busy = false;
    }
  }

  /// Sureyi depodan hazırlar ve global serviste oynatmayı başlatır.
  /// `_busy` kilidi çağıranda TÜM akış boyunca tutulur — hızlı art arda
  /// dokunuşlar iki paralel yükleme/oynatma üretmez.
  Future<void> _loadAndPlayLocked({
    required int chapterId,
    required int expectedVerseCount,
    required int verseNumber,
    required QuranAudioPlaybackMode mode,
    required QuranAudioDisplayInfo display,
  }) async {
    final sourceReadyBefore = state.sourceReady;
    // Yeni istek mevcut oturumu (başka sure dahil) önce durdurur.
    await _service.stop();
    final result = await ref
        .read(quranAudioRepositoryProvider)
        .getChapterRecitation(chapterId, expectedVerseCount);
    final recitation = result.fold(
      onSuccess: (recitation) => recitation,
      onFailure: (_) => null,
    );
    final failAsChapter = mode == QuranAudioPlaybackMode.continuousChapter;
    if (recitation == null || recitation.timingFor(verseNumber) == null) {
      // Yükleme hatası ekranda kalır (servis boşta) — sonraki kullanıcı
      // aksiyonu overlay'i değiştirir.
      _setOverlay(
        QuranVerseAudioState(
          activeChapterId: chapterId,
          status: QuranVerseAudioStatus.error,
          errorVerseKey: failAsChapter ? null : '$chapterId:$verseNumber',
          chapterAudioFailed: failAsChapter,
          sourceReady: sourceReadyBefore,
        ),
      );
      return;
    }
    final request = QuranAudioSessionRequest(
      recitation: recitation,
      totalVerseCount: expectedVerseCount,
      startVerseNumber: verseNumber,
      display: display,
    );
    // Servis devralıyor: ilk loading durumunu senkron yayınlar, sonrası
    // (playing/paused/error/tamamlanma) akıştan gelir.
    _overlayActive = false;
    final playback = failAsChapter
        ? _service.playContinuousChapter(request)
        : _service.playSingleVerse(request);
    state = _service.currentState;
    await playback;
  }
}
