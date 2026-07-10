import 'package:bismillah_app/core/value_objects/language_code.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/content/domain/entities/ai_explanation.dart';
import 'package:bismillah_app/features/content/domain/entities/content_item.dart';
import 'package:bismillah_app/features/content/domain/entities/sacred_content.dart';
import 'package:bismillah_app/features/content/domain/value_objects/content_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('QuranVerse cannot exist without source metadata', () {
    expect(
      () => QuranVerse(
        surah: 2,
        ayahStart: 255,
        arabicText: 'metin',
        source: '',
        sourceReference: '2:255',
      ),
      throwsArgumentError,
    );
    expect(
      () => QuranVerse(
        surah: 2,
        ayahStart: 255,
        arabicText: 'metin',
        source: "Kur'an-ı Kerim",
        sourceReference: '   ',
      ),
      throwsArgumentError,
    );
  });

  test('QuranVerse translation requires translation source', () {
    expect(
      () => QuranVerse(
        surah: 1,
        ayahStart: 1,
        arabicText: 'metin',
        source: "Kur'an-ı Kerim",
        sourceReference: '1:1',
        translation: 'meal',
      ),
      throwsArgumentError,
    );
  });

  test('DuaText and DhikrText require source metadata', () {
    expect(
      () => DuaText(arabicText: 'metin', source: '', sourceReference: 'ref'),
      throwsArgumentError,
    );
    expect(
      () => DhikrText(arabicText: 'metin', source: 'kaynak', sourceReference: ''),
      throwsArgumentError,
    );
  });

  test('hadith content envelope requires grading', () {
    ContentItem hadithItem({HadithGrading? grading}) {
      final now = UtcDateTime(DateTime.utc(2026, 7, 8));
      return ContentItem(
        contentId: ContentId('hadith-kindness-001'),
        contentType: SacredContentType.hadith,
        source: 'Sahih-i Buhârî',
        sourceReference: 'Buhârî 6018',
        language: LanguageCode('tr'),
        version: 1,
        status: ContentStatus.published,
        createdAt: now,
        updatedAt: now,
        grading: grading,
      );
    }

    expect(hadithItem, throwsArgumentError);
    expect(hadithItem(grading: HadithGrading.sahih).isConsumable, isTrue);
  });

  test('AiExplanation is outside the SacredContent hierarchy', () {
    final explanation = AiExplanation(text: 'AI açıklaması');
    expect(explanation, isNot(isA<SacredContent>()));
  });
}
