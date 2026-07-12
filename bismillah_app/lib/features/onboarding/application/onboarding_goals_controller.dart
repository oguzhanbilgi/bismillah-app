import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Onboarding hedef seçimi controller'ı (TASK 026).
///
/// Seçim YALNIZ bellekte yaşar — kalıcılık (Drift/SharedPreferences) ve
/// profil eşlemesi sonraki onboarding görevlerindedir. autoDispose
/// KULLANILMAZ: akış TASK 027'de sonraki adımlara taşınacak; seçim
/// onboarding oturumu boyunca korunur.
final onboardingGoalsControllerProvider =
    NotifierProvider<OnboardingGoalsController, Set<OnboardingFocusGoal>>(
      OnboardingGoalsController.new,
    );

final class OnboardingGoalsController
    extends Notifier<Set<OnboardingFocusGoal>> {
  @override
  Set<OnboardingFocusGoal> build() => const {};

  /// Seçimi aç/kapat (çoklu seçim serbest).
  void toggleGoal(OnboardingFocusGoal goal) {
    state = state.contains(goal)
        ? state.where((g) => g != goal).toSet()
        : {...state, goal};
  }

  /// Devam edebilmek için en az bir hedef gerekir.
  bool get canContinue => state.isNotEmpty;
}
