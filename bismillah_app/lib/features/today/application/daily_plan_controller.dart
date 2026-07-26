import 'dart:async';

import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/today/application/daily_plan_state.dart';
import 'package:bismillah_app/features/today/data/today_data_providers.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Seçili günün plan durum makinesi (TASK 077).
///
/// Kanonik gün-başına `DailyPlan` modelini mevcut `DailyPlanRepository`
/// üzerinden okur, izler, tazeler ve kaydeder. **Plan ÜRETMEZ** (TASK 079)
/// ve hiçbir UI bileşeni içermez.
///
/// ## Bayat sonuç koruması
///
/// Her seçim/işlem bir **jenerasyon (epoch)** açar (`QuranSearchController`
/// ile aynı idiyom). Geç dönen bir okuma/yazma, jenerasyonu artmışsa durumu
/// EZEMEZ. Bu; gün değiştirme, tazeleme, kaydetme ve watch olayları arasında
/// deterministik "en yeni kazanır" davranışı verir.
///
/// ## İlk okuma / watch yarışı
///
/// `watchPlan` abone olurken mevcut değeri TEKRAR YAYINLAMAZ (TASK 076 §9).
/// Bu yüzden controller önce abone olur, sonra `getPlan` çalıştırır. Abonelik
/// sırasında gelen daha yeni bir kayıt jenerasyonu artırır; böylece daha
/// eski `getPlan` sonucu daha yeni watch olayını ezemez.
final dailyPlanControllerProvider =
    NotifierProvider<DailyPlanController, DailyPlanState?>(
      DailyPlanController.new,
    );

final class DailyPlanController extends Notifier<DailyPlanState?> {
  /// Aktif gün. Hiçbir gün seçilmemişken `null`.
  DayKey? _dayKey;

  /// Geçerli işlem jenerasyonu; her seçim/işlem/watch olayında artar.
  int _generation = 0;

  StreamSubscription<DailyPlan?>? _subscription;
  bool _disposed = false;

  /// Başlangıç durumu: gün seçilmemiş. Bootstrap bu controller'ı OKUMAZ.
  @override
  DailyPlanState? build() {
    ref.onDispose(() {
      _disposed = true;
      unawaited(_subscription?.cancel());
      _subscription = null;
    });
    return null;
  }

  /// Test/tanı amaçlı: şu an seçili gün.
  DayKey? get selectedDay => _dayKey;

  /// Bir günü seçer ve yükler. Aynı gün tekrar verilse bile yeniden okur
  /// (açık tazeleme niyeti); önceki abonelik her hâlükârda iptal edilir.
  Future<void> loadDay(DayKey dayKey) async {
    if (_disposed) {
      return;
    }
    final generation = ++_generation;
    _dayKey = dayKey;

    // Yükleme durumu SENKRON yayınlanır: çağıran, ilk `await`'i beklemeden
    // seçimin geçerli olduğunu görür (UI'da bir kare bile boş kalmaz).
    state = DailyPlanLoading(dayKey: dayKey);

    // Önceki günün aboneliği kapatılır — controller başına TEK aktif watch.
    await _subscription?.cancel();
    _subscription = null;
    if (_isStale(generation)) {
      return;
    }

    _subscription = ref
        .read(dailyPlanRepositoryProvider)
        .watchPlan(dayKey)
        .listen(
          (plan) => _onWatchEvent(dayKey, plan),
          // Akış sözleşmesi (core/contracts): watch hatası son bilinen
          // durumu DEVİRMEZ; hata ayrı okuma yolundan raporlanır.
          onError: (Object _, StackTrace _) {},
        );

    await _read(generation, dayKey);
  }

  /// Aktif günü yeniden okur. Gün seçilmemişse güvenle hiçbir şey yapmaz.
  /// Plan ÜRETMEZ.
  Future<void> refresh() async {
    final dayKey = _dayKey;
    if (_disposed || dayKey == null) {
      return;
    }
    final generation = ++_generation;
    _publish(generation, DailyPlanLoading(dayKey: dayKey));
    await _read(generation, dayKey);
  }

  /// Başarısız/bozuk durumdan sonra aynı günü yeniden dener.
  ///
  /// Yalnız çağıran talebiyle çalışır — otomatik yeniden deneme döngüsü
  /// YOKTUR. Bozulma durumunda tekrar okumak aynı sonucu vereceği için
  /// `DailyPlanCorrupt.canRetry` `false`'tur; yine de çağıran ısrar ederse
  /// okuma dürüstçe tekrarlanır (sessiz no-op ile yanıltılmaz).
  Future<void> retry() => refresh();

  /// Aktif güne ait planı kaydeder.
  ///
  /// Farklı bir güne ait plan REDDEDİLİR (durum değişmez). Kaydetme sırasında
  /// mevcut plan gösterimde kalır (`isSaving`), böylece ekran zıplamaz.
  Future<void> savePlan(DailyPlan plan) async {
    final dayKey = _dayKey;
    if (_disposed || dayKey == null || plan.dayKey != dayKey) {
      return;
    }
    final generation = ++_generation;

    final current = state;
    if (current is DailyPlanAvailable) {
      _publish(generation, current.copyWith(isSaving: true));
    }

    final result = await ref.read(dailyPlanRepositoryProvider).savePlan(plan);
    if (_isStale(generation)) {
      // Daha yeni bir işlem/olay araya girdi — eski sonuç durumu EZMEZ.
      return;
    }

    state = result.fold(
      onSuccess: (_) => DailyPlanAvailable(plan: plan),
      onFailure: (failure) => _toFailureState(dayKey, failure),
    );
  }

  /// Depodan tek okuma yapıp durumu eşler.
  Future<void> _read(int generation, DayKey dayKey) async {
    final result = await ref.read(dailyPlanRepositoryProvider).getPlan(dayKey);
    if (_isStale(generation)) {
      // Gün değişti veya daha yeni bir watch olayı/kayıt geldi.
      return;
    }
    state = result.fold(
      onSuccess: (plan) => plan == null
          ? DailyPlanEmpty(dayKey: dayKey)
          : DailyPlanAvailable(plan: plan),
      onFailure: (failure) => _toFailureState(dayKey, failure),
    );
  }

  /// Repository watch olayı: yalnız aktif gün için geçerlidir ve **daha
  /// eski** bekleyen okumaları geçersizleştirir.
  void _onWatchEvent(DayKey dayKey, DailyPlan? plan) {
    if (_disposed || _dayKey != dayKey) {
      return; // eski günün akışı aktif günü ETKİLEMEZ
    }
    final generation = ++_generation;
    _publish(
      generation,
      plan == null
          ? DailyPlanEmpty(dayKey: dayKey)
          : DailyPlanAvailable(plan: plan),
    );
  }

  /// Tipli hata → durum eşlemesi.
  ///
  /// **Yalnız TİP incelenir**: `messageKey` okunmaz, istisna metni
  /// çözümlenmez, string eşleme yapılmaz ve hatanın iç detayı duruma
  /// KOPYALANMAZ.
  static DailyPlanState _toFailureState(DayKey dayKey, AppFailure failure) =>
      switch (failure) {
        StorageCorruptionFailure() => DailyPlanCorrupt(dayKey: dayKey),
        _ => DailyPlanFailure(dayKey: dayKey),
      };

  /// Sonuç bayat mı? (jenerasyon ilerlemiş veya controller kapatılmış)
  bool _isStale(int generation) => _disposed || generation != _generation;

  void _publish(int generation, DailyPlanState next) {
    if (_isStale(generation)) {
      return;
    }
    state = next;
  }
}
