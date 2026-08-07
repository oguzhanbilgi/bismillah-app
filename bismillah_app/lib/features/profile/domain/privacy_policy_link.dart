/// Yayımlanmış herkese açık gizlilik politikası adresi (ALPHA-R3C).
///
/// Adres GERÇEKTEN doğrulanmıştır: ALPHA-R3B'de GitHub Pages dağıtımı
/// tamamlandıktan sonra HTTP 200 ile yanıt verdiği görülmüştür. Uygulama
/// içindeki politika ekranı KALDIRILMAZ — bu adres, Play için gereken
/// herkese açık kopyayı sunar ve aynı kanonik metni taşır
/// (`docs/legal/PRIVACY_POLICY.md`).
abstract final class PrivacyPolicyLink {
  static const String url =
      'https://oguzhanbilgi.github.io/bismillah-app/privacy/';
}

/// Herkese açık politika sayfasını SİSTEM TARAYICISINDA açma sözleşmesi.
///
/// [AppSourceLinkService] ile aynı davranış kuralları: WebView açılmaz,
/// exception FIRLATILMAZ, açılamazsa `false` döner ve çağıran adresi içeren
/// sakin bir fallback gösterir.
///
/// İçerik kaynağı allowlist'i (`AppSourceDomains`) BİLEREK kullanılmaz:
/// orası resmî/altyapı DİN İÇERİĞİ kaynaklarına ayrılmıştır ve uygulamanın
/// kendi yayın adresini oraya eklemek o güvenlik sınırını genişletirdi.
abstract interface class PrivacyPolicyLinkService {
  /// Başarılıysa `true`, tarayıcı açılamadıysa `false`.
  Future<bool> openPublishedPolicy();
}
