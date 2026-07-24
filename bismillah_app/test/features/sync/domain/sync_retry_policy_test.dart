import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/sync/domain/policies/sync_retry_policy.dart';
import 'package:bismillah_app/features/sync/domain/value_objects/sync_failure_class.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = SyncRetryPolicy();
  final now = UtcDateTime(DateTime.utc(2026, 7, 10, 12));

  Duration delayOf(SyncRetryDecision decision) =>
      (decision as SyncRetryAt).retryAt.difference(now);

  SyncRetryDecision decide({
    int attempt = 1,
    SyncFailureClass failureClass = SyncFailureClass.transientNetwork,
    String seed = 'op-seed-1',
  }) => policy.decide(
    attempt: attempt,
    failureClass: failureClass,
    operationSeed: seed,
    now: now,
  );

  group('SyncRetryPolicy — transient backoff', () {
    test('attempt 1 waits at least the 30s base', () {
      final delay = delayOf(decide(attempt: 1));
      expect(delay, greaterThanOrEqualTo(const Duration(seconds: 30)));
      // taban + jitter tavanı (taban/4) üstüne çıkamaz
      expect(delay, lessThan(const Duration(seconds: 38)));
    });

    test('staged delays strictly increase across attempts 1..7', () {
      Duration? previous;
      for (var attempt = 1; attempt <= 7; attempt++) {
        final delay = delayOf(decide(attempt: attempt));
        if (previous != null) {
          expect(
            delay,
            greaterThan(previous),
            reason: 'attempt $attempt gecikmesi öncekinden büyük olmalı',
          );
        }
        previous = delay;
      }
    });

    test('delay never exceeds the 24h cap', () {
      final delay = delayOf(decide(attempt: 7));
      expect(delay, lessThanOrEqualTo(SyncRetryPolicy.maxDelay));
    });

    test('attempt 8 quarantines (maxRetryCount contract preserved)', () {
      expect(decide(attempt: 8), isA<SyncQuarantine>());
    });

    test('retry time is never before the reference time', () {
      for (var attempt = 1; attempt <= 7; attempt++) {
        final decision = decide(attempt: attempt);
        expect((decision as SyncRetryAt).retryAt.isBefore(now), isFalse);
      }
    });
  });

  group('SyncRetryPolicy — deterministic jitter', () {
    test('same seed + same attempt + same now → identical result', () {
      final a = decide(attempt: 3) as SyncRetryAt;
      final b = decide(attempt: 3) as SyncRetryAt;
      expect(a.retryAt, b.retryAt);
    });

    test('different seeds may land on different (bounded) times', () {
      final times = <DateTime>{
        for (var i = 0; i < 20; i++)
          (decide(attempt: 3, seed: 'op-$i') as SyncRetryAt).retryAt.value,
      };
      // 20 farklı operasyonun tamamının aynı milisaniyeye yığılmaması beklenir.
      expect(times.length, greaterThan(1));
      // Hepsi taban(10dk) .. taban+jitter-tavanı aralığında kalmalı.
      for (final t in times) {
        final delay = UtcDateTime(t).difference(now);
        expect(delay, greaterThanOrEqualTo(const Duration(minutes: 10)));
        expect(
          delay,
          lessThanOrEqualTo(
            const Duration(minutes: 10) + SyncRetryPolicy.maxJitter,
          ),
        );
      }
    });

    test('jitter is bounded by min(base/4, 10 minutes)', () {
      // attempt 7 tabanı 24h → jitter tavanı 10 dakika; toplam cap 24h.
      final delay = delayOf(decide(attempt: 7));
      expect(delay, lessThanOrEqualTo(SyncRetryPolicy.maxDelay));
      // attempt 1 tabanı 30s → jitter < 7.5s
      final small = delayOf(decide(attempt: 1));
      expect(
        small,
        lessThan(const Duration(seconds: 30) + const Duration(seconds: 8)),
      );
    });
  });

  group('SyncRetryPolicy — auth unavailable', () {
    test('is slower than ordinary transient retry at attempt 1', () {
      final transient = delayOf(decide(attempt: 1));
      final auth = delayOf(
        decide(
          attempt: 1,
          failureClass: SyncFailureClass.authenticationUnavailable,
        ),
      );
      expect(auth, greaterThan(transient));
      expect(auth, greaterThanOrEqualTo(const Duration(minutes: 15)));
    });

    test('attempt 5+ waits at the 24h cap and never quarantines by count', () {
      for (final attempt in [5, 8, 20]) {
        final decision = decide(
          attempt: attempt,
          failureClass: SyncFailureClass.authenticationUnavailable,
        );
        expect(decision, isA<SyncRetryAt>());
        expect(delayOf(decision), SyncRetryPolicy.maxDelay);
      }
    });
  });

  group('SyncRetryPolicy — permanent and unknown failures', () {
    test('permanent classes quarantine immediately at attempt 1', () {
      for (final cls in [
        SyncFailureClass.permissionDenied,
        SyncFailureClass.validation,
        SyncFailureClass.malformedOperation,
        SyncFailureClass.missingPayload,
        SyncFailureClass.ownershipMismatch,
        SyncFailureClass.unknownPermanent,
      ]) {
        expect(
          decide(attempt: 1, failureClass: cls),
          isA<SyncQuarantine>(),
          reason: '$cls kalıcıdır — anında quarantine',
        );
      }
    });

    test('unknownRetryable: attempts 1..3 retry, attempt 4 quarantines', () {
      for (var attempt = 1; attempt <= 3; attempt++) {
        expect(
          decide(
            attempt: attempt,
            failureClass: SyncFailureClass.unknownRetryable,
          ),
          isA<SyncRetryAt>(),
        );
      }
      expect(
        decide(attempt: 4, failureClass: SyncFailureClass.unknownRetryable),
        isA<SyncQuarantine>(),
      );
    });

    test('attempt below 1 is rejected', () {
      expect(() => decide(attempt: 0), throwsArgumentError);
    });
  });
}
