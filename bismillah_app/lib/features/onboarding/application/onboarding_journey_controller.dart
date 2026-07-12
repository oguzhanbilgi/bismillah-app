import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_journey_stage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Yolculuk aşaması controller'ı (TASK 027) — TEK seçim.
///
/// Seçim YALNIZ bellekte yaşar; kalıcılık ve startup bağlantısı TASK 028.
/// autoDispose KULLANILMAZ: seçim onboarding oturumu boyunca korunur
/// (TASK 026 controller deseniyle aynı).
final onboardingJourneyControllerProvider =
    NotifierProvider<OnboardingJourneyController, OnboardingJourneyStage?>(
      OnboardingJourneyController.new,
    );

final class OnboardingJourneyController
    extends Notifier<OnboardingJourneyStage?> {
  @override
  OnboardingJourneyStage? build() => null;

  void select(OnboardingJourneyStage stage) => state = stage;

  /// Devam edebilmek için bir aşama seçilmiş olmalı.
  bool get canContinue => state != null;
}
