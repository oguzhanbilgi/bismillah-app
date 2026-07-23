import 'package:bismillah_app/features/prayer_reminders/domain/notification_permission_status.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/prayer_reminder.dart';

/// Cihaz-yerel bildirim portu — paket-bağımsız (flutter_local_notifications
/// tipleri bu arayüzün dışına SIZMAZ). FCM/uzak bildirim YOKTUR.
abstract interface class LocalNotificationService {
  /// Eklenti + timezone kurulumunu bir kez hazırlar (ağ gerektirmez).
  Future<void> initialize();

  /// Kullanıcının dokunduğu namaz hatırlatıcısı payload'ları (soğuk açılış
  /// dahil). Uygulama bunu dinleyip Prayer sekmesine yönlendirir. Payload
  /// yalnız `prayer:<name>:<dayKey>` — koordinat/UID YOK.
  Stream<String> get reminderTaps;

  /// Bildirim iznini BAĞLAMSAL olarak ister (açılışta ÇAĞRILMAZ).
  Future<NotificationPermissionStatus> requestPermission();

  /// Mevcut izin durumunu İSTEMEDEN okur.
  Future<NotificationPermissionStatus> checkPermission();

  /// Cihaz kesin (exact) alarm zamanlayabiliyor mu? (Android 12+/14
  /// kısıtları). `false` ise inexact'e düşülür — dakika hassasiyeti değişebilir.
  Future<bool> canScheduleExact();

  /// Android'de "Alarmlar ve hatırlatıcılar" özel-erişim ekranını açar. Ekranı
  /// AÇMAK izin verildiği anlamına GELMEZ; çağıran taraf ardından mutlaka
  /// [canScheduleExact] ile yeniden doğrulamalıdır. Android dışında kesin
  /// zamanlama bu izinle kısıtlanmadığından `true` döner. Yalnız kullanıcının
  /// açık isteğiyle çağrılır (açılışta/otomatik ÇAĞRILMAZ).
  Future<bool?> requestExactAlarmPermission();

  /// Tek hatırlatıcıyı zamanlar; [exact] ise kesin, değilse pil-dostu inexact.
  /// UTC → cihaz timezone dönüşümü implementasyonda (tz) yapılır.
  Future<void> schedule(PrayerReminder reminder, {required bool exact});

  /// YALNIZ Bismillah namaz hatırlatıcılarını iptal eder (payload'a göre;
  /// başka bildirimlere dokunmaz).
  Future<void> cancelAllPrayerReminders();

  /// Kalıcı reddedilmiş izinde sistem bildirim ayarlarını açar.
  Future<void> openSettings();
}
