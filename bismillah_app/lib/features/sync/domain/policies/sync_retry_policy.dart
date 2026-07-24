import 'package:bismillah_app/core/utils/stable_hash.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/sync/domain/entities/sync_operation.dart';
import 'package:bismillah_app/features/sync/domain/value_objects/sync_failure_class.dart';

/// Retry kararı — saf domain sonucu.
sealed class SyncRetryDecision {
  const SyncRetryDecision();
}

/// Belirtilen zamanda yeniden dene.
final class SyncRetryAt extends SyncRetryDecision {
  const SyncRetryAt(this.retryAt);
  final UtcDateTime retryAt;
}

/// Kuyruğu bloklamadan karantinaya ayır (kalıcı hata / deneme tavanı).
final class SyncQuarantine extends SyncRetryDecision {
  const SyncQuarantine();
}

/// Deterministik retry/backoff politikası (TASK 073; 10_DATA_MODEL §12-8/9).
///
/// SAFTIR: `DateTime.now()` çağırmaz (referans zaman parametredir),
/// `Random()` kullanmaz — jitter, kararlı operasyon tohumundan
/// ([StableHash.fnv1a64]) türetilir. Aynı (tohum, attempt, now) girdisi
/// DAİMA aynı sonucu üretir; farklı operasyonlar aynı milisaniyede
/// yığılmaz.
final class SyncRetryPolicy {
  const SyncRetryPolicy();

  /// Geçici (network/servis/unknownRetryable) hatalar için kademeli taban
  /// gecikmeler — attempt 1..7; attempt 8 = quarantine
  /// ([SyncOperation.maxRetryCount] sözleşmesi korunur).
  static const List<Duration> transientSchedule = [
    Duration(seconds: 30),
    Duration(minutes: 2),
    Duration(minutes: 10),
    Duration(minutes: 30),
    Duration(hours: 2),
    Duration(hours: 8),
    Duration(hours: 24),
  ];

  /// Auth-bekleme kademesi — hızlı tekrar YASAK (pil + anlamsız deneme).
  /// attempt 5+ 24 saat tavanında bekler; auth yokluğu tek başına geçerli
  /// bir operasyonu KARANTİNAYA almaz (attempt sayısıyla quarantine yok).
  static const List<Duration> authUnavailableSchedule = [
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(hours: 2),
    Duration(hours: 8),
  ];

  /// Bilinmeyen-retryable hatalar için temkinli kural: ilk 3 deneme
  /// [transientSchedule] tabanıyla; attempt 4+ quarantine (sonsuz tekrar
  /// YASAK, ham hata detayı saklanmaz).
  static const int unknownRetryableMaxAttempts = 3;

  /// Toplam gecikme tavanı (jitter dahil).
  static const Duration maxDelay = Duration(hours: 24);

  /// Jitter üst sınırı: min(taban/4, 10 dakika); daima >= 0.
  static const Duration maxJitter = Duration(minutes: 10);

  /// [attempt] bu HATAYLA birlikte ulaşılan deneme sayısıdır (ilk hata = 1).
  /// [operationSeed] kararlı bir kimliktir (operationId değeri);
  /// deterministik jitter tohumu olarak kullanılır, saklanmaz/loglanmaz.
  SyncRetryDecision decide({
    required int attempt,
    required SyncFailureClass failureClass,
    required String operationSeed,
    required UtcDateTime now,
  }) {
    if (attempt < 1) {
      throw ArgumentError.value(attempt, 'attempt', 'En az 1 olmalı');
    }
    if (failureClass.isPermanent) {
      return const SyncQuarantine();
    }

    final Duration base;
    switch (failureClass) {
      case SyncFailureClass.authenticationUnavailable:
        base = attempt <= authUnavailableSchedule.length
            ? authUnavailableSchedule[attempt - 1]
            : maxDelay; // 5+ → 24 saat tavanı; quarantine YOK.
      case SyncFailureClass.unknownRetryable:
        if (attempt > unknownRetryableMaxAttempts) {
          return const SyncQuarantine();
        }
        base = transientSchedule[attempt - 1];
      default: // transientNetwork / serviceUnavailable
        if (attempt >= SyncOperation.maxRetryCount) {
          return const SyncQuarantine(); // attempt 8 → quarantine (§5.1).
        }
        base = transientSchedule[attempt - 1];
    }

    final delay = _cap(base + _jitter(operationSeed, attempt, base));
    return SyncRetryAt(now.add(delay));
  }

  static Duration _cap(Duration d) => d > maxDelay ? maxDelay : d;

  /// Deterministik, sınırlı jitter: FNV-1a(seed:attempt) → [0, üst-sınır).
  /// Üst sınır = min(taban/4, [maxJitter]). Gecikme asla negatif olmaz →
  /// retry zamanı referans zamanın gerisine düşemez.
  static Duration _jitter(String seed, int attempt, Duration base) {
    final bound = _min(base ~/ 4, maxJitter);
    if (bound <= Duration.zero) {
      return Duration.zero;
    }
    final hex = StableHash.fnv1a64('$seed:$attempt').substring(0, 8);
    final fraction = int.parse(hex, radix: 16) / 0x100000000;
    return Duration(milliseconds: (fraction * bound.inMilliseconds).floor());
  }

  static Duration _min(Duration a, Duration b) => a < b ? a : b;
}
