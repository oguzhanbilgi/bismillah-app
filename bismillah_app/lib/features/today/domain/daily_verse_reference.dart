/// "Bugünün Ayeti" için gözden geçirilmiş referans listesi ve deterministik
/// günlük seçim (TASK 052).
///
/// Kurallar:
/// - Liste SABİTTİR ve gözden geçirilmiştir; algoritma ayet SEÇMEZ, yalnız
///   listeden sıra belirler. Rastgelelik YOKTUR.
/// - Seçim yalnız YEREL TAKVİM GÜNÜNE bağlıdır: aynı gün içinde değişmez,
///   kullanıcı kimliğine/cihazına/ağa bağlı DEĞİLDİR.
/// - Bu sınıf ayet METNİ tutmaz; metin ve meal bundled Tanzil/QuranEnc
///   depolarından okunur (kaynak bütünlüğü korunur).
abstract final class DailyVerseReference {
  /// Umut, sabır ve rahmet temalı gözden geçirilmiş referanslar.
  /// Sıra anlamlı değildir; dinî önem sıralaması İÇERMEZ.
  static const List<String> curated = <String>[
    '2:286',
    '13:28',
    '39:53',
    '94:5',
    '94:6',
    '65:3',
    '29:69',
  ];

  /// Verilen YEREL tarih için referans (`chapterId:verseNumber`).
  ///
  /// Gün numarası UTC'ye normalize edilmiş takvim gününden türetilir; bu
  /// sayede yaz saati/timezone kayması aynı takvim gününde seçimi
  /// DEĞİŞTİRMEZ.
  static String forLocalDate(DateTime localDate) {
    final dayNumber = DateTime.utc(
      localDate.year,
      localDate.month,
      localDate.day,
    ).difference(DateTime.utc(1970)).inDays;
    final index = dayNumber % curated.length;
    return curated[index < 0 ? index + curated.length : index];
  }
}
