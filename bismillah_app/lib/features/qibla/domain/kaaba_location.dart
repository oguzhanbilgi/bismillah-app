/// Kâbe'nin sabit coğrafi konumu (TASK 095).
///
/// ## Kaynak ve gerekçe
///
/// Değer: **21.4225° K, 39.8262° D**.
///
/// Bu koordinat, Kâbe'nin (Mescid-i Harâm, Mekke) yaygın olarak yayımlanan
/// coğrafi etiketidir; Wikipedia "Kaaba" maddesinin geo-etiketinde ve aynı
/// değeri kullanan kıble hesaplayıcılarında bulunur. Açıklanmadan
/// kopyalanmış bir sayı DEĞİLDİR: aşağıdaki sınırları bilinerek seçilmiştir.
///
/// ## Bilinen sınırlar (dürüstlük notu)
///
/// * Kâbe bir nokta değil, yaklaşık 11 m × 13 m tabanı olan bir yapıdır.
///   Buradaki tek nokta, yapının merkezine yakın bir temsil değeridir.
/// * Bu belirsizliğin yön açısına etkisi, uzak bir konumdan bakıldığında
///   derecenin binde biri mertebesindedir — yani telefon manyetometresinin
///   hata payının çok altında kalır.
/// * Bu nedenle uygulama, hesaplanan yönü **yaklaşık** olarak sunar ve
///   ölçüm hassasiyeti ya da dinî bir hüküm iddiasında BULUNMAZ.
abstract final class KaabaLocation {
  /// Kâbe enlemi (kuzey pozitif).
  static const double latitude = 21.4225;

  /// Kâbe boylamı (doğu pozitif).
  static const double longitude = 39.8262;
}
