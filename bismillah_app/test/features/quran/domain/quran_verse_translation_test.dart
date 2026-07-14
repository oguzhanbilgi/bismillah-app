import 'package:bismillah_app/features/quran/domain/entities/quran_verse_translation.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 040 meal domain doğrulamaları.
void main() {
  QuranVerseTranslation verse(int chapterId, int number, [String? text]) =>
      QuranVerseTranslation(
        chapterId: chapterId,
        verseNumber: number,
        verseKey: '$chapterId:$number',
        translationText: text ?? 'Meal $number',
      );

  test('geçerli sure meali kurulur; verseKey uyumu zorunlu', () {
    final translation = QuranChapterTranslation(
      chapterId: 1,
      source: 'Diyanet İşleri Başkanlığı Meali',
      verses: [verse(1, 1), verse(1, 2)],
    );
    expect(translation.verses.first.verseKey, '1:1');

    expect(
      () => QuranVerseTranslation(
        chapterId: 1,
        verseNumber: 2,
        verseKey: '1:3',
        translationText: 'x',
      ),
      throwsArgumentError,
    );
    expect(() => verse(0, 1), throwsArgumentError);
    expect(() => verse(115, 1), throwsArgumentError);
  });

  test('boş meal metni reddedilir', () {
    expect(() => verse(1, 1, '   '), throwsArgumentError);
  });

  test('duplicate verseKey reddedilir', () {
    expect(
      () => QuranChapterTranslation(
        chapterId: 1,
        source: 'Diyanet İşleri Başkanlığı Meali',
        verses: [verse(1, 1), verse(1, 1)],
      ),
      throwsArgumentError,
    );
  });

  test('ayetler verseNumber sırasıyla tutulmalı', () {
    expect(
      () => QuranChapterTranslation(
        chapterId: 1,
        source: 'Diyanet İşleri Başkanlığı Meali',
        verses: [verse(1, 2), verse(1, 1)],
      ),
      throwsArgumentError,
    );
    // Farklı sureye ait ayet de reddedilir.
    expect(
      () => QuranChapterTranslation(
        chapterId: 1,
        source: 'Diyanet İşleri Başkanlığı Meali',
        verses: [verse(2, 1)],
      ),
      throwsArgumentError,
    );
  });
}
