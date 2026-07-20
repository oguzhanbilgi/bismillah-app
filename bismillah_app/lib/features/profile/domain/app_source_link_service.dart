/// İçerik kaynakları için bağlantı açma sözleşmesi (TASK 058 §5).
///
/// Learn içerik bağlantılarından FARKLIDIR: Learn yalnız `diyanet.gov.tr`
/// alanına kilitlidir (dinamik içerik güvenliği), oysa bu servis derleme
/// zamanı sabiti olan altyapı kaynaklarını da (Tanzil, QuranEnc, MP3Quran)
/// açabilir. Yine de yalnız HTTPS + bilinen host allowlist'i geçer.
///
/// WebView AÇILMAZ; hedef sistem tarayıcısıdır. Açma başarısız olursa
/// exception FIRLATILMAZ: `false` döner ve ekran panoya kopyalama sunar.
abstract interface class AppSourceLinkService {
  /// Başarılıysa `true`. Adres izinli değilse veya açılamıyorsa `false`.
  Future<bool> openSource(String url);
}

/// İçerik kaynakları için izin verilen resmî/altyapı host'ları.
///
/// Yalnız bu kök alanlar ve alt alanları HTTPS ile açılabilir. Son ek
/// benzerlikleri (`nottanzil.net` gibi) nokta sınırı kontrolüyle reddedilir.
abstract final class AppSourceDomains {
  static const Set<String> _roots = {
    'tanzil.net',
    'quranenc.com',
    'mp3quran.net',
    'diyanet.gov.tr',
  };

  static bool isAllowed(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || uri.scheme != 'https' || !uri.hasAuthority) {
      return false;
    }
    final host = uri.host.toLowerCase();
    return _roots.any((root) => host == root || host.endsWith('.$root'));
  }
}
