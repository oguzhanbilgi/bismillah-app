import 'dart:async';

import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/quran/application/quran_verse_audio_controller.dart';
import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter_recitation.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_verse.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_audio_repository.dart';
import 'package:bismillah_app/features/quran/domain/services/quran_audio_session_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 041/042/045 ses controller'ı: controller player SAHİBİ DEĞİLDİR —
/// global oturum servisini kullanır. Fake servis, gerçek handler'ın durum
/// davranışını (oynat/duraklat/ilerlet/durdur) bellekte taklit eder;
/// GERÇEK ses/HTTP/platform kanalı YOKTUR.
final class _FakeSessionService implements QuranAudioSessionService {
  final _stateController = StreamController<QuranVerseAudioState>.broadcast();
  final List<String> log = [];

  QuranVerseAudioState _current = const QuranVerseAudioState();
  QuranAudioSessionRequest? _request;
  QuranAudioPlaybackMode? _mode;
  int? _activeVerse;
  bool _sourceReady = false;

  bool get sessionActive => _request != null;

  void _emit(QuranVerseAudioState state) {
    _current = state;
    _stateController.add(state);
  }

  QuranVerseAudioState _sessionState(QuranVerseAudioStatus status) {
    final request = _request!;
    return QuranVerseAudioState(
      activeChapterId: request.recitation.chapterId,
      activeVerseKey: '${request.recitation.chapterId}:$_activeVerse',
      activeVerseNumber: _activeVerse,
      playbackMode: _mode,
      status: status,
      sourceReady: _sourceReady,
      totalVerseCount: request.totalVerseCount,
    );
  }

  void _start(
    QuranAudioSessionRequest request,
    QuranAudioPlaybackMode mode,
    String label,
  ) {
    log.add('$label:${request.recitation.chapterId}'
        ':${request.startVerseNumber}');
    _request = request;
    _mode = mode;
    _activeVerse = request.startVerseNumber;
    _sourceReady = true;
    _emit(_sessionState(QuranVerseAudioStatus.playing));
  }

  /// Clip tamamlandı simülasyonu — gerçek handler'daki otomatik ilerleme:
  /// kesintisiz modda sonraki ayet, aksi halde oturum sonu.
  void completeClip() {
    final verse = _activeVerse;
    final request = _request;
    if (verse == null || request == null) {
      return;
    }
    final next = verse + 1;
    if (_mode == QuranAudioPlaybackMode.continuousChapter &&
        request.recitation.timingFor(next) != null) {
      _activeVerse = next;
      _emit(_sessionState(QuranVerseAudioStatus.playing));
    } else {
      _request = null;
      _activeVerse = null;
      _mode = null;
      _emit(QuranVerseAudioState(sourceReady: _sourceReady));
    }
  }

  @override
  QuranVerseAudioState get currentState => _current;

  @override
  Stream<QuranVerseAudioState> watchState() => _stateController.stream;

  @override
  Future<void> playSingleVerse(QuranAudioSessionRequest request) async {
    _start(request, QuranAudioPlaybackMode.singleVerse, 'single');
  }

  @override
  Future<void> playContinuousChapter(QuranAudioSessionRequest request) async {
    _start(request, QuranAudioPlaybackMode.continuousChapter, 'chapter');
  }

  @override
  Future<void> pause() async {
    log.add('pause');
    if (_request != null) {
      _emit(_sessionState(QuranVerseAudioStatus.paused));
    }
  }

  @override
  Future<void> resume() async {
    log.add('resume');
    if (_request != null) {
      _emit(_sessionState(QuranVerseAudioStatus.playing));
    }
  }

  @override
  Future<void> stop() async {
    log.add('stop');
    _request = null;
    _activeVerse = null;
    _mode = null;
    _emit(QuranVerseAudioState(sourceReady: _sourceReady));
  }

  Future<void> _skip(int delta) async {
    final verse = _activeVerse;
    final target = verse == null ? null : verse + delta;
    if (target == null || _request?.recitation.timingFor(target) == null) {
      return;
    }
    _activeVerse = target;
    _emit(_sessionState(QuranVerseAudioStatus.playing));
  }

  @override
  Future<void> skipToPrevious() => _skip(-1);

  @override
  Future<void> skipToNext() => _skip(1);
}

final class _FakeAudioRepository implements QuranAudioRepository {
  bool fail = false;
  int loadCount = 0;
  final List<int> invalidated = [];

  @override
  ResultFuture<QuranChapterRecitation> getChapterRecitation(
    int chapterId,
    int expectedVerseCount,
  ) async {
    loadCount++;
    if (fail) {
      return const Result.failure(NetworkFailure());
    }
    final source = QuranRecitationSource(
      readId: 5,
      reciterName: 'x',
      rewayaName: 'y',
      folderUrl: 'https://server10.mp3quran.net/ajm/',
      chapterCount: 114,
    );
    return Result.success(
      QuranChapterRecitation(
        chapterId: chapterId,
        audioUrl:
            'https://server10.mp3quran.net/ajm/'
            '${chapterId.toString().padLeft(3, '0')}.mp3',
        source: source,
        verseTimings: [
          for (var i = 1; i <= expectedVerseCount; i++)
            QuranVerseTiming(
              chapterId: chapterId,
              verseNumber: i,
              start: Duration(seconds: i),
              end: Duration(seconds: i + 1),
            ),
        ],
      ),
    );
  }

  @override
  void invalidateChapter(int chapterId) => invalidated.add(chapterId);
}

QuranVerse verse(int number) => QuranVerse(
  chapterId: 1,
  verseNumber: number,
  verseKey: '1:$number',
  textUthmani: 'نص',
);

const _display = QuranAudioDisplayInfo(
  chapterDisplayName: 'Fâtiha Suresi',
  reciterName: 'x',
  rewayaName: 'y',
  albumName: 'Bismillah',
  verseOfLabel: _verseOf,
);

String _verseOf(int current, int total) => 'Ayet $current / $total';

void main() {
  late _FakeSessionService service;
  late _FakeAudioRepository repository;
  late ProviderContainer container;

  QuranVerseAudioState state() =>
      container.read(quranVerseAudioControllerProvider);
  QuranVerseAudioController controller() =>
      container.read(quranVerseAudioControllerProvider.notifier);

  setUp(() {
    service = _FakeSessionService();
    repository = _FakeAudioRepository();
    container = ProviderContainer(
      overrides: [
        quranAudioSessionServiceProvider.overrideWithValue(service),
        quranAudioRepositoryProvider.overrideWithValue(repository),
      ],
    );
    final subscription = container.listen(
      quranVerseAudioControllerProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);
  });

  test('tek ayet: yükle+oynat → duraklat → devam et', () async {
    await controller().toggleVerse(
      verse(3),
      expectedVerseCount: 7,
      display: _display,
    );
    expect(state().status, QuranVerseAudioStatus.playing);
    expect(state().activeVerseKey, '1:3');
    expect(state().playbackMode, QuranAudioPlaybackMode.singleVerse);
    // Yeni istek önce mevcut oturumu durdurur, sonra tek ayeti başlatır.
    expect(service.log, ['stop', 'single:1:3']);

    await controller().toggleVerse(
      verse(3),
      expectedVerseCount: 7,
      display: _display,
    );
    expect(state().status, QuranVerseAudioStatus.paused);

    await controller().toggleVerse(
      verse(3),
      expectedVerseCount: 7,
      display: _display,
    );
    expect(state().status, QuranVerseAudioStatus.playing);
    expect(service.log.last, 'resume');
  });

  test('başka ayet seçilince önceki durur ve yeni ayet başlar', () async {
    await controller().toggleVerse(
      verse(1),
      expectedVerseCount: 7,
      display: _display,
    );
    await controller().toggleVerse(
      verse(5),
      expectedVerseCount: 7,
      display: _display,
    );
    expect(state().activeVerseKey, '1:5');
    expect(service.log.last, 'single:1:5');
  });

  test('singleVerse bitince otomatik SONRAKİ ayete geçilmez', () async {
    await controller().toggleVerse(
      verse(2),
      expectedVerseCount: 7,
      display: _display,
    );
    service.completeClip();
    await pumpEventQueue();
    expect(state().status, QuranVerseAudioStatus.idle);
    expect(state().activeVerseKey, isNull);
  });

  test('continuousChapter: 1. ayetten başlar, completed ile ilerler, '
      'son ayette durur', () async {
    await controller().playChapter(
      chapterId: 1,
      expectedVerseCount: 3,
      display: _display,
    );
    expect(state().activeVerseNumber, 1);
    expect(state().playbackMode, QuranAudioPlaybackMode.continuousChapter);

    service.completeClip();
    await pumpEventQueue();
    expect(state().activeVerseNumber, 2);
    expect(state().status, QuranVerseAudioStatus.playing);

    service.completeClip();
    await pumpEventQueue();
    expect(state().activeVerseNumber, 3);

    service.completeClip();
    await pumpEventQueue();
    expect(state().status, QuranVerseAudioStatus.idle);
    expect(state().activeVerseKey, isNull);
  });

  test('önceki/sonraki sınırları', () async {
    await controller().playChapter(
      chapterId: 1,
      expectedVerseCount: 3,
      display: _display,
    );
    expect(state().hasPrevious, isFalse); // ilk ayette önceki pasif
    expect(state().hasNext, isTrue);

    await controller().skipToAdjacentVerse(forward: true);
    await pumpEventQueue();
    expect(state().activeVerseNumber, 2);

    await controller().skipToAdjacentVerse(forward: true);
    await pumpEventQueue();
    expect(state().activeVerseNumber, 3);
    expect(state().hasNext, isFalse); // son ayette sonraki pasif

    await controller().skipToAdjacentVerse(forward: true); // yok sayılır
    await pumpEventQueue();
    expect(state().activeVerseNumber, 3);

    await controller().skipToAdjacentVerse(forward: false);
    await pumpEventQueue();
    expect(state().activeVerseNumber, 2);
  });

  test('hızlı art arda dokunuşlar çift yükleme/oynatma üretmez', () async {
    final first = controller().toggleVerse(
      verse(1),
      expectedVerseCount: 7,
      display: _display,
    );
    final second = controller().toggleVerse(
      verse(2),
      expectedVerseCount: 7,
      display: _display,
    );
    await Future.wait([first, second]);
    expect(repository.loadCount, 1);
    expect(
      service.log.where((entry) => entry.startsWith('single:')).length,
      1,
    );
  });

  test('hata: ayet hatası yalnız o ayette, sure hatası panelde', () async {
    repository.fail = true;
    await controller().toggleVerse(
      verse(4),
      expectedVerseCount: 7,
      display: _display,
    );
    expect(state().status, QuranVerseAudioStatus.error);
    expect(state().errorVerseKey, '1:4');
    expect(state().activeChapterId, 1);
    expect(state().chapterAudioFailed, isFalse);

    await controller().playChapter(
      chapterId: 1,
      expectedVerseCount: 7,
      display: _display,
    );
    expect(state().chapterAudioFailed, isTrue);

    // Retry cache'i düşürür ve başarılı olur.
    repository.fail = false;
    await controller().retryChapter(
      chapterId: 1,
      expectedVerseCount: 7,
      display: _display,
    );
    expect(repository.invalidated, [1]);
    expect(state().status, QuranVerseAudioStatus.playing);
  });

  test('reader kapanınca global oturum DURMAZ; yeni controller devam eden '
      'durumu yansıtır', () async {
    await controller().toggleVerse(
      verse(1),
      expectedVerseCount: 7,
      display: _display,
    );
    final stopsBefore = service.log.where((e) => e == 'stop').length;

    // Reader'ın kapanması: controller aboneliği düşer (autoDispose).
    container.dispose();
    await pumpEventQueue();
    expect(service.sessionActive, isTrue); // ses sürer
    expect(service.log.where((e) => e == 'stop').length, stopsBefore);

    // Aynı sure tekrar açıldığında durum servisten geri gelir.
    final reopened = ProviderContainer(
      overrides: [
        quranAudioSessionServiceProvider.overrideWithValue(service),
        quranAudioRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(reopened.dispose);
    final resumedState = reopened.read(quranVerseAudioControllerProvider);
    expect(resumedState.status, QuranVerseAudioStatus.playing);
    expect(resumedState.activeVerseKey, '1:1');
  });

  test('stopPlayback oturumu tamamen sonlandırır', () async {
    await controller().playChapter(
      chapterId: 1,
      expectedVerseCount: 3,
      display: _display,
    );
    await controller().stopPlayback();
    expect(state().status, QuranVerseAudioStatus.idle);
    expect(service.sessionActive, isFalse);
  });
}
