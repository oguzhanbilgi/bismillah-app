import 'package:bismillah_app/features/prayer_times/domain/daily_prayer_times.dart';

/// Namaz vakti görünüm durumu — sakin durumlar (izin/hata) HATA değil
/// veri olarak modellenir (CLAUDE.md ton: kırmızı/suçlayıcı yok). Yükleme,
/// AsyncValue.loading ile controller build'inde taşınır.
sealed class PrayerTimesState {
  const PrayerTimesState();
}

/// Vakitler hesaplandı ve gösterilmeye hazır.
final class PrayerTimesReady extends PrayerTimesState {
  const PrayerTimesReady({required this.times, this.approximateLocation = false});

  final DailyPrayerTimes times;

  /// Son-bilinen konumdan tahmini mi? (UI'da nazik not.)
  final bool approximateLocation;
}

/// Konum izni yok — "Konumu kullan" daveti gösterilir (day-0 duvarı değil).
final class PrayerTimesNeedsPermission extends PrayerTimesState {
  const PrayerTimesNeedsPermission({required this.permanentlyDenied});

  /// `true` ise sistem ayarlarından açılmalı.
  final bool permanentlyDenied;
}

/// Konum alınamadı (servis kapalı/hata) — sakin yeniden-dene durumu.
final class PrayerTimesUnavailable extends PrayerTimesState {
  const PrayerTimesUnavailable();
}
