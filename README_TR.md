<!-- Dil gezinmesi -->
[English](README.md) · **Türkçe**

# Bismillah

Günlük ibadet, Kur'an ve öğrenme için sakin, kaynağa dayalı bir İslami yaşam arkadaşı — Flutter ile geliştirildi.

[![Flutter CI](https://github.com/oguzhanbilgi/bismillah-app/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/oguzhanbilgi/bismillah-app/actions/workflows/flutter-ci.yml)
[![Lisans: MPL 2.0](https://img.shields.io/badge/License-MPL_2.0-brightgreen.svg)](LICENSE)

> ⚠️ **Herkese açık alfa.** Bu, erken bir herkese açık alfa sürümüdür (`0.1.0-alpha.1`).
> **Üretime hazır değildir**, **hiçbir uygulama mağazasında yayınlanmamıştır** ve davranışı
> değişebilir. **Resmî bir Diyanet uygulaması değildir** ve **Diyanet tarafından
> onaylanmamıştır**.

---

## Neden Bismillah

Bismillah, Müslümanların her gün açmak isteyeceği bir arkadaş olmayı hedefler — sakin,
sade ve güvenilir. Odağı; ibadette süreklilik, sahih ve açıkça kaynaklandırılmış İslami
bilgi ve gizliliğe saygılı, yerelde çalışan (local-first) bir deneyimdir. Her dinî ifade
bir kaynağa bağlıdır; uygulama yapay zekâ metnini asla vahiy gibi sunmaz.

## Mevcut çalışan özellikler

Aşağıdakiler uygulanmıştır ve test paketi tarafından denenmektedir (Kur'an ve ses
akışları ayrıca gerçek cihazda doğrulanmıştır — bkz. [Desteklenen platformlar](#desteklenen-platformlar)):

- **Today (Bugün)** — salt-okunur günlük özet: sıradaki namaz, haftalık ritim ve tek bir
  "Bugünkü Kur'an" bölümü (günlük hedef, seri, okumaya devam).
- **Prayer (Namaz)** — tamamen çevrimdışı namaz vakti motoru (cihazda hesaplanır), sakin
  bir yerel hatırlatıcı anahtarı, işaretle/geri al günlük kaydı ve salt-okunur son 7 gün
  geçmişi.
- **Quran (Kur'an)** — Tanzil Uthmani Arapça okuyucu, paketlenmiş Türkçe meal, kaldığın
  yerden devam, ayet kaydetme, çevrimdışı Arapça/Türkçe arama, ayet referansı arama ve
  MP3Quran.net'ten akıtılan kıraat sesi (Android arka plan / kilit ekranı oynatma ile).
- **Learn (Öğren)** — kaynağa dayalı bir bilgi tabanı (**30 yayınlanmış / 2 ilmî inceleme
  bekliyor**); her makale kesin bir kaynak konumu (locator) ve delil taşır.
- **Profile (Profil)** — kişiselleştirme özeti, içerik-kaynak bağlantıları, gizlilik ve
  veri kontrolleri.
- **Bismillah Asistanı** — deterministik, yerel, kaynağa dayalı bir yardımcı (aşağıya bkz).

## Ürün alanları

Uygulamada **beş sabit sekme** vardır: **Today, Prayer, Quran, Learn, Profile**.
**Bismillah Asistanı altıncı sekme değildir** — alt gezinmede bir hedef değil, uygulamadan
erişilen bir yardımcı katmandır.

## Kaynağa dayalı Learn

Learn içerikleri, **resmî kaynaklara (öncelikle Diyanet) dayanan özgün kısa özetler**
olarak yazılır — birebir kopya değildir. Her öğe, gösterilebilmeden önce **kesin kaynak
konumu** ve **delil özeti** gerektiren bir yayın kapısından (`sourceBodyVerified`) geçmek
zorundadır. Kanonik dil Türkçedir; İngilizce ve Arapça açıklayıcı çevirilerdir. Görüş
farkı bulunan konularda fark gizlenmez, açıkça belirtilir. Bkz.
[`CONTENT_POLICY.md`](CONTENT_POLICY.md).

## Bismillah Asistanı güvenlik modeli

- Asistan **deterministiktir** ve yanıtları **yalnızca yayınlanmış Learn bilgi tabanı**
  üzerinde **yerel, kaynağa dayalı erişim** ile üretir.
- **Hiçbir harici üretken yapay zekâ API'sini çağırmaz.**
- Doğrulanmış resmî bir fetva kaynağı yoksa **hüküm üretmez** ve **kişisel durumlar için
  fetva vermez** — kullanıcıyı ehil âlimlere yönlendirir.
- **Hassas sorgular** (kişisel durum / hüküm soruları) **kalıcı olarak tutulmaz**.
- Normal Asistan geçmişi **yerelde** saklanır, en fazla son **20** mesajla sınırlıdır.

Asistan bir yardımcıdır — Müftü, İmam ya da âlimlerin yerini tutan bir şey değildir.

## Gizlilik / yerelde çalışma yaklaşımı

- Onboarding seçimleri, okuma ilerlemesi ve yer imleri **cihazda** saklanır.
- Namaz vakitleri **cihazda hesaplanır**; konum yalnızca izin verildiğinde ve ön planda
  kullanılır.
- Ağ; **uzak kıraat sesi** ve **resmî kaynak bağlantılarını** sistem tarayıcısında açmak
  için kullanılır.
- Repoda Firebase **istemci** yapılandırmasının bulunması, kullanıcılar için bulut
  senkronizasyonunun aktif olduğu anlamına **gelmez** — bkz.
  [Bilinen sınırlamalar](#bilinen-sınırlamalar).

Ayrıntılar için [`docs/PRIVACY_MODEL.md`](docs/PRIVACY_MODEL.md).

## Mimari

**Feature-first** yapıya sahip Clean Architecture. Riverpod tek DI/state mekanizmasıdır;
GoRouter tek router'dır; Drift + SharedPreferences yerel kalıcılığı sağlar. UI, Firebase/AI
SDK'larını doğrudan import etmez. Bkz. [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Teknoloji yığını

| Konu | Seçim |
|---|---|
| Çatı | Flutter **3.44.6** / Dart **3.12.2** |
| State / DI | Riverpod |
| Yönlendirme | GoRouter |
| Yerel veritabanı | Drift |
| Anahtar-değer depolama | SharedPreferences |
| Ses | just_audio + audio_service |
| Backend (sınırlı) | Firebase (bu alfada yalnız istemci config) |

## Depo yapısı

```
.
├─ bismillah_app/        # Flutter uygulaması
│  ├─ lib/               # app/ · core/ · shared/ · features/
│  ├─ assets/            # Kur'an metni/meali, Learn bilgi tabanı
│  └─ test/              # birim + widget testleri
├─ functions/            # Firebase Cloud Functions (meal proxy'si)
├─ docs/                 # herkese açık dokümantasyon (aşağıya bkz.)
├─ LICENSE               # Mozilla Public License 2.0 (kaynak kod)
├─ THIRD_PARTY_NOTICES.md
├─ CONTENT_POLICY.md
├─ TRADEMARK.md
├─ SECURITY.md
└─ CONTRIBUTING.md
```

## Yerel kurulum

Ön koşullar: stable kanalda Flutter **3.44.6** (Dart **3.12.2**).

```bash
git clone https://github.com/oguzhanbilgi/bismillah-app.git
cd bismillah-app/bismillah_app
flutter pub get
```

## Geliştirme komutları

```bash
cd bismillah_app
flutter analyze
flutter test
flutter run                 # bağlı bir cihaz/emülatörde
```

İsteğe bağlı flavor seçimi: `flutter run --dart-define=FLAVOR=development`
(varsayılan: `development`; diğerleri: `staging`, `production`).

## Test

```bash
cd bismillah_app
flutter test
```

Paket; birim, widget ve mimari-sınır testlerinin yanı sıra üretici bütünlük
kontrollerini (114 sure / 6236 ayet; ayet→sayfa eşlemesi; arama indeksi) kapsar.

## Desteklenen platformlar

- **Android** — birincil hedef. Paket kimliği `com.bismillah.app`. Kur'an, çevrimdışı
  arama, kıraat sesi ve Android arka plan / medya-bildirimi / kilit ekranı oynatma
  **gerçek cihazda (Samsung Galaxy A36, Android 16)** doğrulanmıştır.
- **iOS** — proje dosyaları mevcuttur, ancak **iOS arka plan sesi fiziksel bir iOS
  cihazında doğrulanmamıştır** ve iOS derlemeleri macOS/Xcode gerektirir.

## Bilinen sınırlamalar

- Hiçbir uygulama mağazasında yayınlanmamıştır; **üretime hazır değildir**.
- **Firestore / bulut senkronizasyonu bu alfada aktif bir kullanıcı özelliği değildir** —
  senkronizasyon kuyruğu yerelde birikir ama bir push motoru yoktur.
- **iOS arka plan sesi** fiziksel donanımda **doğrulanmamıştır**.
- Premium / ödeme akışları **aktif değildir**; `subscription` / `premium` route'ları kodda
  vardır ancak UI'da **atıldır (dormant)**.
- Diyanet meal Cloud Function'ı aktif akışta **devre dışıdır**; aktif Türkçe meal kaynağı
  paketlenmiş çevrimdışı QuranEnc mealidir.

## Yol haritası

Bkz. [`docs/ROADMAP.md`](docs/ROADMAP.md). Tarih, gelir veya teslim sözü verilmez.

## İçerik kaynakları

Bismillah, üçüncü taraf dinî içeriği **kaynak-kod lisansı altında değil**, kendi
şartları altında paketler veya referanslar. Bkz. [`docs/CONTENT_SOURCES.md`](docs/CONTENT_SOURCES.md)
ve [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md). Kısaca: Kur'an metni **Tanzil
Projesi**'nden (CC BY 3.0), Türkçe meal **QuranEnc.com — Rowad Tercüme Merkezi**'nden,
kıraat sesi **MP3Quran.net**'ten akıtılır ve Learn içeriği **Diyanet** kaynaklarına dayanır.

## Katkı

Katkılar memnuniyetle karşılanır. Lütfen önce [`CONTRIBUTING.md`](CONTRIBUTING.md)'yi
okuyun — özellikle dinî içerik politikasını (yalnız kaynaklı içerik). **Kişisel dinî hüküm
(fetva) istemek için GitHub issue açmayın.**

## Güvenlik

Lütfen güvenlik açıklarını veya kimlik bilgilerini **herkese açık issue'lara yazmayın**.
Özel bildirim için bkz. [`SECURITY.md`](SECURITY.md).

## Lisans, marka ve sorumluluk reddi

- **Kaynak kod:** Mozilla Public License 2.0 — bkz. [`LICENSE`](LICENSE).
- **Paketlenmiş/akıtılan içerik** (Kur'an metni, meal, ses, Learn kaynakları) MPL
  kapsamında **değildir** — bkz. [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).
- **Marka** (ad, logo, ikonlar) kod lisansı ile **verilmez** — bkz.
  [`TRADEMARK.md`](TRADEMARK.md).
- **Sorumluluk reddi:** Bismillah **resmî bir Diyanet uygulaması değildir** ve **Diyanet
  tarafından onaylanmamıştır**. Ehil âlimlerin yerini tutmaz.
