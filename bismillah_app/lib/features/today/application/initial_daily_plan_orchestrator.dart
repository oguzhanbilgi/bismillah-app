import 'dart:async';

import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/onboarding/data/onboarding_data_providers.dart';
import 'package:bismillah_app/features/onboarding/domain/entities/onboarding_preferences.dart';
import 'package:bismillah_app/features/onboarding/domain/repositories/onboarding_preferences_repository.dart';
import 'package:bismillah_app/features/today/data/today_data_providers.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/repositories/daily_plan_repository.dart';
import 'package:bismillah_app/features/today/domain/services/core_daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_generation_request.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_generator.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_item_source.dart';
import 'package:bismillah_app/features/today/domain/services/onboarding_profile_mapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// İlk 30 günlük planın oluşturulma sonucu (TASK 083A).
///
/// Sakin sonuçlar (zaten var / onboarding eksik) hata DEĞİL veridir.
/// Hiçbir varyant ham onboarding cevabı, plan JSON'u, makale metni,
/// depolama anahtarı, UID, cihaz verisi, istisna metni veya yığın izi
/// TAŞIMAZ.
sealed class InitialDailyPlanOutcome {
  const InitialDailyPlanOutcome();

  /// Depoya yeni bir plan yazıldı mı?
  bool get didCreate => this is InitialDailyPlanCreated;

  /// Today artık bu gün için bir plan bulabilir mi?
  bool get isPlanAvailable =>
      this is InitialDailyPlanCreated ||
      this is InitialDailyPlanAlreadyAvailable;
}

/// 30 gün üretildi ve tek yazmayla kalıcılaştırıldı.
final class InitialDailyPlanCreated extends InitialDailyPlanOutcome {
  const InitialDailyPlanCreated({
    required this.startDay,
    required this.dayCount,
  });

  final DayKey startDay;
  final int dayCount;
}

/// İstenen aralık zaten eksiksiz ve tutarlı — hiçbir şey yazılmadı.
///
/// Mevcut tamamlanma durumu ve zaman damgaları KORUNUR.
final class InitialDailyPlanAlreadyAvailable extends InitialDailyPlanOutcome {
  const InitialDailyPlanAlreadyAvailable({required this.startDay});

  final DayKey startDay;
}

/// Kayıtlı onboarding tercihi yok veya profil belirlemeye yetmiyor.
///
/// Yalnız stabil alan kimliği taşır (`ProfileMappingMissingField`);
/// kullanıcının cevap içeriği taşınmaz.
final class InitialDailyPlanOnboardingIncomplete
    extends InitialDailyPlanOutcome {
  const InitialDailyPlanOnboardingIncomplete({this.missingField});

  final String? missingField;
}

/// Aralıkta **kısmi** veya **tutarsız** plan var.
///
/// Eksik günler otomatik doldurulmaz, mevcut günler silinmez veya
/// üzerine yazılmaz — kurtarma ayrı bir karardır (TASK 084).
final class InitialDailyPlanRangeConflict extends InitialDailyPlanOutcome {
  const InitialDailyPlanRangeConflict({
    required this.existingDayCount,
    required this.expectedDayCount,
  });

  final int existingDayCount;
  final int expectedDayCount;
}

/// Üretim tipli bir hatayla döndü (istek doğrulaması, bütçe, kaynak…).
final class InitialDailyPlanGenerationFailed extends InitialDailyPlanOutcome {
  const InitialDailyPlanGenerationFailed(this.failure);

  final AppFailure failure;
}

/// Okuma veya atomik yazma başarısız oldu; depo değişmedi.
final class InitialDailyPlanPersistenceFailed extends InitialDailyPlanOutcome {
  const InitialDailyPlanPersistenceFailed(this.failure);

  final AppFailure failure;
}

/// İlk 30 günlük planın uçtan uca oluşturulması (TASK 083A).
///
/// Zinciri tek yerde toplar:
///
/// `OnboardingPreferences` → `OnboardingProfileMapper` →
/// `DailyPlanGenerationRequest` → `DailyPlanGenerator` +
/// `CoreDailyPlanItemSource` (Prayer → Quran → Learn) → **tek atomik
/// yazma**.
///
/// ## Ne YAPMAZ
///
/// Mevcut geçerli bir planı sessizce YENİDEN ÜRETMEZ ve ÜZERİNE YAZMAZ.
/// Kısmi aralığı otomatik tamamlamaz, gün silmez, tamamlanma durumunu veya
/// zaman damgalarını değiştirmez. Kullanıcıya görünen metin İÇERMEZ,
/// `DateTime.now()` çağırmaz, yeni depolama anahtarı veya zarf sürümü
/// eklemez, Drift/Firebase/ağ kullanmaz.
///
/// ## Eşzamanlılık
///
/// Aynı anda gelen çağrılar **tek** mantıksal oluşturmayı paylaşır: ilk
/// çağrının `Future`'ı belleğe alınır, sonraki çağrılar onu bekler ve aynı
/// sonucu görür. Böylece iki eşzamanlı çağrı iki yazma başlatamaz.
final class InitialDailyPlanOrchestrator {
  InitialDailyPlanOrchestrator({
    required this.planRepository,
    required this.preferencesRepository,
    required this.clock,
    this.itemSource = CoreDailyPlanItemSource.approved,
  });

  final DailyPlanRepository planRepository;
  final OnboardingPreferencesRepository preferencesRepository;
  final AppClock clock;

  /// Onaylı çekirdek bileşim (Prayer → Quran → Learn); testler kontrollü
  /// bir kaynak enjekte edebilir.
  final DailyPlanItemSource itemSource;

  /// Devam eden tek oluşturma işlemi (eşzamanlı çağrı koruması).
  Future<InitialDailyPlanOutcome>? _inFlight;

  /// Üretilecek gün sayısı — kanonik 30 günlük çatı.
  static int get planLengthDays => DailyPlanGenerationRequest.planLengthDays;

  /// Bugünden başlayan 30 günlük planın var olduğunu garanti eder.
  ///
  /// [preferences] verilirse depodan okuma yapılmaz (onboarding akışı
  /// tercihleri elinde tutar — çift okuma ve çift kalıcılık olmaz).
  Future<InitialDailyPlanOutcome> ensureInitialPlan({
    OnboardingPreferences? preferences,
  }) {
    final running = _inFlight;
    if (running != null) {
      return running;
    }
    final started = _run(preferences).whenComplete(() => _inFlight = null);
    _inFlight = started;
    return started;
  }

  Future<InitialDailyPlanOutcome> _run(OnboardingPreferences? provided) async {
    final OnboardingPreferences? preferences;
    if (provided != null) {
      preferences = provided;
    } else {
      final loaded = await preferencesRepository.load();
      final loadFailure = loaded.failureOrNull;
      if (loadFailure != null) {
        return InitialDailyPlanPersistenceFailed(loadFailure);
      }
      preferences = loaded.valueOrNull;
    }
    if (preferences == null) {
      // Tamamlanmamış/okunamayan tercih: plan UYDURULMAZ.
      return const InitialDailyPlanOnboardingIncomplete();
    }

    final mapping = OnboardingProfileMapper.map(preferences);
    if (mapping is ProfileIncomplete) {
      return InitialDailyPlanOnboardingIncomplete(
        missingField: mapping.missingField,
      );
    }
    final profile = (mapping as ProfileMapped).profile;

    // Başlangıç günü enjekte edilen saatten YEREL takvimle türetilir
    // (`DateTime.now()` yok, UTC kayması yok).
    final startDay = DayKey.fromLocal(clock.nowLocal());
    final lastDay = DailyPlanGenerator.dayAt(startDay, planLengthDays - 1);

    final existing = await planRepository.getRange(startDay, lastDay);
    final existingFailure = existing.failureOrNull;
    if (existingFailure != null) {
      // Bozuk/okunamayan depo üzerine ASLA yazılmaz.
      return InitialDailyPlanPersistenceFailed(existingFailure);
    }
    final existingPlans = existing.valueOrNull!;
    if (existingPlans.isNotEmpty) {
      return _classifyExisting(existingPlans, startDay);
    }

    final request = DailyPlanGenerationRequest(
      profileType: profile,
      goals: preferences.goals,
      dailyPace: preferences.dailyPace,
      startDay: startDay,
    );

    final generated = await DailyPlanGenerator.generate(
      request,
      source: itemSource,
    );
    final generationFailure = generated.failureOrNull;
    if (generationFailure != null) {
      return InitialDailyPlanGenerationFailed(generationFailure);
    }
    final plans = generated.valueOrNull!;
    if (plans.length != planLengthDays) {
      // Üretici sözleşmesi bunu zaten garanti eder; yine de yarım bir
      // aralık kalıcılaştırılmaz.
      return const InitialDailyPlanGenerationFailed(UnexpectedFailure());
    }

    // TEK mantıksal yazma — 30 ayrı çağrı YAPILMAZ.
    final saved = await planRepository.savePlans(plans);
    final saveFailure = saved.failureOrNull;
    if (saveFailure != null) {
      return InitialDailyPlanPersistenceFailed(saveFailure);
    }
    return InitialDailyPlanCreated(startDay: startDay, dayCount: plans.length);
  }

  /// Mevcut aralığı sınıflandırır: eksiksiz ve sürekli mi, yoksa kısmi mi?
  ///
  /// Hiçbir günü silmez veya değiştirmez.
  InitialDailyPlanOutcome _classifyExisting(
    List<DailyPlan> existingPlans,
    DayKey startDay,
  ) {
    if (existingPlans.length != planLengthDays) {
      return InitialDailyPlanRangeConflict(
        existingDayCount: existingPlans.length,
        expectedDayCount: planLengthDays,
      );
    }
    for (var offset = 0; offset < planLengthDays; offset++) {
      if (existingPlans[offset].dayKey !=
          DailyPlanGenerator.dayAt(startDay, offset)) {
        // Aralık dolu ama sürekli değil — sessizce onarılmaz.
        return InitialDailyPlanRangeConflict(
          existingDayCount: existingPlans.length,
          expectedDayCount: planLengthDays,
        );
      }
    }
    return InitialDailyPlanAlreadyAvailable(startDay: startDay);
  }
}

/// Orkestratörün DI bağlaması.
///
/// Container ömrü boyunca tek örnektir; eşzamanlı çağrı koruması bu
/// örneğin içinde yaşar. Bootstrap bu provider'ı KENDİLİĞİNDEN OKUMAZ —
/// tetikleme açık bir çağrıyla olur.
final initialDailyPlanOrchestratorProvider =
    Provider<InitialDailyPlanOrchestrator>(
      (ref) => InitialDailyPlanOrchestrator(
        planRepository: ref.watch(dailyPlanRepositoryProvider),
        preferencesRepository: ref.watch(
          onboardingPreferencesRepositoryProvider,
        ),
        clock: ref.watch(clockProvider),
      ),
    );
