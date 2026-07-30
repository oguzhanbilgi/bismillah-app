import 'dart:convert';

import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/learn/data/learning_content_parser.dart';
import 'package:bismillah_app/features/learn/domain/entities/knowledge_source.dart';
import 'package:bismillah_app/features/official_answers/data/official_answer_index_parser.dart';
import 'package:bismillah_app/features/official_answers/domain/entities/official_answer_index.dart';
import 'package:bismillah_app/features/official_answers/domain/entities/official_answer_record.dart';
import 'package:bismillah_app/features/official_answers/domain/repositories/official_answer_repository.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

/// Asset tabanlı resmî cevap / fetva dizini deposu (TASK 092 foundation).
///
/// Tamamen OFFLINE: HTTP/Firebase YOKTUR. JSON YALNIZ bu data katmanında
/// parse edilir. Cache: her locale ilk başarılı okumadan sonra bellekte
/// tutulur.
///
/// TASK 092'de bu depo HİÇBİR yerden çağrılmaz (Assistant entegrasyonu
/// TASK 093'ündür) — bağımsız olarak test edilir.
final class AssetOfficialAnswerRepository implements OfficialAnswerRepository {
  AssetOfficialAnswerRepository({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  static const String _sourcesPath = 'assets/content/learn/sources.json';
  static const Set<String> _supportedLocales = {'tr', 'en', 'ar'};
  static const String _fallbackLocale = 'tr';

  final AssetBundle _bundle;

  Map<String, KnowledgeSource>? _sourcesById;
  final Map<String, OfficialAnswerIndex> _indexByLocale = {};

  String _resolveLocale(String locale) =>
      _supportedLocales.contains(locale) ? locale : _fallbackLocale;

  Future<Map<String, KnowledgeSource>> _loadSourcesById() async {
    final cached = _sourcesById;
    if (cached != null) {
      return cached;
    }
    final decoded = json.decode(await _bundle.loadString(_sourcesPath));
    final sources = LearningContentParser.parseSources(decoded);
    final byId = {for (final source in sources) source.id: source};
    _sourcesById = byId;
    return byId;
  }

  Future<OfficialAnswerIndex> _loadIndex(String locale) async {
    final cached = _indexByLocale[locale];
    if (cached != null) {
      return cached;
    }
    final validSources = await _loadSourcesById();
    final decoded = json.decode(
      await _bundle.loadString(
        'assets/content/official_answers/index_$locale.json',
      ),
    );
    final index = OfficialAnswerIndexParser.parseIndex(
      decoded,
      expectedLocale: locale,
      validSources: validSources,
    );
    _indexByLocale[locale] = index;
    return index;
  }

  /// Ortak hata sarmalayıcı — parse/asset hatası kullanıcıya sızmaz, sakin
  /// [StorageFailure] olur. Learn'e ASLA düşülmez (fallback yok).
  ///
  /// [Error] (ör. bozuk bir asset'in [OfficialAnswerRecord] kurucusundan
  /// kaçan bir [ArgumentError]) de burada YUTULUR: aksi hâlde kayıt id'si ve
  /// doğrulama ayrıntıları içeren ham hata mesajı depo sınırını aşıp dışa
  /// SIZARDI. Mesaj metni hiçbir durumda [Result.failure]'a taşınmaz.
  Future<Result<T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Result.success(await body());
    } on ContentSchemaError {
      return const Result.failure(StorageFailure());
    } on Exception {
      return const Result.failure(StorageFailure());
    } on Error {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<OfficialAnswerIndex> getIndex(String locale) {
    final resolved = _resolveLocale(locale);
    return _guard(() => _loadIndex(resolved));
  }

  @override
  ResultFuture<List<OfficialAnswerRecord>> getPublished(String locale) {
    final resolved = _resolveLocale(locale);
    return _guard(() async {
      final index = await _loadIndex(resolved);
      return index.published;
    });
  }

  @override
  ResultFuture<OfficialAnswerRecord?> getById(String locale, String id) {
    final resolved = _resolveLocale(locale);
    return _guard(() async {
      final index = await _loadIndex(resolved);
      for (final answer in index.published) {
        if (answer.id == id) {
          return answer;
        }
      }
      return null;
    });
  }
}
