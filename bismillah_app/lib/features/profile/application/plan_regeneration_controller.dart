import 'package:bismillah_app/features/profile/application/profile_overview_provider.dart';
import 'package:bismillah_app/features/today/application/initial_daily_plan_orchestrator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Plan yenilemenin arayüz durumu (TASK 096).
///
/// Başarısızlık ASLA başarı gibi sunulmaz: yazma yapılmadıysa durum
/// [PlanRegenerationFailureState] olur ve ekran bunu açıkça söyler.
sealed class PlanRegenerationState {
  const PlanRegenerationState();
}

/// Hiçbir işlem yok — varsayılan.
final class PlanRegenerationIdle extends PlanRegenerationState {
  const PlanRegenerationIdle();
}

/// Yenileme sürüyor; buton pasif kalır.
final class PlanRegenerationRunning extends PlanRegenerationState {
  const PlanRegenerationRunning();
}

/// Plan gerçekten yazıldı.
final class PlanRegenerationSuccess extends PlanRegenerationState {
  const PlanRegenerationSuccess({required this.droppedCompletedItems});

  /// Yeni tercihlerle artık üretilmediği için tamamlanma kaydı taşınamayan
  /// öğe sayısı — kullanıcıya dürüstçe bildirilir.
  final int droppedCompletedItems;
}

/// Yenileme yapılamadı; **plan değişmedi**.
final class PlanRegenerationFailureState extends PlanRegenerationState {
  const PlanRegenerationFailureState({required this.onboardingIncomplete});

  /// Sebep kayıtlı tercih eksikliği mi? (Farklı, dürüst bir mesaj gerekir.)
  final bool onboardingIncomplete;
}

final planRegenerationControllerProvider =
    NotifierProvider<PlanRegenerationController, PlanRegenerationState>(
      PlanRegenerationController.new,
    );

/// Plan yenileme controller'ı (TASK 096).
///
/// Üretim mantığı BURADA DEĞİLDİR: iş, ilk planı da üreten
/// [InitialDailyPlanOrchestrator.regenerateFromToday] çağrısına aittir.
/// Böylece ikinci bir plan üreticisi ya da ikinci bir kural seti oluşmaz.
///
/// Çift dokunuş iki katmanda engellenir: buton `running` durumunda pasif
/// olur ve orkestratör devam eden işlemi belleğe alır — iki eşzamanlı
/// çağrı tek yazma üretir.
final class PlanRegenerationController extends Notifier<PlanRegenerationState> {
  @override
  PlanRegenerationState build() => const PlanRegenerationIdle();

  /// Yalnız kullanıcı onayından SONRA çağrılır.
  Future<void> regenerate() async {
    if (state is PlanRegenerationRunning) {
      return;
    }
    state = const PlanRegenerationRunning();
    final outcome = await ref
        .read(initialDailyPlanOrchestratorProvider)
        .regenerateFromToday();

    state = switch (outcome) {
      PlanRegenerated(:final droppedCompletedItems) => PlanRegenerationSuccess(
        droppedCompletedItems: droppedCompletedItems,
      ),
      PlanRegenerationOnboardingIncomplete() =>
        const PlanRegenerationFailureState(onboardingIncomplete: true),
      PlanRegenerationGenerationFailed() ||
      PlanRegenerationPersistenceFailed() => const PlanRegenerationFailureState(
        onboardingIncomplete: false,
      ),
    };

    if (state is PlanRegenerationSuccess) {
      // Özet yalnız gerçekten yazıldığında tazelenir.
      ref.invalidate(profileOverviewProvider);
    }
  }

  /// Kullanıcı mesajı gördükten sonra durumu sıfırlar.
  void acknowledge() => state = const PlanRegenerationIdle();
}
