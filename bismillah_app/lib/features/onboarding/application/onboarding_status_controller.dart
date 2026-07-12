import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Açılış anındaki onboarding tamamlanma değeri.
///
/// PRODÜKSİYONDA DAİMA bootstrap tarafından override edilir (prefs
/// okuması `runApp`'ten ÖNCE biter — yanlış ekran bir an bile görünmez;
/// anahtar yoksa/bozuksa depo `false` döner). Buradaki varsayılan yalnız
/// bootstrap'sız kurulan container'lar (widget testleri) içindir ve mevcut
/// "doğrudan Today" davranışını korur.
final onboardingCompletedAtLaunchProvider = Provider<bool>((ref) => true);

/// Onboarding tamamlanma durumu — startup kapısının TEK kaynağı.
///
/// Router redirect'i her navigasyonda bu değeri okur; router YENİDEN
/// İNŞA EDİLMEZ (bootstrap'ın bildirim-dokunuş bağladığı instance yaşar).
/// Akış tamamlanınca [markCompleted] kapıyı kalıcı olarak açar.
final onboardingCompletedProvider =
    NotifierProvider<OnboardingStatusController, bool>(
      OnboardingStatusController.new,
    );

final class OnboardingStatusController extends Notifier<bool> {
  @override
  bool build() => ref.watch(onboardingCompletedAtLaunchProvider);

  /// Yalnız kayıt BAŞARILI olduktan sonra çağrılır
  /// (OnboardingCompletionController sözleşmesi).
  void markCompleted() => state = true;
}
