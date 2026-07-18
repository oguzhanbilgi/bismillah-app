import 'dart:async';
import 'dart:convert';

import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/date_key.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_daily_reading_progress.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_daily_progress_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences tabanlı, gün başına versioned JSON ilerleme deposu
/// (TASK 047). Mevcut Quran progress Isar collection'ı olmadığı ve bu
/// görevde yeni schema migration açılmadığı için mevcut key-value
/// altyapısı kullanılır — veri YALNIZ cihazda.
///
/// Bozuk gün kaydı okunduğunda kontrollü temizlenir ve gün boş sayılır;
/// diğer günler ETKİLENMEZ, exception kullanıcıya sızmaz. Kayıtta Arapça
/// ayet/meal metni YOKTUR — yalnız verseKey ve sayılar.
final class SharedPrefsQuranDailyProgressRepository
    implements QuranDailyProgressRepository {
  SharedPrefsQuranDailyProgressRepository({required this._clock});

  static const String _keyPrefix = 'bismillah.quran_daily_progress.';

  final AppClock _clock;
  final StreamController<QuranDailyReadingProgress> _todayController =
      StreamController<QuranDailyReadingProgress>.broadcast();

  String get _todayKey => DateKey.fromLocal(_clock.nowLocal());

  @override
  Stream<QuranDailyReadingProgress> watchToday() => _todayController.stream
      .where((progress) => progress.localDateKey == _todayKey);

  @override
  ResultFuture<QuranDailyReadingProgress?> loadDay(String localDateKey) async {
    if (!DateKey.isValid(localDateKey)) {
      return const Result.failure(StorageFailure());
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      return Result.success(await _readDay(prefs, localDateKey));
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<void> saveDay(QuranDailyReadingProgress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '$_keyPrefix${progress.localDateKey}',
        json.encode(_encode(progress)),
      );
      _todayController.add(progress);
      return const Result.success(null);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<List<QuranDailyReadingProgress>> loadRange(
    String startDateKey,
    String endDateKey,
  ) async {
    final start = DateTime.tryParse(startDateKey);
    final end = DateTime.tryParse(endDateKey);
    if (!DateKey.isValid(startDateKey) ||
        !DateKey.isValid(endDateKey) ||
        start == null ||
        end == null ||
        start.isAfter(end)) {
      return const Result.failure(StorageFailure());
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final days = <QuranDailyReadingProgress>[];
      // Gün adımlaması güvenli sınırlıdır (bir yıllık pencereden uzunu
      // kesilir) — İlerlemem 7 gün, seri en fazla 365 gün okur.
      var cursor = start;
      for (var i = 0; i <= 366 && !cursor.isAfter(end); i++) {
        final day = await _readDay(prefs, DateKey.fromLocal(cursor));
        if (day != null) {
          days.add(day);
        }
        cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
      }
      return Result.success(days);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<QuranDailyReadingProgress> recordReadingActivity({
    int activeSeconds = 0,
    Set<String> viewedVerseKeys = const {},
    Set<int> viewedPageNumbers = const {},
    int? lastChapterId,
    String? lastVerseKey,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = _todayKey;
      final existing =
          await _readDay(prefs, dateKey) ??
          QuranDailyReadingProgress.empty(
            localDateKey: dateKey,
            updatedAtUtc: _clock.nowUtc(),
          );
      final updated = existing.merged(
        additionalSeconds: activeSeconds,
        newVerseKeys: viewedVerseKeys,
        newPageNumbers: viewedPageNumbers,
        lastChapterId: lastChapterId,
        lastVerseKey: lastVerseKey,
        updatedAtUtc: _clock.nowUtc(),
      );
      await prefs.setString(
        '$_keyPrefix$dateKey',
        json.encode(_encode(updated)),
      );
      _todayController.add(updated);
      return Result.success(updated);
    } on Exception {
      return const Result.failure(StorageFailure());
    } on ArgumentError {
      // Geçersiz verseKey/page girişleri domain doğrulamasına takıldı.
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<QuranDailyReadingProgress> recordActiveReading(int seconds) =>
      recordReadingActivity(activeSeconds: seconds);

  @override
  ResultFuture<QuranDailyReadingProgress> markVerseMeaningfullyViewed(
    String verseKey,
  ) => recordReadingActivity(viewedVerseKeys: {verseKey});

  @override
  ResultFuture<QuranDailyReadingProgress> markPageMeaningfullyViewed(
    int pageNumber,
  ) => recordReadingActivity(viewedPageNumbers: {pageNumber});

  @override
  ResultFuture<void> clearCorruptRecord(String localDateKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_keyPrefix$localDateKey');
      return const Result.success(null);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  /// Gün kaydını okur; bozuk kayıt SESSİZCE ve yalnız o gün için
  /// temizlenir (`null` döner) — crash veya toplu silme yok.
  Future<QuranDailyReadingProgress?> _readDay(
    SharedPreferences prefs,
    String dateKey,
  ) async {
    final raw = prefs.get('$_keyPrefix$dateKey');
    if (raw == null) {
      return null;
    }
    try {
      if (raw is! String) {
        throw const FormatException('gün kaydı String değil');
      }
      return _decode(dateKey, json.decode(raw));
    } on Exception {
      await prefs.remove('$_keyPrefix$dateKey');
      return null;
    } on ArgumentError {
      await prefs.remove('$_keyPrefix$dateKey');
      return null;
    }
  }

  static Map<String, Object?> _encode(QuranDailyReadingProgress progress) => {
    'v': progress.schemaVersion,
    'seconds': progress.activeReadingSeconds,
    'verses': progress.viewedVerseKeys.toList()..sort(),
    'pages': progress.viewedPageNumbers.toList()..sort(),
    if (progress.lastChapterId != null) 'lastChapterId': progress.lastChapterId,
    if (progress.lastVerseKey != null) 'lastVerseKey': progress.lastVerseKey,
    'updatedAtUtc': progress.updatedAtUtc.toIso8601String(),
  };

  static QuranDailyReadingProgress _decode(String dateKey, Object? decoded) {
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('gün kaydı nesne değil');
    }
    final version = decoded['v'];
    if (version is! int ||
        version < 1 ||
        version > QuranDailyReadingProgress.currentSchemaVersion) {
      throw const FormatException('bilinmeyen şema sürümü');
    }
    final seconds = decoded['seconds'];
    final verses = decoded['verses'];
    final pages = decoded['pages'];
    final updatedAtRaw = decoded['updatedAtUtc'];
    final updatedAt = updatedAtRaw is String
        ? DateTime.tryParse(updatedAtRaw)
        : null;
    final lastChapterId = decoded['lastChapterId'];
    final lastVerseKey = decoded['lastVerseKey'];
    if (seconds is! int ||
        verses is! List ||
        pages is! List ||
        updatedAt == null ||
        (lastChapterId != null && lastChapterId is! int) ||
        (lastVerseKey != null && lastVerseKey is! String)) {
      throw const FormatException('gün kaydı alanları bozuk');
    }
    return QuranDailyReadingProgress(
      localDateKey: dateKey,
      activeReadingSeconds: seconds,
      viewedVerseKeys: {
        for (final key in verses)
          if (key is String) key else throw const FormatException('verseKey'),
      },
      viewedPageNumbers: {
        for (final page in pages)
          if (page is int) page else throw const FormatException('page'),
      },
      lastChapterId: lastChapterId as int?,
      lastVerseKey: lastVerseKey as String?,
      updatedAtUtc: updatedAt.toUtc(),
      schemaVersion: version,
    );
  }
}
