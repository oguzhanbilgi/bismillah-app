# Learn İçerik Doğrulama Kaydı

Dahilî geliştirme dokümanı (TASK 056A). Yayına yönelik bir belge değildir.

## Neden bu kayıt var?

TASK 056'da 16 makale `published` olarak işaretlendi. Ancak o aşamada
yalnız **kaynak URL'lerinin var olduğu ve resmî `diyanet.gov.tr` alan
adında bulunduğu** doğrulanmıştı; kaynak **gövdeleri okunamamıştı**.

Bir adresin var olması, o adresteki metnin makaledeki dinî iddiayı
desteklediği anlamına gelmez. TASK 056A bu boşluğu kapatır:

- `SourceVerification` modeli eklendi (`sourceBodyVerified`,
  `sourceLocator`, `evidenceSummary`, `verifiedAt`, `verifiedBy`,
  `verificationMethod`, `blocker`).
- Yayın kapısı **domain kurucusunda** zorlanır: koşulları sağlamayan bir
  `published` nesne hiç oluşturulamaz.
- `verificationMethod: urlExistenceCheck` yayın için **yetersizdir**.

## Doğrulama turu

- **Yöntem:** `editorialReview` + `sourceBodyReview`
- **Kaynak gövdesi:** Diyanet İşleri Başkanlığı, *İslam İlmihali*,
  34. Baskı, 2019, Ankara (ISBN 978-975-19-6769-5; Din İşleri Yüksek
  Kurulu Kararı 03.04.2003/66). PDF indirildi ve metni çıkarılarak
  makale iddialarıyla karşılaştırıldı.
- **Tarih:** 2026-07-19

### Erişilemeyen kaynaklar

| Kaynak | Durum |
|---|---|
| Hadislerle İslam | Gövde bu ortamdan okunamadı |
| Kur'an Yolu Tefsiri | Gövde okunamadı (yalnız künye doğrulandı) |
| Din İşleri Yüksek Kurulu fetvaları | Gövde okunamadı |
| Dinî Soru Hizmetleri | Gövde okunamadı |

Bu kaynaklara dayanan iddialar doğrulanmış sayılmadı.

## Makale denetimi

`SBV` = source body verified. TR pending ise EN/AR sürümleri de
otomatik olarak yayından düşer (çeviri, doğrulanmamış iddiayı dolaylı
yoldan yayına sokamaz).

| # | Article ID | Türkçe başlık | Review status | Source ID | Exact locator | SBV | EN | AR | Blocker |
|---|---|---|---|---|---|---|---|---|---|
| 1 | `art-islam-nedir` | İslam nedir? | scholarlyReviewPending | diyanet-islam-ilmihali | — | ✗ | pending | pending | Bileşik itikadî ifadeler için tek kesin bölüm eşleştirilemedi |
| 2 | `art-imanin-sartlari` | İmanın şartları | **published** | diyanet-islam-ilmihali | IV. İMAN, F) İman Esasları, s. 41 | ✓ | published | published | — |
| 3 | `art-islamin-sartlari` | İslam'ın şartları | **published** | diyanet-islam-ilmihali | II. İSLAM, A) İslam'ın Şartları, s. 84 | ✓ | published | published | — |
| 4 | `art-kelime-i-sehadet` | Kelime-i şehadet | **published** | diyanet-islam-ilmihali | IV. İMAN, A) Kelime-i Tevhid ve Kelime-i Şahadet, s. 39 | ✓ | published | published | — |
| 5 | `art-abdest-nasil-alinir` | Abdest nasıl alınır? | scholarlyReviewPending | diyanet-islam-ilmihali | (adımlar s. 105 ile örtüşüyor) | ✗ | pending | pending | "Tertip Hanefî'de sünnet, Şâfiî'de farz" ifadesi bu eserde YOK |
| 6 | `art-abdestin-farzlari` | Abdestin farzları | scholarlyReviewPending | diyanet-islam-ilmihali | (dört farz s. 98–99 ile doğrulandı) | ✗ | pending | pending | "Şâfiî'de altı farz" iddiası bu eserde YOK |
| 7 | `art-abdesti-bozan-durumlar` | Abdesti bozan durumlar | **published** | diyanet-islam-ilmihali | V. ABDEST, I) Abdesti Bozan Şeyler, s. 110 (Şâfiî farkı: dipnot 25) | ✓ | published | published | — |
| 8 | `art-gusul-nasil-alinir` | Gusül nasıl alınır? | scholarlyReviewPending | diyanet-islam-ilmihali | (üç farz s. 121 ile doğrulandı) | ✗ | pending | pending | Şâfiî farz sayımı iddiası bu eserde YOK |
| 9 | `art-teyemmum-nedir` | Teyemmüm nedir? | **published** | diyanet-islam-ilmihali | VI. TEYEMMÜM, C) ve E), s. 118 | ✓ | published | published | — |
| 10 | `art-namaza-hazirlik` | Namaza hazırlık | **published** | diyanet-islam-ilmihali | VIII. NAMAZ, F/a) Namazın Şartları, s. 144 | ✓ | published | published | — |
| 11 | `art-bes-vakit-namaz` | Beş vakit namaz | scholarlyReviewPending | diyanet-islam-ilmihali | — | ✗ | pending | pending | Vakit başına FARZ rekât sayılarını açıkça veren bölüm tespit edilemedi |
| 12 | `art-namazin-bolumleri` | Namazın temel bölümleri | scholarlyReviewPending | diyanet-islam-ilmihali | (altı rükün s. 145 ile örtüşüyor) | ✗ | pending | pending | "Rükün sayımı mezheplere göre değişir" ifadesi doğrudan desteklenmiyor |
| 13 | `art-kuran-nedir` | Kur'an nedir? | **published** | diyanet-kuran-portali | Kitaplara İman — Kur'an'ın Nazil Oluşu ve Özellikleri, s. 54–58 | ✓ | published | published | — |
| 14 | `art-kuran-okumaya-baslangic` | Kur'an okumaya başlangıç | scholarlyReviewPending | diyanet-kuran-portali | — | ✗ | pending | pending | Yalnız portal ana sayfası; kesin konum yok (genel ana sayfa kanıt sayılmaz) |
| 15 | `art-dua-adabi` | Dua adabı | scholarlyReviewPending | diyanet-hadislerle-islam | — | ✗ | pending | pending | Hadislerle İslam gövdesi okunamadı |
| 16 | `art-tevbe-ve-umit` | Tevbe ve ümit | scholarlyReviewPending | diyanet-islam-ilmihali | — | ✗ | pending | pending | Tevbe için kesin bölüm eşleştirilemedi |

> **Not (13):** `art-kuran-nedir` doğrulaması ilmihalin "Kitaplara İman"
> bölümünden yapıldı; kayıttaki `sourceId` makalenin ilk kaynağı olan
> Kur'an Portalı'dır. Kaynak künyesinin ilmihale çevrilmesi bir sonraki
> turda düzeltilmelidir.

## Özet

- Denetlenen makale: **16**
- Kaynak gövdesi doğrulanan: **7**
- Pending bırakılan: **9** (bunların **4**'ü kaynaksız mezhep iddiası
  taşıdığı için)
- Yayındaki toplam kayıt: 7 × 3 dil = **21**

## Pending içerikleri açmak için gerekenler

1. **Mezhep iddiaları (5, 6, 8, 12):** Şâfiî pozisyonları için ya ayrı
   bir resmî kaynak eklenmeli ya da bu cümleler çıkarılmalı. Diyanet
   İslam İlmihali'nde bu karşılaştırmalar yer almıyor — tek istisna
   abdesti bozan şeyler bölümündeki 25 numaralı dipnottur.
2. **Rekât sayıları (11):** İlmihalin "Beş Vakit Namazın Kılınışı"
   bölümünden (s. 152–160) sayılar teyit edilip locator yazılmalı.
3. **Dua/tevbe (15, 16):** Hadislerle İslam veya ilmihalin ilgili
   bölümüne erişilip kesin konum belirlenmeli.
4. **Kur'an okuma (14):** Genel portal yerine kesin bir sayfa/bölüm
   gösterilmeli.
5. **İslam nedir (1):** İddialar bölünüp her biri kesin bölüme
   bağlanmalı.

Doğrulanmadan hiçbiri `published` yapılmamalıdır; yayın kapısı zaten
domain katmanında bunu engeller.
