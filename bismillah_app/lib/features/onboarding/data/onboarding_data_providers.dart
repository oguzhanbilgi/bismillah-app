import 'package:bismillah_app/features/onboarding/data/shared_prefs_onboarding_preferences_repository.dart';
import 'package:bismillah_app/features/onboarding/domain/repositories/onboarding_preferences_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Onboarding tercih deposunun DI bağlaması: uygulama arayüzü okur,
/// içeride SharedPreferences implementasyonu döner (06 §11 — tek DI
/// mekanizması Riverpod; presentation SharedPreferences görmez).
final onboardingPreferencesRepositoryProvider =
    Provider<OnboardingPreferencesRepository>(
      (ref) => const SharedPrefsOnboardingPreferencesRepository(),
    );
