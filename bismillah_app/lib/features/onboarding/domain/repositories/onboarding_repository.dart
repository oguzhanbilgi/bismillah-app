import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/features/onboarding/domain/entities/onboarding_answers.dart';
import 'package:bismillah_app/features/onboarding/domain/entities/personalization_profile.dart';

/// Onboarding lokal veri sözleşmesi (10_DATA_MODEL §7).
///
/// Her cevap ANINDA lokale yazılır (04 §15 — yarıda kapatma kurtarması);
/// implementasyon TASK 013+.
abstract interface class OnboardingRepository {
  ResultFuture<OnboardingAnswers?> getAnswers();

  /// Kısmi cevap durumu da kaydedilebilir (completedAt null).
  ResultFuture<void> saveAnswers(OnboardingAnswers answers);

  ResultFuture<PersonalizationProfile?> getPersonalizationProfile();

  /// Türetilmiş cache güncellemesi (§21 — çakışmada yeniden türetilir).
  ResultFuture<void> savePersonalizationProfile(
    PersonalizationProfile profile,
  );
}
