import 'package:bismillah_app/features/prayer_reminders/application/prayer_reminder_scheduler.dart';
import 'package:bismillah_app/features/prayer_reminders/data/prayer_reminders_providers.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/notification_permission_status.dart';
import 'package:bismillah_app/features/prayer_times/data/prayer_times_providers.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_location.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_time_calculation_method.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Açılış anındaki hesaplama yöntemi.
///
/// PRODÜKSİYONDA bootstrap tarafından override edilir (prefs okuması
/// `runApp`'ten önce biter), böylece ilk kare doğru yöntemle çizilir.
/// Buradaki varsayılan yalnız bootstrap'sız container'lar (testler) içindir
/// ve mevcut kurulumların etkin yöntemiyle AYNIDIR.
final prayerCalculationMethodAtLaunchProvider =
    Provider<PrayerTimeCalculationMethod>(
      (ref) => PrayerTimeCalculationMethod.defaultMethod,
    );

/// Seçili hesaplama yönteminin **TEK yetkili kaynağı**.
///
/// Namaz sekmesi, Today kartı ve hatırlatıcı zamanlayıcısı hepsi bunu okur;
/// hiçbir ekran kendi başına depodan yöntem çözmez, bu yüzden iki yüzeyin
/// farklı yöntem göstermesi MÜMKÜN DEĞİLDİR.
final prayerCalculationMethodProvider =
    NotifierProvider<
      PrayerCalculationMethodController,
      PrayerTimeCalculationMethod
    >(PrayerCalculationMethodController.new);

/// Yöntem değişikliğinin tipli sonucu — serbest metin YOKTUR, sunum
/// katmanı bu tiplere göre mesaj seçer.
sealed class PrayerMethodChangeOutcome {
  const PrayerMethodChangeOutcome();
}

/// Zaten seçili olan yöntem seçildi — hiçbir yazma/yeniden zamanlama olmadı.
final class PrayerMethodUnchanged extends PrayerMethodChangeOutcome {
  const PrayerMethodUnchanged();
}

/// Yöntem yazıldı, vakitler yeniden hesaplandı.
///
/// [remindersRescheduled] yalnız hatırlatıcılar AÇIKKEN ve yeniden zamanlama
/// gerçekten yapıldığında `true`'dur. Hatırlatıcılar kapalıyken `false`
/// olması bir HATA DEĞİLDİR — kurulacak bildirim yoktur.
final class PrayerMethodApplied extends PrayerMethodChangeOutcome {
  const PrayerMethodApplied({required this.remindersRescheduled});

  final bool remindersRescheduled;
}

/// Yöntem yazıldı ve vakitler yeniden hesaplandı, ama AÇIK olan hatırlatıcılar
/// yeni yönteme göre yeniden kurulamadı (politika B — aşağıya bakınız).
///
/// Bu KISMİ bir sonuçtur ve tam başarı olarak raporlanmaz; sunum katmanı
/// belirgin bir mesaj gösterir ve [PrayerCalculationMethodController
/// .retryReminderReschedule] ile deterministik bir yeniden deneme sunar.
final class PrayerMethodRemindersNotUpdated extends PrayerMethodChangeOutcome {
  const PrayerMethodRemindersNotUpdated();
}

/// Yöntem YAZILAMADI — hiçbir şey değişmedi (yöntem, vakitler, bildirimler).
final class PrayerMethodSaveFailed extends PrayerMethodChangeOutcome {
  const PrayerMethodSaveFailed();
}

/// Süren bir uygulama işlemi var — ikinci dokunuş YENİ bir işlem başlatmaz.
final class PrayerMethodBusy extends PrayerMethodChangeOutcome {
  const PrayerMethodBusy();
}

/// Hesaplama yöntemi controller'ı.
///
/// **İşlem politikası: B (belgeli seçim).** Yeni yöntem ÖNCE kalıcı yazılır,
/// sonra hatırlatıcılar yeniden kurulur. Gerekçe: saklanan yöntem tek
/// gerçektir — vakit yüzeyleri onu izler; bildirimler ondan TÜRETİLİR.
/// Politika A (önce bildirim, sonra yazma) seçilseydi, yazma başarısız
/// olduğunda cihazda YENİ yönteme göre kurulmuş bildirimler ile ESKİ yönteme
/// göre gösterilen vakitler kalıcı olarak çelişirdi ve bunu düzeltecek
/// deterministik bir yol olmazdı. B'de tutarsızlık yalnız bildirim tarafında
/// ve GEÇİCİDİR: [PrayerMethodRemindersNotUpdated] açıkça bildirilir ve
/// [retryReminderReschedule] aynı işlemi tekrarlar.
///
/// Yeniden zamanlama HİÇBİR yeni sistem izni istemez: mevcut bildirim izni ve
/// zaten verilmiş konum okunur (`currentLocationIfPermitted`). Kullanıcı
/// tercihi (hatırlatıcılar açık/kapalı) DEĞİŞTİRİLMEZ.
final class PrayerCalculationMethodController
    extends Notifier<PrayerTimeCalculationMethod> {
  /// Çift dokunuş koruması — düğme devre dışı bırakılsa bile ikinci bir
  /// çağrı ikinci bir yazma üretemez.
  bool _inFlight = false;

  @override
  PrayerTimeCalculationMethod build() =>
      ref.watch(prayerCalculationMethodAtLaunchProvider);

  /// Kullanıcının açık seçimi. Sonuç tipli döner; hiçbir durumda başarısız
  /// bir yeniden zamanlama tam başarı olarak raporlanmaz.
  Future<PrayerMethodChangeOutcome> select(
    PrayerTimeCalculationMethod method,
    PrayerReminderCopy reminderCopy,
  ) async {
    if (_inFlight) {
      return const PrayerMethodBusy();
    }
    if (method == state) {
      return const PrayerMethodUnchanged();
    }
    _inFlight = true;
    try {
      final saved = await ref
          .read(prayerCalculationMethodRepositoryProvider)
          .saveMethod(method);
      if (saved.isFailure) {
        // Hiçbir şey değişmedi: yöntem, vakitler ve bildirimler eski hâlinde.
        return const PrayerMethodSaveFailed();
      }
      // Yöntem yayınlanır → vakit controller'ı bunu `watch` ettiğinden
      // bayat hesap KALAMAZ; ayrı bir önbellek temizleme adımı gerekmez.
      state = method;

      final rescheduled = await _rescheduleReminders(reminderCopy);
      return switch (rescheduled) {
        _ReminderRescheduleResult.notNeeded => const PrayerMethodApplied(
          remindersRescheduled: false,
        ),
        _ReminderRescheduleResult.done => const PrayerMethodApplied(
          remindersRescheduled: true,
        ),
        _ReminderRescheduleResult.failed =>
          const PrayerMethodRemindersNotUpdated(),
      };
    } finally {
      _inFlight = false;
    }
  }

  /// Kısmi başarıdan sonraki deterministik yeniden deneme: YALNIZ bildirimleri
  /// yeniden kurar (yöntem zaten yazılmıştır, tekrar yazılmaz).
  Future<PrayerMethodChangeOutcome> retryReminderReschedule(
    PrayerReminderCopy reminderCopy,
  ) async {
    if (_inFlight) {
      return const PrayerMethodBusy();
    }
    _inFlight = true;
    try {
      final result = await _rescheduleReminders(reminderCopy);
      return switch (result) {
        _ReminderRescheduleResult.notNeeded => const PrayerMethodApplied(
          remindersRescheduled: false,
        ),
        _ReminderRescheduleResult.done => const PrayerMethodApplied(
          remindersRescheduled: true,
        ),
        _ReminderRescheduleResult.failed =>
          const PrayerMethodRemindersNotUpdated(),
      };
    } finally {
      _inFlight = false;
    }
  }

  /// Hatırlatıcılar KAPALIYSA hiçbir bildirim kurulmaz ve bu bir hata
  /// sayılmaz. Açıksa mevcut mimari (`PrayerReminderScheduler.reschedule`)
  /// kullanılır: önce yalnız Bismillah hatırlatıcıları iptal edilir, sonra
  /// 7 günün GELECEKTEKİ vakitleri kurulur — bu yüzden çift bildirim oluşamaz
  /// ve geçmiş bildirimler yeniden yaratılmaz.
  Future<_ReminderRescheduleResult> _rescheduleReminders(
    PrayerReminderCopy copy,
  ) async {
    try {
      final enabled = await ref
          .read(reminderPreferenceStoreProvider)
          .isEnabled();
      if (!enabled) {
        return _ReminderRescheduleResult.notNeeded;
      }
      final notifications = ref.read(localNotificationServiceProvider);
      if (await notifications.checkPermission() !=
          NotificationPermissionStatus.granted) {
        // İzin yok: yeni izin İSTENMEZ. Kullanıcı hatırlatıcıları açık
        // bıraktığından bu dürüstçe kısmi sonuçtur.
        return _ReminderRescheduleResult.failed;
      }
      final location = await ref
          .read(prayerLocationServiceProvider)
          .currentLocationIfPermitted();
      if (location is! PrayerLocationResolved) {
        return _ReminderRescheduleResult.failed;
      }
      await ref
          .read(prayerReminderSchedulerProvider)
          .reschedule(
            coordinates: location.location.coordinates,
            copy: copy,
            // `state` bu noktada YENİ yöntemdir; bildirimler ekranda
            // gösterilecek vakitlerle aynı yöntemden kurulur.
            method: state,
          );
      return _ReminderRescheduleResult.done;
    } on Object {
      // Sessiz başarı YOK: hata yutulur ama sonuç "güncellenemedi" olarak
      // döner ve kullanıcıya bildirilir.
      return _ReminderRescheduleResult.failed;
    }
  }
}

enum _ReminderRescheduleResult { notNeeded, done, failed }
