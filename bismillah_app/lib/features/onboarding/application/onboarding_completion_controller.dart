import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/onboarding/application/onboarding_goals_controller.dart';
import 'package:bismillah_app/features/onboarding/application/onboarding_journey_controller.dart';
import 'package:bismillah_app/features/onboarding/application/onboarding_pace_controller.dart';
import 'package:bismillah_app/features/onboarding/application/onboarding_status_controller.dart';
import 'package:bismillah_app/features/onboarding/data/onboarding_data_providers.dart';
import 'package:bismillah_app/features/onboarding/domain/entities/onboarding_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Onboarding final adımı controller'ı (TASK 028): üç adımın seçimlerini
/// bir araya getirir, TEK kontrollü kayıtla kalıcılaştırır ve yalnız
/// başarıda tamamlanma kapısını açar. Hata sakin bir durumdur — ana
/// uygulamaya geçilmez, tekrar denenebilir.
final onboardingCompletionControllerProvider =
    AsyncNotifierProvider<OnboardingCompletionController, void>(
      OnboardingCompletionController.new,
    );

final class OnboardingCompletionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Kaydeder; başarıda `true` döner (ekran ancak o zaman Today'e geçer).
  /// `AsyncLoading` sürerken buton pasiftir — çift dokunuş iki kayıt
  /// üretemez; yine de yarış hâlinde ikinci çağrı erken döner.
  Future<bool> complete() async {
    if (state.isLoading) {
      return false;
    }

    final goals = ref.read(onboardingGoalsControllerProvider);
    final journey = ref.read(onboardingJourneyControllerProvider);
    final pace = ref.read(onboardingPaceControllerProvider);
    // UI butonları bu durumları zaten kapatır; yine de doğrulanır —
    // eksik seçimle tamamlanma bayrağı ASLA yazılmaz.
    if (goals.isEmpty || journey == null || pace == null) {
      state = AsyncError(
        const ValidationFailure(messageKey: 'onboardingSaveIssue'),
        StackTrace.current,
      );
      return false;
    }

    state = const AsyncLoading();
    final result = await ref
        .read(onboardingPreferencesRepositoryProvider)
        .saveCompleted(
          OnboardingPreferences(
            goals: goals,
            journeyStage: journey,
            dailyPace: pace,
            completedAtUtc: ref.read(clockProvider).nowUtc(),
          ),
        );
    return result.fold(
      onSuccess: (_) {
        // Kapı yalnız kayıt başarısından SONRA açılır.
        ref.read(onboardingCompletedProvider.notifier).markCompleted();
        state = const AsyncData(null);
        return true;
      },
      onFailure: (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
    );
  }
}
