# Bismillah (bismillah_app)

Premium İslami yaşam arkadaşı — Flutter uygulaması.

**Mevcut aşama:** TASK 025. Son durum:

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
