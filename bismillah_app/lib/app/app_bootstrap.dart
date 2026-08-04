import 'dart:async';

import 'package:bismillah_app/app/app_providers.dart';
import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/core/session/session_bootstrap.dart';
import 'package:bismillah_app/core/session/session_providers.dart';
import 'package:bismillah_app/features/onboarding/application/onboarding_status_controller.dart';
import 'package:bismillah_app/features/onboarding/data/shared_prefs_onboarding_preferences_repository.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:bismillah_app/features/prayer_reminders/application/prayer_reminder_scheduler.dart';
import 'package:bismillah_app/features/prayer_reminders/application/prayer_reminder_tap_router.dart';
import 'package:bismillah_app/features/prayer_reminders/data/prayer_reminders_providers.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/notification_permission_status.dart';
import 'package:bismillah_app/features/prayer_times/application/prayer_calculation_method_controller.dart';
import 'package:bismillah_app/features/prayer_times/data/prayer_times_providers.dart';
import 'package:bismillah_app/features/prayer_times/data/shared_prefs_prayer_calculation_method_repository.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_location.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_time_calculation_method.dart';
import 'package:bismillah_app/features/quran/data/audio_service_quran_handler.dart';
import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/domain/services/quran_audio_session_service.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:bismillah_app/features/sync/data/sync_data_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// Uygulama ön-yüklemesi (06_FLUTTER_ARCHITECTURE §8; TASK 018 sırası):
///
/// 1. Firebase Core başlat — config yoksa/başarısızsa NET raporlanır ve
///    uygulama lokal kimlikle devam eder (07 §127; fatal DEĞİL).
/// 2. Anonim/mevcut kullanıcı kimliği garanti edilir.
/// 3. Uygulama-lokal cihaz kimliği garanti edilir.
/// 4. Lokal kalıcılık başlatılır (DB açılamazsa fatal — tek doğruluk
///    kaynağı lokaldir).
/// 5. Eski uid (placeholder/lokal-fallback) satırları güncel UID'ye
///    remap edilir.
/// 6. Yarım kalmış inFlight sync op'ları kurtarılır.
///
/// Sözleşme: bootstrap AĞ BEKLEMEZ ve uzak sync/Firestore BAŞLATMAZ.
Future<ProviderContainer> bootstrap({
  SessionIdentity? sessionIdentity,
  QuranAudioSessionService? quranAudioSessionService,
  List<Override> overrides = const [],
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final identity = sessionIdentity ?? await resolveSessionIdentity();

  // Onboarding kapısı (TASK 028): tamamlanma değeri runApp'ten ÖNCE okunur —
  // ilk frame'de yanlış ekran bir an bile görünmez. Okuma Firebase'den
  // TAMAMEN bağımsızdır (Firebase başarısız olsa da onboarding çalışır);
  // anahtar yoksa/bozuksa depo güvenli `false` döner (kompozisyon kökü
  // data sınıfını doğrudan kurabilir — DI kuralı presentation içindir).
  final onboardingCompleted =
      await const SharedPrefsOnboardingPreferencesRepository().isCompleted();

  // TASK 053: uygulama dili de runApp'ten ÖNCE çözülür — ilk frame doğru
  // dilde (ve Arapça'da doğru yönde) çizilir; dil için açılış spinner'ı
  // veya siyah ekran OLUŞMAZ. Öncelik: kayıtlı seçim > desteklenen sistem
  // dili > Türkçe. Okuma Firebase'den TAMAMEN bağımsızdır.
  final launchLocale = await resolveLaunchLocale(
    systemLocales: WidgetsBinding.instance.platformDispatcher.locales,
  );

  // TASK 096: seçili namaz vakti hesaplama yöntemi de runApp'ten ÖNCE
  // çözülür — ilk kare doğru yöntemle çizilir ve açılışta yapılan
  // hatırlatıcı yenilemesi de aynı yöntemi kullanır. Seçim yoksa veya
  // saklanan değer tanınmıyorsa varsayılana düşülür ve depo YAZILMAZ:
  // mevcut kurulumların etkin yöntemi olduğu gibi korunur.
  final launchCalculationMethod =
      (await const SharedPrefsPrayerCalculationMethodRepository().loadMethod())
          .valueOrNull ??
      PrayerTimeCalculationMethod.defaultMethod;

  // TASK 045: global Kur'an ses oturumu — AudioService.init uygulama
  // başına yalnız BURADA, bir kez çağrılır ve Riverpod override'ı ile
  // enjekte edilir (global mutable handler değişkeni YOK). Başarısızlık
  // fatal DEĞİLDİR: sakin unavailable implementasyon döner, reader
  // Arapça/meal ile çalışmaya devam eder. Kanal adı bildirim içindir;
  // BuildContext gerektirmez (bootstrap'taki hatırlatıcı desenle aynı).
  // Test seam (sessionIdentity deseniyle aynı): önceden verilmiş servis
  // varsa gerçek AudioService.init ÇAĞRILMAZ — unit testler platform ses
  // kanallarına dokunmaz (gerçek ses testlerde kullanılmaz).
  final resolvedQuranAudioSessionService =
      quranAudioSessionService ??
      await initializeQuranAudioSessionService(
        // Kanal adı BuildContext'siz üretilir; açılışta çözülen uygulama
        // dilini kullanır (TASK 053 — bildirim metinleri de seçilen dilde).
        notificationChannelName: AppLocalizations(
          launchLocale,
        ).quranAudioChannelName,
      );

  final container = ProviderContainer(
    overrides: [
      quranAudioSessionServiceProvider.overrideWithValue(
        resolvedQuranAudioSessionService,
      ),
      currentUserIdProvider.overrideWithValue(identity.userId),
      currentDeviceIdProvider.overrideWithValue(identity.deviceId),
      firebaseInitStatusProvider.overrideWithValue(identity.firebaseStatus),
      onboardingCompletedAtLaunchProvider.overrideWithValue(
        onboardingCompleted,
      ),
      appLocaleAtLaunchProvider.overrideWithValue(launchLocale),
      prayerCalculationMethodAtLaunchProvider.overrideWithValue(
        launchCalculationMethod,
      ),
      ...overrides,
    ],
  );
  // Redakte kimlik teşhisi (07 §146): ham UID ASLA loglanmaz, yalnız
  // kaynak sınıflandırması. Release'te bu satır warning altı olduğu için
  // düşmez (AppLogger seviye kapısı).
  container
      .read(appLoggerProvider)
      .info(
        'bootstrap: identitySource=${identity.identitySource.name} '
        'firebase=${identity.firebaseStatus.isAvailable}'
        '${identity.firebaseStatus.isAvailable ? '' : ' '
                  '(${identity.firebaseStatus.reason}; FlutterFire yapılandırması '
                  'ayrı görev)'}',
      );
  // Firebase mevcutken anonim oturum kurulamadıysa REDAKTE sebep loglanır
  // (sessiz fallback gözlemlenebilir olmalı). Sonraki açılışta kalıcılaşan
  // oturum bulunursa remap veriyi taşır (07 §127).
  if (identity.authFailureReason != null) {
    container
        .read(appLoggerProvider)
        .warning(
          'bootstrap: anonim auth fallback — reason=${identity.authFailureReason}',
        );
  }

  await initializeLocalPersistence(container);
  // TASK 022: bildirim dokunuşu → Prayer yönlendirmesi + açıksa 7 günü
  // tazele. Tamamen GUARDED ve non-blocking (platform yoksa/başarısızsa
  // sessizce atlanır; açılışı bloklamaz, izin/network İSTEMEZ).
  await wirePrayerReminders(container);
  return container;
}

/// Namaz hatırlatıcı açılış bağlaması (best-effort). Dokunuş dinleyicisini
/// kurar; hatırlatıcılar açıksa + izin/konum hazırsa (İSTEMEDEN) 7 günü
/// arka planda yeniden zamanlar.
Future<void> wirePrayerReminders(ProviderContainer container) async {
  try {
    final notifications = container.read(localNotificationServiceProvider);
    await notifications.initialize();
    final router = container.read(appRouterProvider);
    notifications.reminderTaps.listen(
      (payload) => routeReminderTap(payload, () => router.go(AppRoutes.prayer)),
    );
    unawaited(_rescheduleRemindersIfReady(container));
  } on Object {
    // Bildirim altyapısı yoksa (platform/eklenti) sessizce atla.
  }
}

Future<void> _rescheduleRemindersIfReady(ProviderContainer container) async {
  try {
    final enabled = await container
        .read(reminderPreferenceStoreProvider)
        .isEnabled();
    if (!enabled) {
      return;
    }
    final notifications = container.read(localNotificationServiceProvider);
    if (await notifications.checkPermission() !=
        NotificationPermissionStatus.granted) {
      return;
    }
    final location = await container
        .read(prayerLocationServiceProvider)
        .currentLocationIfPermitted();
    if (location is! PrayerLocationResolved) {
      return; // konum hazır değil — mevcut zamanlama 7 gün korunur.
    }
    const l10n = AppLocalizations(SupportedLocale.tr);
    await container
        .read(prayerReminderSchedulerProvider)
        .reschedule(
          coordinates: location.location.coordinates,
          // Açılış yenilemesi de tek yetkili yöntem kaynağını kullanır.
          method: container.read(prayerCalculationMethodProvider),
          copy: PrayerReminderCopy(
            title: l10n.reminderNotificationTitle,
            bodyFor: (name) => l10n.reminderNotificationBody(
              _bootstrapPrayerLabel(l10n, name),
            ),
          ),
        );
  } on Object {
    // Best-effort; açılışı bloklamaz.
  }
}

String _bootstrapPrayerLabel(AppLocalizations l10n, PrayerName name) =>
    switch (name) {
      PrayerName.fajr => l10n.prayerNameFajr,
      PrayerName.dhuhr => l10n.prayerNameDhuhr,
      PrayerName.asr => l10n.prayerNameAsr,
      PrayerName.maghrib => l10n.prayerNameMaghrib,
      PrayerName.isha => l10n.prayerNameIsha,
    };

/// Lokal kalıcılığı açılışta hazırlar (adımlar 4–6). Testler container'ı
/// in-memory DB + sabit kimlik override'larıyla kurar.
Future<void> initializeLocalPersistence(ProviderContainer container) async {
  // DB açılamıyorsa uygulama başlayamaz — hata bilinçli olarak yukarı fırlar.
  await container.read(localDatabaseProvider).initialize();

  // TASK 016–017 gerçek auth'tan önce placeholder-local-user altında lokal
  // sync satırları üretmiş olabilir; gerçek sync açılmadan önce güncel
  // UID'ye remap ŞARTTIR (07 §146). Başarısızlık açılışı bloklamaz —
  // sync engine henüz yok, sonraki açılış yeniden dener.
  final remap = await container
      .read(driftSyncQueueRepositoryProvider)
      .remapUid(to: container.read(currentUserIdProvider));
  if (remap.isFailure) {
    container
        .read(appLoggerProvider)
        .warning('bootstrap: uid remap başarısız — sonraki açılışta denenir');
  }

  final recovery = await container
      .read(syncQueueRepositoryProvider)
      .recoverInFlight();
  if (recovery.isFailure) {
    container
        .read(appLoggerProvider)
        .warning(
          'bootstrap: inFlight sync op kurtarması başarısız — '
          'kuyruk sonraki denemede toparlanır',
        );
  }
}
