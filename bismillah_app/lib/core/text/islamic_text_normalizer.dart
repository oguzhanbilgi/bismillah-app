/// Türkçe/İngilizce/Arapça metin normalizasyonu (TASK 056 §8, TASK 059 §7).
///
/// Learn araması ve Bismillah Asistanı retrieval'ı AYNI normalizasyonu
/// paylaşır — kod KOPYALANMAZ (bu paylaşılan yardımcıya çıkarılmıştır).
/// Yeni bir NLP paketi EKLENMEZ: gereken davranış küçük ve deterministik
/// bir fonksiyonla sağlanır.
abstract final class IslamicTextNormalizer {
  /// Türkçe harf eşlemeleri: "gusul" ↔ "gusül", "kuran" ↔ "Kur'an".
  ///
  /// `İ`/`I` küçültme davranışı Türkçede özeldir; küçültme ELLE yapılır
  /// (`toLowerCase()` `I` → `i` verir ve Türkçe `ı` ayrımını kaybettirir).
  static const Map<String, String> _turkishFolding = {
    'ı': 'i',
    'İ': 'i',
    'I': 'i',
    'ğ': 'g',
    'Ğ': 'g',
    'ü': 'u',
    'Ü': 'u',
    'ş': 's',
    'Ş': 's',
    'ö': 'o',
    'Ö': 'o',
    'ç': 'c',
    'Ç': 'c',
    'â': 'a',
    'Â': 'a',
    'î': 'i',
    'Î': 'i',
    'û': 'u',
    'Û': 'u',
  };

  /// Arapça temel harf varyantları (elif/hemze/ta-marbuta) sadeleşir:
  /// "القرآن" ve "القران" aynı sonuca ulaşır. Kod noktalarıyla kurulur ki
  /// kaynak tamamen ASCII kalsın (birleşen işaret / editör normalizasyonu
  /// aralıkları bozamaz).
  static final Map<int, int> _arabicFolding = {
    0x0623: 0x0627, // ALEF WITH HAMZA ABOVE  -> ALEF
    0x0625: 0x0627, // ALEF WITH HAMZA BELOW  -> ALEF
    0x0622: 0x0627, // ALEF WITH MADDA ABOVE  -> ALEF
    0x0671: 0x0627, // ALEF WASLA             -> ALEF
    0x0649: 0x064A, // ALEF MAKSURA           -> YEH
    0x0629: 0x0647, // TEH MARBUTA            -> HEH
    0x0624: 0x0648, // WAW WITH HAMZA         -> WAW
    0x0626: 0x064A, // YEH WITH HAMZA         -> YEH
  };

  /// Arapça hareke/tatvil/Kur'an işaretlerinin kod-noktası aralıkları.
  /// TEMEL harfler (U+0621–U+064A) ve rakamlar bu kümeye ASLA girmez.
  static const List<List<int>> _arabicMarkRanges = [
    [0x0610, 0x061A], // arabic honorific/sign marks
    [0x064B, 0x065F], // harakat, tanwin ve genişletilmiş işaretler
    [0x0670, 0x0670], // superscript alef
    [0x06D6, 0x06ED], // Kur'an anotasyon işaretleri
    [0x0640, 0x0640], // tatwil (kashida)
  ];

  static bool _isArabicMark(int code) {
    for (final range in _arabicMarkRanges) {
      if (code >= range[0] && code <= range[1]) {
        return true;
      }
    }
    return false;
  }

  /// Alfanümerik olmayan her şey (kesme işareti, boşluk, noktalama).
  static final RegExp _nonAlphanumeric = RegExp(
    r'[^\p{L}\p{N}]+',
    unicode: true,
  );

  /// Arama karşılaştırması için metni BOŞLUKSUZ tek anahtara indirger:
  /// "kur'an" ve "kuran" aynı sonuca çıkar.
  static String normalize(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      // Arapça hareke/tatvil: at.
      if (_isArabicMark(rune)) {
        continue;
      }
      // Arapça temel harf varyantı: sadeleştir.
      final foldedArabic = _arabicFolding[rune];
      if (foldedArabic != null) {
        buffer.writeCharCode(foldedArabic);
        continue;
      }
      final char = String.fromCharCode(rune);
      buffer.write(_turkishFolding[char] ?? char);
    }
    return buffer.toString().toLowerCase().replaceAll(_nonAlphanumeric, '');
  }

  /// Sorgunun hedef metinlerden herhangi birinde geçip geçmediği.
  static bool matches(String query, Iterable<String> haystacks) {
    final normalizedQuery = normalize(query);
    if (normalizedQuery.isEmpty) {
      return false;
    }
    for (final haystack in haystacks) {
      if (normalize(haystack).contains(normalizedQuery)) {
        return true;
      }
    }
    return false;
  }

  /// Metni normalize edilmiş KELİME token'larına böler (retrieval/skorlama
  /// için). Boşluk ve noktalama sınırında bölünür; her token ayrı normalize
  /// edilir. `minLength`'ten kısa token'lar atılır (gürültü azaltma).
  static List<String> tokenize(String input, {int minLength = 2}) {
    final tokens = <String>[];
    for (final piece in input.split(_nonAlphanumeric)) {
      if (piece.isEmpty) {
        continue;
      }
      final normalized = normalize(piece);
      if (normalized.length >= minLength) {
        tokens.add(normalized);
      }
    }
    return tokens;
  }
}
