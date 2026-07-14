import 'dart:convert';

import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_verse_translation.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_translation_repository.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

/// Paketlenmiş QuranEnc Türkçe meali (CHECKPOINT 06 Recovery).
///
/// Kaynak: QuranEnc.com — Rowad Tercüme Merkezi, turkish_rwwad V1.0.4.
/// Tamamen OFFLINE: HTTP/Firebase/token YOK, runtime'da QuranEnc API
/// çağrısı YOK. Metin ve dipnotlar üreticide verbatim korunmuştur.
/// Asset yalnız ilk gereksinimde yüklenir ve oturum boyunca cache'lenir.
/// (Diyanet callable deposu gelecekteki opsiyonel kaynak olarak inactive
/// durur — aktif akış BUDUR.)
final class BundledQuranEncTranslationRepository
    implements QuranTranslationRepository {
  BundledQuranEncTranslationRepository({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  static const String _assetPath =
      'assets/quran/translations/quranenc_turkish_rwwad_v1_0_4.json';

  /// Domain sözleşmesindeki kaynak künyesi (UI etiketleri localization'da).
  static const String sourceLabel =
      'Türkçe Tercüme — Rowad Tercüme Merkezi (QuranEnc.com · V1.0.4)';

  final AssetBundle _bundle;

  Map<int, QuranChapterTranslation>? _byChapter;

  @override
  ResultFuture<QuranChapterTranslation> getChapterTranslation(
    int chapterId,
  ) async {
    if (chapterId < 1 || chapterId > 114) {
      return const Result.failure(
        ValidationFailure(messageKey: 'errorUnexpected'),
      );
    }
    try {
      final byChapter = _byChapter ??= await _loadAndValidate();
      final translation = byChapter[chapterId];
      if (translation == null) {
        return const Result.failure(
          StorageFailure(),
        ); // eksik sure — bozuk asset
      }
      return Result.success(translation);
    } on FormatException {
      return const Result.failure(StorageFailure());
    } on ArgumentError {
      return const Result.failure(StorageFailure()); // entity doğrulaması
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  void invalidateChapter(int chapterId) {
    // Paketlenmiş asset'te sure bazlı tazeleme anlamsızdır; tekrar dene
    // akışı için tüm cache güvenle düşürülür (asset yeniden okunur).
    _byChapter = null;
  }

  /// Üreticinin doğrulamalarını okuma tarafında da uygular: 114 sure,
  /// toplam 6236 ayet, kesintisiz numaralar, boş olmayan metin (entity
  /// kurucuları + sabit kontroller). Metadata kaynağı doğrulanır.
  Future<Map<int, QuranChapterTranslation>> _loadAndValidate() async {
    final decoded = json.decode(await _bundle.loadString(_assetPath));
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('meal asset kökü nesne değil');
    }
    final metadata = decoded['metadata'];
    if (metadata is! Map ||
        metadata['source'] != 'QuranEnc.com' ||
        metadata['publisher'] != 'Rowad Tercüme Merkezi' ||
        metadata['version'] != 'V1.0.4' ||
        metadata['translationKey'] != 'turkish_rwwad') {
      throw const FormatException('meal asset metadata beklenen künye değil');
    }
    final rawVerses = decoded['verses'];
    if (rawVerses is! List || rawVerses.length != 6236) {
      throw const FormatException('6236 ayetlik meal bekleniyordu');
    }

    final grouped = <int, List<QuranVerseTranslation>>{};
    for (final raw in rawVerses) {
      if (raw is! Map) {
        throw const FormatException('meal kaydı nesne değil');
      }
      final chapterId = raw['chapterId'];
      final verseNumber = raw['verseNumber'];
      final verseKey = raw['verseKey'];
      final translationText = raw['translationText'];
      if (chapterId is! int ||
          verseNumber is! int ||
          verseKey is! String ||
          translationText is! String) {
        throw const FormatException('meal alanları eksik/bozuk');
      }
      final list = grouped.putIfAbsent(chapterId, () => []);
      if (verseNumber != list.length + 1) {
        throw FormatException(
          'sure $chapterId: meal ayet numaraları kesintisiz değil',
        );
      }
      list.add(
        QuranVerseTranslation(
          chapterId: chapterId,
          verseNumber: verseNumber,
          verseKey: verseKey,
          translationText: translationText,
        ),
      );
    }
    if (grouped.length != 114) {
      throw const FormatException('114 surelik meal bekleniyordu');
    }
    return {
      for (final entry in grouped.entries)
        entry.key: QuranChapterTranslation(
          chapterId: entry.key,
          source: sourceLabel,
          verses: List.unmodifiable(entry.value),
        ),
    };
  }
}
