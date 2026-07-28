import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Kanonik içerik-kaynak matrisinin yapısal doğrulaması (TASK 086).
///
/// Bu test dinî içeriği YENİDEN doğrulamaz — makale yayın kapısı, kaynak
/// kaydı ve locale kimlik denetimi zaten
/// `test/features/learn/learn_content_integrity_test.dart` içinde yaşar ve
/// burada TEKRARLANMAZ. Buradaki güvence yalnız yönetişim belgesinin
/// kendisidir: kimlikler tekil mi, durum değerleri geçerli mi, gösterilen
/// depo kanıtı gerçekten var mı.
void main() {
  const matrixPath = '../docs/CONTENT_SOURCE_MATRIX.md';
  const repoRoot = '..';

  const allowedStatuses = <String>{
    'READY',
    'READY WITH DOCUMENTED LIMITATION',
    'REVIEW REQUIRED',
    'BLOCKED',
    'NOT IMPLEMENTED',
  };

  const allowedSourceClasses = <String>{
    'official-primary',
    'reviewed-secondary',
    'internal-ui-copy',
    'local-derived',
    'unresolved',
  };

  const allowedDelivery = <String>{
    'bundled-asset',
    'local-generated-metadata',
    'approved-remote-proxy',
    'not-implemented',
  };

  const allowedConsumers = <String>{
    'Today',
    'Prayer',
    'Quran',
    'Learn',
    'Profile',
    'Assistant',
    'Onboarding',
    'none',
  };

  const requiredFields = <String>[
    'Surface',
    'Content type',
    'Source name',
    'Source class',
    'Evidence',
    'Delivery',
    'Publication status',
    'Source review',
    'TR',
    'EN',
    'AR',
    'Locale rule',
    'Attribution',
    'Licensing',
    'Consumers',
    'Prohibited',
    'Status',
    'Follow-up',
  ];

  final file = File(matrixPath);
  final lines = file.readAsLinesSync();

  // --- Ayrıştırma -----------------------------------------------------------

  /// Özet tablosundaki `| \`id\` | ... | ... | STATUS |` satırları.
  final summary = <String, String>{};
  final summaryOrder = <String>[];

  /// Ayrıntı blokları: `### id` başlığı → alan haritası.
  final rows = <String, Map<String, String>>{};
  final rowOrder = <String>[];

  final summaryRow = RegExp(
    r'^\|\s*`([a-z0-9-]+)`\s*\|[^|]*\|[^|]*\|\s*([A-Z][A-Z ]+)\s*\|$',
  );
  final heading = RegExp(r'^### ([a-z0-9-]+)$');
  final field = RegExp(r'^- \*\*([^:*]+):\*\*\s*(.+)$');

  String? currentRow;
  for (final line in lines) {
    // Satır blokları YALNIZ "### id" başlıkları altında yaşar. Bulgular
    // bölümü de "- **Evidence:**" satırları taşır; yeni bir üst başlık
    // görüldüğünde toplama DURUR, aksi hâlde son satırın alanları ezilir.
    if (line.startsWith('## ')) {
      currentRow = null;
    }
    final summaryMatch = summaryRow.firstMatch(line);
    if (summaryMatch != null) {
      summary[summaryMatch.group(1)!] = summaryMatch.group(2)!.trim();
      summaryOrder.add(summaryMatch.group(1)!);
      continue;
    }
    final headingMatch = heading.firstMatch(line);
    if (headingMatch != null) {
      currentRow = headingMatch.group(1)!;
      rows[currentRow] = <String, String>{};
      rowOrder.add(currentRow);
      continue;
    }
    if (currentRow == null) {
      continue;
    }
    final fieldMatch = field.firstMatch(line);
    if (fieldMatch != null) {
      rows[currentRow]![fieldMatch.group(1)!.trim()] = fieldMatch
          .group(2)!
          .trim();
    }
  }

  group('Matris belgesi', () {
    test('belge okunur ve satır taşır', () {
      expect(file.existsSync(), isTrue, reason: matrixPath);
      expect(rows, isNotEmpty);
    });

    test('içerik alanı kimlikleri TEKİLDİR', () {
      expect(rowOrder.toSet().length, rowOrder.length);
      expect(summaryOrder.toSet().length, summaryOrder.length);
    });

    test('özet tablosu ile ayrıntı blokları BİREBİR örtüşür', () {
      expect(summaryOrder, rowOrder);
    });

    test('özet tablosundaki durum ayrıntı bloğuyla AYNIDIR', () {
      for (final id in rowOrder) {
        expect(summary[id], rows[id]!['Status'], reason: id);
      }
    });
  });

  group('Satır alanları', () {
    test('her satır ZORUNLU alanların tamamını taşır', () {
      for (final id in rowOrder) {
        for (final name in requiredFields) {
          expect(
            rows[id]!.containsKey(name),
            isTrue,
            reason: '$id satırında "$name" alanı yok',
          );
          expect(rows[id]![name], isNotEmpty, reason: '$id / $name');
        }
      }
    });

    test('durum değerleri kapalı kümededir', () {
      for (final id in rowOrder) {
        expect(allowedStatuses, contains(rows[id]!['Status']), reason: id);
      }
    });

    test('kaynak sınıfı kapalı kümededir', () {
      for (final id in rowOrder) {
        expect(
          allowedSourceClasses,
          contains(rows[id]!['Source class']),
          reason: id,
        );
      }
    });

    test('teslim yöntemi kapalı kümededir', () {
      for (final id in rowOrder) {
        expect(allowedDelivery, contains(rows[id]!['Delivery']), reason: id);
      }
    });

    test('izin verilen tüketiciler kapalı kümededir', () {
      for (final id in rowOrder) {
        final raw = rows[id]!['Consumers']!;
        // Açıklayıcı parantez/tire notları kaldırılır; yüzey adları kalır.
        final consumers = raw
            .split(',')
            .map((c) => c.split('(').first.split('—').first.trim())
            .where((c) => c.isNotEmpty);
        for (final consumer in consumers) {
          expect(allowedConsumers, contains(consumer), reason: '$id → $raw');
        }
      }
    });
  });

  group('Sınıflandırma tutarlılığı', () {
    test('READY satırı çözülmemiş kaynak/kanıt/lisans TAŞIYAMAZ', () {
      const guarded = [
        'Source name',
        'Source class',
        'Evidence',
        'Publication status',
        'Licensing',
      ];
      for (final id in rowOrder) {
        if (rows[id]!['Status'] != 'READY') {
          continue;
        }
        for (final name in guarded) {
          final value = rows[id]![name]!;
          expect(
            value.contains('UNRESOLVED') || value.contains('UNKNOWN'),
            isFalse,
            reason: '$id READY ama $name çözülmemiş: $value',
          );
        }
      }
    });

    test('belgelenmiş sınırlama durumu bir Limitation alanı gerektirir', () {
      for (final id in rowOrder) {
        final status = rows[id]!['Status']!;
        if (status != 'READY WITH DOCUMENTED LIMITATION' &&
            status != 'REVIEW REQUIRED') {
          continue;
        }
        expect(
          rows[id]!.containsKey('Limitation'),
          isTrue,
          reason: '$id ($status) Limitation alanı taşımıyor',
        );
      }
    });

    test('NOT IMPLEMENTED satırı tüketici veya teslim iddia ETMEZ', () {
      for (final id in rowOrder) {
        if (rows[id]!['Status'] != 'NOT IMPLEMENTED') {
          continue;
        }
        expect(rows[id]!['Consumers'], 'none', reason: id);
        expect(rows[id]!['Delivery'], 'not-implemented', reason: id);
      }
    });
  });

  group('Depo kanıtı', () {
    /// Kanıt alanındaki backtick'li yol adaylarını ayıklar. URL'ler, nokta
    /// içermeyen anahtarlar ve boşluklu ifadeler yol sayılmaz.
    List<String> pathsIn(String evidence) {
      final candidates = RegExp('`([^`]+)`')
          .allMatches(evidence)
          .map((m) => m.group(1)!)
          .where((c) => c.contains('/'))
          .where((c) => !c.startsWith('http'))
          .where((c) => !c.contains(' '))
          .toList();
      return candidates;
    }

    test('uygulanabilir HER satır en az bir gerçek yol gösterir', () {
      for (final id in rowOrder) {
        final paths = pathsIn(rows[id]!['Evidence']!);
        expect(paths, isNotEmpty, reason: '$id kanıt yolu içermiyor');
      }
    });

    test('gösterilen HER yol depoda GERÇEKTEN vardır', () {
      for (final id in rowOrder) {
        for (final path in pathsIn(rows[id]!['Evidence']!)) {
          final full = '$repoRoot/$path';
          final exists =
              File(full).existsSync() || Directory(full).existsSync();
          expect(exists, isTrue, reason: '$id → bulunamayan yol: $path');
        }
      }
    });
  });
}
