import 'dart:convert';

import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_search_result.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_content_repository.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_search_repository.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_translation_repository.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

/// Paketlenmiş offline Kur'an arama deposu (TASK 048).
///
/// İndeks (`quran_search_index_v1.json`) yalnız eşleştirme için normalize
/// değerler taşır; snippet'lerde gösterilen metin HER ZAMAN mevcut Tanzil
/// içerik ve QuranEnc meal depolarından okunan ORİJİNALDİR. İndeks tembel
/// yüklenir, doğrulanır ve oturum boyunca cache'lenir. HTTP/Firebase/
/// analytics YOK; sorgu veya ayet/meal metni LOGLANMAZ.
///
/// Sorgu normalizasyonu `tool/generate_quran_search_index.py` ile birebir
/// aynı kurallardır — değişiklikler iki tarafta birden yapılmalı.
final class BundledQuranSearchRepository implements QuranSearchRepository {
  BundledQuranSearchRepository({
    required this._contentRepository,
    required this._translationRepository,
    AssetBundle? bundle,
  }) : _bundle = bundle ?? rootBundle;

  static const String _assetPath =
      'assets/quran/search/quran_search_index_v1.json';
  static const int _maxChapterResults = 10;
  static const int _maxVerseResults = 50;
  static const int _minLatinQueryLength = 3;
  static const int _minArabicQueryLength = 2;
  static const int _snippetMaxLength = 180;

  final QuranContentRepository _contentRepository;
  final QuranTranslationRepository _translationRepository;
  final AssetBundle _bundle;

  _SearchIndex? _index;

  @override
  ResultFuture<QuranSearchResponse> search(String query) async {
    final normalizedLatin = normalizeTurkishQuery(query);
    final normalizedArabic = normalizeArabicQuery(query);
    if (normalizedLatin.isEmpty && normalizedArabic.isEmpty) {
      return const Result.success(QuranSearchResponse.empty);
    }
    try {
      final index = await _loadIndex();
      final chaptersResult = await _contentRepository.getChapters();
      final chapters = chaptersResult.fold(
        onSuccess: (chapters) => chapters,
        onFailure: (_) => null,
      );
      if (chapters == null) {
        return const Result.failure(StorageFailure());
      }
      final byId = {for (final chapter in chapters) chapter.id: chapter};

      // 1) Tam geçerli ayet referansı veya doğrulanmış referans alias'ı
      //    ("ayetel kürsi" → 2:255): tek ve en öncelikli sonuç.
      final reference =
          _parseReference(normalizedLatin, index) ??
          index.referenceAliases[normalizedLatin];
      if (reference != null) {
        final verse = await _buildVerseResult(
          byId[reference.chapterId]!,
          reference.verseNumber,
          QuranSearchMatchType.exactReference,
        );
        return Result.success(QuranSearchResponse(verses: [?verse]));
      }

      // 2) Yalnız sayı: 1–114 sure sonucu, aralık dışı boş sonuç.
      final numberOnly = RegExp(r'^\d{1,4}$').firstMatch(normalizedLatin);
      if (numberOnly != null) {
        final chapter = byId[int.parse(numberOnly.group(0)!)];
        return Result.success(
          QuranSearchResponse(
            chapters: [
              if (chapter != null)
                _chapterResult(chapter, QuranSearchMatchType.exactReference),
            ],
          ),
        );
      }

      final chapterResults = _searchChapters(
        index,
        byId,
        normalizedLatin,
        normalizedArabic,
      );
      final verseResults = await _searchVerses(
        index,
        byId,
        normalizedLatin,
        normalizedArabic,
      );
      return Result.success(
        QuranSearchResponse(chapters: chapterResults, verses: verseResults),
      );
    } catch (_) {
      // İndeks/içerik/meal yükleme hatası SADECE Exception değildir:
      // eksik veya bozuk asset'te AssetBundle.loadString bir FlutterError
      // (Error) fırlatır. `on Exception` bunu kaçırıp tüm arama yüzeyini
      // kilitliyordu — geniş yakalama sakin failure'a düşürür; reader/
      // meal/ses etkilenmez, indeks yalnız başarıda cache'lendiğinden
      // sonraki aramalar kendiliğinden yeniden dener.
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<QuranVerseSearchTarget?> resolveReference(String input) async {
    try {
      final index = await _loadIndex();
      final normalized = normalizeTurkishQuery(input);
      return Result.success(
        _parseReference(normalized, index) ??
            index.referenceAliases[normalized],
      );
    } catch (_) {
      // Bkz. [search]: asset yükleme hatası Error olabilir — geniş yakala.
      return const Result.failure(StorageFailure());
    }
  }

  // -------------------------------------------------------------------------
  // Eşleştirme
  // -------------------------------------------------------------------------

  QuranVerseSearchTarget? _parseReference(
    String normalized,
    _SearchIndex index,
  ) {
    // Normalizasyon `:` ve `/` ayıraçlarını boşluğa çevirir — tek desen
    // üç biçimi de (2:255, 2/255, 2 255) karşılar; uzun metinler uymaz.
    final match = RegExp(r'^(\d{1,3}) (\d{1,3})$').firstMatch(normalized);
    if (match == null) {
      return null;
    }
    final chapterId = int.parse(match.group(1)!);
    final verseNumber = int.parse(match.group(2)!);
    final verseCount = index.verseCountByChapter[chapterId];
    if (verseCount == null || verseNumber < 1 || verseNumber > verseCount) {
      return null;
    }
    return QuranVerseSearchTarget(
      chapterId: chapterId,
      verseNumber: verseNumber,
    );
  }

  List<QuranChapterSearchResult> _searchChapters(
    _SearchIndex index,
    Map<int, QuranChapter> byId,
    String latinQuery,
    String arabicQuery,
  ) {
    if (latinQuery.length < 2 && arabicQuery.length < _minArabicQueryLength) {
      return const [];
    }
    final scored = <(int rank, QuranChapterSearchResult result)>[];
    for (final entry in index.chapterAliases.entries) {
      final chapter = byId[entry.key];
      if (chapter == null) {
        continue;
      }
      var rank = 99;
      for (final alias in entry.value) {
        for (final query in [
          if (latinQuery.length >= 2) latinQuery,
          if (arabicQuery.length >= _minArabicQueryLength) arabicQuery,
        ]) {
          if (alias == query) {
            rank = rank < 1 ? rank : 1;
          } else if (alias.startsWith(query)) {
            rank = rank < 2 ? rank : 2;
          } else if (alias.contains(query)) {
            rank = rank < 3 ? rank : 3;
          }
        }
      }
      if (rank < 99) {
        scored.add((
          rank,
          _chapterResult(chapter, switch (rank) {
            1 => QuranSearchMatchType.exactChapterName,
            2 => QuranSearchMatchType.chapterNamePrefix,
            _ => QuranSearchMatchType.chapterNameContains,
          }),
        ));
      }
    }
    scored.sort((a, b) {
      final byRank = a.$1.compareTo(b.$1);
      return byRank != 0 ? byRank : a.$2.chapterId.compareTo(b.$2.chapterId);
    });
    return [for (final entry in scored.take(_maxChapterResults)) entry.$2];
  }

  Future<List<QuranVerseSearchResult>> _searchVerses(
    _SearchIndex index,
    Map<int, QuranChapter> byId,
    String latinQuery,
    String arabicQuery,
  ) async {
    final runLatin = latinQuery.length >= _minLatinQueryLength;
    final runArabic =
        arabicQuery.length >= _minArabicQueryLength &&
        _containsArabic(arabicQuery);
    if (!runLatin && !runArabic) {
      return const [];
    }
    final tokens = runLatin ? latinQuery.split(' ') : const <String>[];
    final scored = <(int rank, _IndexVerse verse)>[];
    for (final verse in index.verses) {
      var rank = 99;
      if (runLatin && tokens.isNotEmpty) {
        final padded = ' ${verse.turkish} ';
        if (tokens.every((token) => padded.contains(' $token '))) {
          rank = 5; // meal tam kelime eşleşmesi
        } else if (tokens.every(verse.turkish.contains)) {
          rank = 6; // tüm token'lar kısmi içerme
        }
      }
      if (runArabic && verse.arabic.contains(arabicQuery)) {
        rank = rank < 7 ? rank : 7;
      }
      if (rank < 99) {
        scored.add((rank, verse));
      }
    }
    scored.sort((a, b) {
      final byRank = a.$1.compareTo(b.$1);
      if (byRank != 0) {
        return byRank;
      }
      final byChapter = a.$2.chapterId.compareTo(b.$2.chapterId);
      return byChapter != 0
          ? byChapter
          : a.$2.verseNumber.compareTo(b.$2.verseNumber);
    });

    final results = <QuranVerseSearchResult>[];
    for (final (rank, verse) in scored.take(_maxVerseResults)) {
      final chapter = byId[verse.chapterId];
      if (chapter == null) {
        continue;
      }
      final result = await _buildVerseResult(
        chapter,
        verse.verseNumber,
        rank == 7
            ? QuranSearchMatchType.arabicVerse
            : QuranSearchMatchType.turkishTranslation,
      );
      if (result != null) {
        results.add(result);
      }
    }
    return results;
  }

  /// Orijinal Tanzil + QuranEnc metinlerinden güvenli snippet'li sonuç;
  /// metinler cache'li depolardan gelir, DEĞİŞTİRİLMEZ.
  Future<QuranVerseSearchResult?> _buildVerseResult(
    QuranChapter chapter,
    int verseNumber,
    QuranSearchMatchType matchType,
  ) async {
    final versesResult = await _contentRepository.getVersesForChapter(
      chapter.id,
    );
    final verses = versesResult.fold(
      onSuccess: (verses) => verses,
      onFailure: (_) => null,
    );
    if (verses == null || verseNumber < 1 || verseNumber > verses.length) {
      return null;
    }
    final translationResult = await _translationRepository
        .getChapterTranslation(chapter.id);
    final translation = translationResult.fold(
      onSuccess: (translation) => translation,
      onFailure: (_) => null,
    );
    final translationText =
        translation != null && verseNumber <= translation.verses.length
        ? translation.verses[verseNumber - 1].translationText
        : '';
    return QuranVerseSearchResult(
      chapterId: chapter.id,
      chapterName: chapter.transliteratedName,
      verseNumber: verseNumber,
      verseKey: '${chapter.id}:$verseNumber',
      arabicSnippet: _snippet(verses[verseNumber - 1].textUthmani),
      translationSnippet: _snippet(translationText),
      matchType: matchType,
    );
  }

  QuranChapterSearchResult _chapterResult(
    QuranChapter chapter,
    QuranSearchMatchType matchType,
  ) => QuranChapterSearchResult(
    chapterId: chapter.id,
    chapterName: chapter.transliteratedName,
    arabicName: chapter.arabicName,
    verseCount: chapter.verseCount,
    matchType: matchType,
  );

  /// Uzun metni yalnız KELİME sınırında kısaltır (Unicode karakter/işaret
  /// ortadan bölünmez); kısaltmada ellipsis eklenir.
  static String _snippet(String text) {
    if (text.length <= _snippetMaxLength) {
      return text;
    }
    final cut = text.lastIndexOf(' ', _snippetMaxLength);
    return '${text.substring(0, cut > 0 ? cut : _snippetMaxLength)}…';
  }

  // -------------------------------------------------------------------------
  // Sorgu normalizasyonu (generator ile birebir aynı kurallar)
  // -------------------------------------------------------------------------

  static const Map<String, String> _latinFolds = {
    'â': 'a',
    'á': 'a',
    'à': 'a',
    'ä': 'a',
    'ã': 'a',
    'å': 'a',
    'ê': 'e',
    'é': 'e',
    'è': 'e',
    'ë': 'e',
    'î': 'i',
    'í': 'i',
    'ì': 'i',
    'ï': 'i',
    'ô': 'o',
    'ó': 'o',
    'ò': 'o',
    'ö': 'o',
    'õ': 'o',
    'û': 'u',
    'ú': 'u',
    'ù': 'u',
    'ü': 'u',
    'ç': 'c',
    'ş': 's',
    'ğ': 'g',
    'ñ': 'n',
  };

  static const List<(String, String)> _arabicFolds = [
    ('أ', 'ا'),
    ('إ', 'ا'),
    ('آ', 'ا'),
    ('ٱ', 'ا'),
    ('ؤ', 'و'),
    ('ئ', 'ي'),
    ('ء', ''),
    ('ى', 'ي'),
    ('ة', 'ه'),
  ];

  /// Türkçe sorgu normalizasyonu: küçük harf, ı/i birleştirme, aksan
  /// katlama, noktalama → boşluk, boşluk sadeleştirme.
  static String normalizeTurkishQuery(String query) {
    var text = query
        .replaceAll('İ', 'i')
        .replaceAll('I', 'i')
        .toLowerCase()
        .replaceAll('ı', 'i');
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final ch = String.fromCharCode(rune);
      buffer.write(_latinFolds[ch] ?? ch);
    }
    text = buffer.toString().replaceAll(
      RegExp(r'[\p{P}\p{S}]', unicode: true),
      ' ',
    );
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Arapça sorgu normalizasyonu: hareke/tatweel kaldırma, elif/hemze/ye
  /// katlama, işaret → boşluk. Boş dönerse sorgu Arapça değildir.
  static String normalizeArabicQuery(String query) {
    final buffer = StringBuffer();
    for (final rune in query.runes) {
      // Harekeler ve Kur'an işaretleri (Mn aralıkları) + tatweel atlanır.
      if ((rune >= 0x0610 && rune <= 0x061A) ||
          (rune >= 0x064B && rune <= 0x065F) ||
          rune == 0x0670 ||
          (rune >= 0x06D6 && rune <= 0x06DC) ||
          (rune >= 0x06DF && rune <= 0x06E4) ||
          rune == 0x06E7 ||
          rune == 0x06E8 ||
          (rune >= 0x06EA && rune <= 0x06ED) ||
          (rune >= 0x08D3 && rune <= 0x08FF) ||
          rune == 0x0640) {
        continue;
      }
      buffer.write(String.fromCharCode(rune));
    }
    var text = buffer.toString();
    for (final (src, dst) in _arabicFolds) {
      text = text.replaceAll(src, dst);
    }
    // Arapça harf dışındaki her şey ayıraçtır — Latin sorgular boş kalır.
    text = text.replaceAll(RegExp(r'[^ء-يٱ]+'), ' ');
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static bool _containsArabic(String text) => RegExp(r'[ء-ي]').hasMatch(text);

  // -------------------------------------------------------------------------
  // İndeks yükleme/doğrulama
  // -------------------------------------------------------------------------

  Future<_SearchIndex> _loadIndex() async {
    final cached = _index;
    if (cached != null) {
      return cached;
    }
    final decoded = json.decode(await _bundle.loadString(_assetPath));
    final index = _parseAndValidate(decoded);
    _index = index;
    return index;
  }

  /// Üretici doğrulamaları okuma tarafında da uygulanır: 114 sure, 6236
  /// tekil ayet, sayılar tutarlı. Her ihlal [FormatException] → failure.
  static _SearchIndex _parseAndValidate(Object? decoded) {
    if (decoded is! Map<String, Object?> || decoded['schemaVersion'] != 1) {
      throw const FormatException('arama indeksi kökü/sürümü bozuk');
    }
    final rawChapters = decoded['chapters'];
    final rawVerses = decoded['verses'];
    if (rawChapters is! List || rawChapters.length != 114) {
      throw const FormatException('114 sure bekleniyordu');
    }
    if (rawVerses is! List || rawVerses.length != 6236) {
      throw const FormatException('6236 ayet bekleniyordu');
    }
    final aliases = <int, List<String>>{};
    final verseCounts = <int, int>{};
    for (final raw in rawChapters) {
      if (raw is! Map<String, Object?>) {
        throw const FormatException('sure kaydı nesne değil');
      }
      final id = raw['id'];
      final verseCount = raw['verseCount'];
      final rawAliases = raw['aliases'];
      if (id is! int || verseCount is! int || rawAliases is! List) {
        throw const FormatException('sure alanları bozuk');
      }
      aliases[id] = [
        for (final alias in rawAliases)
          if (alias is String && alias.isNotEmpty)
            alias
          else
            throw const FormatException('alias bozuk'),
      ];
      verseCounts[id] = verseCount;
    }
    // Sınırlı, doğrulanmış referans alias'ları (TASK 049 §0) — generator
    // ile aynı sözleşme; hedef gerçek bir ayet olmalı.
    final referenceAliases = <String, QuranVerseSearchTarget>{};
    final rawAliasEntries = decoded['referenceAliases'];
    if (rawAliasEntries is! List) {
      throw const FormatException('referenceAliases bozuk');
    }
    for (final raw in rawAliasEntries) {
      if (raw is! Map<String, Object?>) {
        throw const FormatException('referans alias kaydı nesne değil');
      }
      final chapterId = raw['chapterId'];
      final verseNumber = raw['verseNumber'];
      final rawAliases = raw['aliases'];
      if (chapterId is! int || verseNumber is! int || rawAliases is! List) {
        throw const FormatException('referans alias alanları bozuk');
      }
      final verseCount = verseCounts[chapterId];
      if (verseCount == null || verseNumber < 1 || verseNumber > verseCount) {
        throw const FormatException('referans alias hedefi geçersiz');
      }
      for (final alias in rawAliases) {
        if (alias is! String ||
            alias.isEmpty ||
            referenceAliases.containsKey(alias)) {
          throw const FormatException('referans alias bozuk/duplicate');
        }
        referenceAliases[alias] = QuranVerseSearchTarget(
          chapterId: chapterId,
          verseNumber: verseNumber,
        );
      }
    }

    final verses = <_IndexVerse>[];
    final seenKeys = <String>{};
    for (final raw in rawVerses) {
      if (raw is! Map<String, Object?>) {
        throw const FormatException('ayet kaydı nesne değil');
      }
      final key = raw['k'];
      final chapterId = raw['c'];
      final verseNumber = raw['v'];
      final arabic = raw['a'];
      final turkish = raw['t'];
      if (key is! String ||
          chapterId is! int ||
          verseNumber is! int ||
          arabic is! String ||
          turkish is! String ||
          !seenKeys.add(key)) {
        throw const FormatException('ayet kaydı bozuk/duplicate');
      }
      verses.add(
        _IndexVerse(
          chapterId: chapterId,
          verseNumber: verseNumber,
          arabic: arabic,
          turkish: turkish,
        ),
      );
    }
    return _SearchIndex(
      chapterAliases: aliases,
      verseCountByChapter: verseCounts,
      referenceAliases: referenceAliases,
      verses: verses,
    );
  }
}

final class _SearchIndex {
  const _SearchIndex({
    required this.chapterAliases,
    required this.verseCountByChapter,
    required this.referenceAliases,
    required this.verses,
  });

  final Map<int, List<String>> chapterAliases;
  final Map<int, int> verseCountByChapter;

  /// Normalize alias → doğrulanmış ayet hedefi ("ayetel kursi" → 2:255).
  final Map<String, QuranVerseSearchTarget> referenceAliases;
  final List<_IndexVerse> verses;
}

final class _IndexVerse {
  const _IndexVerse({
    required this.chapterId,
    required this.verseNumber,
    required this.arabic,
    required this.turkish,
  });

  final int chapterId;
  final int verseNumber;
  final String arabic;
  final String turkish;
}
