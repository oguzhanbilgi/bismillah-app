import 'package:bismillah_app/core/domain/classified.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';

/// Kazanılmış rozet (10_DATA_MODEL §4) — insert-only, idempotent ID.
///
/// Aynı rozet iki cihazda kazanılırsa erken `earnedAt` kazanır (§14).
/// Rozetler ödül-emek ilişkisidir; manipülatif gamification yasak
/// (CLAUDE.md).
final class Achievement implements Classified {
  Achievement({
    required this.achievementId,
    required this.earnedAt,
    required this.triggerContext,
  }) {
    if (triggerContext.trim().isEmpty) {
      throw ArgumentError.value(
        triggerContext,
        'triggerContext',
        'Tetikleyici kova kodu boş olamaz',
      );
    }
  }

  final EntityId achievementId;
  final UtcDateTime earnedAt;

  /// Tetikleyici KOVA kodu (ör. `streak_7`) — serbest metin değil.
  final String triggerContext;

  /// Erken kazanım gerçeği korunur (insert-only çözümü).
  static Achievement resolveEarliest(Achievement a, Achievement b) {
    assert(a.achievementId == b.achievementId);
    return a.earnedAt.isAfter(b.earnedAt) ? b : a;
  }

  @override
  SensitivityClass get sensitivityClass => SensitivityClass.medium;
}
