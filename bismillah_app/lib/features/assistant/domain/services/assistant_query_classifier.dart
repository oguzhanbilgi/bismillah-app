import 'package:bismillah_app/core/text/islamic_text_normalizer.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_enums.dart';

/// Deterministik, test edilebilir soru sınıflandırması (TASK 059 §7).
///
/// Yeni bir NLP paketi EKLENMEZ: paylaşılan [IslamicTextNormalizer] ile
/// tr/en/ar için tek kelime token eşleşmesi + öbek (spaceless) eşleşmesi
/// kullanılır. Sıra ÖNEMLİDİR: kişisel durum ve hassas hüküm sinyalleri
/// genel sınıflardan ÖNCE gelir (güvenli taraf).
abstract final class AssistantQueryClassifier {
  // --- Tek kelime (token) anahtarları ---------------------------------------

  static const Set<String> _firstPerson = {
    'ben',
    'benim',
    'bana',
    'bende',
    'my',
    'أنا',
    'حالتي',
    'وضعي',
  };

  static const Set<String> _situation = {
    'durum',
    'durumum',
    'durumumda',
    'durumunda',
    'sartlar',
    'sartlarda',
    'case',
    'situation',
  };

  static const Set<String> _evidence = {
    'delil',
    'delili',
    'evidence',
    'proof',
    'دليل',
    'برهان',
  };

  static const Set<String> _worshipRule = {'bozar', 'invalidate', 'يبطل'};

  static const Set<String> _verdict = {
    'caiz',
    'haram',
    'helal',
    'gunah',
    'mekruh',
    'sakincali',
    'permissible',
    'halal',
    'forbidden',
    'sinful',
    'جائز',
    'حرام',
    'حلال',
    'مكروه',
    'يجوز',
  };

  static const Set<String> _howTo = {'nasil', 'how', 'كيف'};

  static const Set<String> _definition = {'nedir', 'tanim', 'تعريف'};

  // --- Öbek (normalized, spaceless) anahtarları -----------------------------

  static const List<String> _situationPhrases = [
    'in my case',
    'my situation',
    'for me',
    'benim durumum',
    'kendi durumum',
  ];

  static const List<String> _verdictPhrases = [
    'uygun mu',
    'uygun mudur',
    'dinen sakincali',
    'allowed in islam',
  ];

  static const List<String> _definitionPhrases = [
    'ne demek',
    'ne demektir',
    'what is',
    'what are',
    'what does',
    'ما هو',
    'ما هي',
    'ما معنى',
  ];

  /// Ana giriş: sorguyu tek bir sınıfa yerleştirir.
  static AssistantQueryClass classify(String text) {
    final normalizedFull = IslamicTextNormalizer.normalize(text);
    if (normalizedFull.length < 2) {
      return AssistantQueryClass.unknown;
    }
    final tokens = IslamicTextNormalizer.tokenize(text).toSet();

    final hasFirstPerson = _anyToken(tokens, _firstPerson);
    final hasSituation =
        _anyToken(tokens, _situation) ||
        _anyPhrase(normalizedFull, _situationPhrases);
    final hasEvidence = _anyToken(tokens, _evidence);
    final hasWorshipRule = _anyToken(tokens, _worshipRule);
    final hasVerdict =
        _anyToken(tokens, _verdict) ||
        _anyPhrase(normalizedFull, _verdictPhrases);
    final hasHowTo = _anyToken(tokens, _howTo);
    final hasDefinition =
        _anyToken(tokens, _definition) ||
        _anyPhrase(normalizedFull, _definitionPhrases);

    // 1) Kişisel olay: birinci şahıs + (hüküm bağlamı VEYA durum bağlamı).
    //    Kişisel duruma ASLA hüküm uygulanmaz — en önce elenir.
    if (hasFirstPerson && (hasVerdict || hasWorshipRule || hasSituation)) {
      return AssistantQueryClass.personalCase;
    }

    // 2) Delil talebi.
    if (hasEvidence) {
      return AssistantQueryClass.evidenceRequest;
    }

    // 3) İbadeti bozan durum sorusu (ilmihalden cevaplanabilir ama yine
    //    hassastır: kişisel duruma kesin hüküm YOK).
    if (hasWorshipRule) {
      return AssistantQueryClass.worshipRule;
    }

    // 4) Hassas hüküm sorgusu (caiz/haram/helal/…).
    if (hasVerdict) {
      return AssistantQueryClass.halalHaramVerdict;
    }

    // 5) Nasıl yapılır.
    if (hasHowTo) {
      return AssistantQueryClass.howTo;
    }

    // 6) Tanım.
    if (hasDefinition) {
      return AssistantQueryClass.definition;
    }

    // 7) Genel öğrenme (anlamlı içerik token'ı varsa).
    if (tokens.isNotEmpty) {
      return AssistantQueryClass.generalLearning;
    }

    return AssistantQueryClass.unknown;
  }

  /// Hüküm sınıfları kişisel duruma yeni hüküm çıkaramaz (composer güvenlik
  /// davranışını buradan okur). Bu, TÜM kalıcılık kararlarının okuduğu TEK
  /// kanonik yüklemdir (TASK 094 §A) — ikinci bir kopya oluşturulmamalıdır.
  ///
  /// Bilinçli olarak `default`/wildcard YOKTUR: [AssistantQueryClass]'a yeni
  /// bir değer eklenirse bu switch derleme zamanında HATA verir, yeni sınıf
  /// sessizce "hassas değil" sayılmaz.
  static bool isSensitiveVerdict(AssistantQueryClass queryClass) =>
      switch (queryClass) {
        AssistantQueryClass.halalHaramVerdict => true,
        AssistantQueryClass.worshipRule => true,
        AssistantQueryClass.personalCase => true,
        AssistantQueryClass.howTo => false,
        AssistantQueryClass.definition => false,
        AssistantQueryClass.evidenceRequest => false,
        AssistantQueryClass.generalLearning => false,
        AssistantQueryClass.unknown => false,
      };

  /// Anahtar kelimeler ham (tr/en/ar) yazılır; token'lar normalize
  /// olduğundan karşılaştırmadan önce anahtar da normalize edilir.
  static bool _anyToken(Set<String> tokens, Set<String> keywords) {
    for (final keyword in keywords) {
      if (tokens.contains(IslamicTextNormalizer.normalize(keyword))) {
        return true;
      }
    }
    return false;
  }

  static bool _anyPhrase(String normalizedFull, List<String> phrases) {
    for (final phrase in phrases) {
      if (normalizedFull.contains(IslamicTextNormalizer.normalize(phrase))) {
        return true;
      }
    }
    return false;
  }
}
