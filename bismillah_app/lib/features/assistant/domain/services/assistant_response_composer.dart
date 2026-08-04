import 'package:bismillah_app/features/assistant/domain/entities/assistant_response.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_source_reference.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_enums.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_response_strings.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_article.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';

/// Retrieval sonrası hazırlanmış makale: kaynak künyesi çözülmüş hâli.
final class AssistantGroundedArticle {
  const AssistantGroundedArticle({required this.article, this.source});

  final LearningArticle article;

  /// Makalenin doğrulanmış birincil kaynağı (exact locator ile).
  final AssistantSourceReference? source;
}

/// Doğrulanmış makale bloklarından DETERMİNİSTİK cevap üretimi (TASK 059
/// §9). Harici AI YOKTUR.
abstract final class AssistantResponseComposer {
  static AssistantResponse compose({
    required AssistantQueryClass queryClass,
    required AssistantConfidence confidence,
    required List<AssistantGroundedArticle> grounded,
    required AssistantResponseStrings strings,
    String? officialGuidanceUrl,
  }) {
    final hasGrounded =
        (confidence == AssistantConfidence.exact ||
            confidence == AssistantConfidence.strong) &&
        grounded.isNotEmpty;

    final related = [
      for (final g in grounded)
        AssistantRelatedArticle(
          id: g.article.id,
          slug: g.article.slug,
          title: g.article.title,
        ),
    ];
    final sources = [
      for (final g in grounded)
        if (g.source != null) g.source!,
    ];
    final translationNote =
        grounded.any(
          (g) =>
              g.article.translationStatus ==
              LearningTranslationStatus.explanatoryTranslation,
        )
        ? strings.translationNote
        : null;

    switch (queryClass) {
      // --- Hassas hüküm: yalnız doğrulanmış fatwa/officialAnswer ile kesin
      //     cevap; aksi hâlde güvenli yönlendirme (TASK 059 §2/§9). -------
      case AssistantQueryClass.halalHaramVerdict:
        final verdictArticle = hasGrounded
            ? _firstVerdictCapable(grounded)
            : null;
        if (verdictArticle != null) {
          return _groundedAnswer(
            answerType: AssistantAnswerType.directVerifiedAnswer,
            confidence: confidence,
            primary: verdictArticle,
            sources: sources,
            related: related,
            translationNote: translationNote,
            safetyNotice: strings.generalInfoNotPersonalRuling,
          );
        }
        // Doğrulanmış resmî cevap yok → kesin hüküm verilmez.
        //
        // TASK 095D: hüküm verilmemesi, ELDEKİ genel bilginin künyesiz
        // bırakılmasını gerektirmez. Retrieval gerçekten grounded ise
        // (exact/strong) o yayınlanmış açıklamanın kaynak künyesi de
        // gösterilir — `personalCase` dalının zaten yaptığı şeyin AYNISI.
        // Cevap türü, ret ve güvenlik notu DEĞİŞMEZ; hiçbir kaynak hükmün
        // dayanağı olarak sunulmaz, `confidence` bilinçli olarak
        // `insufficient` kalır (hüküm için delil YETERSİZDİR).
        return AssistantResponse(
          answerType: AssistantAnswerType.officialFatwaRequired,
          confidence: AssistantConfidence.insufficient,
          answer: strings.officialFatwaRequired,
          shortSummary: strings.officialFatwaRequired,
          relatedArticles: related,
          sourceReferences: hasGrounded ? sources : const [],
          safetyNotice: strings.generalInfoNotPersonalRuling,
          shouldOfferOfficialGuidance: true,
          officialGuidanceUrl: officialGuidanceUrl,
        );

      // --- Kişisel olay: kişiye özel fetva YOK; genel bilgi + yönlendirme.
      case AssistantQueryClass.personalCase:
        return AssistantResponse(
          answerType: AssistantAnswerType.qualifiedGuidanceRequired,
          confidence: hasGrounded
              ? confidence
              : AssistantConfidence.insufficient,
          answer: strings.qualifiedGuidance,
          shortSummary: strings.qualifiedGuidance,
          relatedArticles: related,
          sourceReferences: hasGrounded ? sources : const [],
          safetyNotice: hasGrounded ? strings.personalCaseGeneralInfo : null,
          shouldOfferOfficialGuidance: true,
          officialGuidanceUrl: officialGuidanceUrl,
        );

      // --- İbadet kuralı: ilmihalden genel bilgi (kişisel duruma hüküm
      //     UYGULANMAZ); grounded değilse güvenli yönlendirme. -----------
      case AssistantQueryClass.worshipRule:
        if (!hasGrounded) {
          return _noSource(strings, related, officialGuidanceUrl);
        }
        return _groundedAnswer(
          answerType: AssistantAnswerType.generalSourceSummary,
          confidence: confidence,
          primary: grounded.first,
          sources: sources,
          related: related,
          translationNote: translationNote,
          safetyNotice: strings.generalInfoNotPersonalRuling,
        );

      case AssistantQueryClass.howTo:
        if (!hasGrounded) {
          return _noSource(strings, related, officialGuidanceUrl);
        }
        return _groundedAnswer(
          answerType: AssistantAnswerType.stepByStepGuide,
          confidence: confidence,
          primary: grounded.first,
          sources: sources,
          related: related,
          translationNote: translationNote,
        );

      case AssistantQueryClass.definition:
        if (!hasGrounded) {
          return _noSource(strings, related, officialGuidanceUrl);
        }
        return _groundedAnswer(
          answerType: AssistantAnswerType.definition,
          confidence: confidence,
          primary: grounded.first,
          sources: sources,
          related: related,
          translationNote: translationNote,
        );

      case AssistantQueryClass.evidenceRequest:
      case AssistantQueryClass.generalLearning:
        if (!hasGrounded) {
          return _noSource(strings, related, officialGuidanceUrl);
        }
        return _groundedAnswer(
          answerType: AssistantAnswerType.generalSourceSummary,
          confidence: confidence,
          primary: grounded.first,
          sources: sources,
          related: related,
          translationNote: translationNote,
        );

      case AssistantQueryClass.unknown:
        return _noSource(strings, related, officialGuidanceUrl);
    }
  }

  static AssistantResponse _groundedAnswer({
    required AssistantAnswerType answerType,
    required AssistantConfidence confidence,
    required AssistantGroundedArticle primary,
    required List<AssistantSourceReference> sources,
    required List<AssistantRelatedArticle> related,
    String? translationNote,
    String? safetyNotice,
  }) {
    final article = primary.article;
    return AssistantResponse(
      answerType: answerType,
      confidence: confidence,
      answer: _composeAnswer(article),
      shortSummary: article.summary,
      steps: _collect(article, LearningSectionType.steps, useItems: true),
      keyPoints: _collect(article, LearningSectionType.keyPoint),
      practicalAction: _firstText(article, LearningSectionType.practicalAction),
      differenceNote: article.differenceNote,
      safetyNotice: safetyNotice,
      sourceReferences: sources,
      relatedArticles: related,
    );
  }

  static AssistantResponse _noSource(
    AssistantResponseStrings strings,
    List<AssistantRelatedArticle> related,
    String? officialGuidanceUrl,
  ) {
    return AssistantResponse(
      answerType: AssistantAnswerType.noVerifiedSource,
      confidence: AssistantConfidence.insufficient,
      answer: strings.noVerifiedSource,
      shortSummary: strings.noVerifiedSource,
      // "İlgili Learn kategorilerini öner": zayıf eşleşmeler öneri olarak
      // verilir (hüküm/kaynak olarak DEĞİL).
      relatedArticles: related,
      shouldOfferOfficialGuidance: officialGuidanceUrl != null,
      officialGuidanceUrl: officialGuidanceUrl,
    );
  }

  static AssistantGroundedArticle? _firstVerdictCapable(
    List<AssistantGroundedArticle> grounded,
  ) {
    for (final g in grounded) {
      if (g.article.contentType == LearningContentType.officialFatwa &&
          g.article.isSourceBodyVerified) {
        return g;
      }
    }
    return null;
  }

  /// Ana cevap = özet + (varsa) ilk paragraf; adım listesi ayrıca gösterilir.
  static String _composeAnswer(LearningArticle article) {
    final firstParagraph = _firstText(article, LearningSectionType.paragraph);
    if (firstParagraph == null || firstParagraph == article.summary) {
      return article.summary;
    }
    return '${article.summary}\n\n$firstParagraph';
  }

  static List<String> _collect(
    LearningArticle article,
    LearningSectionType type, {
    bool useItems = false,
  }) {
    final out = <String>[];
    for (final section in article.sections) {
      if (section.type != type) {
        continue;
      }
      if (useItems) {
        out.addAll(section.items);
      } else if (section.text != null) {
        out.add(section.text!);
      }
    }
    return out;
  }

  static String? _firstText(LearningArticle article, LearningSectionType type) {
    for (final section in article.sections) {
      if (section.type == type && section.text != null) {
        return section.text;
      }
    }
    return null;
  }
}
