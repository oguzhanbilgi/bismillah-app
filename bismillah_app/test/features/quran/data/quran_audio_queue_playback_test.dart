import 'dart:async';

import 'package:bismillah_app/features/quran/data/audio_service_quran_handler.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter_recitation.dart';
import 'package:bismillah_app/features/quran/domain/services/quran_audio_queue.dart';
import 'package:bismillah_app/features/quran/domain/services/quran_audio_queue_player.dart';
import 'package:bismillah_app/features/quran/domain/services/quran_audio_session_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 095A — sıra tabanlı oynatma.
///
/// Gerçek ağ veya platform zamanlaması BURADA ölçülmez: oynatıcı
/// belirlenimci bir sahte ile doldurulur. Ölçülen şey, handler'ın ayet
/// geçişinde **hiçbir yükleme işi yapmamasıdır** — eski akıştaki
/// uygulama kaynaklı gecikmenin kaynağı tam olarak buydu.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final source = QuranRecitationSource(
    readId: 5,
    reciterName: 'Test Reciter',
    rewayaName: 'Hafs',
    folderUrl: 'https://example.com/audio/',
    chapterCount: 114,
  );

  QuranChapterRecitation recitationOf(int verseCount) => QuranChapterRecitation(
    chapterId: 1,
    audioUrl: 'https://example.com/audio/001.mp3',
    source: source,
    verseTimings: [
      for (var verse = 1; verse <= verseCount; verse++)
        QuranVerseTiming(
          chapterId: 1,
          verseNumber: verse,
          start: Duration(seconds: verse * 10),
          end: Duration(seconds: verse * 10 + 8),
        ),
    ],
  );

  QuranAudioSessionRequest requestOf({
    int verseCount = 5,
    int startVerse = 1,
  }) => QuranAudioSessionRequest(
    recitation: recitationOf(verseCount),
    totalVerseCount: verseCount,
    startVerseNumber: startVerse,
    display: QuranAudioDisplayInfo(
      chapterDisplayName: 'Al-Faatiha',
      reciterName: 'Test Reciter',
      rewayaName: 'Hafs',
      albumName: 'Bismillah',
      verseOfLabel: (current, total) => 'Ayet $current / $total',
    ),
  );

  group('QuranAudioQueue — sıra oynatmadan ÖNCE kurulur', () {
    test('kesintisiz sıra surenin tamamını ayet sırasıyla içerir', () {
      final queue = QuranAudioQueue.forChapter(recitationOf(7));

      expect(queue.length, 7);
      expect(queue.clips.map((c) => c.verseNumber), [1, 2, 3, 4, 5, 6, 7]);
      expect(queue.verseAt(0), 1);
      expect(queue.verseAt(6), 7);
      expect(queue.verseAt(7), isNull);
      expect(queue.indexOfVerse(4), 3);
      expect(queue.indexOfVerse(99), isNull);
    });

    test(
      'timing sırası karışık gelse de sıra ayet numarasına göre dizilir',
      () {
        final recitation = QuranChapterRecitation(
          chapterId: 1,
          audioUrl: 'https://example.com/audio/001.mp3',
          source: source,
          verseTimings: [
            QuranVerseTiming(
              chapterId: 1,
              verseNumber: 3,
              start: const Duration(seconds: 30),
              end: const Duration(seconds: 38),
            ),
            QuranVerseTiming(
              chapterId: 1,
              verseNumber: 1,
              start: const Duration(seconds: 10),
              end: const Duration(seconds: 18),
            ),
            QuranVerseTiming(
              chapterId: 1,
              verseNumber: 2,
              start: const Duration(seconds: 20),
              end: const Duration(seconds: 28),
            ),
          ],
        );

        expect(
          QuranAudioQueue.forChapter(
            recitation,
          ).clips.map((c) => c.verseNumber),
          [1, 2, 3],
        );
      },
    );

    test(
      'parçalar doğrulanmış timing sınırlarını BİREBİR taşır (kırpma yok)',
      () {
        final clip = QuranAudioQueue.forChapter(recitationOf(3)).clips[1];

        expect(clip.start, const Duration(seconds: 20));
        expect(clip.end, const Duration(seconds: 28));
        expect(clip.duration, const Duration(seconds: 8));
        expect(clip.url, 'https://example.com/audio/001.mp3');
      },
    );

    test('kaynak ses içindeki sessizlik NE kırpılır NE doldurulur', () {
      // MP3Quran `ayat_timing` kayıtları olduğu gibi kullanılır. İki ayet
      // arasında kaynakta boşluk varsa (bir ayetin bitişi ile sonrakinin
      // başlangıcı arasındaki fark) uygulama bunu değiştirmez; ayetin
      // kendi aralığındaki sessizliği kısaltmak kıraati kesme riski
      // taşıdığı için de asla yapılmaz. Yani "tam gapless" iddia edilmez.
      final recitation = QuranChapterRecitation(
        chapterId: 1,
        audioUrl: 'https://example.com/audio/001.mp3',
        source: source,
        verseTimings: [
          QuranVerseTiming(
            chapterId: 1,
            verseNumber: 1,
            start: Duration.zero,
            end: const Duration(milliseconds: 5000),
          ),
          QuranVerseTiming(
            chapterId: 1,
            verseNumber: 2,
            // Kaynakta 700 ms'lik bir boşluk var.
            start: const Duration(milliseconds: 5700),
            end: const Duration(milliseconds: 9000),
          ),
        ],
      );

      final clips = QuranAudioQueue.forChapter(recitation).clips;
      expect(clips[0].end, const Duration(milliseconds: 5000));
      expect(clips[1].start, const Duration(milliseconds: 5700));
      expect(
        clips[1].start - clips[0].end,
        const Duration(milliseconds: 700),
        reason: 'kaynaktaki boşluk korunur; uygulama sınırları oynatmaz',
      );
    });

    test('tek ayet sırası tek parçadır — oynatıcı ilerleyemez', () {
      final queue = QuranAudioQueue.forSingleVerse(recitationOf(5), 3);

      expect(queue.length, 1);
      expect(queue.verseAt(0), 3);
      expect(queue.verseAt(1), isNull);
    });

    test('zamanlaması olmayan ayet için sıra boştur', () {
      expect(
        QuranAudioQueue.forSingleVerse(recitationOf(3), 9).isEmpty,
        isTrue,
      );
    });
  });

  group('handler — sıra BİR KEZ kurulur, geçişte yükleme yoktur', () {
    late _FakeQueuePlayer player;
    late AudioServiceQuranHandler handler;

    setUp(() {
      player = _FakeQueuePlayer();
      handler = AudioServiceQuranHandler(
        player: player,
        configureAudioSession: false,
      );
    });

    test('kesintisiz oynatma tüm sureyi tek çağrıda hazırlar', () async {
      await handler.playContinuousChapter(requestOf(verseCount: 5));

      expect(player.setQueueCalls, 1);
      expect(player.lastQueue!.length, 5);
      expect(player.lastInitialIndex, 0);
      expect(player.playCalls, 1);
    });

    test(
      'başlangıç ayeti sıradaki konumla seçilir; sıra yine tüm suredir',
      () async {
        await handler.playContinuousChapter(
          requestOf(verseCount: 5, startVerse: 3),
        );

        expect(player.setQueueCalls, 1);
        expect(player.lastQueue!.length, 5, reason: 'geri gidebilmek için');
        expect(player.lastInitialIndex, 2);
      },
    );

    test(
      'AYET GEÇİŞİ yeni bir sıra kurmaz — gecikme uygulamadan gelmez',
      () async {
        await handler.playContinuousChapter(requestOf(verseCount: 5));
        player.emit(
          index: 0,
          phase: QuranAudioPlayerPhase.ready,
          playing: true,
        );
        await pumpEventQueue();

        // Oynatıcı kendi içinde 2. ayete geçti.
        player.emit(
          index: 1,
          phase: QuranAudioPlayerPhase.ready,
          playing: true,
        );
        await pumpEventQueue();

        expect(
          player.setQueueCalls,
          1,
          reason: 'geçişte ikinci bir hazırlama isteği kurulmamalı',
        );
        expect(player.seekCalls, isEmpty);
        expect(handler.currentState.activeVerseNumber, 2);
        expect(handler.currentState.activeVerseKey, '1:2');
        expect(handler.currentState.status, QuranVerseAudioStatus.playing);
      },
    );

    test(
      'sonraki ayet, mevcut ayet bitmeden ÖNCE sıraya hazırlanmıştır',
      () async {
        await handler.playContinuousChapter(requestOf(verseCount: 4));
        player.emit(
          index: 0,
          phase: QuranAudioPlayerPhase.ready,
          playing: true,
        );
        await pumpEventQueue();

        // 1. ayet daha çalarken sıradaki parça zaten oynatıcıya verilmiştir.
        expect(handler.currentState.activeVerseNumber, 1);
        expect(player.lastQueue!.map((c) => c.verseNumber), [1, 2, 3, 4]);
      },
    );

    test('duraklatma aktif ayeti KORUR, devam aynı ayetten sürer', () async {
      await handler.playContinuousChapter(requestOf(verseCount: 5));
      player.emit(index: 2, phase: QuranAudioPlayerPhase.ready, playing: true);
      await pumpEventQueue();
      expect(handler.currentState.activeVerseNumber, 3);

      await handler.pause();
      player.emit(index: 2, phase: QuranAudioPlayerPhase.ready, playing: false);
      await pumpEventQueue();
      expect(handler.currentState.status, QuranVerseAudioStatus.paused);
      expect(handler.currentState.activeVerseNumber, 3, reason: 'ayet korunur');

      await handler.resume();
      await pumpEventQueue();
      player.emit(index: 2, phase: QuranAudioPlayerPhase.ready, playing: true);
      await pumpEventQueue();
      expect(handler.currentState.status, QuranVerseAudioStatus.playing);
      expect(handler.currentState.activeVerseNumber, 3);
      expect(player.setQueueCalls, 1);
    });

    test('sıranın tamamlanması oturumu ve aktif ayeti temizler', () async {
      await handler.playContinuousChapter(requestOf(verseCount: 3));
      player.emit(index: 2, phase: QuranAudioPlayerPhase.ready, playing: true);
      await pumpEventQueue();

      player.emit(index: 2, phase: QuranAudioPlayerPhase.completed);
      await pumpEventQueue();

      expect(handler.currentState.activeVerseKey, isNull);
      expect(handler.currentState.activeVerseNumber, isNull);
      expect(handler.currentState.status, QuranVerseAudioStatus.idle);
    });

    test(
      'tek ayet oynatma yalnız o ayeti hazırlar ve o ayeti işaretler',
      () async {
        await handler.playSingleVerse(requestOf(verseCount: 6, startVerse: 4));

        expect(player.lastQueue!.map((c) => c.verseNumber), [4]);
        expect(player.lastInitialIndex, 0);

        player.emit(
          index: 0,
          phase: QuranAudioPlayerPhase.ready,
          playing: true,
        );
        await pumpEventQueue();

        expect(handler.currentState.activeVerseKey, '1:4');
        expect(
          handler.currentState.playbackMode,
          QuranAudioPlaybackMode.singleVerse,
        );
      },
    );

    test('önceki/sonraki yalnız sıradaki konumu değiştirir', () async {
      await handler.playContinuousChapter(requestOf(verseCount: 5));
      player.emit(index: 1, phase: QuranAudioPlayerPhase.ready, playing: true);
      await pumpEventQueue();

      await handler.skipToNext();
      expect(player.seekCalls, [2]);
      await handler.skipToPrevious();
      expect(player.seekCalls, [2, 0]);
      expect(
        player.setQueueCalls,
        1,
        reason: 'geçiş yeni yükleme isteği kurmamalı',
      );
    });

    test('sınır dışında geçiş yok sayılır', () async {
      await handler.playContinuousChapter(requestOf(verseCount: 3));
      player.emit(index: 0, phase: QuranAudioPlayerPhase.ready, playing: true);
      await pumpEventQueue();
      await handler.skipToPrevious();
      expect(player.seekCalls, isEmpty);

      player.emit(index: 2, phase: QuranAudioPlayerPhase.ready, playing: true);
      await pumpEventQueue();
      await handler.skipToNext();
      expect(player.seekCalls, isEmpty);
    });

    test('hızlı art arda istekler tek aktif sıra bırakır', () async {
      final first = handler.playContinuousChapter(requestOf(verseCount: 5));
      final second = handler.playContinuousChapter(
        requestOf(verseCount: 5, startVerse: 2),
      );
      await Future.wait([first, second]);

      // Son istek kazanır; eski istek yeni durumu EZMEZ.
      expect(handler.currentState.activeVerseNumber, 2);
      expect(player.lastInitialIndex, 1);
    });

    test('oynatma hatası YANLIŞ ayeti işaretli bırakmaz', () async {
      await handler.playContinuousChapter(requestOf(verseCount: 5));
      player.emit(index: 1, phase: QuranAudioPlayerPhase.ready, playing: true);
      await pumpEventQueue();
      expect(handler.currentState.activeVerseKey, '1:2');

      player.failWith(Exception('network lost'));
      await pumpEventQueue();

      expect(handler.currentState.status, QuranVerseAudioStatus.error);
      expect(
        handler.currentState.activeVerseKey,
        isNull,
        reason: 'hata sonrası hiçbir ayet çalıyor gibi işaretlenmemeli',
      );
      expect(handler.currentState.chapterAudioFailed, isTrue);
    });

    test('hata sonrası gelen geç oynatıcı olayları durumu bozmaz', () async {
      await handler.playContinuousChapter(requestOf(verseCount: 5));
      player.failWith(Exception('network lost'));
      await pumpEventQueue();

      player.emit(index: 3, phase: QuranAudioPlayerPhase.ready, playing: true);
      await pumpEventQueue();

      expect(handler.currentState.status, QuranVerseAudioStatus.error);
      expect(handler.currentState.activeVerseKey, isNull);
    });

    test('durdurma sırayı ve aktif ayeti temizler', () async {
      await handler.playContinuousChapter(requestOf(verseCount: 5));
      player.emit(index: 1, phase: QuranAudioPlayerPhase.ready, playing: true);
      await pumpEventQueue();

      await handler.stop();

      expect(handler.currentState.activeVerseKey, isNull);
      expect(handler.currentState.status, QuranVerseAudioStatus.idle);
      expect(player.stopCalls, greaterThanOrEqualTo(1));
    });
  });
}

/// Belirlenimci sahte oynatıcı — gerçek ses/ağ YOK.
final class _FakeQueuePlayer implements QuranAudioQueuePlayer {
  final StreamController<QuranAudioPlayerSnapshot> _snapshots =
      StreamController<QuranAudioPlayerSnapshot>.broadcast();
  final StreamController<Object> _errors = StreamController<Object>.broadcast();

  int setQueueCalls = 0;
  int playCalls = 0;
  int stopCalls = 0;
  List<QuranAudioClip>? lastQueue;
  int? lastInitialIndex;
  final List<int> seekCalls = [];

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
    setQueueCalls++;
    lastQueue = clips;
    lastInitialIndex = initialIndex;
  }

  @override
  Future<void> play() async => playCalls++;

  @override
  Future<void> pause() async {}

  @override
  Future<void> stop() async => stopCalls++;

  @override
  Future<void> seekToIndex(int index) async => seekCalls.add(index);

  @override
  Future<void> dispose() async {
    await _snapshots.close();
    await _errors.close();
  }

  void emit({
    int? index,
    QuranAudioPlayerPhase phase = QuranAudioPlayerPhase.ready,
    bool playing = false,
  }) {
    _snapshot = QuranAudioPlayerSnapshot(
      phase: phase,
      playing: playing,
      currentIndex: index,
    );
    _snapshots.add(_snapshot);
  }

  void failWith(Object error) => _errors.add(error);
}
