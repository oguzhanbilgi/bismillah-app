import 'package:bismillah_app/core/utils/date_key.dart';

/// Bir yerel takvim gününün Kur'an okuma ilerlemesi (TASK 047) — paket
/// bağımsız, immutable, YALNIZ cihazda saklanır.
///
/// İçerik değil miktar tutulur: Arapça ayet metni veya meal ASLA bu tipe
/// giremez — yalnız verseKey ve sayısal ilerleme (10_DATA_MODEL §2-3).
final class QuranDailyReadingProgress {
  QuranDailyReadingProgress({
    required this.localDateKey,
    this.activeReadingSeconds = 0,
    this.viewedVerseKeys = const {},
    this.viewedPageNumbers = const {},
    this.lastChapterId,
    this.lastVerseKey,
    required this.updatedAtUtc,
    this.schemaVersion = currentSchemaVersion,
  }) {
    if (!DateKey.isValid(localDateKey)) {
      throw ArgumentError.value(
        localDateKey,
        'localDateKey',
        'yyyy-MM-dd olmalı',
      );
    }
    if (activeReadingSeconds < 0) {
      throw ArgumentError.value(
        activeReadingSeconds,
        'activeReadingSeconds',
        'negatif olamaz',
      );
    }
    for (final key in viewedVerseKeys) {
      if (!isValidVerseKey(key)) {
        throw ArgumentError.value(key, 'viewedVerseKeys', 'geçersiz verseKey');
      }
    }
    for (final page in viewedPageNumbers) {
      if (page < 1 || page > mushafPageCount) {
        throw ArgumentError.value(page, 'viewedPageNumbers', '1–604 olmalı');
      }
    }
    if (lastChapterId != null && (lastChapterId! < 1 || lastChapterId! > 114)) {
      throw ArgumentError.value(lastChapterId, 'lastChapterId', '1–114 olmalı');
    }
    if (lastVerseKey != null && !isValidVerseKey(lastVerseKey!)) {
      throw ArgumentError.value(lastVerseKey, 'lastVerseKey', 'geçersiz');
    }
  }

  /// Boş gün kaydı — hiç okuma yapılmamış gün için sıfır ilerleme.
  factory QuranDailyReadingProgress.empty({
    required String localDateKey,
    required DateTime updatedAtUtc,
  }) => QuranDailyReadingProgress(
    localDateKey: localDateKey,
    updatedAtUtc: updatedAtUtc,
  );

  static const int currentSchemaVersion = 1;

  /// Medine Mushafı standart sayfa sayısı.
  static const int mushafPageCount = 604;

  /// `chapterId:verseNumber` biçim ve aralık doğrulaması (1–114 sure).
  static bool isValidVerseKey(String key) {
    final match = RegExp(r'^(\d{1,3}):(\d{1,3})$').firstMatch(key);
    if (match == null) {
      return false;
    }
    final chapterId = int.parse(match.group(1)!);
    final verseNumber = int.parse(match.group(2)!);
    return chapterId >= 1 && chapterId <= 114 && verseNumber >= 1;
  }

  /// `yyyy-MM-dd` yerel gün anahtarı — timezone sonradan değişse bile
  /// geçmiş kayıtlar YENİDEN YAZILMAZ.
  final String localDateKey;

  /// O gün reader'da geçirilen AKTİF (görünür + resumed + idle olmayan)
  /// toplam saniye. Arka plan ses oynatımı buna DAHİL DEĞİLDİR.
  final int activeReadingSeconds;

  /// O gün anlamlı biçimde görüntülenen benzersiz ayet anahtarları.
  final Set<String> viewedVerseKeys;

  /// O gün anlamlı biçimde görüntülenen benzersiz Mushaf sayfaları (1–604).
  final Set<int> viewedPageNumbers;

  /// Son okunan sure/ayet (İlerlemem "Devam et" için); yoksa `null`.
  final int? lastChapterId;
  final String? lastVerseKey;

  /// Yalnız audit/güncelleme sırası için UTC damgası — gün anahtarı
  /// HESAPLAMASINDA kullanılmaz.
  final DateTime updatedAtUtc;

  final int schemaVersion;

  /// Yeni aktiviteyi mevcut kayda birleştirir: süre toplanır (negatif
  /// katkı yok sayılır), kümeler UNION olur (duplicate tutulmaz), son
  /// konum verilirse güncellenir.
  QuranDailyReadingProgress merged({
    int additionalSeconds = 0,
    Set<String> newVerseKeys = const {},
    Set<int> newPageNumbers = const {},
    int? lastChapterId,
    String? lastVerseKey,
    required DateTime updatedAtUtc,
  }) => QuranDailyReadingProgress(
    localDateKey: localDateKey,
    activeReadingSeconds:
        activeReadingSeconds + (additionalSeconds < 0 ? 0 : additionalSeconds),
    viewedVerseKeys: {...viewedVerseKeys, ...newVerseKeys},
    viewedPageNumbers: {...viewedPageNumbers, ...newPageNumbers},
    lastChapterId: lastChapterId ?? this.lastChapterId,
    lastVerseKey: lastVerseKey ?? this.lastVerseKey,
    updatedAtUtc: updatedAtUtc,
  );
}
