import 'dart:convert';

import 'package:bismillah_app/features/quran/data/asset_quran_content_repository.dart';
import 'package:bismillah_app/features/quran/data/bundled_quranenc_translation_repository.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_verse_translation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// CHECKPOINT 06 Recovery: paketlenmiş QuranEnc Rowad V1.0.4 meali —
/// GERÇEK asset ile bütünlük, metadata ve chapter eşleme doğrulaması.
/// İnternet/Firebase YOK.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BundledQuranEncTranslationRepository repository;

  setUp(() {
    repository = BundledQuranEncTranslationRepository();
  });

  Future<QuranChapterTranslation> chapter(int id) async =>
      (await repository.getChapterTranslation(
        id,
      )).fold(onSuccess: (t) => t, onFailure: (f) => throw f);

  test('asset metadata: kaynak, yayıncı ve sürüm künyesi doğru', () async {
    final decoded =
        json.decode(
              await rootBundle.loadString(
                'assets/quran/translations/quranenc_turkish_rwwad_v1_0_4.json',
              ),
            )
            as Map<String, Object?>;
    final metadata = decoded['metadata']! as Map<String, Object?>;
    expect(metadata['source'], 'QuranEnc.com');
    expect(metadata['publisher'], 'Rowad Tercüme Merkezi');
    expect(metadata['version'], 'V1.0.4');
    expect(metadata['translationKey'], 'turkish_rwwad');
    expect(
      metadata['sourceUrl'],
      'https://quranenc.com/tr/browse/turkish_rwwad',
    );
  });

  test('114 sure ve toplam 6236 ayet Tanzil katalogla eşleşir', () async {
    final content = AssetQuranContentRepository();
    final chapters = (await content.getChapters()).fold(
      onSuccess: (c) => c,
      onFailure: (f) => throw f,
    );
    var total = 0;
    for (final catalogChapter in chapters) {
      final translation = await chapter(catalogChapter.id);
      expect(
        translation.verses.length,
        catalogChapter.verseCount,
        reason: 'sure ${catalogChapter.id}',
      );
      total += translation.verses.length;
    }
    expect(total, 6236);
  });

  test('Fatiha meali sıralı, boşsuz ve verseKey uyumlu döner', () async {
    final fatiha = await chapter(1);
    expect(fatiha.verses.length, 7);
    expect(fatiha.source, BundledQuranEncTranslationRepository.sourceLabel);
    for (var i = 0; i < fatiha.verses.length; i++) {
      final verse = fatiha.verses[i];
      expect(verse.verseNumber, i + 1);
      expect(verse.verseKey, '1:${i + 1}');
      expect(verse.translationText.trim(), isNotEmpty);
    }
    // Verbatim örnek: 1:1 kaynak metniyle birebir.
    expect(fatiha.verses.first.translationText, 'Bismillâhirrahmânirrahîm');
  });

  test('geçersiz chapterId kontrollü failure üretir (crash yok)', () async {
    for (final id in [0, 115, -1]) {
      final result = await repository.getChapterTranslation(id);
      expect(
        result.fold(onSuccess: (_) => 'ok', onFailure: (_) => 'failure'),
        'failure',
      );
    }
  });
}
