import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/prayer_times/application/prayer_times_controller.dart';
import 'package:bismillah_app/features/prayer_times/application/prayer_times_state.dart';
import 'package:bismillah_app/features/today/domain/today_greeting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Today karşılamasının zaman dilimi (RDX-02A).
///
/// Today'in ZATEN izlediği `prayerTimesControllerProvider` üzerinden gerçek
/// vakitleri okur — ikinci bir hesap motoru, ikinci bir konum isteği veya
/// ikinci bir kaynak YOKTUR. Vakitler hazır değilse (izin yok, konum yok,
/// hâlâ yükleniyor) çözücü sessizce cihaz yerel saatine düşer.
///
/// Zaman `AppClock`'tan bir kez okunur; **periyodik timer kurulmaz**. Dilim,
/// vakitler değiştiğinde veya ekran yeniden kurulduğunda yeniden hesaplanır —
/// karşılama için saniye hassasiyeti gereksizdir ve arka planda tiklayan bir
/// timer, uygulamanın "yapay gecikme/animasyon yok" kuralına aykırı olurdu.
final todayGreetingPeriodProvider = Provider<TodayGreetingPeriod>((ref) {
  final clock = ref.watch(clockProvider);
  final state = ref.watch(prayerTimesControllerProvider).value;
  return TodayGreetingResolver.resolve(
    times: state is PrayerTimesReady ? state.times : null,
    nowUtc: clock.nowUtc(),
    nowLocal: clock.nowLocal(),
  );
});
