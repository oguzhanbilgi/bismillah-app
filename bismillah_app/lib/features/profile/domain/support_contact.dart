/// Destek / geri bildirim iletişim sözleşmesi (ALPHA-R3A).
///
/// Tek bir kanonik adres vardır; ekranlar adresi kendi içinde YAZMAZ.
/// Gizlilik politikası dosyası (`docs/legal/PRIVACY_POLICY.md`) ile aynı
/// adresi kullanır — ikinci bir elle tutulan kopya yoktur.
abstract final class SupportContact {
  /// Alpha destek adresi. Kullanıcıya gösterilen tek iletişim kanalı.
  static const String email = 'bismillahappsupport@gmail.com';

  /// Konu satırı sabittir ve Bismillah alpha geri bildirimini tanımlar.
  ///
  /// Yerelleştirilmez: gelen kutusunda dile göre değişmeyen tek bir filtre
  /// kuralı çalışsın diye. Sürüm, cihaz kimliği, kullanıcı verisi veya
  /// uygulama içeriği İÇERMEZ.
  static const String subject = 'Bismillah alpha feedback';

  /// Platform e-posta yazma ekranını açan `mailto` adresi.
  ///
  /// Gövde ÖNCEDEN DOLDURULMAZ: hiçbir özel uygulama/kullanıcı verisi
  /// (soru metni, konum, plan, kimlik) e-postaya sızdırılmaz.
  static Uri get mailtoUri =>
      Uri(scheme: 'mailto', path: email, query: 'subject=$subject');
}

/// Destek e-postası açma sözleşmesi.
///
/// Exception FIRLATMAZ: e-posta istemcisi yoksa veya açma başarısız olursa
/// `false` döner ve çağıran dürüst bir fallback (adresi gösterip panoya
/// kopyalama) sunar. Hesap veya giriş GEREKTİRMEZ.
abstract interface class SupportContactService {
  /// Başarılıysa `true`, e-posta yazma ekranı açılamadıysa `false`.
  Future<bool> openSupportEmail();
}
