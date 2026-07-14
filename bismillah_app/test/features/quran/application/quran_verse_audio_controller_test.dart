import 'dart:async';

import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/quran/application/quran_verse_audio_controller.dart';
import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter_recitation.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_verse.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_audio_repository.dart';
import 'package:bismillah_app/features/quran/domain/services/quran_verse_audio_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 041/042 ses controller'ı: tek ayet + kesintisiz sure davranışı —
/// GERÇEK ses/HTTP yok, fake player ve repository kullanılır.
final class _FakePlayer implements QuranVerseAudioPlayer {
  final _statusController =
      StreamController<QuranAudioPlaybackStatus>.broadcast();
  final List<String> log = [];
  int loadCount = 0;
  bool disposed = false;

  void emit(QuranAudioPlaybackStatus status) => _statusController.add(status);

  @override
  Future<void> loadChapter({
    required String audioUrl,
    required int chapterId,
  }) async {
    loadCount++;
    log.add('load:$chapterId');
  }

  @override
  Future<void> playVerse(QuranVerseTiming timing) async {
    log.add('play:${timing.verseNumber}');
  }

  @override
  Future<void> pause() async => log.add('pause');

  @override
  Future<void> resume() async => log.add('resume');

  @override
  Future<void> stop() async => log.add('stop');

  @override
  Future<void> dispose() async {
    disposed = true;
    await _statusController.close();
  }

  @override
  Stream<QuranAudioPlaybackStatus> get statusStream => _statusController.stream;
}

final class _FakeAudioRepository implements QuranAudioRepository {
  bool fail = false;
  final List<int> invalidated = [];

  @override
  ResultFuture<QuranChapterRecitation> getChapterRecitation(
    int chapterId,
    int expectedVerseCount,
  ) async {
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

void main() {
  late _FakePlayer player;
  late _FakeAudioRepository repository;
  late ProviderContainer container;

  QuranVerseAudioState state() =>
      container.read(quranVerseAudioControllerProvider);
  QuranVerseAudioController controller() =>
      container.read(quranVerseAudioControllerProvider.notifier);

  setUp(() {
    player = _FakePlayer();
    repository = _FakeAudioRepository();
    container = ProviderContainer(
      overrides: [
        quranVerseAudioPlayerProvider.overrideWith((ref) {
          ref.onDispose(() => unawaited(player.dispose()));
          return player;
        }),
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
    await controller().toggleVerse(verse(3), expectedVerseCount: 7);
    expect(state().status, QuranVerseAudioStatus.playing);
    expect(state().activeVerseKey, '1:3');
    expect(state().playbackMode, QuranAudioPlaybackMode.singleVerse);
    expect(player.log, ['stop', 'load:1', 'play:3']);

    await controller().toggleVerse(verse(3), expectedVerseCount: 7);
    expect(state().status, QuranVerseAudioStatus.paused);

    await controller().toggleVerse(verse(3), expectedVerseCount: 7);
    expect(state().status, QuranVerseAudioStatus.playing);
    expect(player.log.last, 'resume');
  });

  test('başka ayet seçilince önceki durur; MP3 yeniden yüklenmez', () async {
    await controller().toggleVerse(verse(1), expectedVerseCount: 7);
    await controller().toggleVerse(verse(5), expectedVerseCount: 7);
    expect(state().activeVerseKey, '1:5');
    expect(player.log, contains('stop'));
    expect(player.log.last, 'play:5');
  });

  test('singleVerse bitince otomatik SONRAKİ ayete geçilmez', () async {
    await controller().toggleVerse(verse(2), expectedVerseCount: 7);
    player.emit(QuranAudioPlaybackStatus.completed);
    await pumpEventQueue();
    expect(state().status, QuranVerseAudioStatus.idle);
    expect(state().activeVerseKey, isNull);
    expect(player.log.where((e) => e.startsWith('play:')).length, 1);
  });

  test('continuousChapter: 1. ayetten başlar, completed ile ilerler, '
      'son ayette durur', () async {
    await controller().playChapter(chapterId: 1, expectedVerseCount: 3);
    expect(state().activeVerseNumber, 1);
    expect(state().playbackMode, QuranAudioPlaybackMode.continuousChapter);

    player.emit(QuranAudioPlaybackStatus.completed);
    await pumpEventQueue();
    expect(state().activeVerseNumber, 2);
    expect(state().status, QuranVerseAudioStatus.playing);

    player.emit(QuranAudioPlaybackStatus.completed);
    await pumpEventQueue();
    expect(state().activeVerseNumber, 3);

    player.emit(QuranAudioPlaybackStatus.completed);
    await pumpEventQueue();
    expect(state().status, QuranVerseAudioStatus.idle);
    expect(state().activeVerseKey, isNull);
  });

  test('önceki/sonraki sınırları ve geçişte durdurma', () async {
    await controller().playChapter(chapterId: 1, expectedVerseCount: 3);
    expect(state().hasPrevious, isFalse); // ilk ayette önceki pasif
    expect(state().hasNext, isTrue);

    await controller().skipToAdjacentVerse(forward: true);
    expect(state().activeVerseNumber, 2);

    await controller().skipToAdjacentVerse(forward: true);
    expect(state().activeVerseNumber, 3);
    expect(state().hasNext, isFalse); // son ayette sonraki pasif

    await controller().skipToAdjacentVerse(forward: true); // yok sayılır
    expect(state().activeVerseNumber, 3);

    await controller().skipToAdjacentVerse(forward: false);
    expect(state().activeVerseNumber, 2);
  });

  test('hızlı art arda dokunuşlar çift oynatma üretmez', () async {
    final first = controller().toggleVerse(verse(1), expectedVerseCount: 7);
    final second = controller().toggleVerse(verse(2), expectedVerseCount: 7);
    await Future.wait([first, second]);
    expect(player.loadCount, 1);
    expect(player.log.where((e) => e.startsWith('play:')).length, 1);
  });

  test(
    'sure çalarken başka ayetin Dinle aksiyonu single moda geçirir',
    () async {
      await controller().playChapter(chapterId: 1, expectedVerseCount: 7);
      await controller().toggleVerse(verse(5), expectedVerseCount: 7);
      expect(state().playbackMode, QuranAudioPlaybackMode.singleVerse);
      expect(state().activeVerseNumber, 5);

      // Tek ayet bitince otomatik ilerleme YOK.
      player.emit(QuranAudioPlaybackStatus.completed);
      await pumpEventQueue();
      expect(state().status, QuranVerseAudioStatus.idle);
    },
  );

  test('hata: ayet hatası yalnız o ayette, sure hatası panelde', () async {
    repository.fail = true;
    await controller().toggleVerse(verse(4), expectedVerseCount: 7);
    expect(state().status, QuranVerseAudioStatus.error);
    expect(state().errorVerseKey, '1:4');
    expect(state().chapterAudioFailed, isFalse);

    await controller().playChapter(chapterId: 1, expectedVerseCount: 7);
    expect(state().chapterAudioFailed, isTrue);

    // Retry cache'i düşürür ve başarılı olur.
    repository.fail = false;
    await controller().retryChapter(chapterId: 1, expectedVerseCount: 7);
    expect(repository.invalidated, [1]);
    expect(state().status, QuranVerseAudioStatus.playing);
  });

  test('container dispose olunca player kapanır', () async {
    await controller().toggleVerse(verse(1), expectedVerseCount: 7);
    container.dispose();
    await pumpEventQueue();
    expect(player.disposed, isTrue);
  });
}
