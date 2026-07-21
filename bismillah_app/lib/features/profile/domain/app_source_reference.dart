/// İçerik kaynakları ekranındaki kaynak künyesi (TASK 058 §5).
///
/// Bu kayıtlar DERLEME ZAMANI sabitidir; Learn içerik verisinden bağımsız,
/// uygulamanın dayandığı altyapı ve resmî kaynakların statik listesidir.
/// Kullanım amacı ve dil etiketleri ekranın localization'ından çözülür.
enum AppSourcePurpose {
  tanzil,
  quranenc,
  mp3quran,
  ilmihal,
  portal,
  hadis,
  kurul,
}

final class AppSourceReference {
  const AppSourceReference({
    required this.purpose,
    required this.name,
    required this.originalLanguage,
    required this.canonicalUrl,
  });

  /// Kullanım amacı metnini seçmek için anahtar.
  final AppSourcePurpose purpose;

  /// Kurum/kaynak adı — özel isimdir, dile göre değişmez.
  final String name;

  /// Kaynağın ORİJİNAL dili ('ar' veya 'tr').
  final String originalLanguage;

  /// Doğrulanmış HTTPS kanonik adres (allowlist'ten geçer).
  final String canonicalUrl;
}

/// Uygulamanın dayandığı kaynaklar (TASK 058 §5). URL'ler kod tabanında
/// zaten kullanılan doğrulanmış adreslerdir.
const List<AppSourceReference> kAppSourceReferences = [
  AppSourceReference(
    purpose: AppSourcePurpose.tanzil,
    name: 'Tanzil',
    originalLanguage: 'ar',
    canonicalUrl: 'https://tanzil.net',
  ),
  AppSourceReference(
    purpose: AppSourcePurpose.quranenc,
    name: 'QuranEnc — Rowad',
    originalLanguage: 'ar',
    canonicalUrl: 'https://quranenc.com/tr/browse/turkish_rwwad',
  ),
  AppSourceReference(
    purpose: AppSourcePurpose.mp3quran,
    name: 'MP3Quran.net',
    originalLanguage: 'ar',
    canonicalUrl: 'https://mp3quran.net',
  ),
  AppSourceReference(
    purpose: AppSourcePurpose.ilmihal,
    name: 'Diyanet İslam İlmihali',
    originalLanguage: 'tr',
    canonicalUrl:
        'https://diniyayinlar.diyanet.gov.tr/Documents/islam%20ilmihali%2017%20X%2024%20.pdf',
  ),
  AppSourceReference(
    purpose: AppSourcePurpose.portal,
    name: "Diyanet Kur'an Portalı",
    originalLanguage: 'tr',
    canonicalUrl: 'https://kuran.diyanet.gov.tr/',
  ),
  AppSourceReference(
    purpose: AppSourcePurpose.hadis,
    name: 'Hadislerle İslam',
    originalLanguage: 'tr',
    canonicalUrl: 'https://hadislerleislam.diyanet.gov.tr/',
  ),
  AppSourceReference(
    purpose: AppSourcePurpose.kurul,
    name: 'Din İşleri Yüksek Kurulu',
    originalLanguage: 'tr',
    canonicalUrl: 'https://kurul.diyanet.gov.tr/tr/fetvalar',
  ),
];
