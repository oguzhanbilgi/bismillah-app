import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_reading_preferences.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_arabic_script.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_reading_goal.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_translation_preference.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kur'an ekranı durumu (TASK 033): kurulum akışı + kayıtlı tercihler +
/// hedef düzenleme. Yükleme/okuma hatası AsyncValue katmanındadır;
/// kayıt hatası sakin bir bayraktır — kayıtlı tercihler SİLİNMEZ.
final class QuranPreferencesState {
  const QuranPreferencesState({
    this.savedPreferences,
    this.currentSetupStep = 1,
    this.selectedScript,
    this.selectedTranslation,
    this.selectedGoalType,
    this.selectedGoalAmount,
    this.isEditingGoal = false,
    this.isSaving = false,
    this.saveFailed = false,
  });

  static const int totalSetupSteps = 3;

  /// Kayıtlı tercihler; `null` = kurulum tamamlanmamış → kurulum akışı.
  final QuranReadingPreferences? savedPreferences;

  /// 1..3 arası kurulum adımı (geri dönüşte seçimler korunur).
  final int currentSetupStep;

  final QuranArabicScript? selectedScript;
  final QuranTranslationPreference? selectedTranslation;
  final QuranReadingGoalType? selectedGoalType;
  final int? selectedGoalAmount;

  /// İlerlemem sekmesindeki "Hedefi düzenle" görünümü açık mı.
  final bool isEditingGoal;

  final bool isSaving;
  final bool saveFailed;

  /// Seçili tür+miktar geçerli bir hedefse döner; değilse `null`.
  QuranReadingGoal? get selectedGoal =>
      selectedGoalType == null || selectedGoalAmount == null
      ? null
      : QuranReadingGoal.of(
          type: selectedGoalType!,
          amount: selectedGoalAmount!,
        );

  /// Aktif adımın "devam" koşulu.
  bool get canContinueCurrentStep => switch (currentSetupStep) {
    1 => selectedScript != null,
    2 => selectedTranslation != null,
    _ => canFinishSetup,
  };

  bool get canFinishSetup =>
      selectedScript != null &&
      selectedTranslation != null &&
      selectedGoal != null;

  QuranPreferencesState copyWith({
    QuranReadingPreferences? savedPreferences,
    int? currentSetupStep,
    QuranArabicScript? selectedScript,
    QuranTranslationPreference? selectedTranslation,
    QuranReadingGoalType? selectedGoalType,
    int? selectedGoalAmount,
    bool? isEditingGoal,
    bool? isSaving,
    bool? saveFailed,
    bool clearGoalAmount = false,
  }) => QuranPreferencesState(
    savedPreferences: savedPreferences ?? this.savedPreferences,
    currentSetupStep: currentSetupStep ?? this.currentSetupStep,
    selectedScript: selectedScript ?? this.selectedScript,
    selectedTranslation: selectedTranslation ?? this.selectedTranslation,
    selectedGoalType: selectedGoalType ?? this.selectedGoalType,
    selectedGoalAmount: clearGoalAmount
        ? null
        : (selectedGoalAmount ?? this.selectedGoalAmount),
    isEditingGoal: isEditingGoal ?? this.isEditingGoal,
    isSaving: isSaving ?? this.isSaving,
    saveFailed: saveFailed ?? this.saveFailed,
  );
}

/// Kur'an tercihleri controller'ı (TASK 033).
///
/// Kurulum yalnız Kur'an sekmesi İÇİNDE yaşar: genel onboarding kapısına,
/// route stack'e ve Today yönlendirmesine DOKUNMAZ. SyncOperation
/// üretilmez. autoDispose: sekmeye her dönüşte güncel kaydı okur.
final quranPreferencesControllerProvider =
    AsyncNotifierProvider.autoDispose<
      QuranPreferencesController,
      QuranPreferencesState
    >(QuranPreferencesController.new);

final class QuranPreferencesController
    extends AsyncNotifier<QuranPreferencesState> {
  @override
  Future<QuranPreferencesState> build() async {
    final repository = ref.read(quranReadingPreferencesRepositoryProvider);
    final result = await repository.load();
    return result.fold(
      onSuccess: (preferences) async {
        if (preferences != null) {
          // Hedef düzenleme görünümü için seçimler kayıttan ön-doldurulur.
          return QuranPreferencesState(
            savedPreferences: preferences,
            selectedScript: preferences.arabicScript,
            selectedTranslation: preferences.translation,
            selectedGoalType: preferences.goal.type,
            selectedGoalAmount: preferences.goal.amount,
          );
        }
        // TASK 032'nin eski sayfa hedefi varsa 3. adım ön-seçilir;
        // Uthmani ve Türkçe önerilen varsayılan SEÇİMLERDİR — kullanıcı
        // son butona basmadan HİÇBİR ŞEY kaydedilmez.
        final legacy = await repository.loadLegacyPageGoal();
        final legacyGoal = legacy.fold(
          onSuccess: (goal) => goal,
          onFailure: (_) => null,
        );
        return QuranPreferencesState(
          selectedScript: QuranArabicScript.uthmani,
          selectedTranslation: QuranTranslationPreference.turkish,
          selectedGoalType: legacyGoal?.type,
          selectedGoalAmount: legacyGoal?.amount,
        );
      },
      onFailure: (failure) => throw failure,
    );
  }

  void selectScript(QuranArabicScript script) {
    final current = state.value;
    if (current == null || current.isSaving) {
      return;
    }
    state = AsyncData(current.copyWith(selectedScript: script));
  }

  void selectTranslation(QuranTranslationPreference translation) {
    final current = state.value;
    if (current == null || current.isSaving) {
      return;
    }
    state = AsyncData(current.copyWith(selectedTranslation: translation));
  }

  /// Tür değişince önceki türe ait miktar sıfırlanır (5 dakika ≠ 5 sayfa
  /// olarak taşınmaz); aynı tür yeniden seçilirse miktar korunur.
  void selectGoalType(QuranReadingGoalType type) {
    final current = state.value;
    if (current == null || current.isSaving) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        selectedGoalType: type,
        clearGoalAmount: current.selectedGoalType != type,
      ),
    );
  }

  void selectGoalAmount(int amount) {
    final current = state.value;
    if (current == null || current.isSaving) {
      return;
    }
    state = AsyncData(current.copyWith(selectedGoalAmount: amount));
  }

  void goToNextStep() {
    final current = state.value;
    if (current == null ||
        current.isSaving ||
        current.currentSetupStep >= QuranPreferencesState.totalSetupSteps) {
      return;
    }
    state = AsyncData(
      current.copyWith(currentSetupStep: current.currentSetupStep + 1),
    );
  }

  /// Geri dönüşte seçimler state'te olduğu gibi korunur.
  void goToPreviousStep() {
    final current = state.value;
    if (current == null || current.isSaving || current.currentSetupStep <= 1) {
      return;
    }
    state = AsyncData(
      current.copyWith(currentSetupStep: current.currentSetupStep - 1),
    );
  }

  /// Kurulum finali: doğrula → kaydet → Kur'an ana ekranı (Oku sekmesi).
  /// Çift dokunuş `isSaving` koruması ve pasif butonla engellenir.
  Future<void> completeSetup() async {
    final current = state.value;
    final goal = current?.selectedGoal;
    if (current == null || current.isSaving || !current.canFinishSetup) {
      return;
    }
    await _save(
      current,
      QuranReadingPreferences(
        arabicScript: current.selectedScript!,
        translation: current.selectedTranslation!,
        goal: goal!,
        setupCompleted: true,
      ),
    );
  }

  /// "Hedefi düzenle": mevcut hedef ön-seçili hedef görünümünü açar.
  void startGoalEdit() {
    final current = state.value;
    final saved = current?.savedPreferences;
    if (current == null || saved == null || current.isSaving) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        isEditingGoal: true,
        selectedGoalType: saved.goal.type,
        selectedGoalAmount: saved.goal.amount,
        saveFailed: false,
      ),
    );
  }

  void cancelGoalEdit() {
    final current = state.value;
    if (current == null || current.isSaving) {
      return;
    }
    state = AsyncData(current.copyWith(isEditingGoal: false));
  }

  /// Yalnız hedefi günceller — script ve meal tercihleri KORUNUR.
  Future<void> saveGoalEdit() async {
    final current = state.value;
    final saved = current?.savedPreferences;
    final goal = current?.selectedGoal;
    if (current == null || saved == null || goal == null || current.isSaving) {
      return;
    }
    await _save(current, saved.copyWith(goal: goal));
  }

  Future<void> _save(
    QuranPreferencesState current,
    QuranReadingPreferences preferences,
  ) async {
    state = AsyncData(current.copyWith(isSaving: true, saveFailed: false));
    final result = await ref
        .read(quranReadingPreferencesRepositoryProvider)
        .save(preferences);
    state = AsyncData(
      result.fold(
        onSuccess: (_) => current.copyWith(
          savedPreferences: preferences,
          isEditingGoal: false,
          isSaving: false,
        ),
        onFailure: (_) => current.copyWith(isSaving: false, saveFailed: true),
      ),
    );
  }
}
