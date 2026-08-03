import 'dart:convert';
import 'dart:io';

import 'package:bismillah_app/features/learn/data/learning_content_parser.dart';
import 'package:bismillah_app/features/learn/domain/entities/knowledge_source.dart';
import 'package:bismillah_app/features/profile/domain/app_source_reference.dart';

/// Widget testleri için kanonik künye listesi (TASK 094 §B).
///
/// `sources.json` DOSYADAN SENKRON okunur; böylece widget testi gerçek
/// `AssetBundle` G/Ç zamanlamasına bağlı kalmaz (`pumpAndSettle`, henüz
/// tamamlanmamış bir asset future'ını beklemeyebilir ve test kırılgan olur).
///
/// Veri UYDURULMAZ: üretimdeki `resolvedAppSourcesProvider` ile AYNI kayıt
/// defterinden, AYNI alanlarla üretilir. Kayıt defteriyle gerçek eşleşme
/// ayrıca `task_094_source_drift_test.dart` içinde doğrulanır.
List<ResolvedAppSource> canonicalResolvedAppSources() {
  final raw = File('assets/content/learn/sources.json').readAsStringSync();
  final registry = LearningContentParser.parseSources(json.decode(raw));
  final byId = <String, KnowledgeSource>{
    for (final source in registry) source.id: source,
  };

  return [
    for (final reference in kAppSourceReferences)
      switch (reference.origin) {
        AppSourceOrigin.infrastructure => ResolvedAppSource(
          purpose: reference.purpose,
          name: reference.infrastructureName!,
          originalLanguage: reference.infrastructureLanguage!,
          canonicalUrl: reference.infrastructureUrl!,
        ),
        AppSourceOrigin.registry => () {
          final source = byId[reference.registrySourceId!];
          if (source == null) {
            throw StateError(
              'Kayıtlı kaynak çözülemedi: ${reference.registrySourceId}',
            );
          }
          return ResolvedAppSource(
            purpose: reference.purpose,
            name: source.title,
            originalLanguage: source.originalLanguage,
            canonicalUrl: source.canonicalUrl,
          );
        }(),
      },
  ];
}
