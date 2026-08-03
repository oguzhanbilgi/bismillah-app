import 'dart:convert';
import 'dart:io';

import 'package:bismillah_app/features/learn/data/learning_content_parser.dart';
import 'package:bismillah_app/features/learn/domain/entities/knowledge_source.dart';
import 'package:bismillah_app/features/profile/domain/app_source_link_service.dart';
import 'package:bismillah_app/features/profile/domain/app_source_reference.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 094 §B — TASK 086 bulgusu **F2**: kaynak künyelerinin ikinci bir
/// elle tutulan kopyası ve kayma (drift) riski.
///
/// `sources.json` TEK doğruluk kaynağıdır. Bu dosyadaki testler, ileride
/// biri ikinci bir kanonik kaynak tanımı eklerse BAŞARISIZ olur.
void main() {
  late List<KnowledgeSource> registry;
  late Map<String, KnowledgeSource> registryById;

  setUpAll(() {
    final raw = File(
      'assets/content/learn/sources.json',
    ).readAsStringSync();
    registry = LearningContentParser.parseSources(json.decode(raw));
    registryById = {for (final s in registry) s.id: s};
  });

  group('§B — sources.json kanonik kayıt defteridir', () {
    test('kayıt defterinde YİNELENEN kimlik yoktur', () {
      final ids = registry.map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length, reason: ids.join(', '));
    });

    test('kayıt defterine bağlı HER kimlik gerçekten ÇÖZÜLÜR', () {
      final referenced = kAppSourceReferences
          .where((s) => s.origin == AppSourceOrigin.registry)
          .map((s) => s.registrySourceId!)
          .toList();

      expect(referenced, isNotEmpty);
      for (final id in referenced) {
        expect(
          registryById.containsKey(id),
          isTrue,
          reason: 'Üretimdeki kaynak kimliği sources.json\'da YOK: $id',
        );
      }
    });

    test('kayıt defterine bağlı kimlikler YİNELENMEZ', () {
      final referenced = kAppSourceReferences
          .where((s) => s.origin == AppSourceOrigin.registry)
          .map((s) => s.registrySourceId!)
          .toList();
      expect(referenced.toSet().length, referenced.length);
    });
  });

  group('§B — ikinci bir elle tutulan künye kopyası KALMADI', () {
    // Bu, F2'nin asıl regresyon korumasıdır: kayıt defterine bağlı bir
    // kaynağın adı/dili/adresi app_source_reference.dart içinde TEKRAR
    // yazılırsa bu test başarısız olur.
    test(
      'app_source_reference.dart hiçbir diyanet.gov.tr adresi veya kayıtlı '
      'kaynak başlığı İÇERMEZ',
      () {
        final source = File(
          'lib/features/profile/domain/app_source_reference.dart',
        ).readAsStringSync();

        expect(
          source.contains('diyanet.gov.tr'),
          isFalse,
          reason:
              'Kayıt defterine bağlı bir URL yeniden elle yazılmış — '
              'sources.json tek doğruluk kaynağı olmalı (F2).',
        );

        for (final registered in registry) {
          expect(
            source.contains(registered.title),
            isFalse,
            reason:
                'Kayıtlı kaynak başlığı elle kopyalanmış: '
                '${registered.title} (F2 kayması).',
          );
        }
      },
    );

    test(
      'altyapı kaynakları kayıt defterinde YOKTUR (bu yüzden kopya değildir)',
      () {
        final infrastructure = kAppSourceReferences
            .where((s) => s.origin == AppSourceOrigin.infrastructure)
            .toList();
        expect(infrastructure, isNotEmpty);

        for (final entry in infrastructure) {
          final name = entry.infrastructureName!;
          expect(
            registry.any((s) => s.title == name),
            isFalse,
            reason:
                '$name hem altyapı listesinde hem kayıt defterinde — '
                'tek tanım kalmalı.',
          );
        }
      },
    );
  });

  group('§B — künye alanları kayıt defteriyle BİREBİR aynıdır', () {
    test('çözülen ad/dil/adres sources.json değerleriyle eşleşir', () {
      for (final entry in kAppSourceReferences.where(
        (s) => s.origin == AppSourceOrigin.registry,
      )) {
        final registered = registryById[entry.registrySourceId!]!;
        // Çözüm mantığı resolvedAppSourcesProvider ile AYNI alanları
        // kullanır; burada kaynak-of-truth eşlemesi doğrulanır.
        expect(registered.title, isNotEmpty);
        expect(registered.originalLanguage, isNotEmpty);
        expect(registered.canonicalUrl, startsWith('https://'));
      }
    });

    test('kayıt defterine bağlı HER adres allowlist\'ten geçer', () {
      for (final entry in kAppSourceReferences.where(
        (s) => s.origin == AppSourceOrigin.registry,
      )) {
        final registered = registryById[entry.registrySourceId!]!;
        expect(
          AppSourceDomains.isAllowed(registered.canonicalUrl),
          isTrue,
          reason: registered.id,
        );
      }
    });
  });

  group('§B — yayınlanan içerik bilinmeyen kaynağa referans VEREMEZ', () {
    test('her locale\'de her makalenin sourceIds kimlikleri çözülür', () {
      for (final locale in ['tr', 'en', 'ar']) {
        final raw = File(
          'assets/content/learn/articles_$locale.json',
        ).readAsStringSync();
        final articles = LearningContentParser.parseArticles(
          json.decode(raw),
          expectedLocale: locale,
        );
        expect(articles, isNotEmpty, reason: locale);

        for (final article in articles) {
          for (final id in article.sourceIds) {
            expect(
              registryById.containsKey(id),
              isTrue,
              reason:
                  '[$locale] ${article.id} bilinmeyen kaynağa referans '
                  'veriyor: $id',
            );
          }
        }
      }
    });
  });
}
