import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/features/onboarding/domain/entities/onboarding_preferences.dart';

/// Onboarding tercihlerinin lokal kalıcılık sözleşmesi (TASK 028).
///
/// Dar tutulmuştur: startup kapısı için tamamlanma okuması + tek seferlik
/// kayıt. Presentation bu arayüzü görür — SharedPreferences importu yalnız
/// data katmanındadır.
abstract interface class OnboardingPreferencesRepository {
  /// Onboarding tamamlandı mı? Anahtar yoksa, veri bozuksa veya
  /// tanınmayan enum adı varsa `false` döner — ASLA fırlatmaz
  /// (güvenli varsayılan: onboarding gösterilir).
  Future<bool> isCompleted();

  /// Tercihleri TEK kontrollü işlem olarak kaydeder; tamamlanma bayrağı
  /// yalnız seçimler başarıyla yazıldıktan sonra `true` olur.
  ResultFuture<void> saveCompleted(OnboardingPreferences preferences);

  /// Kayıtlı tercihleri okur (TASK 029 — salt-okunur görünüm için).
  ///
  /// `success(null)` = henüz tamamlanmamış VEYA bozuk/tanınmayan veri
  /// (sakin boş durum; crash yok). `failure` = gerçek okuma hatası
  /// (UI kısa hata + tekrar dene gösterebilir).
  ResultFuture<OnboardingPreferences?> load();
}
