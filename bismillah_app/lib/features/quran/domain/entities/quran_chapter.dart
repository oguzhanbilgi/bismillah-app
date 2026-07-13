/// Nüzul yeri (TASK 034). Stabil `name` ile saklanır; kullanıcıya
/// `.name` gösterilmez — etiketler localization'dadır.
enum QuranRevelationPlace { meccan, medinan }

/// Kur'an suresi katalog girdisi (TASK 034/034B) — yalnız METADATA'dır,
/// ayet metni içermez. Kaynak: Tanzil Quran Metadata 1.0
/// (assets/quran/chapters_v1.json; NOTICE.md kaynak künyesini taşır).
final class QuranChapter {
  const QuranChapter({
    required this.id,
    required this.arabicName,
    required this.transliteratedName,
    required this.englishName,
    required this.verseCount,
    required this.revelationPlace,
    required this.revelationOrder,
    required this.startVerseIndex,
    required this.rukuCount,
  });

  /// Mushaf sırası (1–114).
  final int id;

  final String arabicName;
  final String transliteratedName;
  final String englishName;
  final int verseCount;
  final QuranRevelationPlace revelationPlace;

  /// Nüzul (iniş) sırası (1–114).
  final int revelationOrder;

  /// Surenin ilk ayetinin Kur'an genelindeki 0 tabanlı sıra numarası.
  final int startVerseIndex;

  final int rukuCount;
}
