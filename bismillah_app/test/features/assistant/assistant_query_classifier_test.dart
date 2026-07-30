import 'package:bismillah_app/features/assistant/domain/services/assistant_query_classifier.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_enums.dart';
import 'package:flutter_test/flutter_test.dart';

/// Deterministik soru sınıflandırması (TASK 059 §7/§17).
void main() {
  AssistantQueryClass c(String text) => AssistantQueryClassifier.classify(text);

  group('Türkçe', () {
    test('abdest nasıl alınır → howTo', () {
      expect(c('Abdest nasıl alınır?'), AssistantQueryClass.howTo);
    });

    test('teyemmüm nedir → definition', () {
      expect(c('Teyemmüm nedir?'), AssistantQueryClass.definition);
    });

    test('caiz midir → halalHaramVerdict', () {
      expect(c('Bu caiz midir?'), AssistantQueryClass.halalHaramVerdict);
      expect(c('Bu haram mı?'), AssistantQueryClass.halalHaramVerdict);
      expect(c('Bu helal mi?'), AssistantQueryClass.halalHaramVerdict);
    });

    test('bozar mı → worshipRule', () {
      expect(c('Kan abdesti bozar mı?'), AssistantQueryClass.worshipRule);
    });

    test('kişisel olay → personalCase', () {
      expect(
        c('Ben bu şartlarda kredi çektim, günah mı?'),
        AssistantQueryClass.personalCase,
      );
      expect(
        c('Benim özel durumum ne olur?'),
        AssistantQueryClass.personalCase,
      );
    });

    test('delil talebi → evidenceRequest', () {
      expect(c('Bunun delili nedir?'), AssistantQueryClass.evidenceRequest);
    });

    test('genel öğrenme → generalLearning', () {
      expect(c('Namaz vakitleri'), AssistantQueryClass.generalLearning);
    });

    test('boş/anlamsız → unknown', () {
      expect(c(''), AssistantQueryClass.unknown);
      expect(c('  '), AssistantQueryClass.unknown);
    });
  });

  group('English', () {
    test('how is wudu performed → howTo', () {
      expect(c('How is wudu performed?'), AssistantQueryClass.howTo);
    });

    test('what is tayammum → definition', () {
      expect(c('What is tayammum?'), AssistantQueryClass.definition);
    });

    test('permissible/halal/forbidden/sinful → halalHaramVerdict', () {
      expect(c('Is this permissible?'), AssistantQueryClass.halalHaramVerdict);
      expect(c('Is this forbidden?'), AssistantQueryClass.halalHaramVerdict);
      expect(c('Is this sinful?'), AssistantQueryClass.halalHaramVerdict);
    });
  });

  group('العربية', () {
    test('كيف … → howTo', () {
      expect(c('كيف يُؤخذ الوضوء؟'), AssistantQueryClass.howTo);
    });

    test('ما هو … → definition', () {
      expect(c('ما هو التيمم؟'), AssistantQueryClass.definition);
    });

    test('جائز/حرام/حلال → halalHaramVerdict', () {
      expect(c('هل هذا جائز؟'), AssistantQueryClass.halalHaramVerdict);
      expect(c('هل هذا حرام؟'), AssistantQueryClass.halalHaramVerdict);
    });
  });

  group('Hassas hüküm işareti (TASK 094 §A — TEK kanonik yüklem)', () {
    // Tablo tüm AssistantQueryClass değerlerini kapsar; switch'in `default`
    // içermemesi sayesinde enum'a yeni bir değer eklenirse bu tablo
    // GÜNCELLENMEDEN derleme HATASI alınır (assistant_query_classifier.dart).
    const expected = <AssistantQueryClass, bool>{
      AssistantQueryClass.halalHaramVerdict: true,
      AssistantQueryClass.worshipRule: true,
      AssistantQueryClass.personalCase: true,
      AssistantQueryClass.howTo: false,
      AssistantQueryClass.definition: false,
      AssistantQueryClass.evidenceRequest: false,
      AssistantQueryClass.generalLearning: false,
      AssistantQueryClass.unknown: false,
    };

    test('her AssistantQueryClass değeri tabloda temsil edilir', () {
      expect(expected.keys.toSet(), AssistantQueryClass.values.toSet());
    });

    for (final entry in expected.entries) {
      test('${entry.key} → isSensitiveVerdict == ${entry.value}', () {
        expect(
          AssistantQueryClassifier.isSensitiveVerdict(entry.key),
          entry.value,
        );
      });
    }
  });
}
