import 'package:bismillah_app/features/onboarding/application/onboarding_preferences_provider.dart';
import 'package:bismillah_app/features/onboarding/data/onboarding_data_providers.dart';
import 'package:bismillah_app/features/onboarding/domain/entities/onboarding_preferences.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_daily_pace.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_journey_stage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kişiselleştirme düzenleme durumu (TASK 030). Kayıt sürerken seçenekler
/// görünür kalır (`isSaving` state İÇİNDEDİR); hata sakin bir bayraktır.
final class PersonalizationEditState {
  const PersonalizationEditState({
    required this.goals,
    required this.journeyStage,
    required this.dailyPace,
    required this.completedAtUtc,
    this.isSaving = false,
    this.saveFailed = false,
  });

  final Set<OnboardingFocusGoal> goals;
  final OnboardingJourneyStage journeyStage;
  final OnboardingDailyPace dailyPace;

  /// İLK tamamlanma anı korunur — düzenleme, onboarding zamanını değiştirmez.
  final DateTime completedAtUtc;

  final bool isSaving;
  final bool saveFailed;

  /// En az bir hedef zorunlu (tekli alanlar non-null tipte zaten dolu).
  bool get canSave => goals.isNotEmpty;

  PersonalizationEditState copyWith({
    Set<OnboardingFocusGoal>? goals,
    OnboardingJourneyStage? journeyStage,
    OnboardingDailyPace? dailyPace,
    bool? isSaving,
    bool? saveFailed,
  }) => PersonalizationEditState(
    goals: goals ?? this.goals,
    journeyStage: journeyStage ?? this.journeyStage,
    dailyPace: dailyPace ?? this.dailyPace,
    completedAtUtc: completedAtUtc,
    isSaving: isSaving ?? this.isSaving,
    saveFailed: saveFailed ?? this.saveFailed,
  );
}

/// Kişiselleştirme düzenleme controller'ı (TASK 030).
///
/// İlk yükleme TASK 029 deposundan gelir; `AsyncData(null)` = geçerli
/// tercih yok (sakin durum, Profil'e dönüş), `AsyncError` = okuma hatası.
/// Kayıt mevcut `saveCompleted` ile yapılır — completed bayrağı true
/// KALIR, startup kapısı değişmez, SyncOperation üretilmez. autoDispose:
/// ekran her açılışta güncel kaydı yükler.
final personalizationEditControllerProvider =
    AsyncNotifierProvider.autoDispose<
      PersonalizationEditController,
      PersonalizationEditState?
    >(PersonalizationEditController.new);

final class PersonalizationEditController
    extends AsyncNotifier<PersonalizationEditState?> {
  @override
  Future<PersonalizationEditState?> build() async {
    final result = await ref
        .read(onboardingPreferencesRepositoryProvider)
        .load();
    return result.fold(
      onSuccess: (preferences) => preferences == null
          ? null
          : PersonalizationEditState(
              goals: preferences.goals,
              journeyStage: preferences.journeyStage,
              dailyPace: preferences.dailyPace,
              completedAtUtc: preferences.completedAtUtc,
            ),
      onFailure: (failure) => throw failure,
    );
  }

  void toggleGoal(OnboardingFocusGoal goal) {
    final current = state.value;
    if (current == null || current.isSaving) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        goals: current.goals.contains(goal)
            ? current.goals.where((g) => g != goal).toSet()
            : {...current.goals, goal},
      ),
    );
  }

  void selectJourneyStage(OnboardingJourneyStage stage) {
    final current = state.value;
    if (current == null || current.isSaving) {
      return;
    }
    state = AsyncData(current.copyWith(journeyStage: stage));
  }

  void selectDailyPace(OnboardingDailyPace pace) {
    final current = state.value;
    if (current == null || current.isSaving) {
      return;
    }
    state = AsyncData(current.copyWith(dailyPace: pace));
  }

  /// Kaydeder; başarıda `true` döner (ekran o zaman Profil'e döner).
  /// Çift dokunuş `isSaving` koruması ve pasif butonla engellenir.
  Future<bool> save() async {
    final current = state.value;
    if (current == null || !current.canSave || current.isSaving) {
      return false;
    }
    state = AsyncData(current.copyWith(isSaving: true, saveFailed: false));
    final result = await ref
        .read(onboardingPreferencesRepositoryProvider)
        .saveCompleted(
          OnboardingPreferences(
            goals: current.goals,
            journeyStage: current.journeyStage,
            dailyPace: current.dailyPace,
            completedAtUtc: current.completedAtUtc,
          ),
        );
    return result.fold(
      onSuccess: (_) {
        // Profil özeti aynı kaynaktan beslenir — taze okumaya zorlanır.
        ref.invalidate(onboardingPreferencesProvider);
        state = AsyncData(current.copyWith(isSaving: false));
        return true;
      },
      onFailure: (_) {
        state = AsyncData(current.copyWith(isSaving: false, saveFailed: true));
        return false;
      },
    );
  }
}
