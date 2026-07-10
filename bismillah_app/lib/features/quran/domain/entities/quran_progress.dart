import 'package:bismillah_app/core/domain/classified.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_goal_type.dart';

/// Okuma hedefi (10_DATA_MODEL §4). Çakışmada LWW (§9).
final class QuranGoal implements Classified {
  QuranGoal({
    required this.goalType,
    required this.dailyTarget,
    required this.startedAt,
    required this.updatedAt,
  }) {
    if (dailyTarget < 1) {
      throw ArgumentError.value(dailyTarget, 'dailyTarget', '>= 1 olmalı');
    }
  }

  final QuranGoalType goalType;
  final int dailyTarget;
  final UtcDateTime startedAt;
  final UtcDateTime updatedAt;

  @override
  SensitivityClass get sensitivityClass => SensitivityClass.high;
}

/// Tek okuma kaydı — içerik değil miktar (10_DATA_MODEL §2-3).
/// Çakışmada sessionId üzerinden UNION (iki okuma da gerçek, §14).
final class QuranReadingSession implements Classified {
  QuranReadingSession({
    required this.sessionId,
    required this.dayKey,
    required this.amount,
    required this.unit,
    required this.loggedAt,
  }) {
    if (amount < 1) {
      throw ArgumentError.value(amount, 'amount', '>= 1 olmalı');
    }
  }

  final EntityId sessionId;
  final DayKey dayKey;
  final int amount;
  final QuranGoalType unit;
  final UtcDateTime loggedAt;

  @override
  SensitivityClass get sensitivityClass => SensitivityClass.high;
}

/// Kaldığı yer — tek yer imi (MVP). Çakışmada LWW(updatedAt).
final class QuranBookmark implements Classified {
  QuranBookmark({
    required this.surah,
    required this.ayah,
    required this.updatedAt,
  }) {
    if (surah < 1 || surah > 114) {
      throw ArgumentError.value(surah, 'surah', '1–114 aralığında olmalı');
    }
    if (ayah < 1) {
      throw ArgumentError.value(ayah, 'ayah', '>= 1 olmalı');
    }
  }

  final int surah;
  final int ayah;
  final UtcDateTime updatedAt;

  @override
  SensitivityClass get sensitivityClass => SensitivityClass.high;
}
