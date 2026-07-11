# Bismillah (bismillah_app)

Premium İslami yaşam arkadaşı — Flutter uygulaması.

**Mevcut aşama:** TASK 016 — ilk kullanıcıya görünen dikey dilim: Namaz
sekmesi artık gerçek bir günlük ekranı (bugünün beş vakti, işaretle/geri al,
Drift'e kalıcı yazım + aynı transaction'da sync kuyruğuna op). Vakit
HESABI yok (late/qada çıkarımı yapılmaz, işaretleme `onTime` kaydeder);
sync engine hâlâ yok — kuyruk yalnız birikir.

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
- Kimlik: `currentUserIdProvider` / `currentDeviceIdProvider` GEÇİCİ
  placeholder'dır (`core/session/`) — gerçek Firebase anonim auth ve cihaz
  kimliği ayrı görevde; provider gövdesi değişecek, imzalar sabit.
- AI asistan implementasyonu — AI SDK client'a eklenmeyecek; çağrılar Cloud
  Functions proxy'sinden geçecek.
- Gerçek onboarding akışı, namaz vakti hesabı, içerik (ayet/hadis/dua) —
  ilgili görevlerde.
- ARB tabanlı tam l10n sistemi — mevcut `AppLocalizations` API'si korunarak
  geçilecek.
- Android/iOS platform yapılandırması — scaffold web hedefiyle oluşturuldu;
  native hedefler ilgili görevde eklenecek.
- Marka yazı tipleri (Plus Jakarta Sans, Amiri, Uthmanic Hafs vb.) — asset
  görevinde; tipografi token'ları hazır.

## Secrets Uyarısı

Bu repoda API anahtarı, servis hesabı, keystore, `google-services.json` /
`GoogleService-Info.plist` YOKTUR ve commit edilmez. AI sağlayıcı anahtarları
yalnız sunucu tarafında (Secret Manager) yaşar
(`docs/07_FIREBASE_ARCHITECTURE.md §35`).

## Sıradaki Görevler

1. Firebase anonim auth + gerçek cihaz kimliği (placeholder provider'ların
   gövdesini değiştirir; `placeholder-local-user` verisinin gerçek UID'ye
   remap'i bu görevin kapsamındadır)
3. Sync engine (push worker) — kuyruk hazır, engine yok
4. RevenueCat / kalan entegrasyonlar

Ürün/mimari kararların tamamı repo kökündeki `docs/` klasöründedir;
çelişki hâlinde sıra: `CLAUDE.md` → `docs/01…10`.
