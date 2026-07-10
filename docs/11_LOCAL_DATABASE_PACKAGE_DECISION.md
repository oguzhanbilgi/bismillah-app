# 11 — Local Database Package Decision

| | |
|---|---|
| **Doküman** | 11_LOCAL_DATABASE_PACKAGE_DECISION.md |
| **Versiyon** | 1.0 |
| **Tarih** | 2026-07-10 |
| **Durum** | Onaylı karar — TASK 013 çıktısı; lokal veritabanı implementasyonu (TASK 014+) bu karara uyar |
| **Bağlı dokümanlar** | [CLAUDE.md](../CLAUDE.md) · [06_FLUTTER_ARCHITECTURE.md](06_FLUTTER_ARCHITECTURE.md) · [10_DATA_MODEL_AND_SYNC_SPECIFICATION.md](10_DATA_MODEL_AND_SYNC_SPECIFICATION.md) |
| **Sağlık verisi tarihi** | Tüm pub.dev/GitHub sağlık verileri **2026-07-10** itibarıyla canlı kaynaklardan doğrulanmıştır |

---

## 1. Purpose

`10_DATA_MODEL_AND_SYNC_SPECIFICATION.md` §7'deki **lokal veritabanı paket seçim korkuluğu (v1.1, bağlayıcı)** şunu şart koşar: implementasyona başlamadan önce kullanılacak lokal DB paketinin güncel pub.dev sağlığı doğrulanır; sağlık zayıfsa domain/data sözleşmesi değişmeden başka pakete geçilir. Bu doküman o doğrulamanın kendisidir: adayları değerlendirir, tek bir paket kararı verir ve kaçış planını sabitler.

Bu görevde **hiçbir paket eklenmemiş, hiçbir model yazılmamıştır** — yalnız karar verilmiştir.

## 2. Current Architecture Context

Karar anındaki proje gerçekleri:

- **Domain katmanı hazır (TASK 012/012B):** 27 saf Dart entity, 11 value object, 16+ enum, 12 repository interface'i. Hepsi paket-bağımsız; repository'ler `ResultFuture<T>` döner, UI hiçbir DB tipini görmez.
- **Mimari sözleşme (06 §14–15):** Lokal DB **source of truth**'tur; UI yalnız lokal watch/read ile beslenir; Firestore sonradan eklenecek **gölgedir**. "Önce buluta yaz" deseni yasaktır.
- **Sync sözleşmesi (10 §10–12):** Kalıcı `SyncOperation` kuyruğu; **yazma + kuyruğa ekleme aynı transaction'da** (§12-2); tombstone metadata'sı ack'e kadar hayatta kalır (§11 hardening); kuyruk migration'da drop edilemez (§22).
- **Map yasağı (10 §7 hardening):** DB modellerinde ham `Map` alanı yok; embedded liste / sabit alan / normalize çocuk kayıt / kontrollü JSON'dan biri kullanılır. Domain bu karara hazır (`DhikrCountEntry`, `BehaviorSignals` zaten tipli).
- **Gizlilik (10 §19):** İbadet kayıtları/AI sohbet **Yüksek** hassasiyettir; AI sohbet + sync payload şifreleme adayıdır (keystore destekli).
- **Not:** 06/10 dokümanları Isar adını kullanır; ancak 10 §7 korkuluğu bu adın **bağlayıcı olmadığını**, mimarinin `LocalDatabase` soyutlaması + repository interface'lerine dayandığını açıkça söyler. Bu doküman o esnekliği kullanır.

## 3. Non-Negotiable Requirements

Seçilen paket şunları desteklemek ZORUNDADIR:

| # | Gereksinim | Kaynak |
|---|---|---|
| 1 | Offline-first: tüm okuma/yazma ağsız, anında | 06 §14 |
| 2 | Tipli domain model eşlemesi (mapper ile; ham Map yok) | 10 §7 hardening |
| 3 | Reaktif watch stream'leri (UI ← lokal DB tek yönü) | 06 §14 |
| 4 | **Atomik transaction: entity yazımı + SyncOperation enqueue tek blokta** | 10 §12-2 |
| 5 | Index'ler: `dayKey` (unique), `updatedAt`, `status+nextRetryAt` (kuyruğun en sıcak sorgusu) | 10 §25 |
| 6 | Sürümlü, test edilebilir migration; kuyruk korunumu | 10 §22 |
| 7 | Tombstone/soft-delete deseni (ack'e kadar sorgulanabilir) | 10 §11, §15 |
| 8 | Yüksek hassasiyetli veri için şifreleme yolu (bugün değilse bile açık kapı) | 10 §19 |
| 9 | Birim testte gerçek DB (in-memory) ile mapper/repository testi | 06 §28 |
| 10 | Android + iOS birinci sınıf; masaüstü/web bonus | 06 §2 |
| 11 | Uzun vadeli bakım güvencesi: mağaza sürüm süreçlerini (yeni Dart/Flutter, 16KB page size, Xcode değişimleri) takip eden aktif bakımcı | Bu görevin varlık sebebi |

## 4. Packages Evaluated

2026-07-10 itibarıyla doğrulanan sağlık verileri:

| Paket | Son stabil sürüm | Yayın | Yayıncı | İndirme/beğeni | Bakım durumu |
|---|---|---|---|---|---|
| **isar** (orijinal) | 3.1.0+1 | **Nisan 2023 (~3 yıl önce)** | isar.dev | 5.1k/hafta · 2.45k beğeni | ❌ Fiilen terk edilmiş; v4 "NOT READY FOR PRODUCTION" uyarısıyla yarım; orijinal yazar sessiz |
| **isar_community** (fork) | 3.3.2 | ~3 ay önce | isar-community.dev | 84.9k · 155 beğeni | ⚠️ Aktif ama gönüllü fork; kapsam "v3 için bug fix + küçük iyileştirme"; ilk fork reposu arşivlenip yeniden adlandırıldı |
| **drift** | 2.34.1 | **3 gün önce** | simonbinder.eu | 987k · 2.43k beğeni | ✅ Çok sağlıklı; **Flutter Favorite**; yıllardır kesintisiz ritim |
| **objectbox** | 5.3.2 | ~51 gün önce | objectbox.io | 151k/hafta · 1.57k beğeni | ✅ Şirket destekli, aktif (6.0 preview var) |
| **hive_ce** | 2.19.3 | ~5 ay önce | iodesignteam.com | 815k · 555 beğeni | ✅ Aktif (orijinal hive'ın topluluk devamı) |
| **sqflite** (ham SQL) | 2.4.3 | ~38 gün önce | tekartik.com | 2.49M · 5.55k beğeni | ✅ Çok sağlıklı; Flutter Favorite |

## 5. Evaluation Matrix

Ölçek: 🟢 iyi · 🟡 kabul edilebilir/koşullu · 🔴 zayıf

| Kriter | isar | isar_community | **drift** | objectbox | hive_ce | sqflite |
|---|---|---|---|---|---|---|
| 1. Bakım sağlığı | 🔴 | 🟡 | 🟢 | 🟢 | 🟢 | 🟢 |
| 2. Flutter uyumluluğu (mobil öncelik) | 🟡 | 🟡 | 🟢 | 🟢 | 🟢 | 🟢 |
| 3. Veri modeli uyumu (tip/index/sorgu/embedded) | 🟢 | 🟢 | 🟢 | 🟢 | 🔴 | 🟡 |
| 4. Sync modeli uyumu (transaction+kuyruk+tombstone) | 🟡 | 🟡 | 🟢 | 🟡 | 🔴 | 🟡 |
| 5. Gizlilik/şifreleme yolu | 🟡 | 🟡 | 🟢 (SQLCipher) | 🟡 | 🟢 (yerleşik) | 🟢 (SQLCipher) |
| 6. Geliştirici hızı (testability dahil) | 🟡 | 🟡 | 🟢 | 🟡 | 🟢 | 🔴 |
| 7. Migration/lock-in riski | 🔴 | 🔴 | 🟢 (veri SQLite'ta) | 🟡 (özel format) | 🟡 | 🟢 |
| 8. Ürün riski (launch + uzun vade + mağaza süreçleri) | 🔴 | 🟡 | 🟢 | 🟡 | 🟡 | 🟢 |

## 6. Package-by-Package Analysis

### 6.1 isar (orijinal) — RED

Dokümanların yazıldığı dönemin varsayılanıydı; bugün seçilemez. Son stabil sürüm **Nisan 2023**; v4 hiçbir zaman üretime hazır ilan edilmedi ve repo v4 için açık "NOT READY FOR PRODUCTION" uyarısı taşıyor; orijinal yazar uzun süredir sessiz. Yeni Dart SDK'ları, Android 16KB page size gibi mağaza-zorunlu platform değişimleri karşısında güncelleme garantisi yok. **10 §7 korkuluğunun tam olarak yakalamak için yazıldığı senaryo budur.** Kriter 11'de kalır.

### 6.2 isar_community — RED (yedek olarak not edildi)

Ciddiyetle değerlendirildi: doğrulanmış yayıncı, ~3 ay önce 3.3.2, aktif repo, Isar'ın nesne modeli/embedded desteği ve watch API'si Bismillah'ın veri desenine doğal uyar. Ancak: (a) bildirilen misyonu **yeni özellik değil v3'ü yaşatmak**; (b) gönüllü emeğine bağlı — Dart/platform kırılmalarını zamanında takip garantisi bir kişi/küçük ekip iyi niyetine dayanır; (c) fork tarihçesi çalkantılı (ilk repo arşivlenip yeniden adlandırıldı); (d) veri formatı Isar'a özgü — fork da zayıflarsa çıkış maliyeti tam migration'dur. "İbadet kaydı asla kaybolmaz" taahhüdü veren bir ürün, kalıcı veri katmanını gönüllü fork'a emanet etmemeli. Drift'in ekosistem-dışı kalması gibi bir durumda yeniden değerlendirilecek yedektir.

### 6.3 drift — KABUL (seçilen)

- **Bakım:** En güçlü sinyal seti — karar günü itibarıyla 3 gün önce sürüm, yıllardır aralıksız ritim, Flutter Favorite, 987k indirme, tek ama son derece istikrarlı ve ekosistemce tanınan bakımcı + geniş katkıcı tabanı. Veri motoru **SQLite**'tır: dünyanın en test edilmiş gömülü veritabanı; Drift ölse bile veri dosyası standarttır (lock-in yok).
- **Gereksinim eşlemesi:** Reaktif `watch()` sorguları (Gereksinim 3) · gerçek ACID transaction — entity yazımı + kuyruk enqueue tek `transaction(...)` bloğunda (G4, §12-2'nin birebir karşılığı) · tipli tablolar + composite index'ler dahil tam index desteği (G5) · **şema migration'ları sürümlü ve `drift_dev` şema doğrulama araçlarıyla test edilebilir** — 10 §22'nin "önce-sonra fixture testi" şartının hazır altyapısı (G6) · soft-delete/tombstone sıradan sorgulanabilir kolondur (G7) · SQLCipher entegrasyonu belgeli ve yaygın (G8) · **`NativeDatabase.memory()` ile birim testte gerçek DB** — mock'suz mapper/repository testi (G9) · tüm platformlar, web dahil (G10).
- **Map yasağı uyumu:** 10 §7'nin dört meşru biçimi Drift'te doğal karşılık bulur: `PrayerEntry` seti sabit kolonlar (biçim b), `DhikrCountEntry` normalize çocuk tablo (c), esnek payload'lar kontrollü JSON `TypeConverter` (d).
- **Maliyetler:** build_runner kod üretimi (TASK 012'de yasaktı; DB implementasyon görevinde normal araçtır) · ilişkisel model — nesne grafı yerine tablo düşünmek hafif öğrenme eğrisi · derin nesne gömme Isar'dan daha az "bedava" (mapper yazılır; zaten mimari mapper'ı şart koşuyor).

### 6.4 objectbox — RED

Sağlıklı ve hızlı; ancak (a) tamamen tescilli depolama formatı — en yüksek lock-in; (b) ticari şirket modeli: sync ürünü paralı, ücretsiz çekirdeğin yol haritası şirket önceliğine bağlı; (c) native C kütüphanesi + iOS 15/macOS 11 tabanları ve ayrı generator zinciriyle build karmaşıklığı; (d) topluluk/soru-cevap yüzeyi Drift'ten belirgin küçük. Bizim sync'imiz zaten Firestore'a özel yazılacak — ObjectBox'ın ayırt edici gücü (kendi sync'i) bize kapalı kapı.

### 6.5 hive_ce — RED

Aktif ve şifrelemesi yerleşik; ama **anahtar-değer deposudur**: sorgu dili, index, ilişki yok. `status+nextRetryAt` kuyruk taraması, `dayKey` aralık sorguları, `updatedAt` imleçleri uygulama belleğinde elle filtrelemeye döner; transaction garantileri §12-2'yi karşılamaz. Veri modeli uyumu (Kriter 3) ve sync uyumu (4) kırmızı. Küçük tercih-cache'leri için bile gerek yok — tek DB ilkesi daha temiz.

### 6.6 sqflite (ham SQL) — RED

Motor aynı (SQLite) ve sağlık mükemmel; ama tip güvenliği yok: her sorgu elle string, her satır elle `Map` parse — 27 entity × mapper'da hata yüzeyi ve hız kaybı büyük. Reaktif watch yok (elle stream kurulur). Drift, aynı motorun üstünde bu eksiklerin tamamını kapatan katmandır; ham sqflite seçmek Drift'in çözdüğü problemi kendimize yeniden yazmaktır.

## 7. Recommendation

**Drift.** Tek başına en güçlü gerekçe: Bismillah'ın anayasal taahhüdü ("bir secde kaydı hiçbir koşulda kaybolmaz", 10 §31) kalıcı veri katmanının **on yıl ölçeğinde** ayakta kalmasını gerektirir; adaylar içinde bunu hem aktif bakım hem de motor düzeyinde (SQLite = fiilen endüstri standardı dosya formatı) garanti eden tek seçenek Drift'tir. Ek olarak §12-2'nin atomik yazma+enqueue şartını gerçek transaction'la, §22'nin migration test şartını hazır araçla, §19'un şifreleme kapısını SQLCipher'la karşılar. Spike'a gerek yok: sağlık verisi tereddüde yer bırakmayacak kadar net ve gereksinim eşlemesi tam.

## 8. Decision

> **Bismillah'ın lokal veritabanı Drift'tir (SQLite üzerinde).**
>
> - 06/10 dokümanlarındaki "Isar" adı bundan böyle **"lokal DB (Drift)"** olarak okunur; 10 §7 korkuluğunun öngördüğü ikame tam olarak budur ve **domain/data sözleşmesi değişmez**: Isar-first → **local-first** ilkesi, tüm tablolar/index'ler/migration kuralları (10 §7, §22, §25) anlam koruyarak Drift'e eşlenir.
> - Repository interface'leri, entity'ler, value object'ler ve sync sözleşmesi (TASK 012/012B çıktısı) hiçbir değişiklik gerektirmez — kritik tutarsızlık bulunmamıştır.
> - `isar_community` yedek olarak not edilmiştir; ObjectBox/Hive CE/sqflite elenmiştir.

## 9. Implementation Strategy

TASK 014+ için bağlayıcı sıra:

1. **Paketler:** `drift` + `drift_flutter` (runtime) · `drift_dev` + `build_runner` (dev). Başka persistence paketi eklenmez.
2. **Katman yerleşimi (06 §7/§15):** DB açılışı/şema kaydı/migration çatısı `core/storage` (`LocalDatabase` soyutlaması arkasında); tablo tanımları feature `data/models/`; Drift importu YALNIZ local datasource + `core/storage` içinde — lint ile zorlanır. UI/provider/use case Drift tipini asla görmez.
3. **Tablo eşlemesi:** 10 §7 tablosundaki 18 koleksiyon birebir Drift tablosuna eşlenir; map-benzeri alanlar §7 hardening'in dört biçiminden uygun olanıyla (PrayerEntry → sabit kolonlar; DhikrCount → çocuk tablo; esnek payload → `TypeConverter`'lı kontrollü JSON).
4. **İlk dilim dikey ve dar:** Önce `PrayerLogDay` + `SyncOperation` (en kritik ikili: ibadet kaydı + kuyruk) uçtan uca — tablo, mapper, repository impl, transaction'lı write+enqueue, in-memory testler. Sonra kalan koleksiyonlar aynı desenle.
5. **Şema sürümü 1'den itibaren:** `schemaVersion` + drift_dev şema export'u ilk commit'te; her migration adımı önce-sonra fixture testli (10 §22/§28).
6. **Şifreleme:** MVP'de platform sandbox yeterli (10 §19 Orta sınıf kuralı); AI sohbet/sync payload için SQLCipher geçişi ayrı görev olarak arkada tutulur — Drift tarafında kapı açık.

## 10. Migration and Escape Plan

- **İçe dönük (şema) migration:** Drift'in sürümlü `MigrationStrategy`'si + şema doğrulama testleri; kuyruk tablosu migration'da asla drop edilmez (10 §22).
- **Dışa dönük (paketten kaçış):** Veri standart SQLite dosyasında durur — Drift'ten çıkmak (teorik ihtiyaçta) veri formatı migration'ı değil **erişim katmanı** değişimidir; repository interface'leri sayesinde etki data katmanıyla sınırlıdır. Bu, adaylar arasındaki en ucuz kaçış yoludur ve seçimin bilinçli bir parçasıdır.
- **Karar geri dönüş eşiği:** Drift bakımı 12 ay sürümsüz kalır VEYA kritik platform kırılması 90 gün yanıtsız kalırsa bu doküman revize edilir; ilk değerlendirilecek alternatif o günkü sağlığıyla `isar_community` ya da ham `sqflite` üstüne ince katmandır.

## 11. Risks

| Risk | Olasılık | Etki | Azaltım |
|---|---|---|---|
| Tek-bakımcı yoğunluğu (Drift) | Düşük | Orta | SQLite formatı + kaçış planı §10; Flutter Favorite statüsü ve dev kullanıcı tabanı ekosistem baskısı yaratır |
| build_runner üretim zinciri sürtünmesi | Orta | Düşük | Üretilen dosyalar commit'lenir; CI'da `build_runner build --delete-conflicting-outputs` standart adım |
| İlişkisel modelin nesne-grafı alışkanlığıyla çatışması | Orta | Düşük | Mapper katmanı zaten zorunlu; §9-4'teki dar ilk dilim deseni erken doğrular |
| Derin embedded yapılarda mapper maliyeti | Orta | Düşük | §7 hardening zaten map'i yasaklamıştı; domain tipleri (DhikrCountEntry vb.) tablo eşlemesine hazır |
| Web'de OPFS/wasm kurulum detayları (V2+ ihtiyacı) | Düşük | Düşük | MVP mobil-only; drift web desteği resmi ve belgeli |

## 12. Open Questions

1. SQLCipher şifrelemesi hangi görevde devreye girer? (Öneri: AI asistan persistence görevi ile birlikte — en hassas serbest metin orada doğar.)
2. Üretilen `*.g.dart` dosyaları repoya commit'lenecek mi? (Öneri: evet — CI basitliği ve diff görünürlüğü; TASK 014'te kesinleşir.)
3. `drift_flutter` mı `NativeDatabase` elle kurulum mu? (Öneri: `drift_flutter` — resmi önerilen yol; TASK 014'te doğrulanır.)
4. 06/10 dokümanlarındaki "Isar" adlandırmaları toplu redaksiyon mu, okuma notu mu? (Öneri: dokümanlara tek satır "bkz. doc 11" notu; toplu yeniden yazım değmez.)

## 13. TASK 014 Proposal

**TASK 014 — Drift Local Database Foundation (ilk dikey dilim):**

- `drift`/`drift_flutter`/`drift_dev`/`build_runner` eklenir (pubspec değişikliği bu görevde serbest).
- `core/storage`: `LocalDatabase` soyutlaması, DB açılışı, şema v1, migration çatısı + şema testi altyapısı.
- İlk dilim: `PrayerLogDayModel` (sabit vakit kolonları) + `SyncOperationModel` (status+nextRetryAt index'li) tabloları, mapper'lar, `PrayerLogRepository` + `SyncQueueRepository` somut implementasyonları, **transaction'lı write+enqueue**.
- Testler: in-memory Drift ile mapper round-trip, repository davranışı, transaction atomikliği (§28 satırları), kuyruk birleştirme kuralı.
- Kapsam dışı: Firebase, sync engine, kalan 16 tablo (TASK 015+), şifreleme.

---

**Kaynaklar (2026-07-10):** [pub.dev/packages/isar](https://pub.dev/packages/isar) · [pub.dev/packages/isar_community](https://pub.dev/packages/isar_community) · [github.com/isar/isar](https://github.com/isar/isar) · [github.com/isar-community](https://github.com/isar-community/isar) · [pub.dev/packages/drift](https://pub.dev/packages/drift) · [pub.dev/packages/objectbox](https://pub.dev/packages/objectbox) · [pub.dev/packages/hive_ce](https://pub.dev/packages/hive_ce) · [pub.dev/packages/sqflite](https://pub.dev/packages/sqflite)

*Dokümanın sonu. Bu karar 10 §7 korkuluğunun gereğini yerine getirir; lokal veritabanı implementasyonu bu dokümana ve 10_DATA_MODEL sözleşmesine birlikte uyar.*
