import 'package:bismillah_app/features/assistant/domain/services/assistant_retriever.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_enums.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_article.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';
import 'package:flutter_test/flutter_test.dart';

/// Deterministik retrieval/sıralama (TASK 059 §8/§17).
///
/// Retriever'a YALNIZ yayınlanmış (repo tarafından filtrelenmiş) makaleler
/// gelir; burada davranışını izole etmek için basit draft makaleler kurulur.
LearningArticle article({
  required String id,
  required String title,
  String summary = 'Kısa bir özet metni.',
  List<String> keywords = const [],
  String categoryId = 'cat-basics',
  List<String> sectionTexts = const ['Örnek içerik paragrafı.'],
}) {
  return LearningArticle(
    id: id,
    slug: id,
    categoryId: categoryId,
    title: title,
    summary: summary,
    sections: [
      for (final text in sectionTexts)
        LearningSection(type: LearningSectionType.paragraph, text: text),
    ],
    contentType: LearningContentType.ilmihalKnowledge,
    difficulty: LearningDifficulty.beginner,
    estimatedMinutes: 3,
    keywords: keywords,
    sourceIds: const ['diyanet-islam-ilmihali'],
    reviewStatus: ReviewStatus.draft,
    translationStatus: LearningTranslationStatus.original,
  );
}

void main() {
  final corpus = [
    article(
      id: 'art-abdest-nasil-alinir',
      title: 'Abdest nasıl alınır?',
      keywords: const ['abdest', 'aptes', 'abdest almak'],
    ),
    article(
      id: 'art-teyemmum-nedir',
      title: 'Teyemmüm nedir?',
      keywords: const ['teyemmum', 'toprakla temizlik'],
    ),
    article(
      id: 'art-imanin-sartlari',
      title: 'İmanın şartları',
      keywords: const ['iman', 'amentu'],
    ),
    article(
      id: 'art-kuran-nedir',
      title: "Kur'an nedir?",
      keywords: const ['kuran', 'mushaf'],
    ),
  ];

  group('Sıralama', () {
    test('exact normalized title → exact confidence, ilk sırada', () {
      final result = AssistantRetriever.rank('Abdest nasıl alınır?', corpus);
      expect(result.confidence, AssistantConfidence.exact);
      expect(result.articles.first.article.id, 'art-abdest-nasil-alinir');
      expect(result.hasGroundedMatch, isTrue);
    });

    test('exact alias → exact', () {
      final result = AssistantRetriever.rank('aptes', corpus);
      expect(result.confidence, AssistantConfidence.exact);
      expect(result.articles.first.article.id, 'art-abdest-nasil-alinir');
    });

    test('başlık sorgunun içindeyse (phrase) → strong', () {
      final result = AssistantRetriever.rank(
        'İmanın şartları nelerdir?',
        corpus,
      );
      expect(result.confidence, AssistantConfidence.strong);
      expect(result.articles.first.article.id, 'art-imanin-sartlari');
      expect(result.hasGroundedMatch, isTrue);
    });

    test('Türkçe normalizasyon: "kuran" → "Kur\'an nedir?"', () {
      final result = AssistantRetriever.rank('kuran', corpus);
      expect(result.articles.first.article.id, 'art-kuran-nedir');
      expect(result.confidence, AssistantConfidence.exact);
    });

    test('Arapça normalizasyon eşleşir (alias)', () {
      final withArabic = [
        ...corpus,
        article(
          id: 'art-salah',
          title: 'Namaz',
          keywords: const ['الصلاة', 'namaz'],
        ),
      ];
      final result = AssistantRetriever.rank('الصلاة', withArabic);
      expect(result.articles.first.article.id, 'art-salah');
    });

    test('en fazla 3 makale döner', () {
      final many = [
        for (var i = 0; i < 8; i++)
          article(
            id: 'art-temizlik-$i',
            title: 'Temizlik konusu $i',
            keywords: const ['temizlik'],
          ),
      ];
      final result = AssistantRetriever.rank('temizlik', many);
      expect(result.articles.length, lessThanOrEqualTo(3));
      expect(result.articles.length, 3);
    });

    test('zayıf/ilişkisiz sorgu grounded eşleşme üretmez', () {
      final result = AssistantRetriever.rank('blockchain teknolojisi', corpus);
      expect(result.hasGroundedMatch, isFalse);
      expect(
        result.confidence,
        anyOf(AssistantConfidence.insufficient, AssistantConfidence.related),
      );
    });

    test('tek zayıf token → related (grounded değil)', () {
      // "temizlik" yalnız summary/özette geçen zayıf bir sinyal olabilir.
      final weak = [
        article(
          id: 'art-x',
          title: 'Bambaşka bir başlık',
          summary: 'İçinde temizlik kelimesi geçen özet.',
          keywords: const [],
        ),
      ];
      final result = AssistantRetriever.rank('temizlik', weak);
      expect(result.confidence, AssistantConfidence.related);
      expect(result.hasGroundedMatch, isFalse);
    });
  });
}
