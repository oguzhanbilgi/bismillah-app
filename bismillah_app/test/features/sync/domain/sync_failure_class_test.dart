import 'dart:async' show TimeoutException;

import 'package:bismillah_app/features/sync/domain/value_objects/sync_failure_class.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncFailureClass', () {
    test('permanent classes are exactly the documented set', () {
      const permanent = {
        SyncFailureClass.permissionDenied,
        SyncFailureClass.validation,
        SyncFailureClass.malformedOperation,
        SyncFailureClass.missingPayload,
        SyncFailureClass.ownershipMismatch,
        SyncFailureClass.unknownPermanent,
      };
      for (final cls in SyncFailureClass.values) {
        expect(
          cls.isPermanent,
          permanent.contains(cls),
          reason: '$cls kalıcılık sınıflandırması',
        );
      }
    });

    test('enum names are stable machine-readable identifiers', () {
      // Kalıcı alan (`lastErrorCode`) bu adları saklar — değişmeleri
      // persist edilmiş kuyruk kayıtlarını bozar.
      expect(SyncFailureClass.transientNetwork.name, 'transientNetwork');
      expect(
        SyncFailureClass.authenticationUnavailable.name,
        'authenticationUnavailable',
      );
      expect(SyncFailureClass.permissionDenied.name, 'permissionDenied');
      expect(SyncFailureClass.unknownRetryable.name, 'unknownRetryable');
    });
  });

  group('SyncFailureClassifier', () {
    test('timeout classifies as transientNetwork', () {
      expect(
        SyncFailureClassifier.classify(
          TimeoutException('SECRET-DETAIL should never persist'),
        ),
        SyncFailureClass.transientNetwork,
      );
    });

    test('format problems classify as malformedOperation', () {
      expect(
        SyncFailureClassifier.classify(const FormatException('bad')),
        SyncFailureClass.malformedOperation,
      );
    });

    test('argument/state errors classify as validation', () {
      expect(
        SyncFailureClassifier.classify(ArgumentError('bad arg')),
        SyncFailureClass.validation,
      );
      expect(
        SyncFailureClassifier.classify(StateError('bad state')),
        SyncFailureClass.validation,
      );
    });

    test(
      'unrecognized errors follow the conservative unknownRetryable rule',
      () {
        expect(
          SyncFailureClassifier.classify(Exception('whatever')),
          SyncFailureClass.unknownRetryable,
        );
        expect(
          SyncFailureClassifier.classify('a plain string error'),
          SyncFailureClass.unknownRetryable,
        );
      },
    );

    test('classifier output carries no raw exception text', () {
      final result = SyncFailureClassifier.classify(
        TimeoutException('token=abc123 url=https://x'),
      );
      // Çıktı yalnız enum'dur; ad sabit ve mesajdan bağımsızdır.
      expect(result.name, 'transientNetwork');
      expect(result.name.contains('token'), isFalse);
      expect(result.name.contains('http'), isFalse);
    });
  });
}
