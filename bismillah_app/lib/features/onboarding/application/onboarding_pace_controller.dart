import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_daily_pace.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Günlük tempo controller'ı (TASK 027) — TEK seçim.
///
/// Seçim YALNIZ bellekte yaşar; kalıcılık ve startup bağlantısı TASK 028.
/// autoDispose KULLANILMAZ: seçim onboarding oturumu boyunca korunur
/// (TASK 026 controller deseniyle aynı).
final onboardingPaceControllerProvider =
    NotifierProvider<OnboardingPaceController, OnboardingDailyPace?>(
      OnboardingPaceController.new,
    );

final class OnboardingPaceController extends Notifier<OnboardingDailyPace?> {
  @override
  OnboardingDailyPace? build() => null;

  void select(OnboardingDailyPace pace) => state = pace;

  /// Devam edebilmek için bir tempo seçilmiş olmalı.
  bool get canContinue => state != null;
}
