import 'dart:convert';

import 'package:bismillah_app/features/quran/data/mp3quran_audio_repository.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter_recitation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// TASK 041/049 MP3Quran deposu: kaynak-bağımsız timing bütünlüğü,
/// üç haneli MP3 URL üretimi ve (readId, chapterId) cache'i — GERÇEK
/// HTTP YOK.
void main() {
  QuranRecitationSource read5Source({
    String folderUrl = 'https://server10.mp3quran.net/ajm/',
  }) => QuranRecitationSource(
    readId: 5,
    reciterName: 'أحمد بن علي العجمي',
    rewayaName: 'حفص عن عاصم',
    folderUrl: folderUrl,
    chapterCount: 114,
    isDefault: true,
  );

  List<Map<String, Object?>> fatihaTimings() => [
    {'ayah': 0, 'start_time': 0, 'end_time': 2731},
    for (var i = 1; i <= 7; i++)
      {'ayah': i, 'start_time': i * 1000, 'end_time': (i + 1) * 1000},
  ];

  ({Mp3QuranAudioRepository repository, List<Uri> requests}) build({
    Object? timings,
  }) {
    final requests = <Uri>[];
    final client = MockClient((request) async {
      requests.add(request.url);
      return http.Response(
        json.encode(timings ?? fatihaTimings()),
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
    QuranRecitationSource? source,
  }) async => (await repository.getChapterRecitation(
    chapterId,
    expectedVerseCount,
    source ?? read5Source(),
  )).fold(onSuccess: (r) => r, onFailure: (_) => null);

  test(
    'seçilen kaynaktan üç haneli HTTPS MP3 URL kurulur; ayah=0 eşlenmez',
    () async {
      final (repository: repo, requests: requests) = build();
      final result = await recitation(repo);
      expect(result, isNotNull);
      expect(result!.audioUrl, 'https://server10.mp3quran.net/ajm/001.mp3');
      expect(result.source.readId, 5);
      expect(result.source.chapterCount, 114);
      expect(result.verseTimings.length, 7); // ayah=0 kaydı dahil DEĞİL
      expect(result.verseTimings.first.verseNumber, 1);
      expect(result.timingFor(3)!.start, const Duration(seconds: 3));
      // Timing sorgusu seçilen read kimliğiyle kurulur (TASK 049).
      expect(requests.single.queryParameters['read'], '5');
    },
  );

  test(
    'HTTP folder_url veya eksik 114 kapsamı kaynak seviyesinde reddedilir',
    () {
      expect(
        () => read5Source(folderUrl: 'http://server10.mp3quran.net/ajm/'),
        throwsArgumentError,
      );
      expect(
        () => QuranRecitationSource(
          readId: 5,
          reciterName: 'x',
          rewayaName: 'y',
          folderUrl: 'https://server10.mp3quran.net/ajm/',
          chapterCount: 100,
        ),
        throwsArgumentError,
      );
    },
  );

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

  test('cache (readId, chapterId): tekrar çağrı ağa gitmez; invalidate '
      'yalnız ilgili kaydı yeniler', () async {
    final (repository: repo, requests: requests) = build();
    expect(await recitation(repo), isNotNull);
    final callsAfterFirst = requests.length;
    expect(await recitation(repo), isNotNull);
    expect(requests.length, callsAfterFirst); // cache — yeni istek yok

    // Başka read kimliği ayrı cache girdisidir (TASK 049).
    repo.invalidateChapter(1, 999); // farklı read — mevcut cache bozulmaz
    expect(await recitation(repo), isNotNull);
    expect(requests.length, callsAfterFirst);

    repo.invalidateChapter(1, 5);
    expect(await recitation(repo), isNotNull);
    expect(requests.length, greaterThan(callsAfterFirst));
  });
}
