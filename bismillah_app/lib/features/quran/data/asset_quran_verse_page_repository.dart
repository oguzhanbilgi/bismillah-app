import 'dart:convert';

import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_daily_reading_progress.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_verse_page_repository.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

/// Asset tabanlı ayet → Mushaf sayfası deposu (TASK 047).
///
/// Kaynak: `assets/quran/verse_pages_v1.json` — Tanzil Quran Metadata
/// 1.0'ın doğrulanmış 604 sayfalık Medine Mushafı sınırlarından
/// `tool/generate_quran_verse_pages.py` ile deterministik üretilir.
/// Üreticinin bütünlük doğrulamaları okuma tarafında da uygulanır; her
/// ihlal kontrollü failure'dır (sahte sayfa ilerlemesi üretilmez).
final class AssetQuranVersePageRepository implements QuranVersePageRepository {
  AssetQuranVersePageRepository({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  static const String _assetPath = 'assets/quran/verse_pages_v1.json';
  static const int _totalVerses = 6236;

  final AssetBundle _bundle;

  Map<String, int>? _cache;

  @override
  ResultFuture<Map<String, int>> pagesForChapter(int chapterId) async {
    if (chapterId < 1 || chapterId > 114) {
      return const Result.failure(StorageFailure());
    }
    final mapResult = await _loadMapping();
    return mapResult.fold(
      onSuccess: (mapping) => Result.success({
        for (final entry in mapping.entries)
          if (entry.key.startsWith('$chapterId:')) entry.key: entry.value,
      }),
      onFailure: Result.failure,
    );
  }

  ResultFuture<Map<String, int>> _loadMapping() async {
    final cached = _cache;
    if (cached != null) {
      return Result.success(cached);
    }
    try {
      final decoded = json.decode(await _bundle.loadString(_assetPath));
      final mapping = _parseAndValidate(decoded);
      _cache = mapping;
      return Result.success(mapping);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  /// Bütünlük: tam 6236 geçerli verseKey, sayfalar 1–604 aralığında ve
  /// 604 sayfanın TAMAMI mevcut. İhlal → [FormatException] → failure.
  static Map<String, int> _parseAndValidate(Object? decoded) {
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('sayfa eşlemesi kökü nesne değil');
    }
    final raw = decoded['verseKeyToPage'];
    if (raw is! Map<String, Object?> || raw.length != _totalVerses) {
      throw const FormatException('6236 verseKey eşlemesi bekleniyordu');
    }
    final seenPages = <int>{};
    final mapping = <String, int>{};
    for (final entry in raw.entries) {
      final page = entry.value;
      if (!QuranDailyReadingProgress.isValidVerseKey(entry.key) ||
          page is! int ||
          page < 1 ||
          page > QuranDailyReadingProgress.mushafPageCount) {
        throw FormatException('bozuk eşleme: ${entry.key}');
      }
      mapping[entry.key] = page;
      seenPages.add(page);
    }
    if (seenPages.length != QuranDailyReadingProgress.mushafPageCount) {
      throw const FormatException('604 sayfanın tamamı kapsanmalı');
    }
    return Map.unmodifiable(mapping);
  }
}
