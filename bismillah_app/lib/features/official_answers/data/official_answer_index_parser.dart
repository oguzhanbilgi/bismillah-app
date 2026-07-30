import 'package:bismillah_app/features/learn/data/learning_content_parser.dart'
    show ContentSchemaError;
import 'package:bismillah_app/features/learn/domain/entities/knowledge_source.dart';
import 'package:bismillah_app/features/learn/domain/entities/source_verification.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';
import 'package:bismillah_app/features/official_answers/domain/entities/official_answer_index.dart';
import 'package:bismillah_app/features/official_answers/domain/entities/official_answer_record.dart';
import 'package:bismillah_app/features/official_answers/domain/value_objects/official_answer_publication_gate.dart';

/// Resmî cevap dizini asset'lerinin katı parser + validator'ı (TASK 092
/// foundation).
///
/// [LearningContentParser] ile AYNI disiplini uygular ve AYNI
/// [ContentSchemaError] tipini fırlatır: bozuk veri sessizce yutulmaz.
/// Bu sınıf saf Dart'tır (Flutter/asset bağımlılığı yok).
///
/// TASK 092, sıfır üretim kaydıyla teslim edilir — bu parser gelecekteki
/// gerçek kayıtlar için sözleşmedir.
abstract final class OfficialAnswerIndexParser {
  /// Desteklenen şema sürümü. Learn ile aynı sayısal alan adı taşınır ama
  /// bağımsız bir sabittir — Learn'ün sürümüyle birlikte İLERLEMEZ.
  static const int supportedSchemaVersion = 1;

  static OfficialAnswerIndex parseIndex(
    Object? decoded, {
    required String expectedLocale,
    // ZORUNLU (opsiyonel DEĞİL): bu harita olmadan yetki-kaynağı TÜR
    // kontrolü ve sourceUrl-derinlik kontrolü SESSİZCE atlanır — bu, TASK
    // 093'te bir çağıranın fark etmeden daha zayıf bir kapı elde etmesine
    // yol açardı. Bu yüzden parametre BİLİNÇLİ OLARAK zorunlu tutulur.
    required Map<String, KnowledgeSource> validSources,
  }) {
    final root = _asMap(decoded, 'index_$expectedLocale.json');
    _checkSchemaVersion(root, 'index_$expectedLocale.json');

    final declaredLocale = _requireString(root, 'locale', 'index');
    if (declaredLocale != expectedLocale) {
      throw ContentSchemaError(
        'Locale uyuşmazlığı: beklenen $expectedLocale, bulunan $declaredLocale',
      );
    }

    final rawList = _asList(root['answers'], 'answers');
    final answers = <OfficialAnswerRecord>[];
    final seenIds = <String>{};

    for (final raw in rawList) {
      final map = _asMap(raw, 'answer');
      final id = _requireString(map, 'id', 'answer');
      if (!id.startsWith('oa-')) {
        throw ContentSchemaError(
          'Resmî cevap id\'si "oa-" ile başlamalıdır: $id',
        );
      }
      if (id.contains(':')) {
        throw ContentSchemaError(
          'Resmî cevap id\'si ":" karakteri içeremez (plan öğesi ayıracı): $id',
        );
      }
      if (!seenIds.add(id)) {
        throw ContentSchemaError('Yinelenen resmî cevap id: $id');
      }

      final sourceId = (map['sourceId'] as String? ?? '').trim();
      KnowledgeSource? resolvedSource;
      if (sourceId.isNotEmpty) {
        final source = validSources[sourceId];
        if (source == null) {
          throw ContentSchemaError(
            'Kayıt $id tanımsız kaynağa referans veriyor: $sourceId',
          );
        }
        // Ek savunma katmanı: kaynağın kendi kurucusu zaten
        // OfficialSourceDomains.isAllowed'ı zorunlu kılar; burası kaynak
        // ÇÖZÜMÜ anında da aynı kapının geçildiğini AÇIKÇA doğrular.
        if (!OfficialSourceDomains.isAllowed(source.canonicalUrl)) {
          throw ContentSchemaError(
            'Kayıt $id izin verilmeyen alan adındaki bir kaynağa bağlı: '
            '${source.canonicalUrl}',
          );
        }
        resolvedSource = source;
      }

      final reviewStatus = _parseEnum(
        ReviewStatus.values,
        _requireString(map, 'reviewStatus', 'answer[$id]'),
        'reviewStatus',
      );
      final isGeneralInformationOnly = map['isGeneralInformationOnly'];
      if (isGeneralInformationOnly is! bool) {
        throw ContentSchemaError(
          'answer[$id].isGeneralInformationOnly zorunlu bir boolean alandır',
        );
      }

      final OfficialAnswerRecord record;
      try {
        record = OfficialAnswerRecord(
          id: id,
          topic: _requireString(map, 'topic', 'answer[$id]'),
          summary: _requireString(map, 'summary', 'answer[$id]'),
          sourceId: sourceId,
          reviewStatus: reviewStatus,
          locale: expectedLocale,
          verification: _parseVerification(map['verification'], id),
          sourceUrl: (map['sourceUrl'] as String? ?? '').trim(),
          isGeneralInformationOnly: isGeneralInformationOnly,
        );
      } on ArgumentError catch (e) {
        // Kayıt kurucusundaki yayın kapısı reddi de TEK bir tip
        // (ContentSchemaError) olarak dışa yansır — data katmanı iki farklı
        // hata tipiyle uğraşmaz.
        throw ContentSchemaError('Kayıt $id reddedildi: ${e.message}');
      }

      // Kaynak ÇÖZÜLEBİLDİYSE, kapıyı kaynağa özel kurallarla (onaylı yetki
      // kaynağı türü + sourceUrl derinliği) DE burada çalıştır — kayıt
      // kurucusu `source` parametresi olmadan yalnız kayıt-içi kuralları
      // görebilir.
      if (reviewStatus == ReviewStatus.published) {
        final issues = OfficialAnswerPublicationGate.evaluate(
          record,
          source: resolvedSource,
          expectedLocale: expectedLocale,
        );
        if (issues.isNotEmpty) {
          throw ContentSchemaError(
            'Kayıt $id resmî cevap yayın kapısını geçemedi: '
            '${issues.map((i) => i.name).join(', ')}',
          );
        }
      }

      answers.add(record);
    }

    return OfficialAnswerIndex(
      schemaVersion: root['schemaVersion'] as int,
      locale: expectedLocale,
      answers: answers,
    );
  }

  /// Kaynak gövdesi doğrulama kaydını okur (Learn TASK 056A §2 ile AYNI
  /// alan adları ve kural).
  ///
  /// Locator kalite kontrolü BURADA yapılır: genel bir ana sayfa adresi
  /// kesin bir dinî hükme/fetvaya KANIT sayılmaz.
  static SourceVerification? _parseVerification(Object? raw, String answerId) {
    if (raw == null) {
      return null;
    }
    final map = _asMap(raw, 'answer[$answerId].verification');
    final locator = (map['sourceLocator'] as String? ?? '').trim();
    final bodyVerified = map['sourceBodyVerified'] == true;

    if (bodyVerified && _isGenericHomepageLocator(locator)) {
      throw ContentSchemaError(
        'Kayıt $answerId genel bir ana sayfayı kesin kaynak konumu gibi '
        'kullanıyor: "$locator"',
      );
    }

    return SourceVerification(
      sourceBodyVerified: bodyVerified,
      sourceId: _requireString(
        map,
        'sourceId',
        'answer[$answerId].verification',
      ),
      sourceLocator: locator,
      evidenceSummary: (map['evidenceSummary'] as String? ?? '').trim(),
      verifiedAt: (map['verifiedAt'] as String? ?? '').trim(),
      verifiedBy: _parseEnum(
        VerifiedBy.values,
        _requireString(map, 'verifiedBy', 'answer[$answerId].verification'),
        'verifiedBy',
      ),
      verificationMethod: _parseEnum(
        VerificationMethod.values,
        _requireString(
          map,
          'verificationMethod',
          'answer[$answerId].verification',
        ),
        'verificationMethod',
      ),
      blocker: map['blocker'] as String?,
    );
  }

  /// Kesin konum içermeyen locator'lar — [LearningContentParser]'ın aynı
  /// adlı özel (private) kuralının BİREBİR kopyasıdır: o kural dışa açık
  /// değildir, bu yüzden burada TEKRARLANIR (kasıtlı çoğaltma).
  static bool _isGenericHomepageLocator(String locator) {
    if (locator.isEmpty) {
      return true;
    }
    if (!locator.contains(RegExp(r'\s'))) {
      final uri = Uri.tryParse(locator);
      if (uri != null && uri.hasScheme && uri.hasAuthority) {
        return true;
      }
    }
    return false;
  }

  static void _checkSchemaVersion(Map<String, Object?> root, String file) {
    final version = root['schemaVersion'];
    if (version != supportedSchemaVersion) {
      throw ContentSchemaError(
        '$file şema sürümü desteklenmiyor: $version '
        '(beklenen $supportedSchemaVersion)',
      );
    }
  }

  static Map<String, Object?> _asMap(Object? value, String context) {
    if (value is Map<String, Object?>) {
      return value;
    }
    if (value is Map) {
      return value.cast<String, Object?>();
    }
    throw ContentSchemaError('$context geçerli bir nesne değil');
  }

  static List<Object?> _asList(Object? value, String context) {
    if (value is List) {
      return value;
    }
    throw ContentSchemaError('$context geçerli bir liste değil');
  }

  static String _requireString(
    Map<String, Object?> map,
    String key,
    String context,
  ) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    throw ContentSchemaError('$context.$key zorunlu bir metin alanıdır');
  }

  static T _parseEnum<T extends Enum>(
    List<T> values,
    String raw,
    String field,
  ) {
    for (final value in values) {
      if (value.name == raw) {
        return value;
      }
    }
    throw ContentSchemaError('Tanınmayan $field değeri: $raw');
  }
}
