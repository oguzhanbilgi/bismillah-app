import 'dart:convert';

import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_verse.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_content_repository.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

/// Asset tabanlı Kur'an içerik deposu (TASK 034B).
///
/// Katalog `assets/quran/chapters_v1.json`den okunur (Tanzil Quran
/// Metadata 1.0 — künye assets/quran/NOTICE.md). JSON YALNIZ bu data
/// katmanında parse edilir; presentation AssetBundle/JSON görmez. İlk
/// başarılı okumadan sonra bellekte cache edilir. Eksik/duplicate/bozuk
/// kayıt kontrollü `StorageFailure` üretir — crash yok.
final class AssetQuranContentRepository implements QuranContentRepository {
  AssetQuranContentRepository({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  static const String _assetPath = 'assets/quran/chapters_v1.json';
  static const String _versesAssetPath = 'assets/quran/verses_uthmani_v1.json';
  static const int _totalVerses = 6236;

  final AssetBundle _bundle;

  List<QuranChapter>? _cache;
  Map<int, QuranChapter>? _byId;

  /// Sure id → ayet numarasına sıralı ayet listesi (ilk başarılı
  /// okumadan sonra bellekte).
  Map<int, List<QuranVerse>>? _versesByChapter;

  @override
  ResultFuture<List<QuranChapter>> getChapters() async {
    final cached = _cache;
    if (cached != null) {
      return Result.success(cached);
    }
    try {
      final decoded = json.decode(await _bundle.loadString(_assetPath));
      final chapters = _parseAndValidate(decoded);
      _cache = chapters;
      _byId = {for (final chapter in chapters) chapter.id: chapter};
      return Result.success(chapters);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<QuranChapter?> getChapter(int id) async {
    final result = await getChapters();
    return result.fold(
      onSuccess: (_) => Result.success(_byId?[id]),
      onFailure: Result.failure,
    );
  }

  @override
  ResultFuture<List<QuranVerse>> getVersesForChapter(int chapterId) async {
    if (chapterId < 1 || chapterId > 114) {
      return const Result.failure(StorageFailure());
    }
    final cached = _versesByChapter;
    if (cached != null) {
      return Result.success(cached[chapterId]!);
    }
    // Ayet sayıları katalogla çapraz doğrulanır — önce katalog yüklenir.
    final chaptersResult = await getChapters();
    final chapters = chaptersResult.fold(
      onSuccess: (chapters) => chapters,
      onFailure: (_) => null,
    );
    if (chapters == null) {
      return const Result.failure(StorageFailure());
    }
    try {
      final decoded = json.decode(await _bundle.loadString(_versesAssetPath));
      final byChapter = _parseAndValidateVerses(decoded, chapters);
      _versesByChapter = byChapter;
      return Result.success(byChapter[chapterId]!);
    } on Exception {
      return const Result.failure(StorageFailure());
    } on ArgumentError {
      // QuranVerse kurucu doğrulaması — bozuk kayıt kontrollü failure.
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<QuranVerse?> getVerse(String verseKey) async {
    final parts = verseKey.split(':');
    if (parts.length != 2) {
      return const Result.success(null);
    }
    final chapterId = int.tryParse(parts[0]);
    final verseNumber = int.tryParse(parts[1]);
    if (chapterId == null ||
        verseNumber == null ||
        chapterId < 1 ||
        chapterId > 114) {
      return const Result.success(null);
    }
    final result = await getVersesForChapter(chapterId);
    return result.fold(
      onSuccess: (verses) => Result.success(
        verseNumber >= 1 && verseNumber <= verses.length
            ? verses[verseNumber - 1]
            : null,
      ),
      onFailure: Result.failure,
    );
  }

  /// Üreticinin doğrulamalarını okuma tarafında da uygular: toplam 6236
  /// ayet, sure başına katalogla eşleşen sayıda ve 1'den kesintisiz
  /// numaralı, duplicate'siz, boş olmayan metin. Her ihlal
  /// [FormatException] → kontrollü failure.
  static Map<int, List<QuranVerse>> _parseAndValidateVerses(
    Object? decoded,
    List<QuranChapter> chapters,
  ) {
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('ayet dosyası kökü nesne değil');
    }
    final rawVerses = decoded['verses'];
    if (rawVerses is! List || rawVerses.length != _totalVerses) {
      throw const FormatException('6236 ayet bekleniyordu');
    }

    final byChapter = <int, List<QuranVerse>>{};
    for (final raw in rawVerses) {
      if (raw is! Map<String, Object?>) {
        throw const FormatException('ayet kaydı nesne değil');
      }
      final chapterId = raw['chapterId'];
      final verseNumber = raw['verseNumber'];
      final verseKey = raw['verseKey'];
      final text = raw['textUthmani'];
      if (chapterId is! int ||
          verseNumber is! int ||
          verseKey is! String ||
          text is! String) {
        throw const FormatException('ayet alanları eksik/bozuk');
      }
      final list = byChapter.putIfAbsent(chapterId, () => []);
      // Üretici sure+ayet sıralı yazar; kesintisizlik burada da doğrulanır
      // (duplicate veya atlama bu kontrole takılır).
      if (verseNumber != list.length + 1) {
        throw FormatException(
          'sure $chapterId: ayet numaraları kesintisiz değil ($verseNumber)',
        );
      }
      list.add(
        QuranVerse(
          chapterId: chapterId,
          verseNumber: verseNumber,
          verseKey: verseKey,
          textUthmani: text,
        ),
      );
    }

    for (final chapter in chapters) {
      final verses = byChapter[chapter.id];
      if (verses == null || verses.length != chapter.verseCount) {
        throw FormatException(
          'sure ${chapter.id}: ayet sayısı katalogla eşleşmiyor',
        );
      }
    }
    return {
      for (final entry in byChapter.entries)
        entry.key: List.unmodifiable(entry.value),
    };
  }

  /// Üreticinin doğrulamalarını okuma tarafında da uygular: tam 114 kayıt,
  /// benzersiz 1–114 id, pozitif sayılar, boş olmayan adlar, tanınan
  /// nüzul yeri. Her ihlal [FormatException] → kontrollü failure.
  static List<QuranChapter> _parseAndValidate(Object? decoded) {
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('katalog kökü nesne değil');
    }
    final rawChapters = decoded['chapters'];
    if (rawChapters is! List || rawChapters.length != 114) {
      throw const FormatException('114 sure bekleniyordu');
    }

    int intField(Map<String, Object?> map, String key) {
      final value = map[key];
      if (value is! int) {
        throw FormatException('$key alanı eksik/bozuk');
      }
      return value;
    }

    String nameField(Map<String, Object?> map, String key) {
      final value = map[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('$key alanı boş/bozuk');
      }
      return value;
    }

    final chapters = <QuranChapter>[];
    final seenIds = <int>{};
    for (final raw in rawChapters) {
      if (raw is! Map<String, Object?>) {
        throw const FormatException('sure kaydı nesne değil');
      }
      final id = intField(raw, 'id');
      if (id < 1 || id > 114 || !seenIds.add(id)) {
        throw FormatException('id benzersiz ve 1–114 olmalı: $id');
      }
      final verseCount = intField(raw, 'verseCount');
      final revelationOrder = intField(raw, 'revelationOrder');
      final rukuCount = intField(raw, 'rukuCount');
      final startVerseIndex = intField(raw, 'startVerseIndex');
      if (verseCount <= 0 || revelationOrder <= 0 || rukuCount <= 0) {
        throw FormatException('sure $id: sayı alanları pozitif olmalı');
      }
      if (startVerseIndex < 0) {
        throw FormatException('sure $id: startVerseIndex negatif olamaz');
      }
      final place = switch (raw['revelationPlace']) {
        'meccan' => QuranRevelationPlace.meccan,
        'medinan' => QuranRevelationPlace.medinan,
        _ => throw FormatException('sure $id: tanınmayan nüzul yeri'),
      };
      chapters.add(
        QuranChapter(
          id: id,
          arabicName: nameField(raw, 'arabicName'),
          transliteratedName: nameField(raw, 'transliteratedName'),
          englishName: nameField(raw, 'englishName'),
          verseCount: verseCount,
          revelationPlace: place,
          revelationOrder: revelationOrder,
          startVerseIndex: startVerseIndex,
          rukuCount: rukuCount,
        ),
      );
    }
    chapters.sort((a, b) => a.id.compareTo(b.id));
    return List.unmodifiable(chapters);
  }
}
