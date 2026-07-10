# Bismillah — İş Modeli Hizalama Changelog'u

| | |
|---|---|
| **Doküman** | 09_BUSINESS_ALIGNMENT_CHANGELOG.md |
| **Tarih** | 2026-07-08 |
| **Görev** | TASK 009 — Business model change request'lerinin (CR-01…CR-08) mevcut dokümanlara uygulanması |
| **Kaynak** | [08_BUSINESS_MODEL_AND_GROWTH_STRATEGY.md](08_BUSINESS_MODEL_AND_GROWTH_STRATEGY.md) §6, §19 |

---

## 1. Neden bu değişiklik yapıldı?

08 numaralı iş modeli dokümanı iki bağlayıcı karar getirdi: (1) **Bismillah+ public launch günü satışta olacak** — premium artık V2'ye ertelenmiş değil; (2) **launch sonrası aylık 1.500 TL kontrollü paid growth test bütçesi** var. Önceki dokümanlar (01–07) "premium V2'de" varsayımıyla yazılmıştı; bu görev tüm doküman setindeki çelişkileri giderdi.

## 2. Ana kararlar

- Bismillah+ **launch günü satışta**; MVP kapsamına RevenueCat altyapısı, paywall ekranı, abonelik yönetimi ve server-side abonelik eventleri eklendi.
- **Temel ibadet araçları ücretsiz kalır** — hiçbir mevcut ücretsiz özellik geriye dönük kilitlenmez.
- Premium yalnız **derinlik ve kişiselleştirme** sunar (gelişmiş AI koçu, sınırsız asistan, derin programlar, ileri istatistik).
- **10.000 TL/ay brüt gelir hedefi** korunur (90 gün; ana senaryo: 200 ödeyen × ~50 TL).
- **1.500 TL/ay paid growth test bütçesi** eklendi; **organiğin yerine geçmez**, yalnız kontrollü hızlandırıcıdır.
- Paywall; onboarding'de, ilk 14 günde otomatik olarak, recovery/kaçırılmış ibadet bağlamında, kutsal içerik ekranlarında ve âlim-yönlendirme cevabı altında **gösterilmez**.
- **Etik monetizasyon ve etik reklam kuralları** tüm ilgili dokümanlara yansıtıldı.

## 3. Güncellenen dosyalar

01_PRODUCT_PRD.md · 02_BRAND_GUIDELINES.md · 03_DESIGN_SYSTEM.md · 04_ONBOARDING_FLOW.md · 05_INFORMATION_ARCHITECTURE.md · 06_FLUTTER_ARCHITECTURE.md · 07_FIREBASE_ARCHITECTURE.md · 08_BUSINESS_MODEL_AND_GROWTH_STRATEGY.md

## 4. Dosya bazlı değişiklik özeti

| Dosya | CR | Yapılan değişiklikler |
|---|---|---|
| **01_PRODUCT_PRD.md** | CR-01 | §15'e hedef #9 (90 günde ≥10.000 TL brüt MRR + paid budget notu); §16'ya MRR/ödeyen-kullanıcı metrikleri; §27.19 yeni modül "Premium / Bismillah+ Launch Monetization (P0)"; §28 premium satırı "kapsam İÇİNDE" olarak revize + MVP/V1.x/V2 katmanlaması; §29 pillar-1 "premium derinleştirme"; §33 başlık "launch günü satışta" + launch paketi + fiyat/erken-destekçi detayı + dönüşüm-yasağı anları genişletildi; §34'e ilke #10 (core accessible, value-after-use); §45.7 "monetization live and healthy" olarak güncellendi |
| **02_BRAND_GUIDELINES.md** | CR-02, CR-08 | §26'ya launch kapsam notu + onaylı davet dili seti ("Yolculuğunu derinleştirmek istersen…" vb.) + yasaklı dile 2 ekleme ("Premium olmazsa eksik kalırsın", günah/ceza/korku dili) + yeni "Paid growth / reklam tonu" bloğu (6 kural); §24 tablosuna IAP şeffaflık satırı |
| **03_DESIGN_SYSTEM.md** | CR-03 | Yeni §12.1: 7 premium bileşen (`PremiumPaywallScreen`, `PremiumFeatureCard`, `PricingPlanCard`, `TrialInfoRow`, `RestorePurchaseButton`, `SubscriptionManagementRow`, `BismillahPlusBadge`) amaç/anatomi/durum/erişilebilirlik/etik kısıt kolonlarıyla + 7 bağlayıcı paywall tasarım kuralı + paid growth kreatif görsel kuralları |
| **04_ONBOARDING_FLOW.md** | CR-04 | Minimal: §11 auth davetine "hesap zorunlu değil / satın alma geri yükleme hesapla kolaylaşır" notu + yeni "Monetizasyon sınırı" bloğu (onboarding'de paywall/fiyat/satış mesajı yok; ilk 14 gün otomatik paywall yok) |
| **05_INFORMATION_ARCHITECTURE.md** | CR-05 | §6 route tablosuna `/premium` (full-screen modal) ve `/settings/subscription` (push); §10'a paywall yerleşim kuralları; §11'e 4 yeni akış (paywall görüntüleme, deneme başlatma, restore, abonelik yönetimi/iptal); §12'ye 2 deep link köprüsü; §15'e Abonelik ayar bölümü; §23 MVP kapsamına premium katmanı taşındı, V2 satırı "premium derinleştirme" oldu |
| **06_FLUTTER_ARCHITECTURE.md** | CR-06 | §6 klasör ağacına `features/premium/`; §11'e `premiumStateProvider` + `purchaseControllerProvider`; §12'ye premium route kuralları; §14'e offline entitlement cache kuralı; §21'e 7 abonelik eventi (PII'siz, gelir eventleri sunucudan); §26 feature tablosuna premium satırı (`PremiumEntitlement`, `SubscriptionPlan`, use case'ler, `RevenueCatDataSource`); §33 RevenueCat paketi V2→MVP; §34 flavor satırı V2→MVP; §36 premium satırı "MVP'ye alındı" |
| **07_FIREBASE_ARCHITECTURE.md** | CR-07 | §16 `entitlementSync` V2→MVP (webhook alma + entitlement yazma + server-side analytics, idempotent); §9'a 5 premium meta alanı (`plusStatus`, `plusUntil`, `plusSource`, `revenueCatAppUserId`, `subscriptionUpdatedAt` — yalnız server yazar) + "ödeme kartı verisi asla Firebase'de tutulmaz" gizlilik notu; §14'e kural #12 (entitlement alanları istemci-yazımına kapalı); §19 abonelik eventleri V2→MVP; §29'a RevenueCat webhook maliyet satırı |
| **08_BUSINESS_MODEL_AND_GROWTH_STRATEGY.md** | Temizlik | Dosya sonundaki bağımsız CR-08 bloğu kaldırıldı ve §19 tablosuna CR-08 satırı olarak düzenli eklendi; §19'a "CR'lar uygulandı" durum notu; §26 kabul kriterlerine paid growth maddesi (#15); kapanış notu güncellendi; versiyon 1.1 korundu |

## 5. Kalan açık konu var mı?

- **Fiyat noktaları varsayımdır** (49,99 TL aylık / 399,99 TL yıllık / 299,99 TL erken destekçi) — kapalı beta anketi ve launch verisiyle kalibre edilecek; kesinleşince 01 §33 ve 08 §7 birlikte güncellenmeli.
- **AI ücretsiz mesaj limiti (10/gün) varsayımdır** — beta verisiyle ayarlanacak.
- Paywall ekranının **TR/EN/AR nihai metinleri** implementasyon öncesi Marka §29 örnek setine eklenebilir (CR-02'nin opsiyonel kalan parçası).
- CLAUDE.md'ye dokunulmadı — Constitution zaten RevenueCat'i stack'te tanımlıyor; monetizasyon zamanlaması Constitution konusu değil.

## 6. Sonuç

Doküman seti artık tek sesli: **Bismillah+ launch günü satışta, temel ibadet araçları sonsuza dek ücretsiz, paywall yalnız doğal anlarda, reklam yalnız merhametli tonda ve 1.500 TL/ay kontrollü bütçeyle.** "Premium V2'de" çelişkisi tüm dokümanlardan temizlendi; V2'nin premium rolü artık "derinleştirme"dir (aile planı, Ramazan+, segmentasyon). Uygulama geliştirmesi bu hizalanmış set üzerinden başlayabilir.
