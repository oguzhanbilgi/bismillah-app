import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';

/// Zamanlanacak tek namaz hatırlatıcısı — paket-bağımsız değer nesnesi.
///
/// [scheduledUtc] UTC instant'tır; yerel/timezone dönüşümü data katmanında
/// (tz.TZDateTime) yapılır — sabit UTC+3 EKLENMEZ. [payload] konum/UID/
/// hassas veri TAŞIMAZ; yalnız `prayer:<name>:<dayKey>` (Prayer sekmesine
/// yönlendirme + tekilleştirme için).
final class PrayerReminder {
  const PrayerReminder({
    required this.id,
    required this.prayerName,
    required this.dayKey,
    required this.scheduledUtc,
    required this.title,
    required this.body,
  });

  /// Tarih+vakit'e göre DETERMİNİSTİK id (yeniden zamanlamada çift üretmez):
  /// `yyyyMMdd * 10 + prayerIndex`. Sunrise dahil değildir (PrayerName'de yok).
  final int id;

  final PrayerName prayerName;
  final String dayKey; // yyyy-MM-dd
  final DateTime scheduledUtc;
  final String title;
  final String body;

  /// Payload'da yalnız yönlendirme/tekilleştirme verisi — koordinat/UID YOK.
  String get payload => 'prayer:${prayerName.name}:$dayKey';

  static int deterministicId(String dayKey, PrayerName prayerName) {
    final compact = int.parse(dayKey.replaceAll('-', '')); // 2026-07-12→20260712
    return compact * 10 + prayerName.index;
  }

  /// Bir payload Bismillah namaz hatırlatıcısına mı ait? (Yalnız kendi
  /// bildirimlerimizi iptal etmek için — başka bildirimlere dokunulmaz.)
  static bool isPrayerPayload(String? payload) =>
      payload != null && payload.startsWith('prayer:');
}
