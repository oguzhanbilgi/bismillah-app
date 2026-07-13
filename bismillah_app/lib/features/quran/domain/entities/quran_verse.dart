/// Doğrulanmış Kur'an ayeti (TASK 035) — paket bağımsız, immutable.
///
/// Kaynak: Tanzil Quran Text (Uthmani, 1.1); metin AYNEN korunur —
/// normalizasyon/düzeltme/Besmele ekleme-çıkarma YAPILMAZ. AI metni bu
/// tipe ASLA giremez.
final class QuranVerse {
  QuranVerse({
    required this.chapterId,
    required this.verseNumber,
    required this.verseKey,
    required this.textUthmani,
  }) {
    if (chapterId < 1 || chapterId > 114) {
      throw ArgumentError.value(chapterId, 'chapterId', '1–114 olmalı');
    }
    if (verseNumber < 1) {
      throw ArgumentError.value(verseNumber, 'verseNumber', 'pozitif olmalı');
    }
    if (verseKey != '$chapterId:$verseNumber') {
      throw ArgumentError.value(
        verseKey,
        'verseKey',
        'chapterId:verseNumber ile uyumlu olmalı',
      );
    }
    if (textUthmani.trim().isEmpty) {
      throw ArgumentError.value(textUthmani, 'textUthmani', 'boş olamaz');
    }
  }

  /// Sure numarası (1–114).
  final int chapterId;

  /// Sure içi ayet numarası (1 tabanlı, kesintisiz).
  final int verseNumber;

  /// "1:1" biçiminde benzersiz anahtar.
  final String verseKey;

  /// Uthmani yazımıyla tam harekeli ayet metni.
  final String textUthmani;
}
