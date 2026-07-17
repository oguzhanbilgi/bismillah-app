import 'dart:async';

import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_daily_progress_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reader başına TEK aktif okuma tracker'ı (TASK 047). Reader ekranı
/// açıkken yaşar; dispose'da birikmiş geçerli parça güvenle persist
/// edilir. autoDispose family — sure değişince yeni tracker kurulur.
final quranReadingTrackerProvider = Provider.autoDispose
    .family<QuranReadingTracker, int>((ref, chapterId) {
      final tracker = QuranReadingTracker(
        chapterId: chapterId,
        clock: ref.watch(clockProvider),
        repository: ref.watch(quranDailyProgressRepositoryProvider),
      );
      tracker.start();
      ref.onDispose(tracker.dispose);
      return tracker;
    });

/// Gerçek aktif okuma süresi + anlamlı ayet/sayfa görüntüleme takibi
/// (TASK 047).
///
/// Süre YALNIZ şu koşulların tamamında ilerler: reader görünür (sekme/
/// route), uygulama resumed, son kullanıcı etkileşiminden en fazla 90 sn
/// geçmiş. Arka plan ses oynatımı, kilitli ekran veya başka sekme süre
/// SAYMAZ. Zaman ~12 sn'lik heartbeat parçalarıyla toplanır; tek parçada
/// beklenmeyen büyük süre eklenmez, background dönüşünde aradaki zaman
/// EKLENMEZ. Disk yazımı toplu/debounced'tır (~45 sn'de bir + flush
/// anları) — her saniye yazılmaz, UI rebuild tetiklenmez (Notifier
/// DEĞİLDİR). Persist hatasında birikmiş parça korunur ve sonraki
/// flush'ta yeniden denenir; reader/Arapça/meal/ses ETKİLENMEZ.
final class QuranReadingTracker {
  QuranReadingTracker({
    required this.chapterId,
    required this._clock,
    required this._repository,
  });

  static const Duration heartbeat = Duration(seconds: 12);
  static const Duration idleLimit = Duration(seconds: 90);

  /// Tek heartbeat parçasında sayılabilecek azami süre (timer gecikmesi
  /// toleransı; büyük sıçramalar kırpılır).
  static const Duration maxSegment = Duration(seconds: 18);
  static const Duration persistEvery = Duration(seconds: 45);
  static const Duration verseDwell = Duration(seconds: 3);
  static const Duration pageDwell = Duration(seconds: 8);

  final int chapterId;
  final AppClock _clock;
  final QuranDailyProgressRepository _repository;

  Timer? _timer;
  bool _disposed = false;
  bool _screenVisible = true;
  bool _appResumed = true;

  late DateTime _lastInteractionAt;
  late DateTime _lastTickAt;
  DateTime _lastPersistAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// Persist bekleyen birikimler (persist başarısızsa korunur).
  int _pendingSeconds = 0;
  final Set<String> _pendingVerseKeys = {};
  final Set<int> _pendingPageNumbers = {};
  bool _pendingPosition = false;
  bool _flushInFlight = false;

  /// Oturum içinde zaten işaretlenenler — aynı ayet/sayfa için tekrar
  /// tekrar persist kuyruğu oluşturulmaz (depo zaten UNION yapar).
  final Set<String> _markedVerseKeys = {};
  final Set<int> _markedPageNumbers = {};

  /// Ayet → sayfa eşlemesi reader tarafından sağlanır (doğrulanmış
  /// asset'ten); yoksa yalnız sayfa işaretleme atlanır.
  Map<String, int> _versePages = const {};

  String? _primaryVerseKey;
  DateTime? _primaryVerseSince;
  int? _primaryPage;
  DateTime? _primaryPageSince;

  void start() {
    final now = _clock.nowUtc();
    _lastInteractionAt = now;
    _lastTickAt = now;
    _lastPersistAt = now;
    _timer = Timer.periodic(heartbeat, (_) => _onTick());
  }

  /// Doğrulanmış `verseKey → pageNumber` eşlemesini bağlar (asenkron
  /// yüklendiği için sonradan gelir). Eşleme yoksa sayfa takibi kapalı
  /// kalır — sahte sayfa ilerlemesi üretilmez.
  void attachVersePages(Map<String, int> versePages) {
    _versePages = versePages;
  }

  /// Kullanıcı etkileşimi (dokunma/scroll/ayar/bookmark/ses): idle
  /// sayacını yeniler.
  void noteInteraction() {
    if (_disposed) {
      return;
    }
    _lastInteractionAt = _clock.nowUtc();
  }

  /// Reader route/sekme görünürlüğü (shell sekme geçişi dahil).
  void setScreenVisible(bool visible) => _setActivityGate(
    () => _screenVisible = visible,
    becameInactive: !visible && _screenVisible,
  );

  /// Uygulama lifecycle'ı: resumed dışında süre HEMEN duraklar.
  void setAppResumed(bool resumed) => _setActivityGate(
    () => _appResumed = resumed,
    becameInactive: !resumed && _appResumed,
  );

  /// Reader'ın birincil (okuma bandındaki) ayeti değişti. Dwell süreleri
  /// yalnız aktifken işler; hızlı scroll'da eşikler dolmaz.
  void reportPrimaryVerse(String verseKey) {
    if (_disposed) {
      return;
    }
    _evaluateDwell();
    final now = _clock.nowUtc();
    if (_primaryVerseKey != verseKey) {
      _primaryVerseKey = verseKey;
      _primaryVerseSince = now;
      _pendingPosition = true;
    }
    final page = _versePages[verseKey];
    if (page != _primaryPage) {
      _primaryPage = page;
      _primaryPageSince = page == null ? null : now;
    }
  }

  /// Dispose: birikmiş geçerli parça + bekleyen işaretler persist edilir;
  /// global ses servisine DOKUNULMAZ.
  void dispose() {
    if (_disposed) {
      return;
    }
    _accrueActiveTime();
    _evaluateDwell();
    _disposed = true;
    _timer?.cancel();
    unawaited(_flush());
  }

  bool get _isActive =>
      _screenVisible &&
      _appResumed &&
      _clock.nowUtc().difference(_lastInteractionAt) <= idleLimit;

  void _setActivityGate(void Function() apply, {required bool becameInactive}) {
    if (_disposed) {
      return;
    }
    if (becameInactive) {
      // Duraklamadan ÖNCE o ana kadarki geçerli parça toplanır ve
      // persist edilir; dwell zamanlayıcıları sıfırlanır.
      _accrueActiveTime();
      _evaluateDwell();
      apply();
      _primaryVerseSince = null;
      _primaryPageSince = null;
      unawaited(_flush());
      return;
    }
    apply();
    // Aktifliğe dönüş: aradaki (background/kilit) zaman SAYILMAZ.
    final now = _clock.nowUtc();
    _lastTickAt = now;
    _lastInteractionAt = now;
    if (_primaryVerseKey != null) {
      _primaryVerseSince = now;
    }
    if (_primaryPage != null) {
      _primaryPageSince = now;
    }
  }

  void _onTick() {
    if (_disposed) {
      return;
    }
    _accrueActiveTime();
    _evaluateDwell();
    if (_clock.nowUtc().difference(_lastPersistAt) >= persistEvery) {
      unawaited(_flush());
    }
  }

  /// Son tick'ten bu yana geçen süreyi — yalnız aktifse ve tek parça
  /// sınırını aşmadan — biriktirir.
  void _accrueActiveTime() {
    final now = _clock.nowUtc();
    final elapsed = now.difference(_lastTickAt);
    _lastTickAt = now;
    if (!_isActive || elapsed.isNegative) {
      return;
    }
    final clamped = elapsed > maxSegment ? maxSegment : elapsed;
    _pendingSeconds += clamped.inSeconds;
  }

  /// Birincil ayet/sayfa yeterince uzun süre aktif kaldıysa o gün için
  /// bir kez işaretlenir.
  void _evaluateDwell() {
    if (!_isActive) {
      return;
    }
    final now = _clock.nowUtc();
    final verse = _primaryVerseKey;
    final verseSince = _primaryVerseSince;
    if (verse != null &&
        verseSince != null &&
        now.difference(verseSince) >= verseDwell &&
        _markedVerseKeys.add(verse)) {
      _pendingVerseKeys.add(verse);
    }
    final page = _primaryPage;
    final pageSince = _primaryPageSince;
    if (page != null &&
        pageSince != null &&
        now.difference(pageSince) >= pageDwell &&
        _markedPageNumbers.add(page)) {
      _pendingPageNumbers.add(page);
    }
  }

  Future<void> _flush() async {
    if (_flushInFlight) {
      return;
    }
    final seconds = _pendingSeconds;
    final verses = Set<String>.of(_pendingVerseKeys);
    final pages = Set<int>.of(_pendingPageNumbers);
    final includePosition = _pendingPosition && _primaryVerseKey != null;
    if (seconds == 0 && verses.isEmpty && pages.isEmpty && !includePosition) {
      _lastPersistAt = _clock.nowUtc();
      return;
    }
    _flushInFlight = true;
    try {
      final result = await _repository.recordReadingActivity(
        activeSeconds: seconds,
        viewedVerseKeys: verses,
        viewedPageNumbers: pages,
        lastChapterId: includePosition ? chapterId : null,
        lastVerseKey: includePosition ? _primaryVerseKey : null,
      );
      result.fold(
        onSuccess: (_) {
          _pendingSeconds -= seconds;
          _pendingVerseKeys.removeAll(verses);
          _pendingPageNumbers.removeAll(pages);
          if (includePosition) {
            _pendingPosition = false;
          }
        },
        // Persist hatası sessiz kalır: birikim korunur, sonraki flush
        // yeniden dener; okuma deneyimi kesintiye uğramaz.
        onFailure: (_) {},
      );
    } finally {
      _flushInFlight = false;
      _lastPersistAt = _clock.nowUtc();
    }
  }
}
