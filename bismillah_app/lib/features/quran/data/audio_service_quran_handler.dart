import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:bismillah_app/features/quran/data/just_audio_quran_queue_player.dart';
import 'package:bismillah_app/features/quran/data/unavailable_quran_audio_session_service.dart';
import 'package:bismillah_app/features/quran/domain/services/quran_audio_queue.dart';
import 'package:bismillah_app/features/quran/domain/services/quran_audio_queue_player.dart';
import 'package:bismillah_app/features/quran/domain/services/quran_audio_session_service.dart';

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

/// Global Kur'an ses oturumu handler'ı (TASK 045; sıra modeli TASK 095A).
///
/// Uygulama süresince TEK handler ve TEK oynatıcı yaşar — reader başına
/// player OLUŞTURULMAZ. Kesintisiz modda ayet ilerletme, sistem
/// bildirimi/kilit ekranı kontrolleri ve ses odağı yönetimi tamamen bu
/// sınıftadır; reader kapansa da oynatma sürer. Ses oturumu konuşma
/// odaklıdır; arama/odak kaybı/kulaklık çıkarma duraklatır — interruption
/// dinleyicisi YALNIZ burada kurulur (ikinci katman yok).
///
/// ## TASK 095A — sıra modeli
///
/// Oturum başlarken **tüm ayet sırası bir kez** hazırlanır
/// ([QuranAudioQueue]) ve oynatıcıya tek çağrıda verilir. Ayet geçişinde
/// handler hiçbir yükleme yapmaz: aktif ayet, oynatıcının bildirdiği sıra
/// konumundan TÜRETİLİR. Böylece ayetler arasındaki uygulama kaynaklı
/// bekleme ortadan kalkar.
final class AudioServiceQuranHandler extends BaseAudioHandler
    implements QuranAudioSessionService {
  AudioServiceQuranHandler({
    QuranAudioQueuePlayer? player,
    bool configureAudioSession = true,
  }) : _player = player ?? JustAudioQuranQueuePlayer() {
    if (configureAudioSession) {
      unawaited(_configureSession());
    }
    _subscriptions.add(_player.snapshots.listen(_onSnapshot));
    // Oynatma sırasındaki platform hatası (ör. ağ kopması): bildirim
    // sonsuza dek loading KALMAZ, foreground service kapanır.
    _subscriptions.add(_player.errors.listen((_) => _failSession()));
  }

  final QuranAudioQueuePlayer _player;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  final StreamController<QuranVerseAudioState> _stateController =
      StreamController<QuranVerseAudioState>.broadcast();

  QuranVerseAudioState _current = const QuranVerseAudioState();
  QuranAudioSessionRequest? _request;
  QuranAudioPlaybackMode? _mode;
  QuranAudioQueue? _queue;
  int? _activeVerse;
  bool _sourceReady = false;

  /// Komut jetonu: her yeni oynat/durdur komutu artırır; eski async
  /// işlemler await sonrası jetonu doğrular — hızlı komutlarda iki paralel
  /// hazırlama oluşmaz, eski işlem yeni isteğin durumunu EZMEZ.
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
    // play() future'ı parça bitene dek tamamlanmayabilir — durum oynatıcı
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

  /// Oturumu başlatır: sıra BİR KEZ kurulur, ardından oynatma başlar.
  ///
  /// Tek ayet modunda sıra tek parçadır, dolayısıyla oynatıcı sonraki
  /// ayete geçemez. Kesintisiz modda sıra surenin tamamıdır ve başlangıç
  /// ayeti sıradaki konumla seçilir — böylece geri gitmek de mümkündür ve
  /// tüm sure önceden hazırlanmış olur.
  Future<void> _startSession(
    QuranAudioSessionRequest request,
    QuranAudioPlaybackMode mode,
  ) async {
    final generation = ++_generation;
    final queue = mode == QuranAudioPlaybackMode.continuousChapter
        ? QuranAudioQueue.forChapter(request.recitation)
        : QuranAudioQueue.forSingleVerse(
            request.recitation,
            request.startVerseNumber,
          );
    final initialIndex = queue.indexOfVerse(request.startVerseNumber);
    _request = request;
    _mode = mode;
    _queue = queue;
    _activeVerse = request.startVerseNumber;
    // Yükleme durumu senkron yayınlanır — çağıran anında yansıtabilir.
    _emit(_sessionState(QuranVerseAudioStatus.loading));
    if (queue.isEmpty || initialIndex == null) {
      _failSession();
      return;
    }
    try {
      await _player.setQueue(queue.clips, initialIndex: initialIndex);
      if (generation != _generation) {
        return;
      }
      _publishMediaItem(request, queue.clips[initialIndex]);
      unawaited(_playQuietly());
    } on Exception {
      if (generation == _generation) {
        _failSession();
      }
    }
  }

  /// Önceki/sonraki ayet: sıra zaten hazır olduğu için yalnız konum
  /// değişir — yeni bir yükleme isteği kurulmaz.
  Future<void> _skipTo(int delta) async {
    final queue = _queue;
    final verse = _activeVerse;
    if (queue == null || verse == null) {
      return;
    }
    final index = queue.indexOfVerse(verse);
    final target = index == null ? null : index + delta;
    if (target == null || queue.verseAt(target) == null) {
      return; // sınır dışı — ilk ayette önceki, son ayette sonraki yok
    }
    try {
      await _player.seekToIndex(target);
    } on Exception {
      // Geçiş hatası oturumu bozmaz — durum akıştan gelir.
    }
  }

  /// Oynatıcının tek durum kaynağı. Aktif ayet burada sıradaki konumdan
  /// TÜRETİLİR; handler ayet geçişinde hiçbir yükleme tetiklemez.
  void _onSnapshot(QuranAudioPlayerSnapshot snapshot) {
    final queue = _queue;
    if (_request == null || queue == null) {
      return; // oturum yok — stop/hata akışı kendi durumunu yayınladı
    }
    final index = snapshot.currentIndex;
    final verse = index == null ? null : queue.verseAt(index);
    if (verse != null && verse != _activeVerse) {
      _activeVerse = verse;
      _publishMediaItem(_request!, queue.clips[index!]);
    }
    if (_activeVerse == null) {
      return;
    }
    switch (snapshot.phase) {
      case QuranAudioPlayerPhase.loading || QuranAudioPlayerPhase.buffering:
        _emit(_sessionState(QuranVerseAudioStatus.loading));
      case QuranAudioPlayerPhase.ready:
        _sourceReady = true;
        _emit(
          _sessionState(
            snapshot.playing
                ? QuranVerseAudioStatus.playing
                : QuranVerseAudioStatus.paused,
          ),
        );
      case QuranAudioPlayerPhase.completed:
        // Sıranın SONU: tek ayet modunda tek parça bitmiştir, kesintisiz
        // modda sure bitmiştir. Ara geçişler burada görünmez — onları
        // oynatıcı kendi içinde yapar.
        unawaited(stop());
        return;
      case QuranAudioPlayerPhase.idle:
        break; // stop/hata geçişleri kendi bildirimlerini yayınlar
    }
    _broadcastSystemState(snapshot);
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
    _queue = null;
    _activeVerse = null;
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
      // Hata errors akışı üzerinden _failSession'a düşer.
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
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  /// Her aktif ayette sistem MediaItem'ı: doğrulanmış sure adı + "Ayet
  /// X / Y" + kâri künyesi. Arapça ayet/meal metni, audio URL veya
  /// kullanıcı verisi bildirime KONMAZ (TASK 045 §7).
  void _publishMediaItem(
    QuranAudioSessionRequest request,
    QuranAudioClip clip,
  ) {
    final display = request.display;
    mediaItem.add(
      MediaItem(
        id:
            'quran:read${request.recitation.source.readId}:'
            '${request.recitation.chapterId}:${clip.verseNumber}',
        title:
            '${display.chapterDisplayName} · '
            '${display.verseOfLabel(clip.verseNumber, request.totalVerseCount)}',
        artist: '${display.reciterName} · ${display.rewayaName}',
        album: display.albumName,
        duration: clip.duration,
      ),
    );
  }

  /// Oynatıcı durumunu sistem PlaybackState'ine eşler. Kontroller gerçek
  /// işlevlerdir: tek ayette önceki/sonraki YOK, kesintisiz modda sınırlar
  /// dışına düşen yön gizlenir (TASK 045 §8/§9).
  void _broadcastSystemState(QuranAudioPlayerSnapshot snapshot) {
    final request = _request;
    final queue = _queue;
    final verse = _activeVerse;
    if (request == null || queue == null || verse == null) {
      return; // oturum sonu durumunu _clearSession yayınladı
    }
    final index = queue.indexOfVerse(verse);
    final continuous = _mode == QuranAudioPlaybackMode.continuousChapter;
    final controls = <MediaControl>[
      if (continuous && index != null && queue.verseAt(index - 1) != null)
        MediaControl.skipToPrevious,
      if (snapshot.playing) MediaControl.pause else MediaControl.play,
      if (continuous && index != null && queue.verseAt(index + 1) != null)
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
        processingState: switch (snapshot.phase) {
          QuranAudioPlayerPhase.idle => AudioProcessingState.idle,
          QuranAudioPlayerPhase.loading => AudioProcessingState.loading,
          QuranAudioPlayerPhase.buffering => AudioProcessingState.buffering,
          QuranAudioPlayerPhase.ready => AudioProcessingState.ready,
          QuranAudioPlayerPhase.completed => AudioProcessingState.completed,
        },
        playing:
            snapshot.playing &&
            snapshot.phase != QuranAudioPlayerPhase.idle &&
            snapshot.phase != QuranAudioPlayerPhase.completed,
        updatePosition: snapshot.position,
        bufferedPosition: snapshot.bufferedPosition,
        speed: snapshot.speed,
      ),
    );
  }
}
