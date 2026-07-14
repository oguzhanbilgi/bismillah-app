import 'dart:convert';

import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter_recitation.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_audio_repository.dart';
import 'package:http/http.dart' as http;

/// MP3Quran tabanlı kıraat deposu (TASK 041).
///
/// Yalnız resmî HTTPS endpoint'leri kullanır (read 5 — Ahmed bin Ali
/// el-Acemi, Hafs an Asım). JSON parse YALNIZ bu katmandadır; yanıtlar
/// ve ayet zamanları LOGLANMAZ; Firebase/token/UID/analytics YOK.
/// Read kaydı ve sure timing'leri oturum boyunca bellekte cache edilir.
final class Mp3QuranAudioRepository implements QuranAudioRepository {
  Mp3QuranAudioRepository({http.Client? client})
    : _client = client ?? http.Client();

  static const int _readId = 5;
  static const String _readsUrl =
      'https://www.mp3quran.net/api/v3/ayat_timing/reads';
  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _client;

  QuranRecitationSource? _sourceCache;
  final Map<int, QuranChapterRecitation> _chapterCache = {};

  @override
  ResultFuture<QuranChapterRecitation> getChapterRecitation(
    int chapterId,
    int expectedVerseCount,
  ) async {
    if (chapterId < 1 || chapterId > 114 || expectedVerseCount < 1) {
      return const Result.failure(UnexpectedFailure());
    }
    final cached = _chapterCache[chapterId];
    if (cached != null) {
      return Result.success(cached);
    }
    try {
      final source = _sourceCache ??= await _fetchSource();
      final timings = await _fetchTimings(
        source,
        chapterId,
        expectedVerseCount,
      );
      final recitation = QuranChapterRecitation(
        chapterId: chapterId,
        // Sure MP3'ü: folder_url + üç haneli sure numarası + .mp3
        audioUrl:
            '${source.folderUrl}${chapterId.toString().padLeft(3, '0')}.mp3',
        source: source,
        verseTimings: timings,
      );
      _chapterCache[chapterId] = recitation;
      return Result.success(recitation);
    } on FormatException {
      return const Result.failure(UnexpectedFailure()); // sözleşme ihlali
    } on ArgumentError {
      return const Result.failure(UnexpectedFailure()); // entity doğrulaması
    } on Exception {
      return const Result.failure(NetworkFailure());
    }
  }

  @override
  void invalidateChapter(int chapterId) {
    _chapterCache.remove(chapterId);
  }

  Future<Object?> _getJson(Uri uri) async {
    final response = await _client.get(uri).timeout(_timeout);
    if (response.statusCode != 200) {
      throw http.ClientException('HTTP ${response.statusCode}');
    }
    return json.decode(utf8.decode(response.bodyBytes));
  }

  /// Read 5 kaydını bulur ve doğrular: HTTPS folder_url + 114 sure.
  Future<QuranRecitationSource> _fetchSource() async {
    final decoded = await _getJson(Uri.parse(_readsUrl));
    if (decoded is! List) {
      throw const FormatException('reads yanıtı liste değil');
    }
    for (final raw in decoded) {
      if (raw is! Map) {
        continue;
      }
      if (raw['id'] != _readId) {
        continue;
      }
      final name = raw['name'];
      final rewaya = raw['rewaya'];
      final folderUrl = raw['folder_url'];
      final chapterCount = raw['soar_count'];
      if (name is! String ||
          rewaya is! String ||
          folderUrl is! String ||
          chapterCount is! int) {
        throw const FormatException('read kaydı alanları eksik/bozuk');
      }
      // Entity kurucusu HTTPS ve 114 sure kapsamını doğrular.
      return QuranRecitationSource(
        readId: _readId,
        reciterName: name,
        rewayaName: rewaya,
        folderUrl: folderUrl,
        chapterCount: chapterCount,
      );
    }
    throw const FormatException('read 5 kaydı bulunamadı');
  }

  /// Sure timing'lerini çeker ve doğrular: ayah=0 giriş kaydı eşlenmez;
  /// 1..expectedVerseCount TÜM ayetler mevcut, duplicate'siz ve tutarlı
  /// aralıklı olmalı.
  Future<List<QuranVerseTiming>> _fetchTimings(
    QuranRecitationSource source,
    int chapterId,
    int expectedVerseCount,
  ) async {
    final decoded = await _getJson(
      Uri.parse(
        'https://www.mp3quran.net/api/v3/ayat_timing'
        '?surah=$chapterId&read=$_readId',
      ),
    );
    if (decoded is! List) {
      throw const FormatException('timing yanıtı liste değil');
    }
    final byVerse = <int, QuranVerseTiming>{};
    for (final raw in decoded) {
      if (raw is! Map) {
        throw const FormatException('timing kaydı nesne değil');
      }
      final ayah = raw['ayah'];
      final start = raw['start_time'];
      final end = raw['end_time'];
      if (ayah is! int || start is! int || end is! int) {
        throw const FormatException('timing alanları eksik/bozuk');
      }
      if (ayah == 0) {
        continue; // giriş kaydı (besmele/istiaze) — kullanıcı ayeti DEĞİL
      }
      if (byVerse.containsKey(ayah)) {
        throw const FormatException('duplicate ayet timing kaydı');
      }
      // Entity kurucusu aralık kurallarını (start >= 0, end > start) doğrular.
      byVerse[ayah] = QuranVerseTiming(
        chapterId: chapterId,
        verseNumber: ayah,
        start: Duration(milliseconds: start),
        end: Duration(milliseconds: end),
      );
    }
    final timings = <QuranVerseTiming>[];
    for (var verse = 1; verse <= expectedVerseCount; verse++) {
      final timing = byVerse[verse];
      if (timing == null) {
        throw const FormatException('eksik ayet timing kaydı');
      }
      timings.add(timing);
    }
    return List.unmodifiable(timings);
  }
}
