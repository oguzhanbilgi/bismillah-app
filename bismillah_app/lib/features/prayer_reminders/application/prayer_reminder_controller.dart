import 'package:bismillah_app/features/prayer_reminders/application/prayer_reminder_scheduler.dart';
import 'package:bismillah_app/features/prayer_reminders/application/prayer_reminder_state.dart';
import 'package:bismillah_app/features/prayer_reminders/data/prayer_reminders_providers.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/local_notification_service.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/notification_permission_status.dart';
import 'package:bismillah_app/features/prayer_times/data/prayer_times_providers.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Namaz hatırlatıcı controller'ı (application). Açılışta İZİN İSTEMEZ —
/// yalnız mevcut durumu okur. Etkinleştirme bağlamsaldır ("Hatırlatıcıları
/// aç" dokunuşu). Namaz KAYDI'ndan bağımsızdır.
final prayerReminderControllerProvider =
    AsyncNotifierProvider<PrayerReminderController, PrayerReminderState>(
      PrayerReminderController.new,
    );

final class PrayerReminderController
    extends AsyncNotifier<PrayerReminderState> {
  // Aynı anda iki kez özel-erişim ekranı açılmasını / çift zamanlamayı önler.
  bool _exactRequestInFlight = false;

  @override
  Future<PrayerReminderState> build() async {
    // Bildirim altyapısı hazırlanamazsa (platform yok/eklenti hatası) sakin
    // KAPALI durumuna düşülür — namaz kaydı bundan etkilenmez.
    try {
      final notifications = ref.watch(localNotificationServiceProvider);
      // Init asılırsa (platform) sonsuz LOADING'te kalmayı önle → KAPALI'ya düş.
      await notifications.initialize().timeout(const Duration(seconds: 5));
      final enabled = await ref
          .watch(reminderPreferenceStoreProvider)
          .isEnabled();
      if (!enabled) {
        return const ReminderDisabled();
      }
      return _statusForEnabled(notifications);
    } on Object {
      return const ReminderDisabled();
    }
  }

  /// "Hatırlatıcıları aç": izni İSTER → konumu alır → 7 günü zamanlar →
  /// tercihi kalıcı yazar. [copy] bildirim metinlerini localization'dan taşır.
  Future<void> enable(PrayerReminderCopy copy) async {
    state = const AsyncLoading<PrayerReminderState>();
    final notifications = ref.read(localNotificationServiceProvider);

    final perm = await notifications.requestPermission();
    if (perm != NotificationPermissionStatus.granted) {
      state = AsyncData(
        ReminderPermissionBlocked(
          permanentlyDenied:
              perm == NotificationPermissionStatus.permanentlyDenied,
        ),
      );
      return;
    }

    final location = await ref
        .read(prayerLocationServiceProvider)
        .requestLocation();
    if (location is! PrayerLocationResolved) {
      state = const AsyncData(ReminderLocationNeeded());
      return;
    }

    final outcome = await ref
        .read(prayerReminderSchedulerProvider)
        .reschedule(coordinates: location.location.coordinates, copy: copy);
    await ref.read(reminderPreferenceStoreProvider).setEnabled(true);
    state = AsyncData(ReminderEnabled(exact: outcome.exact));
  }

  /// "Hatırlatıcıları kapat": YALNIZ Bismillah namaz hatırlatıcılarını iptal
  /// eder, tercihi kapatır.
  Future<void> disable() async {
    await ref.read(localNotificationServiceProvider).cancelAllPrayerReminders();
    await ref.read(reminderPreferenceStoreProvider).setEnabled(false);
    state = const AsyncData(ReminderDisabled());
  }

  /// Kullanıcı "tam zamanlı hatırlatmalar" istediğinde (hatırlatıcılar açık ama
  /// inexact planlanmışken) çağrılır: Android'in "Alarmlar ve hatırlatıcılar"
  /// özel-erişim ekranını açar, DÖNÜŞTE kesin-alarm yeteneğini YENİDEN kontrol
  /// eder ve izin verildiyse mevcut hatırlatıcı setini exact modda yeniden
  /// planlar. İzin verilmezse hatırlatıcılar açık kalır ve inexact fallback
  /// korunur. Ekranı açmak izin sayılmaz — sonuç yalnız [canScheduleExact] ile
  /// belirlenir. Dönen değer: sonuçta kesin zamanlama etkin mi?
  Future<bool> requestExactTiming(PrayerReminderCopy copy) async {
    if (_exactRequestInFlight) {
      // Zaten süren bir istek varsa mevcut kesin durumu bildir (çift açmayı önle).
      return _safeCanExact();
    }
    _exactRequestInFlight = true;
    try {
      final notifications = ref.read(localNotificationServiceProvider);
      await notifications.requestExactAlarmPermission();
      // Ayar ekranını açmak İZİN demek değildir → her zaman yeniden doğrula.
      final canExact = await notifications.canScheduleExact();
      var exact = false;
      if (canExact) {
        final location = await ref
            .read(prayerLocationServiceProvider)
            .requestLocation();
        if (location is PrayerLocationResolved) {
          final outcome = await ref
              .read(prayerReminderSchedulerProvider)
              .reschedule(
                coordinates: location.location.coordinates,
                copy: copy,
              );
          exact = outcome.exact;
        }
      }
      state = AsyncData(ReminderEnabled(exact: exact));
      return exact;
    } on Object {
      // Sakin ve çökme-yok: gerçek yeteneği yansıt, hatırlatıcılar açık kalır.
      final exact = await _safeCanExact();
      state = AsyncData(ReminderEnabled(exact: exact));
      return exact;
    } finally {
      _exactRequestInFlight = false;
    }
  }

  Future<bool> _safeCanExact() async {
    try {
      return await ref
          .read(localNotificationServiceProvider)
          .canScheduleExact();
    } on Object {
      return false;
    }
  }

  Future<void> openSettings() =>
      ref.read(localNotificationServiceProvider).openSettings();

  Future<PrayerReminderState> _statusForEnabled(
    LocalNotificationService notifications,
  ) async {
    final perm = await notifications.checkPermission();
    if (perm != NotificationPermissionStatus.granted) {
      return ReminderPermissionBlocked(
        permanentlyDenied:
            perm == NotificationPermissionStatus.permanentlyDenied,
      );
    }
    return ReminderEnabled(exact: await notifications.canScheduleExact());
  }
}
