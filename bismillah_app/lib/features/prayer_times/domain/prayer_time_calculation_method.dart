/// Namaz vakti hesaplama yöntemi — KARARLI enum isimleri (adhan_dart
/// tiplerinden bağımsız). Her değer, hesaplama motorunun GERÇEKTEN sahip
/// olduğu bir hazır ayar (preset) ile birebir eşleşir; motorda karşılığı
/// olmayan hiçbir yöntem burada YER ALMAZ (TASK 096).
///
/// **Kurumsal ad = parametre setinin yayımlandığı kaynak, ONAY DEĞİLDİR.**
/// `turkiyeDiyanet` bir **Diyanet YAKLAŞIMIDIR** — resmi/sertifikalı Diyanet
/// vakti DEĞİLDİR (adhan_dart `turkiye()` preset'i: fajr 18°, isha 17° +
/// yöntem dakika ayarları). Bu yüzden kullanıcıya görünen etiketlerde
/// "Diyanet" kurumsal iddiası KULLANILMAZ; yalnız bölge adı ("Türkiye")
/// ve yöntemin gerçek parametreleri gösterilir.
///
/// **Bilinçli olarak DIŞARIDA bırakılanlar** (motorda var, listede yok):
/// - `other`: fajr 0° / isha 0° — özel/boş şablon; gerçek bir yöntem değildir
///   ve kullanıcıya anlamsız vakitler üretir.
/// - `jafari`, `tehran`: farklı bir fıkhî geleneğin yöntemleridir; sunulmaları
///   ayrı bir içerik/onay kararı gerektirir ve bu görevde alınmamıştır.
///
/// Bu dışlamalar gizli değildir: test hem listelenen her yöntemin motorda
/// karşılığı olduğunu, hem de bu üç değerin listede olmadığını doğrular.
enum PrayerTimeCalculationMethod {
  /// Mevcut ve DEĞİŞMEYEN varsayılan (bkz. [defaultMethod]).
  turkiyeDiyanet,
  muslimWorldLeague,
  egyptian,
  karachi,
  northAmerica,
  ummAlQura,
  dubai,
  qatar,
  kuwait,
  gulfRegion,
  moonsightingCommittee,
  singapore,
  indonesian,
  morocco,
  algerian,
  tunisia,
  jordan,
  france,
  portugal,
  russia;

  /// UI etiketi localization'dan çözülür; bu yalnız kararlı anahtardır.
  String get stableName => name;

  /// Uygulamanın ilk gününden beri yürürlükte olan varsayılan. Bu değer
  /// SESSİZCE DEĞİŞTİRİLMEZ: seçim yapmamış mevcut kurulumlar burada kalır.
  static const PrayerTimeCalculationMethod defaultMethod = turkiyeDiyanet;

  /// Saklanmış değeri çözer. Bilinmeyen/bozuk/boş değer `null` döner —
  /// "seçim yok" sayılır, çağıran [defaultMethod]'a düşer. Depoya
  /// GERİ YAZILMAZ: kullanıcı açık bir seçim yapana kadar saklanan bayt
  /// olduğu gibi korunur.
  static PrayerTimeCalculationMethod? fromStorageKey(Object? value) {
    if (value is! String) {
      return null;
    }
    for (final method in values) {
      if (method.name == value) {
        return method;
      }
    }
    return null;
  }
}

/// Bir yöntemin motordan OKUNAN parametreleri — sunum katmanı açıklamayı
/// bu değerlerden üretir, metne gömülü sabitlerden değil.
///
/// Değerler elle yazılmaz; [PrayerCalculationMethodCatalog] onları
/// hesaplayıcının kullandığı AYNI preset'ten okur, böylece açıklama ile
/// gerçek hesap arasında sürüklenme (drift) oluşamaz.
final class PrayerCalculationMethodParameters {
  const PrayerCalculationMethodParameters({
    required this.fajrAngle,
    required this.ishaAngle,
    required this.ishaIntervalMinutes,
    required this.hasMethodMinuteAdjustments,
  });

  /// Sabah (fajr) güneş açısı, derece.
  final double fajrAngle;

  /// Yatsı (isha) güneş açısı, derece. [usesIshaInterval] ise anlamsızdır.
  final double ishaAngle;

  /// Yatsı akşamdan kaç dakika sonra (0 = açı yöntemi kullanılır).
  final int ishaIntervalMinutes;

  /// Yöntemin kendi dakika ayarları var mı (ör. öğle +5 dk)?
  final bool hasMethodMinuteAdjustments;

  bool get usesIshaInterval => ishaIntervalMinutes > 0;
}

/// Seçilebilir yöntemlerin ve parametrelerinin TEK kaynağı.
///
/// Somut implementasyon data katmanındadır (adhan tipleri domain'e sızmaz).
abstract interface class PrayerCalculationMethodCatalog {
  /// Kullanıcıya sunulabilecek yöntemler — hepsinin motorda karşılığı vardır.
  List<PrayerTimeCalculationMethod> get supportedMethods;

  PrayerCalculationMethodParameters parametersFor(
    PrayerTimeCalculationMethod method,
  );
}

/// İkindi (Asr) fıkhî yöntemi (PRD §27.5 "madhhab-aware Asr").
///
/// **Varsayılan `standard`** (gölge = nesne boyu, ×1): Diyanet RESMİ
/// takvimi Asr'ı bu standart (Şâfiî) yöntemle hesaplar — Türkiye ağırlıklı
/// Hanefî olsa da resmi vakit standart yöntemdedir (fixture'larla
/// doğrulandı). `hanafi` (×2) ileride ayarlardan seçilebilir kılınacak;
/// TASK 096 mezhep/Asr seçimi EKLEMEZ (kanonik kapsamında yoktur) —
/// karar burada izole + belgeli kalır.
enum AsrCalculationMethod { standard, hanafi }
