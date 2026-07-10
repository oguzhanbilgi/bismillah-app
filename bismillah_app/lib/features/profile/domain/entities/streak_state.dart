import 'package:bismillah_app/core/domain/classified.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';

/// Seri durumu — TÜRETİLMİŞ veri (10_DATA_MODEL §4, §21).
///
/// Kaynak: namaz/Kur'an/zikir log'ları. Çakışmada ASLA merge edilmez —
/// `StreakCalculator` (sonraki görev) kaynak log'lardan yeniden hesaplar.
/// Bu nesne yalnız hesap sonucunun cache gösterimidir.
final class StreakState implements Classified {
  StreakState({
    required this.current,
    required this.longest,
    this.lastActiveDay,
    this.repairAvailable = false,
    List<DayKey> repairedDays = const [],
  }) : repairedDays = List.unmodifiable(repairedDays) {
    if (current < 0) {
      throw ArgumentError.value(current, 'current', 'Negatif olamaz');
    }
    if (longest < current) {
      throw ArgumentError.value(
        longest,
        'longest',
        'longest >= current olmalı (türetme hatası)',
      );
    }
  }

  const StreakState.empty()
    : current = 0,
      longest = 0,
      lastActiveDay = null,
      repairAvailable = false,
      repairedDays = const [];

  final int current;
  final int longest;
  final DayKey? lastActiveDay;
  final bool repairAvailable;
  final List<DayKey> repairedDays;

  /// Ham seri zaman çizelgesi analytics'e YASAKTIR (10_DATA_MODEL §18) —
  /// yalnız kova (ör. `streak_band`) çıkabilir.
  @override
  SensitivityClass get sensitivityClass => SensitivityClass.medium;
}
