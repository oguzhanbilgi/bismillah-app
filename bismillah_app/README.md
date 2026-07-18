# Bismillah (bismillah_app)

Premium İslami yaşam arkadaşı — Flutter uygulaması.

**Mevcut aşama:** CHECKPOINT 07 (TASK 050) — otomatik doğrulama. Son durum:

- **TASK 021 — Offline namaz vakti motoru:** adhan_dart ile TAM OFFLINE
  hesap; konum yalnız foreground/izinliyse (day-0 izin duvarı YOK). Zamanlar
  UTC saklanır, sunumda `.toLocal()` (sabit UTC+3 yasak).
- **TASK 022 — Yerel namaz hatırlatıcıları:** flutter_local_notifications
  temeli; sakin aç/kapat kartı Prayer'da. FCM/sunucu bildirimi yok.
- **TASK 023 — Today "Sıradaki namaz" kartı:** beş vakitten sıradakini
  gösterir (Güneş asla seçilmez); saat `clockProvider`'dan, canlı sayaç yok.
- **TASK 024 — Son 7 gün geçmişi:** `/prayer/history` salt-okunur ekran;
  mevcut `getRange` ile TEK aralık sorgusu; kayıtsız gün sakin 0/5.
- **TASK 025 — Today haftalık ritim kartı:** TASK 024 controller'ını paylaşır;
  toplam X/35 + 7 kompakt sütun; streak/puan/rozet YOK.
- **TASK 026–028 — Onboarding:** Welcome → Goals (çoklu) → Journey (tekli)
  → Pace (tekli) → Today. Seçimler SharedPreferences'a stabil enum
  adlarıyla yazılır; `completed` bayrağı EN SON. Startup kapısı bootstrap'ta
  okunur + router `redirect` (tek kaynak, döngü yok); bozuk veri
  tamamlanmamış sayılır. İzin/login/paywall İSTENMEZ; Firestore sync YOK.
- **TASK 029 — Profil kişiselleştirme özeti:** odak/journey/pace salt-okunur kart.
- **TASK 030 — Tercih düzenleme:** `/profile/personalization`; `completed` true kalır.
- **TASK 031 — Today kişiselleştirilmiş küçük adım:** deterministik günlük öneri kartı.
- **TASK 032 — Kur'an günlük hedef temeli:** SharedPreferences'ta sayfa hedefi.
- **TASK 033 — Kur'an kurulumu ve iç sekmeler:** yazı biçimi/meal/hedef + Oku/Öğren/İlerlemem.
- **TASK 034/034B — Doğrulanmış 114 sure kataloğu:** Tanzil metadata → `chapters_v1.json` + arama.
- **TASK 035 — Tanzil Uthmani Arapça okuyucu:** `/quran/chapter/:id`, 6236 doğrulanmış ayet (kaynak: `assets/quran/NOTICE.md`).
- **TASK 036 — Kur'an kaldığın yerden devam:** scroll-end'de yerel konum kaydı + devam kartı.
- **TASK 037 — Ayet kaydetme ve okuma görünümü:** bookmark + Arapça metin boyutu (Küçük/Orta/Büyük).
- **TASK 038 — Kaydedilen ayetler ve Today Kur'an kartı:** `/quran/bookmarks` + Today devam kartı.
- **TASK 039 — Diyanet meal backend'i:** `functions/` altında v2 callable
  `getQuranChapterTranslation` (europe-west1, Node 20, auth zorunlu, anonim
  kabul). Diyanet API tokenı YALNIZ Firebase Secret Manager'da
  (`DIB_KURAN_API_TOKEN`); istemcide/logda/repo'da ASLA bulunmaz. Kurulum:
  `firebase functions:secrets:set DIB_KURAN_API_TOKEN --project
  bismillah-app-dev-oguzhan` (değer terminale elle girilir).
- **TASK 040 + CHECKPOINT 06 Recovery — Reader'da Türkçe meal:** AKTİF
  kaynak **QuranEnc Rowad Tercüme Merkezi V1.0.4** — tamamen OFFLINE
  paketlenmiş asset (`assets/quran/translations/
  quranenc_turkish_rwwad_v1_0_4.json`; künye `assets/quran/NOTICE.md`).
  Metin ve dipnotlar DEĞİŞTİRİLMEDEN kullanılır; kaynak ve sürüm atfı
  reader'da gösterilir ("Meal: Rowad Tercüme Merkezi" / "Kaynak:
  QuranEnc.com · V1.0.4"). "Türkçe meali göster" ayarı korunur
  (varsayılan açık). Runtime'da QuranEnc/İnternet çağrısı YOKTUR.
  **Diyanet entegrasyonu (TASK 039 callable + istemci deposu) INACTIVE/
  future provider durumundadır:** `api.diyanet.gov.tr` DNS üzerinden
  çözümlenemediği için aktif akışta ÇAĞRILMAZ ve production ready
  DEĞİLDİR; doğru resmî base URL sağlandığında yalnız backend
  yapılandırması güncellenecektir.
- **TASK 041 — MP3Quran ayet sesi:** read 5 (Ahmed el-Acemi · Hafs an Asım),
  ayet bazlı Dinle/Duraklat/Devam et (just_audio `setClip`), timing
  doğrulamalı; kaynak atfı MP3Quran.net.
- **TASK 042 — Kesintisiz sure dinleme:** "Sureyi dinle" paneli, otomatik
  ayet geçişi, önceki/sonraki, Ayet X/Y. Arka plan / lock-screen / media
  notification oynatma HENÜZ YOK (uygulama içi, ön planda).
  Kaynak atıfları: Tanzil (Arapça metin), Diyanet İşleri Başkanlığı Meali
  (Türkçe meal), MP3Quran.net (kıraat sesi).
- **TASK 044–046 — Arka plan Kur'an sesi:** tek global `AudioPlayer` +
  `audio_service` ile arka plan / bildirim / kilit ekranı oynatma; uygulama
  genelinde tek **mini player** (shell seviyesinde, reader kapansa da sürer).
  `AudioService.init` bootstrap'ta BİR KEZ; başarısızlık fatal değil (sakin
  unavailable servise düşer). **iOS arka plan sesi henüz gerçek cihazda
  DOĞRULANMADI** (Android emülatör/masaüstü doğrulandı).
- **TASK 047 — Cihaz-lokal okuma ilerlemesi:** günlük hedef, gerçek aktif
  okuma (idle 90 sn, arka plan ses sayılmaz; ayet 3 sn / sayfa 8 sn), seri
  ve son 7 gün. YALNIZ cihazda saklanır; analytics/Firebase'e ilerleme veya
  verseKey GÖNDERİLMEZ. Sayfa hedefi doğrulanmış ayet→sayfa eşlemesiyle
  (`verse_pages_v1.json`, 6236 ayet / 604 sayfa).
- **TASK 048 — Çevrimdışı Arapça/Türkçe arama:** paketlenmiş normalize indeks
  (`assets/quran/search/quran_search_index_v1.json`, 114 sure / 6236 ayet) +
  sure adı/numara, ayet referansı (`2:255`, `2/255`, `2 255`) ve doğrulanmış
  **Ayetel Kürsi alias'ı** (`ayetel kürsi` → 2:255). Snippet metinleri her
  zaman ORİJİNAL Tanzil/QuranEnc'tendir; sorgular hiçbir yere gönderilmez.
- **TASK 049 — Kâri seçimi:** MP3Quran reads kataloğu + cihaz-lokal kâri
  tercihi; oynatılan sesin kaynağı/kârisi metadata olarak gösterilir.
- **TASK 050 — Today Kur'an merkezi:** Today'de tek "Bugünkü Kur'an" bölümü —
  günlük hedef/ilerleme/seri, son okuma + Okumaya devam et, Kur'an'ı aç /
  Kur'an'da ara / Kaydedilen ayetler hızlı aksiyonları ve İlerlemem geçişi.
  Namaz ve kişiselleştirme kartları korunur; ikinci oynatıcı/AI önerisi YOK.

### CHECKPOINT 07 — doğrulama sonucu

Otomatik (bu repoda tekrarlanabilir): `flutter analyze` temiz, tüm birim/
widget testleri geçiyor, debug APK üretiliyor; generator bütünlük kontrolleri
(114 sure / 6236 ayet; 6236 ayet → 604 sayfa; arama indeksi 114/6236) ve
deterministik üretim doğrulandı.

Aşağıdakiler **fiziksel cihazda elle** doğrulandı (Samsung SM A366B,
Android 16) — otomatik test değildir:

- Çevrimdışı Tanzil Arapça Kur'an metni
- Çevrimdışı QuranEnc Rowad Türkçe meal
- Çevrimdışı Arapça/Türkçe Kur'an araması
- Ayet referansı (`2:255`) ve Ayetel Kürsi alias'ı
- Gerçek Kur'an sesi oynatma (loading → playback, pause/resume/prev/next/stop)
- Uygulama genelinde Kur'an mini-player'ı
- Android arka plan oynatma (Home tuşu sonrası)
- Android medya bildirimi
- Android kilit ekranı medya kontrolleri
- Kâri değiştirme ve kaynak-farkında (source-aware) cache
- Yalnız-cihazda Kur'an okuma ilerlemesi yaşam döngüsü (3 sn ayet / 8 sn
  sayfa, arka plan süresi sayılmaz, 90 sn idle, yeniden açılışta persistence)

**iOS arka plan sesi hâlâ fiziksel bir iOS cihazında DOĞRULANMADI.**

Today SALT-OKUNURDUR ve Prayer dilimiyle AYNI lokal kaynağı izler
(`PrayerLogRepository` → Drift). TASK 016: Namaz sekmesi gerçek
günlük ekranı (işaretle/geri al, kalıcı yazım + aynı transaction'da sync
op). Sync engine hâlâ yok — kuyruk yalnız birikir.

## Çalıştırma

```bash
cd bismillah_app
flutter pub get
flutter analyze
flutter test
flutter run -d chrome   # web hedefi (native hedefler henüz yapılandırılmadı)
```

Flavor seçimi: `flutter run --dart-define=FLAVOR=development` (varsayılan:
development; diğerleri: staging, production).

## Klasör Yapısı

```
lib/
  main.dart            # Giriş noktası
  app/                 # Kompozisyon kökü: bootstrap, tema, router, shell, l10n
    router/            # GoRouter + route sabitleri + route metadata
    theme/             # Design token'ları (renk/boşluk/radius/tipografi/gölge/motion)
    localization/      # TR/EN/AR placeholder localization (ARB'ye geçiş sonraki görev)
    shell/             # 5 sekmeli kabuk, AppScaffold, alt nav, asistan FAB
  core/                # Yatay altyapı: Result/Failure, analytics, privacy,
                       # LocalDatabase soyutlaması, logging, config, utils
  shared/              # Yeniden kullanılabilir bileşenler
    widgets/           # AppButton, AppCard, AppText, boş/hata durumları...
    sacred/            # Kutsal içerik blokları (kaynak zorunlu)
    premium/           # Bismillah+ rozeti ve fayda kartı
  features/            # Feature-first dikey dilimler (domain/application/data/presentation)
test/                  # Smoke + birim testleri
```

## Mimari İlkeler

- Clean Architecture + feature-first (bkz. `docs/06_FLUTTER_ARCHITECTURE.md`).
- Riverpod tek DI/state mekanizması; GoRouter tek router.
- UI hiçbir zaman Firebase/Isar/RevenueCat/AI SDK'sı import etmez.
- Design token dışı renk/spacing/radius/duration yasak (`lib/app/theme/`).
- Kullanıcıya görünen string'ler widget'a hardcode edilmez (`AppLocalizations`).
- 5 sekme: Today, Prayer, Quran, Learn, Profile — Asistan sekme DEĞİL,
  her ekrandan erişilen FAB katmanıdır.
- `/premium` full-screen modal; `/settings/subscription` push route.
- Onboarding'de ve ilk 14 günde otomatik paywall YOK; temel ibadet araçları
  ücretsiz kalır (bkz. `docs/08_BUSINESS_MODEL_AND_GROWTH_STRATEGY.md`).
- Kutsal içerik bileşenleri kaynak parametresi olmadan derlenmez
  ("no source, no render"); `QuranTextBlock` `maxLines` sunmaz; AI metni
  yalnız `AiExplanationBlock` ile ve etiketli render edilir.
- `PrivacyGuard` + tipli `AnalyticsEvent`: PII ve ham ibadet verisi
  telemetriye çıkamaz.

## Bilinçli Olarak HENÜZ Yapılmayanlar

- Firebase entegrasyonu (Auth/Firestore/Analytics/Crashlytics/FCM) — yalnız
  mimari yerleri hazır.
- RevenueCat / satın alma akışı — `/premium` ve `/settings/subscription`
  placeholder.
- ~~Gerçek lokal DB~~ → **Drift bağlandı** (TASK 013 kararı + TASK 014/015):
  `appDatabaseProvider` tek paylaşımlı `AppDatabase` açar, container
  dispose'unda kapatır; `prayerLogRepositoryProvider` /
  `syncQueueRepositoryProvider` arayüz tipleriyle çözülür. Drift importu
  yalnız `core/storage` + `features/*/data/{local,mappers}` katmanlarında
  (mimari testle korunur: `test/architecture/`). Sync ENGINE yok — yalnız
  kalıcı kuyruk.
- Kimlik (TASK 018–019): **anonim kimlik temeli var.** Bootstrap sırası:
  Firebase Core → anonim/mevcut UID (**3 sn timeout**, süre aşımı/ağ/auth
  hatası kalıcı `local-*` kimliğe düşer, döngüsel retry YOK) → cihaz
  kimliği → lokal DB → uid remap → inFlight kurtarma. Cihaz kimliği
  UYGULAMA-LOKAL UUID v4'tür (shared_preferences) — reklam/donanım kimliği
  DEĞİLDİR. Debug log yalnız redakte `identitySource=firebase|local`
  yazar, ham UID ASLA loglanmaz. Gerçek hesap bağlama (Apple/Google/
  e-posta) ve Firestore sync HÂLÂ YOK. Eski `placeholder-local-user` /
  `local-*` satırlarını güncel UID'ye taşıyan idempotent remap bootstrap'ta
  çalışır.
- **Native hedefler (TASK 019): android/ + ios/ oluşturuldu.** Onaylı ID
  `com.bismillah.app` (docs 06 §34, 07 §4); app adı "Bismillah". Flavor
  son ekleri (`.dev`/`.staging`) Gradle product flavor kurulumuyla ayrı
  görevde eklenecek. iOS dosyaları üretildi ancak **iOS build macOS/Xcode
  gerektirir — Windows'ta derlenmedi/test edilmedi.**
- **Firebase config durumu: BAĞLI (TASK 019).** FlutterFire ile Firebase
  projesi `bismillah-app-dev-oguzhan` yapılandırıldı: `lib/firebase_options.dart`
  (Android+iOS, `com.bismillah.app`), `android/app/google-services.json` ve
  Gradle plugin'leri mevcut. `DefaultFirebaseInitializer` artık
  `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
  çağırıyor; yapılandırılmamış platform (web/desktop) veya native kanalı
  olmayan test ortamında `unavailable` dönüp kalıcı `local-*` kimliğe düşer.
  **iOS native `GoogleService-Info.plist` yerleştirilmedi** (FlutterFire
  Windows davranışı); Dart seçenekleri mevcut ama iOS build macOS/Xcode
  gerektirir. Firebase Console'da **Anonim kimlik doğrulama etkin**. Firestore
  sync HÂLÂ YOK. Testler canlı Firebase projesi GEREKTİRMEZ (fake'ler).
- AI asistan implementasyonu — AI SDK client'a eklenmeyecek; çağrılar Cloud
  Functions proxy'sinden geçecek.
- Gerçek onboarding akışı, namaz vakti hesabı, içerik (ayet/hadis/dua) —
  ilgili görevlerde.
- ARB tabanlı tam l10n sistemi — mevcut `AppLocalizations` API'si korunarak
  geçilecek.
- Android/iOS native hedefleri TASK 019'da eklendi (yukarı bakınız); build
  flavor'ları ve gerçek imzalama ayrı görevde.
- Marka yazı tipleri (Plus Jakarta Sans, Amiri, Uthmanic Hafs vb.) — asset
  görevinde; tipografi token'ları hazır.

## Secrets Politikası

**Firebase istemci yapılandırması commit EDİLİR** (TASK 019 kararı — standart
istemci-config politikası):

- `lib/firebase_options.dart` ve `android/app/google-services.json` Firebase
  **istemci** yapılandırmasıdır; bir uygulamaya gömülmek üzere tasarlanmış
  public tanımlayıcılar taşır (app ID, proje ID, istemci API anahtarı).
- Bunlar **yetkilendirme sırrı DEĞİLDİR**: içerdikleri API anahtarı tek başına
  hiçbir kullanıcı verisine erişim vermez.
- Güvenlik, anahtarı gizlemeye değil şunlara dayanır: **Firebase Authentication,
  Security Rules, (Google Cloud Console'da) API anahtarı kısıtlamaları** ve
  ileride **App Check**.

**ASLA commit edilmeyen GERÇEK sırlar** (`.gitignore` ile engelli):
servis hesabı / Admin SDK private key'leri (`service-account*.json`,
`*adminsdk*.json`), OAuth client secret'ları, Firebase CLI token'ları,
imzalama keystore'ları (`*.jks` / `*.keystore` / `android/key.properties`),
gizli ortam değerleri (`.env`). AI sağlayıcı anahtarları yalnız sunucu tarafında
(Secret Manager) yaşar (`docs/07_FIREBASE_ARCHITECTURE.md §35`).

**iOS:** `GoogleService-Info.plist` henüz repoda yoktur (FlutterFire Windows'ta
yerleştiremedi); macOS'ta üretildiğinde aynı istemci-config politikasıyla
commit edilir.

## Sıradaki Görevler

1. Firebase anonim auth + gerçek cihaz kimliği (placeholder provider'ların
   gövdesini değiştirir; `placeholder-local-user` verisinin gerçek UID'ye
   remap'i bu görevin kapsamındadır)
3. Sync engine (push worker) — kuyruk hazır, engine yok
4. RevenueCat / kalan entegrasyonlar

Ürün/mimari kararların tamamı repo kökündeki `docs/` klasöründedir;
çelişki hâlinde sıra: `CLAUDE.md` → `docs/01…10`.
