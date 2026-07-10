import 'package:bismillah_app/features/content/domain/value_objects/content_enums.dart';

/// Kutsal içerik sealed hiyerarşisi (06_FLUTTER_ARCH §19; 10_DATA_MODEL §20).
///
/// "Edep şemadadır": her alt tip kaynak metadata'sını ZORUNLU constructor
/// parametresi olarak taşır — kaynaksız kutsal içerik bu tiplerle temsil
/// edilemez (no source, no render'ın domain ayağı). `AiExplanation` bu
/// hiyerarşinin DIŞINDADIR; ikisini karıştıran kod derlenmez.
sealed class SacredContent {
  SacredContent({required this.source, required this.sourceReference}) {
    _requireNonEmpty(source, 'source');
    _requireNonEmpty(sourceReference, 'sourceReference');
  }

  /// Kaynak külliyat/eser adı (ör. "Kur'an-ı Kerim", "Sahih-i Buhârî").
  final String source;

  /// Kaynak içi referans (ör. "2:255", "Buhârî 6018").
  final String sourceReference;

  SacredContentType get contentType;

  static void _requireNonEmpty(String value, String field) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(
        value,
        field,
        'Kutsal içerik kaynak metadata\'sız temsil edilemez '
        '(no source, no render)',
      );
    }
  }
}

/// Doğrulanmış ayet metni. Algoritmik kırpma/önizleme alanı BİLİNÇLİ
/// olarak yoktur (06 §19-4); önizleme editoryal `previewText` ile gelir
/// (içerik görevi kapsamı).
final class QuranVerse extends SacredContent {
  QuranVerse({
    required this.surah,
    required this.ayahStart,
    int? ayahEnd,
    required this.arabicText,
    required super.source,
    required super.sourceReference,
    this.translation,
    this.translationSource,
  }) : ayahEnd = ayahEnd ?? ayahStart {
    if (surah < 1 || surah > 114) {
      throw ArgumentError.value(surah, 'surah', '1–114 aralığında olmalı');
    }
    if (ayahStart < 1 || this.ayahEnd < ayahStart) {
      throw ArgumentError.value(ayahStart, 'ayahStart', 'Geçersiz ayet aralığı');
    }
    SacredContent._requireNonEmpty(arabicText, 'arabicText');
    if (translation != null && (translationSource?.trim().isEmpty ?? true)) {
      throw ArgumentError.value(
        translationSource,
        'translationSource',
        'Meal varsa meal kaynağı zorunludur',
      );
    }
  }

  final int surah;
  final int ayahStart;
  final int ayahEnd;
  final String arabicText;
  final String? translation;
  final String? translationSource;

  @override
  SacredContentType get contentType => SacredContentType.quran;
}

/// Hadis metni — `grading` zorunludur; derecesiz hadis bu tiple
/// TEMSİL EDİLEMEZ (derlenmez).
final class HadithText extends SacredContent {
  HadithText({
    required this.collection,
    required this.number,
    required this.grading,
    required this.text,
    required super.sourceReference,
  }) : super(source: collection) {
    SacredContent._requireNonEmpty(collection, 'collection');
    SacredContent._requireNonEmpty(number, 'number');
    SacredContent._requireNonEmpty(text, 'text');
  }

  final String collection;
  final String number;
  final HadithGrading grading;
  final String text;

  @override
  SacredContentType get contentType => SacredContentType.hadith;
}

/// Dua metni — kaynak zorunlu.
final class DuaText extends SacredContent {
  DuaText({
    required this.arabicText,
    required super.source,
    required super.sourceReference,
    this.transliteration,
    this.translation,
  }) {
    SacredContent._requireNonEmpty(arabicText, 'arabicText');
  }

  final String arabicText;
  final String? transliteration;
  final String? translation;

  @override
  SacredContentType get contentType => SacredContentType.dua;
}

/// Zikir metni — kaynak zorunlu.
final class DhikrText extends SacredContent {
  DhikrText({
    required this.arabicText,
    required super.source,
    required super.sourceReference,
    this.transliteration,
    this.translation,
  }) {
    SacredContent._requireNonEmpty(arabicText, 'arabicText');
  }

  final String arabicText;
  final String? transliteration;
  final String? translation;

  @override
  SacredContentType get contentType => SacredContentType.dhikr;
}

/// Âlim görüşü/notu — kime ait olduğu (attribution) zorunludur; görüş
/// daima Kur'an/hadis'ten AYRI etiketlenir (CLAUDE.md İslami ilkeler).
final class ScholarlyNote extends SacredContent {
  ScholarlyNote({
    required this.scholarAttribution,
    required this.text,
    required super.source,
    required super.sourceReference,
  }) {
    SacredContent._requireNonEmpty(scholarAttribution, 'scholarAttribution');
    SacredContent._requireNonEmpty(text, 'text');
  }

  final String scholarAttribution;
  final String text;

  @override
  SacredContentType get contentType => SacredContentType.scholarlyNote;
}
