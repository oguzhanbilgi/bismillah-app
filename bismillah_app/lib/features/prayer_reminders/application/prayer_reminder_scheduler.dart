import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/local_notification_service.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/prayer_reminder.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_coordinates.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_time_calculation_method.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_time_calculator.dart';

/// Bildirim metinleri — presentation/localization'dan enjekte edilir
/// (scheduler BuildContext bilmez). Ton sakindir (suçlayıcı/streak YOK).
final class PrayerReminderCopy {
  const PrayerReminderCopy({required this.title, required this.bodyFor});

  final String title; // ör. "Namaz vakti"
  final String Function(PrayerName) bodyFor; // ör. "İkindi vakti için…"
}

/// Zamanlama sonucu — UI/rapor için.
final class ReminderScheduleOutcome {
  const ReminderScheduleOutcome({
    required this.scheduledCount,
    required this.exact,
  });

  final int scheduledCount;

  /// Kesin (exact) alarm kullanıldı mı? `false` ise inexact — dakika
  /// hassasiyeti cihaza göre değişebilir.
  final bool exact;
}

/// Namaz hatırlatıcı zamanlayıcısı (application). Mevcut OFFLINE vakit
/// motorunu kullanır; ağ GEREKTİRMEZ. Sunrise'a hatırlatıcı kurmaz.
final class PrayerReminderScheduler {
  const PrayerReminderScheduler({
    required this._calculator,
    required this._notifications,
    required this._clock,
  });

  final PrayerTimeCalculator _calculator;
  final LocalNotificationService _notifications;
  final AppClock _clock;

  /// Kaç gün ileri zamanlanır (bugün dahil 7 gün).
  static const int horizonDays = 7;

  /// Bayat zamanları çift üretmeden yeniler: önce YALNIZ kendi
  /// hatırlatıcılarını iptal eder, sonra 7 günün gelecekteki 5 vaktini kurar.
  ///
  /// [method] **zorunludur** (TASK 096): hatırlatıcılar ekranda gösterilen
  /// vakitlerle AYNI yöntemden hesaplanmalıdır. Zamanlayıcı yöntemi kendisi
  /// çözmez — çağıran onu tek yetkili kaynaktan
  /// (`prayerCalculationMethodProvider`) okur; parametre zorunlu olduğu için
  /// bir çağrı yerinin bunu unutması DERLEME hatasıdır. Bu bağımlılık
  /// bilinçli olarak kurucuya konmadı: zamanlayıcı provider'ı yöntem
  /// provider'ını izleseydi, yöntemi değiştiren controller zamanlayıcıyı
  /// okuduğunda dairesel bağımlılık oluşurdu.
  Future<ReminderScheduleOutcome> reschedule({
    required PrayerCoordinates coordinates,
    required PrayerReminderCopy copy,
    required PrayerTimeCalculationMethod method,
  }) async {
    await _notifications.cancelAllPrayerReminders();
    final exact = await _notifications.canScheduleExact();

    final reminders = computeReminders(
      calculator: _calculator,
      coordinates: coordinates,
      localNow: _clock.nowLocal(),
      nowUtc: _clock.nowUtc(),
      copy: copy,
      method: method,
    );
    for (final reminder in reminders) {
      await _notifications.schedule(reminder, exact: exact);
    }
    return ReminderScheduleOutcome(
      scheduledCount: reminders.length,
      exact: exact,
    );
  }

  /// Bugünden itibaren 7 günün GELECEKTEKİ 5 vaktini (Güneş HARİÇ) hesaplar.
  /// Saf fonksiyon — deterministik id + horizon + geçmiş-atlama testlenir.
  static List<PrayerReminder> computeReminders({
    required PrayerTimeCalculator calculator,
    required PrayerCoordinates coordinates,
    required DateTime localNow,
    required DateTime nowUtc,
    required PrayerReminderCopy copy,
    PrayerTimeCalculationMethod method =
        PrayerTimeCalculationMethod.defaultMethod,
  }) {
    final reminders = <PrayerReminder>[];
    for (var day = 0; day < horizonDays; day++) {
      // Gün taşması normalize edilir (ay/yıl geçişi); yalnız y/m/d kullanılır.
      final date = DateTime(localNow.year, localNow.month, localNow.day + day);
      final times = calculator.calculate(
        coordinates: coordinates,
        date: date,
        method: method,
      );
      for (final name in PrayerName.values) {
        final instant = times.instantFor(name);
        if (instant.isAfter(nowUtc)) {
          reminders.add(
            PrayerReminder(
              id: PrayerReminder.deterministicId(times.dayKey, name),
              prayerName: name,
              dayKey: times.dayKey,
              scheduledUtc: instant,
              title: copy.title,
              body: copy.bodyFor(name),
            ),
          );
        }
      }
    }
    return reminders;
  }
}
