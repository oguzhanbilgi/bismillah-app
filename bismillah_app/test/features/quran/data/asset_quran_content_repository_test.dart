import 'package:bismillah_app/features/quran/data/asset_quran_content_repository.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_verse.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 034B/035 içerik deposu: GERÇEK üretilmiş asset'lerle doğrulama —
/// katalog ve ayet bütünlüğü, kontrollü hata yolları.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AssetQuranContentRepository repository;

  setUp(() {
    repository = AssetQuranContentRepository();
  });

  Future<List<QuranChapter>> chapters() async =>
      (await repository.getChapters()).fold(
        onSuccess: (c) => c,
        onFailure: (f) => throw f,
      );

  Future<List<QuranVerse>> verses(int chapterId) async =>
      (await repository.getVersesForChapter(chapterId)).fold(
        onSuccess: (v) => v,
        onFailure: (f) => throw f,
      );

  test('katalog 114 sureyi id sırasıyla döndürür', () async {
    final list = await chapters();
    expect(list.length, 114);
    expect(list.first.id, 1);
    expect(list.last.id, 114);
    for (var i = 0; i < list.length; i++) {
      expect(list[i].id, i + 1);
    }
    expect(list.first.transliteratedName, 'Al-Faatiha');
  });

  test('ayetler: toplam 6236 ve her sure katalogla eşleşir', () async {
    final catalog = await chapters();
    var total = 0;
    for (final chapter in catalog) {
      final chapterVerses = await verses(chapter.id);
      expect(chapterVerses.length, chapter.verseCount,
          reason: 'sure ${chapter.id}');
      total += chapterVerses.length;
    }
    expect(total, 6236);
  });

  test('Fatiha 7, Bakara 286, Nas 6 ayet döndürür; sıra kesintisiz',
      () async {
    expect((await verses(1)).length, 7);
    expect((await verses(114)).length, 6);

    final baqara = await verses(2);
    expect(baqara.length, 286);
    for (var i = 0; i < baqara.length; i++) {
      expect(baqara[i].verseNumber, i + 1);
      expect(baqara[i].verseKey, '2:${i + 1}');
      expect(baqara[i].textUthmani.trim(), isNotEmpty);
    }
    // Tanzil metnine otomatik Besmele EKLENMEZ (2:1 "الم" ile başlar).
    expect(baqara.first.textUthmani.startsWith('بِسْمِ'), isFalse);
  });

  test('getChapter/getVerse geçersiz girişte crash etmez', () async {
    Future<Object?> chapterOf(int id) async =>
        (await repository.getChapter(id)).fold(
          onSuccess: (c) => c,
          onFailure: (_) => 'failure',
        );
    expect(await chapterOf(0), isNull);
    expect(await chapterOf(115), isNull);
    expect(await chapterOf(-3), isNull);

    Future<Object?> verseOf(String key) async =>
        (await repository.getVerse(key)).fold(
          onSuccess: (v) => v,
          onFailure: (_) => 'failure',
        );
    expect(await verseOf('abc'), isNull);
    expect(await verseOf('1:999'), isNull);
    expect(await verseOf('999:1'), isNull);
    expect(await verseOf(''), isNull);
    expect(await verseOf('1:1:1'), isNull);

    final valid = await verseOf('1:1');
    expect(valid, isA<QuranVerse>());

    // Geçersiz chapterId aralığı kontrollü failure üretir (exception değil).
    final invalidChapter = await repository.getVersesForChapter(0);
    expect(
      invalidChapter.fold(onSuccess: (_) => 'ok', onFailure: (_) => 'failure'),
      'failure',
    );
  });
}
