import 'dart:convert';

import 'package:bismillah_app/features/quran/data/mp3quran_audio_repository.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter_recitation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// TASK 041 MP3Quran deposu: read 5 doğrulaması, timing bütünlüğü,
/// üç haneli MP3 URL üretimi ve oturum cache'i — GERÇEK HTTP YOK.
void main() {
  Map<String, Object?> read5({
    String folderUrl = 'https://server10.mp3quran.net/ajm/',
    int soarCount = 114,
  }) => {
    'id': 5,
    'name': 'أحمد بن علي العجمي',
    'rewaya': 'حفص عن عاصم',
    'folder_url': folderUrl,
    'soar_count': soarCount,
  };

  List<Map<String, Object?>> fatihaTimings() => [
    {'ayah': 0, 'start_time': 0, 'end_time': 2731},
    for (var i = 1; i <= 7; i++)
      {'ayah': i, 'start_time': i * 1000, 'end_time': (i + 1) * 1000},
  ];

  ({Mp3QuranAudioRepository repository, List<Uri> requests}) build({
    Object? reads,
    Object? timings,
  }) {
    final requests = <Uri>[];
    final client = MockClient((request) async {
      requests.add(request.url);
      final body = request.url.path.endsWith('/reads')
          ? (reads ?? [read5()])
          : (timings ?? fatihaTimings());
      return http.Response(
        json.encode(body),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    return (
      repository: Mp3QuranAudioRepository(client: client),
      requests: requests,
    );
  }

  Future<QuranChapterRecitation?> recitation(
    Mp3QuranAudioRepository repository, {
    int chapterId = 1,
    int expectedVerseCount = 7,
  }) async => (await repository.getChapterRecitation(
    chapterId,
    expectedVerseCount,
  )).fold(onSuccess: (r) => r, onFailure: (_) => null);

  test(
    'read 5 seçilir; üç haneli HTTPS MP3 URL kurulur; ayah=0 eşlenmez',
    () async {
      final (repository: repo, requests: _) = build();
      final result = await recitation(repo);
      expect(result, isNotNull);
      expect(result!.audioUrl, 'https://server10.mp3quran.net/ajm/001.mp3');
      expect(result.source.readId, 5);
      expect(result.source.chapterCount, 114);
      expect(result.verseTimings.length, 7); // ayah=0 kaydı dahil DEĞİL
      expect(result.verseTimings.first.verseNumber, 1);
      expect(result.timingFor(3)!.start, const Duration(seconds: 3));
    },
  );

  test('HTTP folder_url veya eksik 114 kapsamı reddedilir', () async {
    final insecure = build(
      reads: [read5(folderUrl: 'http://server10.mp3quran.net/ajm/')],
    );
    expect(await recitation(insecure.repository), isNull);

    final partial = build(reads: [read5(soarCount: 100)]);
    expect(await recitation(partial.repository), isNull);
  });

  test('eksik, duplicate veya bozuk timing kontrollü failure üretir', () async {
    // Eksik ayet (7 bekleniyor, 6 var).
    final missing = build(
      timings: [
        for (var i = 1; i <= 6; i++)
          {'ayah': i, 'start_time': i * 1000, 'end_time': (i + 1) * 1000},
      ],
    );
    expect(await recitation(missing.repository), isNull);

    // Duplicate ayet.
    final duplicate = build(
      timings: [
        ...fatihaTimings(),
        {'ayah': 3, 'start_time': 99000, 'end_time': 99500},
      ],
    );
    expect(await recitation(duplicate.repository), isNull);

    // end <= start.
    final broken = build(
      timings: [
        {'ayah': 1, 'start_time': 5000, 'end_time': 5000},
        for (var i = 2; i <= 7; i++)
          {'ayah': i, 'start_time': i * 1000, 'end_time': (i + 1) * 1000},
      ],
    );
    expect(await recitation(broken.repository), isNull);
  });

  test('geçersiz chapterId kontrollü failure üretir', () async {
    final (repository: repo, requests: requests) = build();
    expect(await recitation(repo, chapterId: 0), isNull);
    expect(await recitation(repo, chapterId: 115), isNull);
    expect(requests, isEmpty); // ağ hiç çağrılmaz
  });

  test('chapter cache: tekrar çağrı ağa gitmez; invalidate yeniler', () async {
    final (repository: repo, requests: requests) = build();
    expect(await recitation(repo), isNotNull);
    final callsAfterFirst = requests.length; // reads + timing
    expect(await recitation(repo), isNotNull);
    expect(requests.length, callsAfterFirst); // cache — yeni istek yok

    repo.invalidateChapter(1);
    expect(await recitation(repo), isNotNull);
    expect(requests.length, greaterThan(callsAfterFirst));
  });
}
