# Learn İçerik Doğrulama Kaydı

Dahilî geliştirme dokümanı (TASK 056A → TASK 057). Yayına yönelik bir
belge değildir.

## Neden bu kayıt var?

TASK 056'da 16 makale yalnız **kaynak URL'lerinin var olduğu** doğrulanarak
yayına alınmıştı. Bir adresin var olması, o adresteki metnin makaledeki
dinî iddiayı desteklediği anlamına gelmez. TASK 056A bu boşluğu bir
**yayın kapısı** ile kapattı; TASK 057 ise kaynak gövdesini gerçekten
okuyarak kütüphaneyi genişletti.

Yayın kapısı `LearningArticle` kurucusunda zorlanır: koşulları
sağlamayan bir `published` nesne **hiç oluşturulamaz**.

- `verificationMethod: urlExistenceCheck` yayın için **yetersizdir**.
- `sourceLocator` ve `evidenceSummary` boş olamaz.
- Doğrulama, makalenin gerçekten atıf yaptığı kaynağa dayanmalıdır.
- Çıplak bir URL geçerli locator sayılmaz (liste/ana sayfa kanıt değildir).
- Bir çeviri, Türkçe kanonik kayıttan güçlü bir yayın durumunda olamaz.

## Doğrulama turu (TASK 057)

- **Yöntem:** `editorialReview` + `sourceBodyReview`
- **Kaynak:** Diyanet İşleri Başkanlığı, *İslam İlmihali*, 34. Baskı,
  2019, Ankara (ISBN 978-975-19-6769-5; Din İşleri Yüksek Kurulu Kararı
  03.04.2003/66). PDF indirildi, `pdftotext` ile sayfa sayfa çıkarıldı.
- **Sayfa eşlemesi:** pdftotext sayfa indeksi *N* → basılı sayfa *N+1*.
  Eşleme, içindekiler tablosundaki sayfa numaralarıyla çapraz doğrulandı
  (ör. "Namazın Vacipleri" içindekilerde 147, gövdede de basılı 147).
  Locator'larda **basılı eser sayfası** kullanılır; pdftotext satır veya
  indeks numarası kullanılmaz.
- **Tarih:** 2026-07-19

### Erişilemeyen kaynaklar

| Kaynak | Durum |
|---|---|
| Hadislerle İslam | Gövde okunamadı |
| Kur'an Yolu Tefsiri | Gövde okunamadı (yalnız künye doğrulandı) |
| Din İşleri Yüksek Kurulu fetvaları | Gövde okunamadı |
| Dinî Soru Hizmetleri | Gövde okunamadı |

Bu kaynaklara dayanan iddialar doğrulanmış sayılmadı.

## Yayındaki içerikler (30)

Tamamı `sourceBodyVerified: true`, `verificationMethod: sourceBodyReview`,
`verifiedAt: 2026-07-19`. EN/AR sürümleri `explanatoryTranslation`
etiketiyle yayında olup Türkçe kanonik kayda bağlıdır.

| # | Article ID | Türkçe başlık | Exact locator |
|---|---|---|---|
| 1 | `art-islam-nedir` | İslam nedir? | II. İSLAM, s. 83 |
| 2 | `art-imanin-sartlari` | İmanın şartları | IV. İMAN, F) İman Esasları, s. 41 |
| 3 | `art-islamin-sartlari` | İslam'ın şartları | II. İSLAM, A) İslam'ın Şartları, s. 84 |
| 4 | `art-kelime-i-sehadet` | Kelime-i şehadet | IV. İMAN, A) Kelime-i Tevhid ve Kelime-i Şahadet, s. 39 |
| 5 | `art-temizligin-cesitleri` | Temizliğin iki türü | III. TEMİZLİK, B) Temizliğin Çeşitleri, s. 90-91 |
| 6 | `art-necaset-nedir` | Necaset nedir? | III. TEMİZLİK, B/2) Necasetten Taharet, s. 91 |
| 7 | `art-abdestin-farzlari` | Abdestin farzları | V. ABDEST, B) Abdestin Farzları, s. 98-99 |
| 8 | `art-abdestin-sunnetleri` | Abdestin sünnetleri | V. ABDEST, C) Abdestin Sünnetleri, s. 101-104 |
| 9 | `art-abdest-nasil-alinir` | Abdest nasıl alınır? | V. ABDEST, F) Abdest Nasıl Alınır?, s. 105-107 |
| 10 | `art-abdesti-bozan-durumlar` | Abdesti bozan durumlar | V. ABDEST, I) Abdesti Bozan Şeyler, s. 110 (Şâfiî farkı: dipnot 25) |
| 11 | `art-mest-uzerine-mesh` | Mest üzerine mesh | V. ABDEST, K) Mestler Üzerine Meshetmek, s. 112-114 |
| 12 | `art-teyemmum-nedir` | Teyemmüm nedir? | VI. TEYEMMÜM, C) ve E), s. 118 |
| 13 | `art-guslu-gerektiren-haller` | Guslün gerekli olduğu durumlar | VII. GUSÜL, B) Gusül Yapmayı Gerektiren Hâller, s. 120-121 |
| 14 | `art-gusul-nasil-alinir` | Gusül nasıl alınır? | VII. GUSÜL, C) ve G), s. 121-122 |
| 15 | `art-namaz-vakitleri` | Namaz vakitleri | VIII. NAMAZ, C) Namaz Vakitleri, s. 134-137 |
| 16 | `art-namazin-farzlari` | Namazın farzları | VIII. NAMAZ, F) Namazın Farzları, s. 144 |
| 17 | `art-namaza-hazirlik` | Namaza hazırlık | VIII. NAMAZ, F/a) Namazın Şartları, s. 144 |
| 18 | `art-namazin-bolumleri` | Namazın temel bölümleri | VIII. NAMAZ, F/b) Namazın Rükünleri, s. 145-147 |
| 19 | `art-namazin-vacipleri` | Namazın vacipleri | VIII. NAMAZ, G) Namazın Vacipleri, s. 147-148 |
| 20 | `art-namazin-sunnetleri` | Namazın sünnetleri | VIII. NAMAZ, H) Namazın Sünnetleri, s. 148-151 |
| 21 | `art-bes-vakit-namaz` | Beş vakit namaz | VIII. NAMAZ, İ) Beş Vakit Namazın Kılınışı, s. 152-160 |
| 22 | `art-cemaatle-namaz` | Cemaatle namaz | VIII. NAMAZ, R/1) Cemaatle Namaz Kılmanın Fazileti, s. 176-177 |
| 23 | `art-tevbe-ve-umit` | Tevbe ve ümit | Nafile Namazlar, 7. Tevbe Namazı, s. 224 |
| 24 | `art-oruc-kimlere-farzdir` | Oruç kimlere farzdır? | IX. ORUÇ, D) Oruç Kimlere Farzdır?, s. 261-262 |
| 25 | `art-orucu-bozan-durumlar` | Orucu bozan durumlar | IX. ORUÇ, K) Orucu Bozan Şeyler, s. 277-279 |
| 26 | `art-zekatin-sartlari` | Zekât kimlere farzdır? | X. ZEKÂT, B) Zekâtın Farz Olmasının Şartları, s. 294-295 |
| 27 | `art-zekat-kimlere-verilir` | Zekât kimlere verilir? | X. ZEKÂT, E) Zekât Kimlere Verilir?, s. 302-303 |
| 28 | `art-hac-kimlere-farzdir` | Hac kimlere farzdır? | XI. HAC, B) Hac Kimlere Farzdır?, s. 308-309 |
| 29 | `art-kurban-nedir` | Kurban ibadeti | XII. KURBAN, A) Kurban Nedir?, s. 349-350 |
| 30 | `art-kuran-nedir` | Kur'an nedir? | Kitaplara İman — Kur'an'ın Nazil Oluşu ve Özellikleri, s. 54-58 |

Locator'lardaki eser künyesi tam hâliyle
"İslam İlmihali (34. Baskı, 2019), …" biçimindedir.

## Bekleyen içerikler (2)

| Article ID | Başlık | Blocker | Gereken |
|---|---|---|---|
| `art-kuran-okumaya-baslangic` | Kur'an okumaya başlangıç | İlmihalde bu sürece dair kesin bölüm/sayfa eşleştirilemedi; Kur'an Portalı gövdesi okunamadı. | Portal gövdesine erişim veya ilmihalde uygun bölümün tespiti |
| `art-dua-adabi` | Dua adabı | Hadislerle İslam gövdesi okunamadı; ilmihalde dua adabı için kesin konum bulunamadı. | Hadislerle İslam gövdesine erişim veya editoryal inceleme |

## TASK 057'de yapılan düzeltmeler

1. **`art-kuran-nedir` kaynak uyuşmazlığı giderildi.** Doğrulama İslam
   İlmihali'ne dayanıyordu ama `sourceIds` Kur'an Portalı'nı
   gösteriyordu. Kaynak referansı ilmihale çevrildi; portal, gövdesi
   doğrulanmadığı için destekleyici kaynak olarak da bırakılmadı.
   Kalan 15 makalede benzer uyuşmazlık taranmış, başka örnek
   bulunmamıştır. Bir test artık `sourceIds`'in `verification.sourceId`
   içermesini zorunlu kılar.

2. **Kaynaksız mezhep iddiaları kaldırıldı.** `abdestin-farzlari`,
   `gusul-nasil-alinir`, `abdest-nasil-alinir` ve `namazin-bolumleri`
   makalelerindeki Şâfiî karşılaştırmalarının bu eserde karşılığı
   **yoktu**; bu cümleler çıkarıldı ve makaleler kalan doğrulanmış
   içerikle yayına alındı. Eserde dipnotla desteklenen tek fark
   (abdesti bozan şeyler, dipnot 25) ve zekât bölümündeki parantez içi
   Şâfiî notu **korundu**.

3. **16 yeni makale** İslam İlmihali gövdesinden doğrulanarak eklendi
   (temizlik 5, namaz 5, oruç 2, zekât 2, hac/kurban 2 — sıralama
   yukarıdaki tabloda).

Doğrulanmadan hiçbir içerik `published` yapılmamalıdır; yayın kapısı
bunu domain katmanında zaten engeller.
