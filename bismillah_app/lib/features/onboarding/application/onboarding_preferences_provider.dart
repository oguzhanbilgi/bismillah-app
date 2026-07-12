import 'package:bismillah_app/features/onboarding/data/onboarding_data_providers.dart';
import 'package:bismillah_app/features/onboarding/domain/entities/onboarding_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kayıtlı onboarding tercihlerinin SALT-OKUNUR görünümü (TASK 029).
///
/// `null` = henüz tamamlanmamış veya bozuk veri (sakin boş durum);
/// hata = gerçek okuma sorunu (UI tekrar dene sunar, `ref.invalidate`
/// ile yenilenir). Yazma yolu YOKTUR — kayıt yalnız onboarding
/// tamamlama akışındadır. autoDispose: dinleyici kalmayınca düşer,
/// sonraki açılışta güncel değeri okur.
final onboardingPreferencesProvider =
    FutureProvider.autoDispose<OnboardingPreferences?>((ref) async {
      final result = await ref
          .watch(onboardingPreferencesRepositoryProvider)
          .load();
      return result.fold(
        onSuccess: (preferences) => preferences,
        onFailure: (failure) => throw failure,
      );
    });
