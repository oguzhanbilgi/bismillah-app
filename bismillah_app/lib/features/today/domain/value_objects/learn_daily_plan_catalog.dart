/// 30 günlük planın Learn (öğrenme) katalog sırası (TASK 082).
///
/// Bu dosya **yalnız makine kimliği** taşır: yayınlanmış ve kaynak gövdesi
/// doğrulanmış Learn makalelerinin stabil `id` değerleri. Başlık, özet,
/// gövde metni, çeviri, kaynak metni, locale, tarih, UID veya cihaz verisi
/// BURAYA KOPYALANMAZ — kullanıcıya görünen her metin Learn içerik
/// katmanında kalır.
library;

/// Katalogdaki tek giriş — bir günün Learn referansı.
///
/// Yalnız stabil makale kimliği tutar; şablon kimliği bundan deterministik
/// olarak türetilir.
final class LearnPlanCatalogEntry {
  const LearnPlanCatalogEntry(this.articleId);

  /// `assets/content/learn/articles_*.json` içindeki stabil `id`.
  ///
  /// Üç locale de AYNI kimlik kümesini taşır; bu değer locale'e duyarlı
  /// DEĞİLDİR ve yerelleştirilmiş bir metin değildir.
  final String articleId;

  /// Bu giriş için stabil plan şablonu kimliği.
  String get templateId => LearnDailyPlanCatalog.templateIdFor(articleId);

  @override
  bool operator ==(Object other) =>
      other is LearnPlanCatalogEntry && other.articleId == articleId;

  @override
  int get hashCode => articleId.hashCode;
}

/// Katalogun yapısal tutarsızlığının stabil, nötr kimliği.
///
/// `GenerationRequestIssue` (TASK 079) ile aynı desendedir: kullanıcı
/// metni, makale gövdesi, istisna bilgisi veya dosya yolu TAŞIMAZ ve yeni
/// bir `AppFailure` alt tipi gerektirmez.
enum LearnPlanCatalogIssue {
  /// Giriş sayısı kanonik 30 günlük çatıya eşit değil.
  entryCountMismatch,

  /// Boş/yalnız boşluktan oluşan makale kimliği.
  blankArticleId,

  /// Aynı makale iki güne atanmış.
  duplicateArticleId,

  /// Nihai öğe kimliği ayırıcısını içeren makale kimliği — kimlik
  /// çakışmasına yol açabilir.
  unsafeArticleId,
}

/// Learn plan öğelerinin **değişmez, versiyonlu ve açık** 30 günlük sırası.
///
/// ## Neden açık bir liste
///
/// Plan sırası; JSON dosya sırasına, yerelleştirilmiş başlık sıralamasına,
/// çalışma zamanı locale'ine, `Map`/`Set` yineleme sırasına veya kategori
/// yüklemesine BIRAKILAMAZ. Bu liste tek yetkili sıradır; asset dosyasında
/// makalelerin yeri değişse bile plan sırası değişmez.
///
/// ## Sıra nereden geliyor
///
/// - **0–10 (kaynak destekli):** katalog dondurulduğunda (TASK 082) asset'lerde
///   ZATEN var olan editoryal `beginnerPathOrder` alanının **o an
///   yayınlanmış** üyeleri, artan sırada (1,2,3,4,5,6,7,8,9,10,13).
///   `beginnerPathOrder` 11 ve 12 numaralı iki makale o tarihte
///   `scholarlyReviewPending` olduğu için **bilinçli olarak dışarıdadır** —
///   yayınlanmamış içerik plana giremez. **TASK 091 güncellemesi:** 11 numaralı
///   `art-kuran-okumaya-baslangic` incelenip yayına alındı, 12 numaralı
///   `art-dua-adabi` ise beklemede kaldı. Katalog yine de **değişmez**: bu
///   liste dondurulmuş bir alt kümedir, büyüyen kütüphanenin aynası değildir
///   (CP11 katalog sınırı kuralı).
/// - **11–29 (onaylı TASK 082 ürün kararı):** kalan 19 yayınlanmış makale.
///   Gruplama `categories.json` içindeki mevcut `sortOrder` alanını izler
///   (temizlik 3 → namaz 4 → oruç 5 → zekât 6 → hac 7); grup İÇİNDEKİ sıra
///   konu sürekliliğine göre açıkça yazılmış bir TASK 082 kararıdır. Bu bir
///   ürün sıralamasıdır; **dinî bir öncelik, üstünlük veya yükümlülük
///   sırası DEĞİLDİR** ve eski bir belgeden devralınmamıştır.
///
/// Sıra profile, ilerleme fazına (`weekIndex`), tempoya, tarihe veya
/// locale'e göre DEĞİŞMEZ.
final class LearnDailyPlanCatalog {
  const LearnDailyPlanCatalog({required this.entries});

  /// Açık sıralı girişler; indeks = sıfır tabanlı gün ofseti.
  final List<LearnPlanCatalogEntry> entries;

  /// Kanonik 30 günlük çatı (10_DATA_MODEL §4).
  static const int requiredEntryCount = 30;

  /// Şablon kimliği öneki — yerelleştirilmiş metin DEĞİL.
  static const String templateIdPrefix = 'learn_article_';

  /// `DailyPlanItemIdBuilder` nihai kimliği bu karakterle birleştirir;
  /// makale kimliği bunu içeremez.
  static const String reservedIdSeparator = ':';

  /// Bir makale kimliğinin stabil şablon kimliği.
  ///
  /// Kayıpsızdır: makale kimliği aynen eklenir, normalize edilmez,
  /// kısaltılmaz ve `hashCode`/karma kullanılmaz — iki farklı makale asla
  /// aynı şablon kimliğine düşemez.
  static String templateIdFor(String articleId) =>
      '$templateIdPrefix$articleId';

  /// Yapısal doğrulama; sorun yoksa `null`.
  ///
  /// Sonuç makale gövdesi, başlık veya ham katalog içeriği taşımaz.
  LearnPlanCatalogIssue? validate() {
    if (entries.length != requiredEntryCount) {
      return LearnPlanCatalogIssue.entryCountMismatch;
    }
    final seen = <String>{};
    for (final entry in entries) {
      final id = entry.articleId;
      if (id.trim().isEmpty) {
        return LearnPlanCatalogIssue.blankArticleId;
      }
      if (id.contains(reservedIdSeparator)) {
        return LearnPlanCatalogIssue.unsafeArticleId;
      }
      if (!seen.add(id)) {
        return LearnPlanCatalogIssue.duplicateArticleId;
      }
    }
    return null;
  }

  bool get isValid => validate() == null;

  /// Üretimde kullanılan sürüm 1 kataloğu.
  ///
  /// Her kimlik `assets/content/learn/articles_tr|en|ar.json` içinde
  /// **`published`** durumdadır, `sourceBodyReview` ile doğrulanmış bir
  /// `verification` kaydı taşır ve üç locale'de de mevcuttur. Bu koşullar
  /// asset'lere karşı testte kilitlenir; içerik değişirse test kırılır.
  ///
  /// Tekrar YOKTUR: 30 gün, 30 farklı makale. Sayıyı tutturmak için
  /// hiçbir makale çoğaltılmamış ve doğrulanmamış hiçbir makale sessizce
  /// eklenmemiştir.
  static const LearnDailyPlanCatalog v1 = LearnDailyPlanCatalog(
    entries: [
      // --- 0–10: mevcut editoryal `beginnerPathOrder` (yayınlanmış) ---
      LearnPlanCatalogEntry('art-islam-nedir'), // beginnerPathOrder 1
      LearnPlanCatalogEntry('art-imanin-sartlari'), // 2
      LearnPlanCatalogEntry('art-islamin-sartlari'), // 3
      LearnPlanCatalogEntry('art-kelime-i-sehadet'), // 4
      LearnPlanCatalogEntry('art-abdest-nasil-alinir'), // 5
      LearnPlanCatalogEntry('art-abdestin-farzlari'), // 6
      LearnPlanCatalogEntry('art-namaza-hazirlik'), // 7
      LearnPlanCatalogEntry('art-bes-vakit-namaz'), // 8
      LearnPlanCatalogEntry('art-namazin-bolumleri'), // 9
      LearnPlanCatalogEntry('art-kuran-nedir'), // 10
      LearnPlanCatalogEntry('art-tevbe-ve-umit'), // 13 (11–12 yayında değil)
      // --- 11–29: onaylı TASK 082 ürün kararı, kategori sırasıyla ---
      // cat-purity (sortOrder 3)
      LearnPlanCatalogEntry('art-abdesti-bozan-durumlar'),
      LearnPlanCatalogEntry('art-abdestin-sunnetleri'),
      LearnPlanCatalogEntry('art-temizligin-cesitleri'),
      LearnPlanCatalogEntry('art-necaset-nedir'),
      LearnPlanCatalogEntry('art-mest-uzerine-mesh'),
      LearnPlanCatalogEntry('art-gusul-nasil-alinir'),
      LearnPlanCatalogEntry('art-guslu-gerektiren-haller'),
      LearnPlanCatalogEntry('art-teyemmum-nedir'),
      // cat-prayer (sortOrder 4)
      LearnPlanCatalogEntry('art-namaz-vakitleri'),
      LearnPlanCatalogEntry('art-namazin-farzlari'),
      LearnPlanCatalogEntry('art-namazin-vacipleri'),
      LearnPlanCatalogEntry('art-namazin-sunnetleri'),
      LearnPlanCatalogEntry('art-cemaatle-namaz'),
      // cat-fasting (sortOrder 5)
      LearnPlanCatalogEntry('art-oruc-kimlere-farzdir'),
      LearnPlanCatalogEntry('art-orucu-bozan-durumlar'),
      // cat-zakat (sortOrder 6)
      LearnPlanCatalogEntry('art-zekatin-sartlari'),
      LearnPlanCatalogEntry('art-zekat-kimlere-verilir'),
      // cat-hajj (sortOrder 7)
      LearnPlanCatalogEntry('art-hac-kimlere-farzdir'),
      LearnPlanCatalogEntry('art-kurban-nedir'),
    ],
  );
}
