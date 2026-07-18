import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:bismillah_app/features/quran/data/unavailable_quran_audio_session_service.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter_recitation.dart';
import 'package:bismillah_app/features/quran/domain/services/quran_audio_session_service.dart';
import 'package:just_audio/just_audio.dart';

/// AudioService.init YALNIZ burada, bootstrap'ta BİR KEZ çağrılır
/// (TASK 045). Başarısızlık fatal DEĞİLDİR: reader Arapça/meal ile açılır,
/// ses aksiyonları sakin hata veren unavailable implementasyona düşer.
///
/// NOT: audio_service, `androidNotificationOngoing: true` değerini yalnız
/// `androidStopForegroundOnPause: true` ile kabul eder (paket assert'i).
/// Görevin davranış önceliği "paused oturum foreground kalabilir" olduğu
/// için stopForegroundOnPause=false korunur, ongoing varsayılanda kalır.
Future<QuranAudioSessionService> initializeQuranAudioSessionService({
  required String notificationChannelName,
}) async {
  try {
    return await AudioService.init<AudioServiceQuranHandler>(
      builder: AudioServiceQuranHandler.new,
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.bismillah.quran.audio',
        androidNotificationChannelName: notificationChannelName,
        androidStopForegroundOnPause: false,
      ),
    );
  } on Object {
    return UnavailableQuranAudioSessionService();
  }
}

/// Global Kur'an ses oturumu handler'ı (TASK 045).
///
/// Uygulama süresince TEK handler ve TEK [AudioPlayer] yaşar — reader
/// başına player OLUŞTURULMAZ. Kesintisiz modda ayet ilerletme, sistem
/// bildirimi/kilit ekranı kontrolleri ve ses odağı yönetimi tamamen bu
/// sınıftadır; reader kapansa da oynatma sürer. Ses oturumu konuşma
/// odaklıdır; arama/odak kaybı/kulaklık çıkarma duraklatır — interruption
/// dinleyicisi YALNIZ burada kurulur (ikinci katman yok).
final class AudioServiceQuranHandler extends BaseAudioHandler
    implements QuranAudioSessionService {
  AudioServiceQuranHandler() {
    unawaited(_configureSession());
    _subscriptions.add(_player.playerStateStream.listen(_onPlayerState));
    _subscriptions.add(
      _player.playbackEventStream.listen(
        (_) => _broadcastSystemState(),
        // Oynatma sırasındaki platform hatası (ör. ağ kopması): bildirim
        // sonsuza dek loading KALMAZ, foreground service kapanır.
        onError: (Object error, StackTrace stackTrace) => _failSession(),
      ),
    );
  }

  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription<Object?>> _subscriptions = [];
  final StreamController<QuranVerseAudioState> _stateController =
      StreamController<QuranVerseAudioState>.broadcast();

  QuranVerseAudioState _current = const QuranVerseAudioState();
  QuranAudioSessionRequest? _request;
  QuranAudioPlaybackMode? _mode;
  int? _activeVerse;
  int? _completedVerse;
  String? _loadedAudioUrl;
  bool _sourceReady = false;

  /// Komut jetonu: her yeni oynat/geç/durdur komutu artırır; eski async
  /// işlemler await sonrası jetonu doğrular — hızlı komutlarda iki paralel
  /// load/play oluşmaz, eski işlem yeni isteğin durumunu EZMEZ.
  int _generation = 0;

  @override
  QuranVerseAudioState get currentState => _current;

  @override
  Stream<QuranVerseAudioState> watchState() => _stateController.stream;

  @override
  Future<void> playSingleVerse(QuranAudioSessionRequest request) =>
      _startSession(request, QuranAudioPlaybackMode.singleVerse);

  @override
  Future<void> playContinuousChapter(QuranAudioSessionRequest request) =>
      _startSession(request, QuranAudioPlaybackMode.continuousChapter);

  @override
  Future<void> pause() async {
    if (_request == null) {
      return;
    }
    try {
      await _player.pause();
    } on Exception {
      // Duraklatma hatası oturumu bozmaz — durum akıştan gelir.
    }
  }

  @override
  Future<void> resume() async {
    if (_request == null) {
      return;
    }
    // play() future'ı clip bitene dek tamamlanmayabilir — durum player
    // akışından türetildiği için await EDİLMEZ.
    unawaited(_playQuietly());
  }

  /// Sistem media session "play" komutu (bildirim/kilit ekranı/kulaklık).
  @override
  Future<void> play() => resume();

  @override
  Future<void> stop() async {
    _generation++;
    final sourceReady = _sourceReady;
    _clearSession();
    _emit(QuranVerseAudioState(sourceReady: sourceReady));
    await _stopPlayerQuietly();
    await super.stop();
  }

  @override
  Future<void> skipToPrevious() => _skipTo(-1);

  @override
  Future<void> skipToNext() => _skipTo(1);

  Future<void> _configureSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
      _subscriptions.add(
        session.interruptionEventStream.listen((event) {
          // Arama/geçici veya kalıcı odak kaybı: sakin duraklatma
          // (devam kararı kullanıcıda).
          if (event.begin) {
            unawaited(pause());
          }
        }),
      );
      _subscriptions.add(
        session.becomingNoisyEventStream.listen((_) => unawaited(pause())),
      );
    } on Exception {
      // Oturum yapılandırılamazsa oynatma yine denenir — crash yok.
    }
  }

  Future<void> _startSession(
    QuranAudioSessionRequest request,
    QuranAudioPlaybackMode mode,
  ) async {
    final generation = ++_generation;
    _request = request;
    _mode = mode;
    _activeVerse = request.startVerseNumber;
    _completedVerse = null;
    // Yükleme durumu senkron yayınlanır — çağıran anında yansıtabilir.
    _emit(_sessionState(QuranVerseAudioStatus.loading));
    try {
      await _player.stop();
      if (generation != _generation) {
        return;
      }
      // Aynı surenin MP3'ü zaten yüklüyse yeniden İNDİRİLMEZ.
      if (_loadedAudioUrl != request.recitation.audioUrl) {
        await _player.setUrl(request.recitation.audioUrl);
        if (generation != _generation) {
          return;
        }
        _loadedAudioUrl = request.recitation.audioUrl;
      }
      await _playClip(request.startVerseNumber, generation);
    } on Exception {
      if (generation == _generation) {
        _failSession();
      }
    }
  }

  /// Yüklü MP3 içinde tek ayet clip'ini başlatır. Hatası oturumu sakin
  /// biçimde sonlandırır — asla fırlatmaz.
  Future<void> _playClip(int verseNumber, int generation) async {
    final request = _request;
    final timing = request?.recitation.timingFor(verseNumber);
    if (request == null || timing == null) {
      return;
    }
    _activeVerse = verseNumber;
    _completedVerse = null;
    _publishMediaItem(request, timing);
    _emit(_sessionState(QuranVerseAudioStatus.loading));
    try {
      await _player.setClip(start: timing.start, end: timing.end);
      if (generation != _generation) {
        return;
      }
      await _player.seek(Duration.zero);
      if (generation != _generation) {
        return;
      }
      unawaited(_playQuietly());
    } on Exception {
      if (generation == _generation) {
        _failSession();
      }
    }
  }

  Future<void> _skipTo(int delta) async {
    final verse = _activeVerse;
    final target = verse == null ? null : verse + delta;
    if (target == null || _request?.recitation.timingFor(target) == null) {
      return; // sınır dışı — ilk ayette önceki, son ayette sonraki yok
    }
    await _playClip(target, ++_generation);
  }

  void _onPlayerState(PlayerState playerState) {
    if (_request == null || _activeVerse == null) {
      return; // oturum yok — stop/hata akışı kendi durumunu yayınladı
    }
    switch (playerState.processingState) {
      case ProcessingState.loading || ProcessingState.buffering:
        _emit(_sessionState(QuranVerseAudioStatus.loading));
      case ProcessingState.ready:
        _sourceReady = true;
        _emit(
          _sessionState(
            playerState.playing
                ? QuranVerseAudioStatus.playing
                : QuranVerseAudioStatus.paused,
          ),
        );
      case ProcessingState.completed:
        _onClipCompleted();
      case ProcessingState.idle:
        break; // stop/hata geçişleri kendi bildirimlerini yayınlar
    }
    _broadcastSystemState();
  }

  /// Clip bitti: kesintisiz modda sonraki ayete geçilir (arka planda da);
  /// tek ayet modunda veya son ayette oturum tamamen sonlanır — foreground
  /// service boşta KALMAZ.
  void _onClipCompleted() {
    final verse = _activeVerse;
    if (verse == null || _completedVerse == verse) {
      return; // aynı clip için yinelenen completed olayı
    }
    _completedVerse = verse;
    final next = verse + 1;
    if (_mode == QuranAudioPlaybackMode.continuousChapter &&
        _request?.recitation.timingFor(next) != null) {
      unawaited(_playClip(next, _generation));
    } else {
      unawaited(stop());
    }
  }

  /// Kalıcı oynatma hatası: bildirim/oturum temizlenir, reader'a yalnız
  /// sakin ses hatası yansır — Arapça, meal ve bookmark etkilenmez.
  void _failSession() {
    final request = _request;
    if (request == null) {
      return;
    }
    _generation++;
    final chapterFailed = _mode == QuranAudioPlaybackMode.continuousChapter;
    final failedKey =
        '${request.recitation.chapterId}:'
        '${_activeVerse ?? request.startVerseNumber}';
    _clearSession();
    _emit(
      QuranVerseAudioState(
        activeChapterId: request.recitation.chapterId,
        activeChapterName: request.display.chapterDisplayName,
        status: QuranVerseAudioStatus.error,
        errorVerseKey: chapterFailed ? null : failedKey,
        chapterAudioFailed: chapterFailed,
        sourceReady: _sourceReady,
      ),
    );
    unawaited(_stopPlayerQuietly());
  }

  /// Oturum bağlamını ve sistem media session'ını temizler:
  /// processingState=idle + playing=false, audio_service'in foreground
  /// service'i/bildirimi kapatmasını sağlar.
  void _clearSession() {
    _request = null;
    _mode = null;
    _activeVerse = null;
    _completedVerse = null;
    mediaItem.add(null);
    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
        controls: const [],
        systemActions: const {},
        updatePosition: Duration.zero,
      ),
    );
  }

  Future<void> _playQuietly() async {
    try {
      await _player.play();
    } on Exception {
      // Hata playbackEventStream üzerinden _failSession'a düşer.
    }
  }

  Future<void> _stopPlayerQuietly() async {
    try {
      await _player.stop();
    } on Exception {
      // Oturum zaten sonlandırıldı — durdurma hatası yutulur.
    }
  }

  QuranVerseAudioState _sessionState(QuranVerseAudioStatus status) {
    final request = _request!;
    final verse = _activeVerse!;
    return QuranVerseAudioState(
      activeChapterId: request.recitation.chapterId,
      activeChapterName: request.display.chapterDisplayName,
      activeReciterName: request.display.reciterName,
      activeVerseKey: '${request.recitation.chapterId}:$verse',
      activeVerseNumber: verse,
      playbackMode: _mode,
      status: status,
      sourceReady: _sourceReady,
      totalVerseCount: request.totalVerseCount,
    );
  }

  void _emit(QuranVerseAudioState state) {
    _current = state;
    _stateController.add(state);
  }

  /// Her aktif ayette sistem MediaItem'ı: doğrulanmış sure adı + "Ayet
  /// X / Y" + kâri künyesi. Arapça ayet/meal metni, audio URL veya
  /// kullanıcı verisi bildirime KONMAZ (TASK 045 §7).
  void _publishMediaItem(
    QuranAudioSessionRequest request,
    QuranVerseTiming timing,
  ) {
    final display = request.display;
    mediaItem.add(
      MediaItem(
        id:
            'quran:read${request.recitation.source.readId}:'
            '${request.recitation.chapterId}:${timing.verseNumber}',
        title:
            '${display.chapterDisplayName} · '
            '${display.verseOfLabel(timing.verseNumber, request.totalVerseCount)}',
        artist: '${display.reciterName} · ${display.rewayaName}',
        album: display.albumName,
        duration: timing.end - timing.start,
      ),
    );
  }

  /// just_audio durumunu sistem PlaybackState'ine eşler. Kontroller
  /// gerçek işlevlerdir: tek ayette önceki/sonraki YOK, kesintisiz modda
  /// sınırlar dışına düşen yön gizlenir (TASK 045 §8/§9).
  void _broadcastSystemState() {
    final request = _request;
    final verse = _activeVerse;
    if (request == null || verse == null) {
      return; // oturum sonu durumunu _clearSession yayınladı
    }
    final continuous = _mode == QuranAudioPlaybackMode.continuousChapter;
    final controls = <MediaControl>[
      if (continuous && request.recitation.timingFor(verse - 1) != null)
        MediaControl.skipToPrevious,
      if (_player.playing) MediaControl.pause else MediaControl.play,
      if (continuous && request.recitation.timingFor(verse + 1) != null)
        MediaControl.skipToNext,
      MediaControl.stop,
    ];
    playbackState.add(
      playbackState.value.copyWith(
        controls: controls,
        systemActions: const {MediaAction.stop},
        androidCompactActionIndices: [
          for (var i = 0; i < controls.length && i < 3; i++) i,
        ],
        processingState: switch (_player.processingState) {
          ProcessingState.idle => AudioProcessingState.idle,
          ProcessingState.loading => AudioProcessingState.loading,
          ProcessingState.buffering => AudioProcessingState.buffering,
          ProcessingState.ready => AudioProcessingState.ready,
          ProcessingState.completed => AudioProcessingState.completed,
        },
        playing:
            _player.playing &&
            _player.processingState != ProcessingState.idle &&
            _player.processingState != ProcessingState.completed,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ),
    );
  }
}
