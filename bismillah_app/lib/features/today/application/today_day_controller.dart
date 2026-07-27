import 'dart:async';

import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/today/application/daily_plan_controller.dart';
import 'package:bismillah_app/features/today/application/initial_daily_plan_bootstrap_controller.dart';
import 'package:bismillah_app/features/today/data/today_data_providers.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_generator.dart';
import 'package:bismillah_app/features/today/domain/value_objects/missed_day_recovery.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tek atışlık gecikmeli çalıştırma soyutlaması (TASK 084).
///
/// Neden var: yerel gece yarısı geçişi gerçek bir `Timer` gerektirir, ama
/// testin saatlerce beklemesi kabul edilemez. Bu arayüz enjekte edildiği
/// için testler geçişi **anında ve deterministik** tetikler.
///
/// **Periyodik yoklama (polling) YOKTUR:** her seferinde yalnız bir
/// sonraki yerel takvim sınırına kadar tek bir zamanlama kurulur.
abstract interface class DayRolloverScheduler {
  /// Önceki zamanlamayı iptal eder ve [delay] sonrası için yenisini kurar.
  void schedule(Duration delay, void Function() onFire);

  /// Bekleyen zamanlamayı iptal eder (tekrar çağrılması güvenlidir).
  void cancel();
}

/// Üretim implementasyonu — tek `Timer`, sızıntısız.
final class TimerDayRolloverScheduler implements DayRolloverScheduler {
  Timer? _timer;

  @override
  void schedule(Duration delay, void Function() onFire) {
    _timer?.cancel();
    _timer = Timer(delay, onFire);
  }

  @override
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Zamanlayıcının DI bağlaması; testler sahte bir zamanlayıcı verir.
final dayRolloverSchedulerProvider = Provider<DayRolloverScheduler>((ref) {
  final scheduler = TimerDayRolloverScheduler();
  ref.onDispose(scheduler.cancel);
  return scheduler;
});

/// Today'in gösterdiği gün ve sakin dönüş durumu (TASK 084).
final class TodayDayState {
  const TodayDayState({
    this.selectedDay,
    this.recovery = MissedDayRecovery.none,
  });

  /// Şu an gösterilen yerel takvim günü; henüz seçilmemişken `null`.
  final DayKey? selectedDay;

  /// Bugünden hemen önceki kesintisiz kaçırılmış günler.
  final MissedDayRecovery recovery;

  TodayDayState copyWith({DayKey? selectedDay, MissedDayRecovery? recovery}) =>
      TodayDayState(
        selectedDay: selectedDay ?? this.selectedDay,
        recovery: recovery ?? this.recovery,
      );

  @override
  bool operator ==(Object other) =>
      other is TodayDayState &&
      other.selectedDay == selectedDay &&
      other.recovery == recovery;

  @override
  int get hashCode => Object.hash(selectedDay, recovery);
}

/// Today'in yerel takvim günü devri (TASK 084).
///
/// Sorumluluğu üç şeyle sınırlıdır: **hangi gün gösterilecek**, o gün
/// değiştiğinde durumu bir kez tazelemek ve bugünden önceki kesintisiz
/// kaçırılmış günleri hesaplamak.
///
/// ## Ne YAPMAZ
///
/// Plan **ÜRETMEZ**, kopyalamaz, silmez, tamamlamaz ve geçmiş günleri
/// DEĞİŞTİRMEZ. Seri (streak), puan, rozet, bildirim, arka plan görevi,
/// uzak senkron veya kalıcı yeni anahtar EKLEMEZ. `DateTime.now()`
/// çağırmaz — gün yalnız enjekte edilen `AppClock` ve `DayKey` kuralıyla
/// türetilir; UTC dönüşümü kullanılmaz.
///
/// ## Bayat sonuç koruması
///
/// Her geçiş bir jenerasyon açar; geç dönen bir kaçırılmış-gün okuması
/// daha yeni bir günün durumunu EZEMEZ. Gün değişmediyse hiçbir şey
/// yapılmaz, bu yüzden ikinci bir `watchPlan` aboneliği açılmaz ve
/// kurulum (bootstrap) tekrar çalışmaz.
final todayDayControllerProvider =
    NotifierProvider<TodayDayController, TodayDayState>(TodayDayController.new);

final class TodayDayController extends Notifier<TodayDayState> {
  int _generation = 0;
  bool _disposed = false;
  bool _started = false;

  /// Zamanlayıcı `build` sırasında çözülür ve saklanır: `onDispose`
  /// içinde `ref` KULLANILAMAZ, ama bekleyen zamanlama mutlaka iptal
  /// edilmelidir (sızıntı ve kapatıldıktan sonra tetiklenme yok).
  DayRolloverScheduler? _scheduler;

  @override
  TodayDayState build() {
    _scheduler = ref.read(dayRolloverSchedulerProvider);
    ref.onDispose(() {
      _disposed = true;
      _scheduler?.cancel();
      _scheduler = null;
    });
    return const TodayDayState();
  }

  /// İlk mount: gerekirse ilk planı kurar, günü seçer, sınırı zamanlar.
  ///
  /// Uygulama ömrü başına **bir kez** kurulum çağırır; sonraki çağrılar
  /// yalnız gün tazeler.
  Future<void> start() async {
    if (_disposed) {
      return;
    }
    if (!_started) {
      _started = true;
      // Planı olmayan mevcut kullanıcı boş ekranla karşılaşmasın
      // (TASK 083A). Zaten planı olanda bu çağrı yazma YAPMAZ.
      await ref.read(initialDailyPlanBootstrapProvider.notifier).ensureOnce();
      if (_disposed) {
        return;
      }
    }
    await _syncToLocalDay();
  }

  /// Uygulama ön plana döndüğünde çağrılır.
  ///
  /// Gün değişmediyse hiçbir şey yapmaz — yeniden okuma, yeni abonelik
  /// veya yeni kurulum tetiklenmez.
  Future<void> onAppResumed() => _syncToLocalDay();

  /// Kullanıcı isteğiyle yeniden deneme (nötr hata yolundan).
  ///
  /// Önce plan kurulumu tekrar denenir (ilk deneme bir okuma hatası
  /// yüzünden düşmüş olabilir), sonra gün **zorla** yeniden okunur.
  /// Zorlanmış senkron zaten `loadDay` çalıştırdığı için ayrıca
  /// `DailyPlanController.retry()` çağrılmaz — çift okuma olmaz.
  Future<void> retry() async {
    if (_disposed) {
      return;
    }
    await ref.read(initialDailyPlanBootstrapProvider.notifier).retry();
    if (_disposed) {
      return;
    }
    await _syncToLocalDay(force: true);
  }

  /// Bir sonraki yerel takvim sınırına kalan süre.
  ///
  /// **24 saat VARSAYILMAZ:** ertesi günün yerel gece yarısı
  /// `DateTime(y, m, d + 1)` ile kurulur, bu yüzden yaz saati geçişinde
  /// 23 veya 25 saat doğal olarak çıkar.
  Duration durationUntilNextLocalDay() {
    final now = ref.read(clockProvider).nowLocal();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final remaining = nextMidnight.difference(now);
    // Saat geriye alınmış olsa bile zamanlayıcı negatif süre almaz.
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Yerel günü okur; değiştiyse (veya ilk kez) durumu tazeler.
  Future<void> _syncToLocalDay({bool force = false}) async {
    if (_disposed) {
      return;
    }
    final today = DayKey.fromLocal(ref.read(clockProvider).nowLocal());
    final unchanged = state.selectedDay == today;

    // Sınır her senkronda yeniden zamanlanır: uygulama uykudan döndüğünde
    // bekleyen zamanlama artık geçersiz olabilir.
    _scheduleNextBoundary();

    if (unchanged && !force) {
      return; // aynı gün → yeni abonelik ve yeni okuma YOK
    }

    final generation = ++_generation;
    state = state.copyWith(selectedDay: today);

    await ref.read(dailyPlanControllerProvider.notifier).loadDay(today);
    if (_isStale(generation)) {
      return;
    }
    await _refreshRecovery(generation, today);
  }

  void _scheduleNextBoundary() {
    _scheduler?.schedule(durationUntilNextLocalDay(), () {
      if (_disposed) {
        return;
      }
      unawaited(_syncToLocalDay());
    });
  }

  /// Bugünden önceki kesintisiz kaçırılmış günleri yeniden hesaplar.
  ///
  /// Okuma başarısız olursa (bozuk/erişilemeyen depo) sakin şekilde
  /// [MissedDayRecovery.none] kullanılır — veri sorunu bir kullanıcı
  /// kusuru gibi SUNULMAZ.
  Future<void> _refreshRecovery(int generation, DayKey today) async {
    final from = DailyPlanGenerator.dayAt(
      today,
      -MissedDayCalculator.lookbackDays,
    );
    final to = DailyPlanGenerator.dayAt(today, -1);

    final result = await ref
        .read(dailyPlanRepositoryProvider)
        .getRange(from, to);
    if (_isStale(generation)) {
      return;
    }
    final plans = result.valueOrNull;
    state = state.copyWith(
      recovery: plans == null
          ? MissedDayRecovery.none
          : MissedDayCalculator.evaluate(previousPlans: plans, today: today),
    );
  }

  bool _isStale(int generation) => _disposed || generation != _generation;
}
