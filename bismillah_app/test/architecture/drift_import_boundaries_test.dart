import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Mimari sınır bekçisi (10_DATA_MODEL §7 hardening; TASK 014/015 kuralı):
/// `package:drift` importu YALNIZ şu katmanlarda yaşayabilir:
///
/// - `lib/core/storage/` (DB + yaşam döngüsü provider'ı)
/// - `lib/features/*/data/local/` (tablolar + Drift repository'leri)
/// - `lib/features/*/data/mappers/` (satır ↔ domain eşlemesi)
///
/// UI, application, domain, app kabuğu ve shared bileşenler Drift'i
/// GÖREMEZ — paket değişimi infrastructure'da izole kalır.
void main() {
  test('package:drift imports never leak outside storage/data layers', () {
    final allowed = [
      RegExp(r'lib[/\\]core[/\\]storage[/\\]'),
      RegExp(r'lib[/\\]features[/\\][^/\\]+[/\\]data[/\\]local[/\\]'),
      RegExp(r'lib[/\\]features[/\\][^/\\]+[/\\]data[/\\]mappers[/\\]'),
    ];

    final violations = <String>[
      for (final file in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>())
        if (file.path.endsWith('.dart') &&
            !allowed.any((layer) => layer.hasMatch(file.path)) &&
            file
                .readAsStringSync()
                .contains(RegExp("import 'package:drift")))
          file.path,
    ];

    expect(
      violations,
      isEmpty,
      reason: 'Drift importu izinli katmanların dışına sızdı — repository '
          'interface/domain/UI Drift tipi göremez (06 §7, doc 11 §karar).',
    );
  });

  test('firebase imports never leak outside core/firebase + core/session',
      () {
    final allowed = [
      RegExp(r'lib[/\\]core[/\\]firebase[/\\]'),
      RegExp(r'lib[/\\]core[/\\]session[/\\]'),
      // FlutterFire CLI üretimi (TASK 019): `flutterfire configure` bu
      // dosyayı üretir ve `firebase_core`'u import eder. Üretilen tek
      // istisnadır; elle yazılmaz, kimlik/anahtar taşımaz (yalnız public
      // Firebase app tanımlayıcıları).
      RegExp(r'lib[/\\]firebase_options\.dart$'),
    ];

    final violations = <String>[
      for (final file in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>())
        if (file.path.endsWith('.dart') &&
            !allowed.any((layer) => layer.hasMatch(file.path)) &&
            file
                .readAsStringSync()
                .contains(RegExp("import 'package:firebase_")))
          file.path,
    ];

    expect(
      violations,
      isEmpty,
      reason: 'Firebase importu yalnız core/firebase ve core/session '
          'katmanlarında yaşayabilir (TASK 018 kuralı); UI/domain/'
          'application Firebase tipi göremez.',
    );
  });

  test('adhan_dart / geolocator imports never leak outside data layers', () {
    // TASK 021: hesaplama/konum paketleri YALNIZ feature data katmanında.
    final allowed = RegExp(r'lib[/\\]features[/\\][^/\\]+[/\\]data[/\\]');
    final pkg = RegExp("import 'package:(adhan_dart|geolocator)");

    final violations = <String>[
      for (final file in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>())
        if (file.path.endsWith('.dart') &&
            !allowed.hasMatch(file.path) &&
            file.readAsStringSync().contains(pkg))
          file.path,
    ];

    expect(
      violations,
      isEmpty,
      reason: 'adhan_dart/geolocator yalnız features/*/data katmanında '
          'yaşayabilir (TASK 021); domain/application/presentation göremez.',
    );
  });

  test('forbidden packages are not declared (scope guard)', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    const forbidden = [
      'cloud_firestore',
      'firebase_storage',
      'firebase_messaging',
      'firebase_analytics',
      'firebase_crashlytics',
      'purchases_flutter',
    ];
    for (final package in forbidden) {
      expect(
        pubspec.contains(RegExp('^  $package:', multiLine: true)),
        isFalse,
        reason: '$package ilgili entegrasyon görevinden önce eklenemez '
            '(TASK 018 kapsam kuralı).',
      );
    }
  });
}
