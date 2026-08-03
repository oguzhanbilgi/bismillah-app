/// İçerik kaynakları ekranındaki kaynak künyesi (TASK 058 §5; TASK 094 §B).
///
/// F2 DÜZELTMESİ: bu dosya bir zamanlar `sources.json`'daki resmî kaynakların
/// adını, dilini ve adresini ELLE KOPYALIYORDU; iki liste birbirinden
/// kayabiliyordu (TASK 086 bulgusu F2). Artık resmî kaynaklar için burada
/// YALNIZ kayıt defteri kimliği ([registrySourceId]) tutulur — künye alanları
/// çalışma zamanında `sources.json`'dan ÇÖZÜLÜR. Kopyalanacak alan kalmadığı
/// için kayma (drift) YAPISAL OLARAK imkânsızdır.
///
/// Altyapı kaynakları (Tanzil, QuranEnc, MP3Quran) `sources.json`'da YOKTUR
/// ve orası yalnız Diyanet kaynak kaydı içindir; bunlar bu yüzden burada
/// künyeleriyle kalır. Bir KOPYA değildirler: tek tanım burasıdır ve bir test
/// bunların kayıt defterinde bulunmadığını doğrular.
library;

enum AppSourcePurpose {
  tanzil,
  quranenc,
  mp3quran,
  ilmihal,
  portal,
  hadis,
  kurul,
}

/// Bir kaynak künyesinin nereden geldiği.
enum AppSourceOrigin {
  /// Künye `sources.json` kayıt defterinden çözülür (tek doğruluk kaynağı).
  registry,

  /// Kayıt defterinde bulunmayan altyapı kaynağı; künye burada tanımlıdır.
  infrastructure,
}

final class AppSourceReference {
  /// Kayıt defterine bağlı resmî kaynak: künye alanları BURADA TUTULMAZ.
  const AppSourceReference.registry({
    required this.purpose,
    required String this.registrySourceId,
  }) : origin = AppSourceOrigin.registry,
       infrastructureName = null,
       infrastructureLanguage = null,
       infrastructureUrl = null;

  /// `sources.json`'da karşılığı OLMAYAN altyapı kaynağı.
  const AppSourceReference.infrastructure({
    required this.purpose,
    required String name,
    required String originalLanguage,
    required String canonicalUrl,
  }) : origin = AppSourceOrigin.infrastructure,
       registrySourceId = null,
       infrastructureName = name,
       infrastructureLanguage = originalLanguage,
       infrastructureUrl = canonicalUrl;

  /// Kullanım amacı metnini seçmek için anahtar.
  final AppSourcePurpose purpose;

  final AppSourceOrigin origin;

  /// `sources.json` kimliği — yalnız [AppSourceOrigin.registry] için doludur.
  final String? registrySourceId;

  final String? infrastructureName;
  final String? infrastructureLanguage;
  final String? infrastructureUrl;
}

/// Uygulamanın dayandığı kaynaklar (TASK 058 §5).
///
/// Resmî Diyanet kaynakları kimlikle referans verilir; künyeleri
/// `assets/content/learn/sources.json`'dan gelir.
const List<AppSourceReference> kAppSourceReferences = [
  AppSourceReference.infrastructure(
    purpose: AppSourcePurpose.tanzil,
    name: 'Tanzil',
    originalLanguage: 'ar',
    canonicalUrl: 'https://tanzil.net',
  ),
  AppSourceReference.infrastructure(
    purpose: AppSourcePurpose.quranenc,
    name: 'QuranEnc — Rowad',
    originalLanguage: 'ar',
    canonicalUrl: 'https://quranenc.com/tr/browse/turkish_rwwad',
  ),
  AppSourceReference.infrastructure(
    purpose: AppSourcePurpose.mp3quran,
    name: 'MP3Quran.net',
    originalLanguage: 'ar',
    canonicalUrl: 'https://mp3quran.net',
  ),
  AppSourceReference.registry(
    purpose: AppSourcePurpose.ilmihal,
    registrySourceId: 'diyanet-islam-ilmihali',
  ),
  AppSourceReference.registry(
    purpose: AppSourcePurpose.portal,
    registrySourceId: 'diyanet-kuran-portali',
  ),
  AppSourceReference.registry(
    purpose: AppSourcePurpose.hadis,
    registrySourceId: 'diyanet-hadislerle-islam',
  ),
  AppSourceReference.registry(
    purpose: AppSourcePurpose.kurul,
    registrySourceId: 'diyanet-din-isleri-yuksek-kurulu',
  ),
];

/// Ekranda gösterilecek ÇÖZÜLMÜŞ künye.
///
/// Kayıt defterine bağlı kaynaklar için alanlar `sources.json`'dan gelir;
/// altyapı kaynakları için [AppSourceReference]'ın kendi alanlarından.
final class ResolvedAppSource {
  const ResolvedAppSource({
    required this.purpose,
    required this.name,
    required this.originalLanguage,
    required this.canonicalUrl,
  });

  final AppSourcePurpose purpose;

  /// Kurum/eser adı — özel isimdir, dile göre değişmez.
  final String name;

  /// Kaynağın ORİJİNAL dili ('ar' veya 'tr').
  final String originalLanguage;

  /// Doğrulanmış HTTPS kanonik adres.
  final String canonicalUrl;
}
