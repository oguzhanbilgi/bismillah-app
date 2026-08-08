/// Günün sakin kapanış cümlesinin seçimi (RDX-02B).
///
/// ## Bu içerik NEDİR, ne DEĞİLDİR
///
/// Cümleler **arayüz metnidir** (`internal-ui-copy`): ayet, hadis, dua,
/// fetva veya Allah'a ya da Peygamber'e atfedilen bir söz **DEĞİLDİR**.
/// Bu yüzden tırnak içine alınmaz, kaynak künyesi taşımaz ve sevap/karşılık
/// vaat etmez. Uydurma bir atıf üretilemez, çünkü ortada atıf yoktur.
///
/// ## Seçim kuralı
///
/// Seçim **cihazın yerel takvim gününden** deterministik olarak türetilir:
/// aynı yerel gün — uygulama yeniden başlasa bile — aynı cümleyi verir,
/// ertesi yerel gün bir sonrakine geçer. Ağ, `Random`, kalıcı depolama ve
/// timer **yoktur**; ekranın normal yeniden kurulması yeterlidir.
///
/// Gün sınırı **yereldir, UTC değildir**: gün numarası yerel yıl/ay/gün
/// alanlarından üretilir. UTC sınırı kullanılsaydı, kullanıcı hâlâ dünkü
/// gününü yaşarken cümle değişebilirdi.
abstract final class TodayReflection {
  /// Küratörlü cümle sayısı. Üç dilde de AYNIdır ve aynı indeks üç dilde
  /// AYNI anlamı taşır (çeviri, ayrı bir cümle değil).
  static const int count = 14;

  /// Yerel takvim gününden 0..[count) aralığında deterministik indeks.
  ///
  /// [nowLocal] cihazın yerel saatidir; yalnız **yıl/ay/gün** alanları
  /// kullanılır — saat, dakika ve timezone ofseti sonucu etkilemez, bu
  /// yüzden gün içinde cümle asla değişmez.
  static int indexForLocalDate(DateTime nowLocal) {
    // Yerel takvim alanları UTC bir güne taşınır: UTC'de yaz saati kayması
    // olmadığı için gün farkı tam sayıdır ve aritmetik kararlıdır. Bu bir
    // "UTC gün sınırı" DEĞİLDİR — sınırı belirleyen alanlar yereldir.
    final localDay = DateTime.utc(nowLocal.year, nowLocal.month, nowLocal.day);
    final dayNumber = localDay.difference(_epoch).inDays;
    // Dart'ta `%` sonucu negatif olmaz; epoch öncesi tarihler de güvenlidir.
    return dayNumber % count;
  }

  /// Sabit referans günü. Değeri anlam taşımaz — yalnız sayma başlangıcıdır
  /// ve DEĞİŞTİRİLMEMELİDİR: değişirse herkesin sırası kayar.
  static final DateTime _epoch = DateTime.utc(2026, 1, 1);
}
