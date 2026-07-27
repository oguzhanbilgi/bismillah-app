import 'package:bismillah_app/features/today/application/initial_daily_plan_orchestrator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Zaten onboarding'i tamamlamış ama planı olmayan kullanıcılar için
/// **tek seferlik** plan kurulumu (TASK 083A).
///
/// Neden ayrı bir controller: üretim bir widget `build` metodunda
/// çalışamaz — her yeniden çizimde tetiklenir, provider döngüsü kurar ve
/// çift yazma riski doğurur. Burada tetikleme açıktır ve bayrakla
/// korunur.
///
/// ## Yaşam döngüsü
///
/// Uygulama/bootstrap ömrü başına **en fazla bir kez** çalışır. Sonuç ne
/// olursa olsun (oluşturuldu, zaten var, onboarding eksik, çakışma, hata)
/// otomatik olarak TEKRARLANMAZ; yeniden deneme yalnız [retry] ile,
/// kullanıcı isteğiyle olur.
///
/// Kullanıcıya görünen metin İÇERMEZ; hata gösterimi UI katmanının işidir.
final initialDailyPlanBootstrapProvider =
    NotifierProvider<
      InitialDailyPlanBootstrapController,
      InitialDailyPlanOutcome?
    >(InitialDailyPlanBootstrapController.new);

final class InitialDailyPlanBootstrapController
    extends Notifier<InitialDailyPlanOutcome?> {
  /// Bu ömür içinde çalıştırıldı mı? (sonuçtan bağımsız)
  bool _attempted = false;

  /// Henüz hiçbir deneme yapılmamışken `null`.
  @override
  InitialDailyPlanOutcome? build() => null;

  /// Test/tanı amaçlı: bu ömürde bir deneme yapıldı mı?
  bool get hasAttempted => _attempted;

  /// Planı en fazla bir kez kurmayı dener.
  ///
  /// İkinci ve sonraki çağrılar üretim/yazma BAŞLATMAZ; mevcut sonucu
  /// döndürür. Böylece yeniden çizim, sekme değişimi veya tazeleme
  /// tekrar plan üretemez.
  Future<InitialDailyPlanOutcome?> ensureOnce() async {
    if (_attempted) {
      return state;
    }
    _attempted = true;
    return _run();
  }

  /// Kullanıcı isteğiyle yeniden dener (nötr hata yolundan çağrılır).
  ///
  /// Orkestratör mevcut geçerli planı zaten korur, bu yüzden tekrar
  /// denemek çift plan üretemez.
  Future<InitialDailyPlanOutcome?> retry() {
    _attempted = true;
    return _run();
  }

  Future<InitialDailyPlanOutcome?> _run() async {
    final outcome = await ref
        .read(initialDailyPlanOrchestratorProvider)
        .ensureInitialPlan();
    state = outcome;
    return outcome;
  }
}
