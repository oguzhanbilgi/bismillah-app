# Bismillah — İş Modeli ve Büyüme Stratejisi

| | |
|---|---|
| **Doküman** | 08_BUSINESS_MODEL_AND_GROWTH_STRATEGY.md |
| **Versiyon** | 1.1 — aylık 1.500 TL paid growth test bütçesi eklendi (TASK 008B) |
| **Tarih** | 2026-07-08 |
| **Durum** | Onaylı temel — monetizasyon ve büyüme çalışması bu dokümana uyar |
| **Bağlı dokümanlar** | [CLAUDE.md](../CLAUDE.md) · [01_PRODUCT_PRD.md](01_PRODUCT_PRD.md) · [02_BRAND_GUIDELINES.md](02_BRAND_GUIDELINES.md) · [05_INFORMATION_ARCHITECTURE.md](05_INFORMATION_ARCHITECTURE.md) · [06_FLUTTER_ARCHITECTURE.md](06_FLUTTER_ARCHITECTURE.md) · [07_FIREBASE_ARCHITECTURE.md](07_FIREBASE_ARCHITECTURE.md) |

> ⚠️ **Kapsam değişikliği uyarısı:** Bu doküman, önceki dokümanlardaki "premium V2'de gelir" kararını **"Bismillah+ public launch'ta gelir"** olarak revize eder. Gerekçe §2 ve §6'da; önceki dokümanlara gereken değişiklik talepleri §19'dadır. Bu görevde önceki dosyalar DÜZENLENMEMİŞTİR — yalnız change request listelenmiştir.

---

## İçindekiler

1. [İş Stratejisi Genel Bakış](#1-i̇ş-stratejisi-genel-bakış)
2. [Gelir Hedefi](#2-gelir-hedefi)
3. [Free vs Premium Felsefesi](#3-free-vs-premium-felsefesi)
4. [Ücretsiz Plan Kapsamı](#4-ücretsiz-plan-kapsamı)
5. [Bismillah+ Premium Kapsamı](#5-bismillah-premium-kapsamı)
6. [MVP Monetizasyon Kapsamı](#6-mvp-monetizasyon-kapsamı)
7. [Fiyatlandırma Stratejisi Varsayımları](#7-fiyatlandırma-stratejisi-varsayımları)
8. [Dönüşüm (Conversion) Stratejisi](#8-dönüşüm-conversion-stratejisi)
9. [Paywall Stratejisi](#9-paywall-stratejisi)
10. [RevenueCat Stratejisi](#10-revenuecat-stratejisi)
11. [App Store / Google Play Monetizasyon Konumlandırması](#11-app-store--google-play-monetizasyon-konumlandırması)
12. [Launch Stratejisi](#12-launch-stratejisi)
13. [90 Günlük Gelir Planı](#13-90-günlük-gelir-planı)
14. [Büyüme Kanalları](#14-büyüme-kanalları)
15. [İçerik Pazarlama Stratejisi](#15-i̇çerik-pazarlama-stratejisi)
16. [Retention Stratejisi](#16-retention-stratejisi)
17. [Monetizasyon Metrikleri](#17-monetizasyon-metrikleri)
18. [Etik Monetizasyon Kuralları](#18-etik-monetizasyon-kuralları)
19. [Gerekli Ürün Değişiklikleri (Change Requests)](#19-gerekli-ürün-değişiklikleri-change-requests)
20. [Premium Özellik Önceliklendirmesi](#20-premium-özellik-önceliklendirmesi)
21. [AI Maliyeti ve Monetizasyon Dengesi](#21-ai-maliyeti-ve-monetizasyon-dengesi)
22. [Founder-Led Growth Planı](#22-founder-led-growth-planı)
23. [Finansal Model Varsayımları](#23-finansal-model-varsayımları)
24. [Riskler ve Azaltımlar](#24-riskler-ve-azaltımlar)
25. [Business QA Kontrol Listesi](#25-business-qa-kontrol-listesi)
26. [Kabul Kriterleri](#26-kabul-kriterleri)
27. [Nihai İş Yönü](#27-nihai-i̇ş-yönü)

---

## 1. İş Stratejisi Genel Bakış

**Bismillah ücretsiz bir hobi uygulaması değildir.** Sürdürülebilir, reklamsız, gizliliğe saygılı bir İslami yaşam uygulaması ancak abonelik geliriyle yaşayabilir — reklam modeli kutsal içerik yanında ahlaken kapalı (PRD §34), veri satışı kalıcı yasak (PRD §35). Gelir; sunucu, AI ve içerik doğrulama maliyetlerini karşılamanın ötesinde, ürünün yıllarca geliştirilebilmesinin tek dürüst yoludur.

**Model:** Freemium abonelik — **Bismillah+**. Ücretsiz katman gerçek ve eksiksiz bir ibadet arkadaşıdır (§4); Bismillah+ derinlik satar: gelişmiş AI koçluğu, sınırsız asistan, ileri istatistik ve planlama (§5). Değer önce verilir, ödeme daveti sonra gelir — "auth-after-value" ilkesinin ticari ikizi: **"payment-after-value."**

**Strateji üç bacaklıdır:** (1) **Ürün** — dönüşümün motoru pazarlama değil, 30. gün deneyimini yaşamış kullanıcının derinleşme isteğidir; (2) **Founder-led organik büyüme** — kısa video + topluluk + ASO ana motor olarak kalır (§14, §22); (3) **Etik çizgi** — §18 kuralları gelir hedefinden üstündür; çizgiyi bozan hiçbir taktik, hedefi tuttursa bile kullanılmaz.

**Paid growth ek bacağı (v1.1):** Launch sonrası aylık **1.500 TL kontrollü reklam test bütçesi** ayrılmıştır. Bu bütçe organik/founder-led stratejinin YERİNE GEÇMEZ; onu destekleyen bir öğrenme ve hızlandırma aracıdır. Üç kural: (a) amaç ilk aşamada satış değil **öğrenmedir** (hangi mesaj, hangi kitle, hangi kalite); (b) reklam yalnız **organikte zaten çalışan mesajları büyütmek** için kullanılır — organikte tutmayan kreatif parayla itilmez; (c) ana büyüme her zaman ürün kalitesi + retention + organik içerik + topluluk + ASO'dur; paid, kontrollü hızlandırıcıdır.

---

## 2. Gelir Hedefi

> **Bismillah, public launch sonrası ilk 3 ay içinde aylık en az 10.000 TL gelir üretmeye başlamayı hedefler.**

**Hedefin matematiği — üç eşdeğer senaryo:**

| Senaryo | Ödeyen kullanıcı | Kullanıcı başına aylık | Aylık brüt gelir |
|---|---|---|---|
| A | 100 | 100 TL | 10.000 TL |
| B | **200** | **50 TL** | **10.000 TL** ← ana senaryo |
| C | 400 | 25 TL | 10.000 TL |

**Ana senaryo B'dir:** Türkiye pazarında ~50 TL/ay algılanabilir ve savunulabilir bir fiyat noktasıdır (§7); 200 ödeyen kullanıcı, solo-founder organik büyümeyle 90 günde ulaşılabilir ama iddialı bir hedeftir. **İlk kilometre taşı: 100–200 ödeme yapan kullanıcı.** 100 ödeyen kullanıcı (≈5.000 TL/ay) "model çalışıyor" kanıtıdır; 200 ödeyen kullanıcı hedefin kendisidir.

**Brüt / net ayrımı (önemli):**

- **10.000 TL hedefi BRÜT gelir hedefidir** (kullanıcıların ödediği toplam).
- **Store komisyonu:** Apple/Google, ilk yıl / küçük işletme programlarında ~%15 keser *(varsayım: Small Business Program / 15% service fee koşulları sağlanır)* → 10.000 TL brüt ≈ **8.500 TL store-sonrası**.
- **AI maliyeti:** ödeyen kullanıcı ağırlıklı kullanım varsayımıyla aylık ~500–1.500 TL bandı (§21) *(varsayım: kullanıcı başına AI maliyeti kontrollü tutulursa)*.
- **Firebase maliyeti:** Isar-first mimari sayesinde MVP ölçeğinde düşük — aylık ~0–500 TL bandı (07 §29) *(varsayım: 25–50K MAU altında büyük ölçüde ücretsiz katman)*.
- **Reklam gideri (v1.1):** aylık **1.500 TL** paid growth test bütçesi (§14 dağılımı) — sabit gider olarak modele dahildir.
- **Sonuç:** hedef tutarsa **net ~5.000–6.500 TL/ay** — solo founder için anlamlı ilk gelir + tüm maliyetlerin (reklam dahil) karşılanması.

Bu hedef bir tavan değil tabandır: Ramazan 2027 (Şubat–Mart) çarpanı §12–13'te ayrıca planlanır.

---

## 3. Free vs Premium Felsefesi

Çizgi tek cümledir (Marka §26 ile birebir):

> **Ücretsiz = eksiksiz bir ibadet arkadaşı. Bismillah+ = aynı yolda daha donanımlı yürüyüş.**

- Ücretsiz kullanıcı **ömür boyu** namazını takip eder, vaktini görür, zikrini çeker, duasını bulur, planını yaşar. Bu, pazarlık konusu olmayan ürün sözüdür (PRD §33, Marka §26).
- Premium **ibadete erişim** satmaz; **derinlik** satar: daha akıllı koçluk, daha zengin analiz, daha uzun vadeli planlama, daha fazla AI sohbeti.
- "Free kullanıcı, dönüşmemiş müşteri değil; ağırlanan misafirdir." Ücretsiz deneyim hiçbir yerde "kısıtlı sürüm" gibi anılamaz; kilit ikonu yasaktır (Marka §26).
- Dönüşümün doğal anı, kullanıcının **kendi derinleşme isteği**dir — 30 gün istikrar yaşamış kullanıcının "daha fazlasını istiyorum" dediği an. Paywall bu anlarda *görünür olur*, hiçbir anda *dayatılmaz* (§9).

---

## 4. Ücretsiz Plan Kapsamı

Aşağıdaki set **kalıcı olarak ücretsizdir** (değiştirilmesi Constitution ihlalidir):

| Alan | Ücretsiz kapsam |
|---|---|
| Onboarding + kişisel plan | Tam 16 soruluk onboarding, kişiselleştirilmiş günlük plan, 30 günlük plan çatısı |
| Namaz | Vakitler (tüm yöntemler), kıble, 5 vakit + kaza takibi, hatırlatmalar — TAM |
| Kur'an | Günlük hedef, okuma kaydı, yer imi, günlük ayet, haftalık tutarlılık görünümü |
| Zikir | Tüm hazır setler (sabah/akşam/namaz sonrası/uyku), tam sayaç deneyimi, özel zikir |
| Dua | Kütüphanenin TAMAMI (kategoriler, arama, favoriler) — dua içeriği asla bölünmez |
| Öğren | Temeller yolu + günlük hadis/yansıma |
| AI Asistan | Günlük mesaj hakkı: **10 mesaj/gün** *(varsayım: beta verisiyle ayarlanır; "cömert ve gerçekten faydalı" kalır)* |
| Oyunlaştırma | Seri (onarım DAHİL — onarım asla satılmaz), XP, seviyeler, temel rozetler |
| İstatistik | Haftalık özet + temel aylık görünüm |
| Platform | 3 dil, offline çekirdek, reklamsızlık — sonsuza dek |

---

## 5. Bismillah+ Premium Kapsamı

| Özellik | Ne verir | Neden adil premium |
|---|---|---|
| **Gelişmiş AI koçu** | Haftalık değerlendirme sohbetleri, plan müzakeresi, desen içgörüleri ("hafta sonları düşüyorsun — hafta sonu planı kuralım mı?") | Sürekli compute maliyeti + en derin kişiselleştirme değeri |
| **Sınırsız AI sohbeti** | Günlük limit kalkar | Doğrudan maliyet kalemi; ücretsiz hak zaten faydalı |
| **Kişisel 30 günlük derin programlar** | Hedefe özel yapılandırılmış programlar ("Fajr'ı kökleştir", "Kur'an'la 30 gün") | Editoryal + AI bileşimi özel içerik |
| **İleri istatistik ve aylık rapor** | Trendler, vakit dakiklik desenleri, aylık içgörü raporu | Ücretsizde çekirdek istatistik kalır; bu derinlik katmanı |
| **Hatim planlayıcı** (V1.x'te eklenir) | Tarihe göre hatim planı + geride kalınca merhametli yeniden planlama | Uzun vadeli planlama aracı |
| **Premium temalar** | Hat-esinli özel tema setleri (+ koyu tema herkese ücretsiz gelir — koyu tema premium DEĞİLDİR *karar*) | Saf estetik, ibadet işlevi yok |
| **Aile planı** (V2) | 6 üyeye kadar | Çoklu hesap değeri |
| **Ramazan+ katmanı** (V2) | İleri Ramazan analizi/koçluğu — **çekirdek Ramazan modu herkese ücretsiz** | PRD §33 kuralı korunur |

**Launch paketi (ilk 90 gün):** gelişmiş AI koçu + sınırsız sohbet + derin programlar + ileri istatistik. Hatim planlayıcı ve temalar V1.x'te eklenir (§20).

---

## 6. MVP Monetizasyon Kapsamı

**Karar (önceki dokümanları revize eder):** PRD §33 "premium V2'de" demişti; iş hedefi bunu öne çeker. Yeni kapsam:

- **Kapalı beta (launch öncesi):** paywall YOK; RevenueCat entitlement iskeleti + paywall ekranı feature-flag arkasında test edilir.
- **Public launch:** **Bismillah+ launch günü satışta.** 7 gün ücretsiz deneme, aylık + yıllık paketler, RevenueCat ile.
- **Gerekçe:** (1) 90 günde gelir hedefi V2'yi bekleyemez; (2) "değer önce" ilkesi korunur — paywall yalnız doğal anlarda (§9); (3) launch'ta premium'un varlığı, "bu ürün ciddi ve sürdürülebilir" sinyalidir; (4) erken destekçi fiyatı erken geliri VE sadakati birlikte üretir.
- **Değişmeyenler:** ücretsiz kapsam (§4) launch'ta tam; hiçbir mevcut MVP özelliği geriye dönük kilitlenmez ("free'den premium'a taşıma" YASAK — bir kez ücretsiz verilen, ücretsiz kalır).
- Önceki dokümanlara yansıması: §19 change request listesi.

---

## 7. Fiyatlandırma Stratejisi Varsayımları

*(Tümü varsayımdır; kapalı beta anketi + launch verisiyle kalibre edilir. Fiyatlar TL; store bölgesel fiyatlandırması ayrıca eşlenir.)*

| Paket | Fiyat (varsayım) | Not |
|---|---|---|
| **Bismillah+ Aylık** | **49,99 TL/ay** | Ana senaryo B'nin ~50 TL noktası; "bir kahve" çerçevesi — ama bu çerçeve pazarlamada dini kıyasla KULLANILMAZ ("çayını bağışla, sevap al" tarzı dil yasak) |
| **Bismillah+ Yıllık** | **399,99 TL/yıl** (≈33,3 TL/ay, ~%33 indirim) | Nakit akışı + taahhüt; launch'ta öne çıkan paket |
| **Erken Destekçi (ilk 90 gün)** | Yıllık **299,99 TL** — "kurucu fiyatı, senin için hep bu kalır" | Fiyat koruması sözü verilir ve tutulur; erken topluluk inşası |
| **Deneme** | 7 gün ücretsiz, açık iletişim, bitmeden hatırlatma bildirimi | "İptal etmeyi unutursun" modeliyle gelir YAZILMAZ (§18) |
| **Lifetime** | YOK *(karar)* | Sürekli AI maliyeti olan üründe lifetime, gelecekteki kullanıcı deneyimini ipotek eder |
| **Bölgesel** | TR fiyatı yerli; EN/AR pazarlarında ~$4,99/ay, ~$39,99/yıl *(varsayım)* | Satın alma gücü duyarlı (PRD §34) |

**Fiyat İLKELERİ:** indirim tiyatrosu yok (sahte "%80 indirim!" çarpıları yasak); fiyat değişikliği mevcut abonelere uygulanmaz (grandfathering); iptal iki dokunuş ve görünür.

---

## 8. Dönüşüm (Conversion) Stratejisi

Dönüşüm hunisi: **İndirme → Onboarding (%70) → D7 aktif (%30) → D30 aktif (%20) → değer anı → deneme → ödeme.**

**Free → Premium doğal dönüşüm noktaları (yalnız bunlar):**

| # | An | Neden doğal | Mesaj çerçevesi |
|---|---|---|---|
| 1 | **30. gün aylık özet töreni** | Kullanıcı kendi büyümesini GÖRDÜ; derinleşme isteği zirvede | "İlk 30 günün böyleydi. Sonraki 30'u birlikte derinleştirelim mi?" |
| 2 | **AI günlük hakkın dolduğu an** (etkileşim ortasında DEĞİL, gün sonunda) | Değeri yaşarken sınıra dokundu | "Bugünlük sohbet hakkın doldu — yarın devam ederiz. Sınırsız istersen Bismillah+ var." |
| 3 | **İleri istatistik kartına dokunuş** (Profil'de "daha derin gör" satırı) | Kullanıcı kendisi merak etti | Önizleme + davet |
| 4 | **Haftalık özette içgörü teaser'ı** | "Bir desen fark ettik" — tek cümlelik gerçek içgörü ücretsiz verilir, derinliği premium | Dürüst teaser (yalan içgörü yasak) |
| 5 | **Hedef büyütme anı** (kullanıcı planını büyütmek istediğinde) | Derin program ihtiyacı doğdu | "30 günlük yapılandırılmış program ister misin?" |
| 6 | **Ayarlar > Bismillah+** satırı | Kullanıcı kendi aradı | Sade bilgi sayfası |

**Dönüşüm hedefleri** *(varsayım)*: paywall görüntüleme→deneme %8–12; deneme→ödeme ≥%40 (PRD §16); MAU→ödeyen %3–5 (olgunlaşınca; ilk 90 günde %2–3 gerçekçi).

---

## 9. Paywall Stratejisi

**Paywall'ın gösterildiği yerler (yalnız §8 anları):** 30. gün özeti sonrası tek sayfa; AI limit gün-sonu bilgisi; Profil "daha derin gör"; haftalık özet teaser dokunuşu; Ayarlar satırı.

**Paywall'ın ASLA gösterilmediği yerler (bağlayıcı):**

- ❌ Kaçırılan ibadet sonrası / seri bozulduğunda / **recovery modundayken** (duygusal kırılganlık anları — Marka §26, PRD §34)
- ❌ Onboarding sırasında ve ilk 14 gün içinde otomatik olarak (menüden kendisi bakabilir)
- ❌ Namaz/zikir/Kur'an akışlarının ORTASINDA (ibadet kesintiye uğratılmaz)
- ❌ Kutsal içerik ekranlarında (ayet/hadis/dua yüzeyinde satış yok)
- ❌ Gece 00.00–06.00 bildirimleriyle (satış bildirimi zaten yok; premium bildirimi hiç yok)
- ❌ Asistanın âlim-yönlendirme cevabının içinde/altında

**Paywall tasarım kuralları:** tek ekran, kapatma (✕) büyük ve daima görünür; "Daha sonra" utandırmaz; fiyat + deneme süresi + iptal kolaylığı AÇIK yazılır; koyu orman + zarif altın (DS/Marka premium dili); kilit ikonu YOK; frekans tavanı: aynı kullanıcıya otomatik paywall ≤1/hafta; kapatan kullanıcıya 7 gün otomatik gösterim yok.

---

## 10. RevenueCat Stratejisi

- **Entitlement modeli:** tek entitlement — **`plus`**; tüm premium özellikler bu tek anahtara bakar (06 §36 `PremiumGate` sözleşmesi). Özellik-başına entitlement karmaşası YOK.
- **Offerings:** `default` offering (aylık + yıllık) ve `founder` offering (erken destekçi yıllık) — Remote Config/RC dashboard'la seçilir; A/B testine hazır ama launch'ta tek varyant (§18: fiyat manipülasyon deneyleri yasak; test edilebilecek olan sunum sırası/metin netliğidir).
- **Mimari yerleşim:** `purchases_flutter` infrastructure katmanında; `PremiumRepository` + `premiumStateProvider` (06 mimarisine uygun); UI yalnız `isPlus` boolean'ı görür.
- **Anonim satın alma:** RevenueCat anonim app-user-id ile çalışır; Firebase UID'ye alias'lanır — **satın alma için hesap zorunlu DEĞİLDİR** *(karar: auth-duvarsızlık ilkesi ödemede de korunur; cihaz değişimi senaryosu için "satın almayı geri yükle" + hesap bağlama önerilir ama şart koşulmaz)*.
- **Webhook:** `entitlementSync` function (07 §16) RevenueCat webhook'unu dinler → `users/{uid}` premium meta; abonelik analytics eventleri SUNUCUDAN atılır (çifte sayım yok, 07 §19).
- **Sandbox disiplini:** dev/staging RevenueCat sandbox; prod anahtarları Secret Manager'da (07 §35).

---

## 11. App Store / Google Play Monetizasyon Konumlandırması

- Store listesi ürünün KENDİSİNİ anlatır; premium, uzun açıklamanın güven bloğunda tek dürüst paragraftır: "Bismillah'ın çekirdeği ücretsizdir ve hep öyle kalacak. Bismillah+ isteyenler için koçluk ve derin analiz ekler."
- **"Ücretsiz" vaadi dürüst:** store'da "free" kategorisinde IAP açıkça işaretli; ekran görüntülerinde premium özellikler "Bismillah+" rozetiyle şeffaf gösterilir (gizli sürpriz paywall algısı ASO'yu ve güveni öldürür).
- Fiyat/promosyon metinlerinde dini vaat yasağı aynen geçerli (Marka §24: "neyi asla iddia etmeyiz" listesi).
- İlk yorum yönetimi: erken destekçilerden dürüst değerlendirme ricası (ürün içi nazik istem, D30+ mutlu anlarda — asla ödeme/ödül karşılığı).
- Yıllık paket store'da varsayılan seçili sunulur; karşılaştırma tablosu net ("aylık 49,99 · yıllık 399,99 ≈ %33 daha uygun").

---

## 12. Launch Stratejisi

**Sıralı rampa** *(tarihler varsayımsal — geliştirme tamamlanma hızına bağlı)*:

1. **Kapalı beta (4–6 hafta):** 100–300 kullanıcı (çevre + TR İslami topluluk gönüllüleri + 3 dilde test kullanıcıları); hedef: D7 ≥%30 kanıtı, plan tamamlama ≥%50, paywall'ın feature-flag testi, fiyat anketi.
2. **Soft launch (2 hafta):** TR App Store/Play'de sessiz yayın; ASO temelleri; ilk organik yorumlar; Bismillah+ AÇIK (erken destekçi fiyatıyla); huni metriklerinin gerçek veriyle kalibrasyonu.
3. **Public launch (Gün 0):** üç kanalda eşzamanlı içerik patlaması (§14); Product Hunt benzeri platformlar İngilizce için *(varsayım: ikincil)*; launch hikâyesi: "Müslümanlar için Headspace kalitesinde, reklamsız, suçlamayan bir yol arkadaşı — ve neden ücretsiz çekirdek + dürüst premium modelini seçtik" (şeffaflık pazarlaması).
4. **Ramazan penceresi:** Ramazan 2027 (~Şubat ortası) kategorinin zirvesidir. Launch takvimi ne olursa olsun, **Ramazan'dan ≥6 hafta önce** uygulama store'da oturmuş ve yorum toplamış olmalıdır; Ramazan çekirdek modu ÜCRETSİZ gelir (PRD kuralı), dönüşüm Ramazan sonrası "kazanımları koru" anında beklenir.

---

## 13. 90 Günlük Gelir Planı

**Hedef eğrisi** *(varsayım; ana senaryo B — 200 ödeyen × ~50 TL ort.)*:

| Dönem | İndirme (kümülatif) | MAU | Ödeyen (kümülatif) | Aylık brüt |
|---|---|---|---|---|
| Gün 30 | ~5.000 | ~1.500 | 30–50 | ~1.500–2.500 TL |
| Gün 60 | ~12.000 | ~3.500 | 90–130 | ~4.500–6.500 TL |
| Gün 90 | ~25.000 | ~6.000 | **180–220** | **~9.000–11.000 TL** ✅ |

**Gün 1–30 — "Temel + ilk 50 ödeyen":** launch içerik dalgası (günde 1–2 kısa video, §22); ASO ilk iterasyon; kapalı beta kullanıcılarının erken-destekçi dönüşümü (ilk 20–30 ödeyen buradan); D1/D7 huni sızıntılarına ürün yaması; haftalık metrik incelemesi. Çıkış kriteri: ≥30 ödeyen, deneme→ödeme ≥%35.
*Paid growth (Gün 1–30):* bütçenin küçük kısmı (ilk 2 hafta ~500–750 TL) saf TEST için: **3–5 kreatif** düşük bütçeli denemeyle yayına alınır; ölçüt install SAYISI DEĞİL, **paid install → onboarding completion oranı ve paid D7 retention KALİTESİ**dir. Kalitesiz install getiren kreatif/kitle anında durdurulur.

**Gün 31–60 — "Kanal keskinleştirme":** en iyi performans gösteren 2 kanala konsantrasyon (veriye göre); topluluk ortaklıkları (5–10 mikro işbirliği: İslami içerik hesapları, öğrenci kulüpleri); 30-gün-özeti dönüşüm anının optimizasyonu (ilk gerçek kohort 30. gününe ulaşıyor); yıllık paket vurgusu. Çıkış kriteri: ≥100 ödeyen, MRR ≥5.000 TL.
*Paid growth (Gün 31–60):* ilk ayın verisiyle **en iyi 1–2 kreatif büyütülür** (bütçenin ~%70'i onlara); store listing/ekran görüntüsü varyant testi (install-conversion); **paid CAC ve paid deneme dönüşümü** haftalık izlenir — CAC eşiği (§17) aşılırsa kampanya durur.

**Gün 61–90 — "Ölçek + tutundurma":** çalışan içerik formatının seri üretimi; ASO ikinci iterasyon (gerçek arama verisiyle); winback: deneme bırakanlara TEK nazik e-posta/bildirim *(izinli)*; hatim planlayıcı (V1.x premium ek değeri) yayını; churn analizi ve ilk iptal-nedeni anketi. Çıkış kriteri: **≥180 ödeyen, MRR ≥9.000 TL, aylık churn ≤%10.**
*Paid growth (Gün 61–90):* karar noktası — çalışan bir paid kanal KANITLANDIYSA (CAC eşiği içinde + paid D7 ≥ organiğin %80'i) bütçe o kanala yoğunlaştırılır; kanıtlanmadıysa **bütçe azaltılır/durdurulur** ve kaynak (para + founder zamanı) organik/topluluk kanallarına geri döner. Batık maliyet inadı yok: 90. günde paid'in tek görevi "ölçeklenebilir mi?" sorusuna veriyle cevap vermiş olmaktır.

Hedef tutmazsa (Gün 75 kontrol noktası: <120 ödeyen): fiyat noktası anketi, paywall metin/yerleşim revizyonu (etik çizgi İÇİNDE), kanal pivotu — panik indirimi ve dark pattern ASLA (§18).

---

## 14. Büyüme Kanalları

| Kanal | Strateji | Beklenti |
|---|---|---|
| **TikTok** | Günlük 15–45sn: "namaza dönüş" hikâyeleri, uygulama içi sakin ekran kayıtları, "5 dakikalık sünnet rutini" formatları; TR öncelik | Ana keşif motoru — viral tavanı yüksek |
| **Instagram Reels** | TikTok içeriğinin uyarlaması + estetik ayet kartları (uygulama şablonuyla, kaynaklı) + hikâyelerde günlük kullanım | TR/diaspora kadın kitlesinde güçlü |
| **YouTube Shorts** | Aynı video havuzu + ayda 1–2 uzun video ("Bismillah'ı neden yaptım", "İslami uygulamalar neden kötü ve biz ne yaptık") | Güven derinliği + arama kalıcılığı |
| **ASO (App Store)** | Başlık/altbaşlık anahtar kelimeleri (Marka §24); ekran görüntüsü A/B; yorum hızı yönetimi | Kalıcı, bileşik büyüme — en yüksek ROI |
| **Google Play keywords** | TR: "namaz vakitleri, zikirmatik, kuran, dua"; uzun kuyruk: "namaz takip", "ibadet alışkanlığı" | Yüksek niyetli trafik |
| **İslami topluluklar** | Cami gençlik kolları, üniversite İslami toplulukları, Telegram/Discord grupları — ürün tanıtımı değil DEĞER paylaşımı (ücretsiz içerik kartları, Ramazan planı PDF'i) + nazik uygulama dipnotu | Yavaş ama en sadık kohort |
| **Öğrenci grupları** | Kampüs elçi mini-programı (gönüllü, 5–10 üniversite); öğrenciye erken-destekçi fiyatı | Genç, viral, geri bildirim zengini |
| **Ramazan içerikleri** | Ramazan'a 6 hafta kala içerik serisi ("Ramazan'a hazırlık planı"); Ramazan boyunca günlük mikro içerik | Yıllık en büyük dalga — §12 |

**Kural:** hiçbir kanalda korku/suçluluk içeriği ("namaz kılmayanın sonu…" tarzı viral formatlar) — marka intiharıdır ve yasaktır (Marka §25).

### 14.1 Paid Growth Kanalları (aylık 1.500 TL test bütçesi)

*(v1.1 eklemesi — organik kanalların yerine değil, yanına.)*

| Paid kanal | Neden denenebilir | 1.500 TL'deki rolü | Ölçüm metriği | Etik reklam sınırı |
|---|---|---|---|---|
| **TikTok Ads** | Ana keşif motorumuzun ücretli hızlandırıcısı; organik kazanan videolar hazır kreatif havuzu | Video test bütçesinin ana kalemi (%50 blokunun içinde) | Paid install → onboarding completion; paid D7 | Korku/suçluluk formatı yasak; ayet üzerinden satış görseli yasak; merhametli marka tonu zorunlu |
| **Instagram Reels Ads** | Aynı kreatif havuzu, farklı demografi (TR/diaspora); Meta hedefleme derinliği | Video test bütçesini TikTok'la paylaşır | Paid install kalitesi + cost per activated user | Aynı yasaklar + "dini otorite iması" içeren metin yasak |
| **Meta Ads (feed/stories)** | Reels dışı yerleşimlerle ilgi-bazlı hedefleme testi | Küçük ikincil test (video bloku içinde) | CAC, trial start | Baskı kuran sayaç/"son fırsat" kreatifi yasak |
| **Google App Campaigns / Play testi** | Yüksek niyetli arama trafiği ("namaz takip" arayan kullanıcı); store conversion optimizasyonu | %25 blok: install + store listing varyant testleri | Cost per install → onboarding completion; store conversion rate | Anahtar kelime reklamlarında dini vaat metni yasak |
| **Boosted organic content** | Organikte KANITLANMIŞ içeriği aynı formatta büyütmek — en düşük riskli paid harcama | %15 blok | Boost edilen içeriğin paid D7'si vs organik D7 | Yalnız organikte tutan içerik boost edilir (kural c, §1) |
| **Retargeting / hatırlatma** | Uygulamayı indirip onboarding'i yarım bırakanlara TEK nazik hatırlatma | %10 blok (deneysel) | Yarım-onboarding'den dönüş oranı | Frekans tavanı sıkı (kişi başına ≤2 gösterim); ısrar/suçlama dili yasak |

### 14.2 Paid Bütçe Dağılımı (aylık 1.500 TL)

| Blok | Pay | Tutar | İçerik |
|---|---|---|---|
| Kısa video reklam testleri (TikTok/IG) | %50 | **750 TL** | 3–5 kreatif düşük bütçeli test → kazanan 1–2'ye yoğunlaşma |
| Store / install-conversion testleri | %25 | **375 TL** | Google App Campaigns + store listing varyantları |
| Boosted organic content | %15 | **225 TL** | Organik kazananların büyütülmesi |
| Retargeting / yeniden hatırlatma | %10 | **150 TL** | Yarım-onboarding kitlesi, sıkı frekans tavanlı |

Dağılım aylık metrik incelemesinde revize edilebilir; tek kural: hiçbir ay bütçe 1.500 TL'yi aşmaz ve haftalık harcama limitleri (≈375 TL/hafta) platform seviyesinde kilitlenir — "kör harcama" teknik olarak imkânsızlaştırılır.

### 14.3 Etik Reklam Kuralları (bağlayıcı — §18'in reklam uzantısı)

1. Korku temelli reklam YASAK ("kabir azabı", "hesap günü" korkutmalı kancalar dahil).
2. Günah/ceza dili YASAK.
3. "Namaz kılmıyorsan…" tarzı utandırıcı girişler YASAK.
4. "Sevap kazanmak için premium" ve her türlü sevap-satış bağlantısı YASAK.
5. Ayet/hadis üzerinden satış banner'ı YASAK — kutsal metin reklam kreatifinde satış aracı olamaz (kaynaklı ayet kartı, satış CTA'sız marka içeriği olarak kalabilir).
6. Reklamlarda dini otorite iddiası YASAK ("en doğru İslami rehber" vb.).
7. Baskı kuran sayaç/"son fırsat" dili YASAK.
8. Tüm reklam kreatifleri Bismillah'ın merhametli marka tonuna (Marka §8–11) uymak zorundadır; yayın öncesi §25 etik kontrol listesinden geçer.

---

## 15. İçerik Pazarlama Stratejisi

Marka §25 sütunları ticari hedefle hizalanır — oran: **%80 değer / %20 ürün.**

- **Değer içeriği (dönüşümü besleyen):** "az ama devamlı" pratiği serisi; bilim + sünnet alışkanlık içerikleri; kaynaklı günlük hatırlatma kartları; Ramazan hazırlık serisi; "yeniden başlayanlara" merhamet serisi (recovery kitlesi = en duygusal bağ kuran kitle).
- **Ürün içeriği:** özellik hikâyeleri fayda diliyle ("seri bozulunca ne olur? Hiçbir şey kaybetmezsin"); "ürünün mutfağı" şeffaflık serisi (içerik doğrulama süreci, neden reklamsız, premium modeli neden böyle kurduk) — güven pazarlaması Bismillah'ın en ayırt edici içerik kozudur.
- **Format disiplini:** kısa video birincil (üç platforma aynı havuz); görsel kartlar ikincil; blog/SEO üçüncül (V1.x, EN pazarı için).
- **Üretim ritmi (solo):** haftada 1 çekim günü → 7–10 video; şablonlaşmış kurgu; içerik takvimi 2 hafta önden (§22).

---

## 16. Retention Stratejisi

Gelirin gerçek motoru retention'dır — churn'lü büyüme delikli kovadır.

| Metrik | Hedef (PRD §16) | Ana kaldıraç |
|---|---|---|
| D1 | ≥%45 | Onboarding kalitesi + ilk eylem ≤2 dokunuş |
| D7 | ≥%30 | 7 gün deneyimi: ilk hafta mikro kazanımlar, 7. gün yansıma töreni |
| D30 | ≥%20 | Plan gerçekçiliği + otomatik küçülme + recovery mekaniği |
| **WCW/WAU** | ≥%35 | Kuzey yıldızı: haftada 5+ gün gerçek ibadet eylemi (PRD §17) |
| Abone churn | ≤%7–10/ay | Premium'un sürekli değer üretmesi (haftalık koçluk, aylık rapor) |

**Retention oyun planı:** bildirimler eylem-tamamlama optimizasyonlu (aç-tıklat değil); seri onarımı ücretsiz ve merhametli (geri dönüşün önü hep açık); 30-gün ve aylık törenler (dönüşüm VE retention anı aynı anda); Ramazan yıllık reaktivasyon dalgası; kişiselleştirme derinleştikçe geçiş maliyeti doğal artar (ürün verisi = kullanıcının kendi tarihi). **Premium churn özel kuralı:** iptal akışı tek ekran ve kolaydır; iptal edene "verilerin ve ücretsiz deneyimin aynen durur" güvencesi verilir — dönüş kapısı açık bırakılır (winback'in ön koşulu saygıdır).

---

## 17. Monetizasyon Metrikleri

| Metrik | Tanım | 90. gün hedefi *(varsayım)* |
|---|---|---|
| **MRR** | Aylık yinelenen gelir (yıllıklar 12'ye bölünür) | ≥10.000 TL |
| **Ödeyen kullanıcı** | Aktif entitlement sahibi | 180–220 |
| **ARPU** | Brüt gelir / MAU | ~1,5–2 TL |
| **ARPPU** | Brüt gelir / ödeyen | ~45–55 TL |
| **Paywall conversion** | Paywall görüntüleme → deneme | %8–12 |
| **Trial→paid** | Deneme → ödeme | ≥%40 |
| **Free→paid** | MAU → ödeyen | %2–3 (ilk 90 gün) |
| **Churn (abone)** | Aylık iptal oranı | ≤%10 |
| **LTV** | ARPPU × ort. abonelik ömrü (1/churn) | ≥450–500 TL (churn %10 varsayımıyla ~5+ ay ömür) |
| **AI cost per user** | Aylık AI maliyeti / MAU (ayrıca /ödeyen) | ≤0,5 TL/MAU; ≤5 TL/ödeyen (§21) |
| **CAC** | Organik model → ~0 TL nakit; founder zamanı saat olarak izlenir | Saat/ödeyen: düşen trend |

**Paid growth metrikleri (v1.1):**

| Metrik | Tanım | Karar eşiği *(varsayım — ilk ay verisiyle kalibre edilir)* |
|---|---|---|
| **Paid CAC** | Reklam harcaması / paid-attributed ödeyen kullanıcı | ≤150 TL (≈3 aylık ARPPU); üstünde kampanya durur |
| **Paid install → onboarding completion** | Paid install'ların onboarding tamamlama oranı | ≥%55 (organiğin ≥%80'i); altındaysa kitle/kreatif yanlış |
| **Paid D7 retention** | Paid kohortun 7. gün dönüşü | ≥%24 (organik hedefin ≥%80'i); altındaysa o kanal kalitesiz |
| **Paid free-to-paid conversion** | Paid kohortta MAU→ödeyen | Organik oranın ≥%70'i; belirgin düşükse paid kitle yanlış |
| **Cost per activated user** | Harcama / (ilk gün ≥1 plan eylemi tamamlayan paid kullanıcı) | ≤15 TL; ana optimizasyon metriği (install değil) |
| **Cost per trial start** | Harcama / paid-attributed deneme başlangıcı | ≤75 TL |
| **Payback period** | Paid CAC'nin abonelik net geliriyle geri dönme süresi | ≤3 ay; üstünde ölçekleme yok |
| **ROAS** *(ileride)* | Gelir / reklam harcaması (kohort bazlı, 90 gün penceresi) | İlk 90 günde raporlanır, karar metriği olarak V1.x'te devreye girer (veri olgunlaşınca) |

Ölçüm: RevenueCat dashboard (gelir gerçeği) + Firebase Analytics hunisi (davranış; paid/organik ayrımı UTM/attribution ile) + haftalık tek sayfalık metrik özeti (§22 ritmi). Abonelik eventleri sunucudan (07 §19).

---

## 18. Etik Monetizasyon Kuralları

Bu bölüm gelir hedefinden ÜSTÜNDÜR; ihlali "başarılı" olsa bile geri alınır:

1. Temel ibadet araçları hiçbir zaman kilitlenmez (§4 listesi anayasadır).
2. Din üzerinden suçluluk/korku/ayıp/baskı ile satış YASAK.
3. "Premium olmazsan eksik Müslümansın" hissi veren her metin yasak — imada bile.
4. Yasaklı satış sözlüğü: "kilidi aç", "kaçırma", "son fırsat/şans", "sevabını artır", "daha iyi Müslüman ol", "günahından arın", geri sayım sayaçları, sahte stok/kota.
5. Paywall duygusal kırılganlık anında gösterilmez (§9 yasak listesi).
6. Seri onarımı, recovery ve merhamet mekanikleri ASLA satılmaz.
7. Ücretsiz kullanıcı küçümsenmez; "kısıtlı sürüm" dili yasak.
8. Bismillah+ dili davetkârdır: "Yolculuğunu derinleştirmek istersen…" — dayatma değil el uzatma (Marka §26).
9. Deneme şeffaftır: süre, fiyat, iptal yolu paywall'da yazılıdır; deneme bitmeden hatırlatılır.
10. Fiyat dürüstlüğü: sahte indirim, fiyat çapası tiyatrosu, bölgesel fırsatçılık yok; erken destekçi sözü ömür boyu tutulur.
11. Dini içerik premium rozeti taşımaz: hiçbir ayet/hadis/dua "premium içerik" olamaz.
12. Bir kez ücretsiz verilen özellik geriye dönük kilitlenmez.

---

## 19. Gerekli Ürün Değişiklikleri (Change Requests)

*(Bu görevde dosyalar DÜZENLENMEDİ; aşağıdaki CR'lar ayrı görevlerde uygulanacak.)*

| Dosya | CR | Değişiklik |
|---|---|---|
| **01_PRODUCT_PRD.md** | CR-01 | §27 MVP kapsamına "Premium/Paywall (launch)" modülü ekle; §28 "Out of Scope" tablosundan premium satırını çıkar/revize et; §29 V2 pillar-1'i "premium derinleştirme" olarak güncelle; §33'e launch paketi + erken destekçi fiyatı; §16/§45'e 90-gün gelir metrikleri (MRR, ödeyen sayısı); §45.7'yi "launch'ta canlı" olarak güncelle |
| **02_BRAND_GUIDELINES.md** | CR-02 | §26 Premium bölümüne launch-dönemi mesaj seti (erken destekçi dili, deneme iletişimi); §24 store metinlerine IAP şeffaflık notu; §29 örneklerine paywall ekran metni (TR/EN/AR) |
| **03_DESIGN_SYSTEM.md** | CR-03 | §12'ye Paywall ekran bileşeni + fiyat kartı bileşeni spesifikasyonu; Premium Card'ın launch varyantı; "Bismillah+ rozeti" (premium işaret) bileşeni — kilit ikonsuz |
| **04_ONBOARDING_FLOW.md** | CR-04 | Değişiklik MİNİMAL: onboarding'e paywall EKLENMEZ (ilke korunur); yalnız §11 auth bölümüne "satın alma geri yükleme, hesapla kolaylaşır" notu |
| **05_INFORMATION_ARCHITECTURE.md** | CR-05 | §23 V2 listesinden premium'u MVP kapsamına taşı; route tablosuna `/premium` (full-screen modal paywall) + `/settings/subscription` ekle; §12 deep link tablosuna 30-gün-özeti→paywall köprüsü; §11'e "abonelik yönetimi" user flow |
| **06_FLUTTER_ARCHITECTURE.md** | CR-06 | §36'daki `PremiumGate` sözleşmesini MVP kapsamına al; `features/premium/` feature'ı tanımla (`premiumStateProvider`, `PremiumRepository`, `purchases_flutter` infrastructure); §33 paket listesinde RevenueCat "V2" notunu "MVP" yap; §34 flavor tablosunda RevenueCat sandbox/prod satırını MVP'ye çek |
| **07_FIREBASE_ARCHITECTURE.md** | CR-07 | §16 `entitlementSync` function'ını V2'den MVP'ye taşı; `users/{uid}` şemasına premium meta alanları (`plusUntil, plusSource`); §19'a sunucu-kaynaklı abonelik eventleri MVP notu; §29 maliyet tablosuna RevenueCat webhook maliyeti (ihmal edilebilir) |
| **08 (bu doküman) + 02_BRAND_GUIDELINES.md** | CR-08 | Paid Growth Budget Update: launch sonrası aylık 1.500 TL kontrollü reklam test bütçesi — organik büyümeyi destekler, çalışan içerikleri büyütür, store dönüşümünü test eder, CAC/payback ölçer; §14.3 etik reklam kurallarına bağlıdır (korku/suçluluk/günah/ceza/"sevap kazan"/dini baskı dili yasak). Bu dokümanda §1, §2, §13, §14, §17, §22–25'e işlendi (v1.1); marka tarafı 02 §26'ya yansıtılır |

> **Uygulama durumu:** CR-01…CR-08, TASK 009 kapsamında ilgili dokümanlara uygulanmıştır — bkz. [09_BUSINESS_ALIGNMENT_CHANGELOG.md](09_BUSINESS_ALIGNMENT_CHANGELOG.md).

---

## 20. Premium Özellik Önceliklendirmesi

| Sıra | Özellik | Neden bu sıra | Hazır olma |
|---|---|---|---|
| 1 | Sınırsız AI + gelişmiş koç | En net değer, en düşük ek geliştirme (mevcut asistan + limit kaldırma + koç akışları) | Launch |
| 2 | İleri istatistik + aylık rapor | Veri zaten toplanıyor; sunum katmanı işi | Launch |
| 3 | Kişisel 30 günlük derin programlar | Plan motoru mevcut; program şablonları editoryal iş | Launch |
| 4 | Hatim planlayıcı | Yüksek talep sinyali beklenen özellik; plan motorunun uzun-arc modu | Launch +30–45 gün (V1.x) |
| 5 | Premium temalar | Düşük efor, tatlı ek değer; koyu tema HERKESE ücretsiz | V1.x |
| 6 | Ramazan+ katmanı | Ramazan 2027 öncesi | V2 (Ramazan −6 hafta) |
| 7 | Aile planı | Aile grupları altyapısı gerektirir | V2 |

---

## 21. AI Maliyeti ve Monetizasyon Dengesi

- **Maliyet modeli** *(varsayım — sağlayıcı fiyatlarıyla kalibre edilir)*: ücretsiz kullanıcı 10 mesaj/gün tavanlı ama medyan kullanım ~1–3 mesaj/gün; küçük/orta model + kısa bağlam ile mesaj başına maliyet çok düşük tutulur. Hedef: **≤0,5 TL/MAU/ay; ödeyen kullanıcıda ≤5 TL/ay** (ARPPU'nun ~%10'u tavan).
- **Kontrol mekanizmaları** (07 §17/§29): fetva-türü ve sık beginner soruları modele gitmeden şablon/cache'ten (bedava); Remote Config ile model seçimi (maliyet artarsa anlık küçültme); UID bazlı rate limit; bağlam ÖZETİ gönderimi (token diyeti); premium koç akışları daha yetenekli modele, ücretsiz sohbet ekonomik modele yönlendirilebilir *(varsayım: kalite çıtası düşmeden)*.
- **Denge ilkesi:** AI limiti bir "acı noktası pazarlaması" değil maliyet gerçeğidir — iletişimi de öyle yapılır ("sınırsız sohbetin bir maliyeti var; Bismillah+ bunu karşılıyor"). Limit, kullanıcıyı cezalandıracak kadar düşük tutulamaz (10/gün gerçekten faydalıdır); maliyet baskısı olursa önce model/route optimizasyonu, EN SON limit düşürme.

---

## 22. Founder-Led Growth Planı

Solo founder gerçeğine göre haftalık işletim sistemi:

**Günlük (60–90 dk):**
- 1 kısa video yayınla (hazır havuzdan) + yorumlara cevap (TikTok/IG/Shorts)
- Store yorumlarına yanıt (özellikle olumsuzlara — kamuya açık müşteri hizmeti)
- Metrik panosuna 5 dakikalık bakış (MRR, deneme, D1)

**Haftalık ritim:**
- **1 gün içerik üretimi:** toplu çekim → 7–10 video kurgu → 2 haftalık takvim
- **Haftalık metrik incelemesi (1 saat):** huni, kanal performansı, churn nedenleri → tek sayfa not → sonraki haftanın TEK odağı
- **2–3 topluluk teması:** İslami topluluk/öğrenci grubu iletişimi, mikro-işbirliği takibi
- **Kullanıcı sohbetleri (2 adet):** her hafta 2 gerçek kullanıcıyla 20 dk görüşme (retention içgörüsünün altın kaynağı)
- **1 reklam kontrol günü (≤1 saat, v1.1):** haftalık paid harcama/metrik kontrolü — SADECE bu günde reklam paneline girilir (günlük panel bakma tuzağı = founder zaman kaybı riski, §24-13); 3–5 aktif kreatif testinin durumu; eşik (§17) aşan kampanyanın durdurulması; haftaki en iyi organik videonun boost kararı (yalnız organikte kanıtlanmışsa)
- **Paid disiplin kuralları:** haftalık harcama limiti platformda kilitli (~375 TL); kanal başına küçük test (tek seferde tüm bütçe tek kanala yatırılmaz); her kreatif teste "hangi soruyu cevaplıyor?" notu — sorusuz test = kör harcama, açılmaz

**İlk 100 ödeyen kullanıcıya giden yol:** 20–30 kapalı beta erken destekçisi → 30–40 launch dalgası (içerik + erken fiyat) → 30–40 ilk 30-gün-özeti kohortu (doğal dönüşüm anı). Yani ilk 100, "reklamla satın alınmış" değil "elle kazanılmış" kullanıcıdır — her biriyle ilişki kurulabilir ölçekte.

**Founder zaman bütçesi** *(varsayım)*: %50 ürün/geliştirme, %30 içerik/büyüme, %10 kullanıcı iletişimi, %10 operasyon/metrik.

---

## 23. Finansal Model Varsayımları

*(Tümü varsayım; aylık gerçekle güncellenir.)*

| Kalem | Değer | Not |
|---|---|---|
| İndirme→onboarding tamamlama | %70 | PRD hedefi |
| Onboarding→D30 | %20 | PRD hedefi |
| MAU→ödeyen (90. gün) | %2–3 | Olgunlukta %3–5 |
| Ortalama paket dağılımı | %60 yıllık / %40 aylık | Yıllık vurgusuyla |
| Efektif ARPPU | ~45–55 TL/ay | Erken destekçi karışımıyla |
| Store komisyonu | %15 | Small business varsayımı |
| AI maliyeti | ≤1.500 TL/ay (90. gün ölçeği) | §21 |
| Firebase | ≤500 TL/ay | 07 §29; büyük olasılıkla daha az |
| RevenueCat | Ücretsiz katman (MRR eşiği altında) | *(varsayım: giriş katmanı yeterli)* |
| **Reklam gideri (v1.1)** | **1.500 TL/ay sabit** | §14.2 dağılımı; haftalık limitlerle kilitli |
| Diğer (domain, araçlar) | ~300 TL/ay | — |
| **90. gün net** | **~5.000–6.500 TL/ay** | 10.000 TL brüt − ~1.500 TL store komisyonu − ~500–1.500 TL AI − ~0–500 TL Firebase − **1.500 TL reklam** − ~300 TL diğer |
| Başabaş noktası | **~70–90 ödeyen kullanıcı** | Maliyetler ≈ 3.000–3.800 TL/ay (reklam dahil); ödeyen başına store-sonrası ~42,5 TL net |

---

## 24. Riskler ve Azaltımlar

| # | Risk | Etki | Olasılık | Azaltım |
|---|---|---|---|---|
| 1 | 90 günde 200 ödeyene ulaşılamaz | Orta (hedef kayar) | Orta-Yüksek | Gün-75 kontrol noktası + kanal pivotu; hedef "iptal" değil "ertelenir" — panik taktiği yasak; Ramazan dalgası ikinci şans |
| 2 | "Din para kazanıyor" algısı/eleştirisi | Yüksek (itibar) | Orta | Şeffaflık pazarlaması (neden premium, maliyetler); §18 çizgisinin görünür tutarlılığı; ücretsiz çekirdeğin cömertliği en güçlü cevap |
| 3 | AI maliyeti geliri yer | Orta | Düşük-Orta | §21 tavanları + model yönlendirme + cache; maliyet/kullanıcı haftalık izlenir |
| 4 | Deneme kötüye kullanımı (tekrar tekrar deneme) | Düşük | Orta | RevenueCat cihaz/store hesabı bazlı deneme takibi; kabul edilebilir kayıp |
| 5 | Store komisyon koşulları değişir | Düşük-Orta | Düşük | Model %30 komisyonda da başabaşın üstünde; fiyat esnekliği payı var |
| 6 | İçerik üretimi sürdürülemez (solo tükenmişlik) | Yüksek | Orta | Toplu üretim + şablon; kanal sayısını 2'ye düşürme opsiyonu; büyüme temposu > founder sağlığı DEĞİL |
| 7 | Premium değer algısı zayıf (churn >%15) | Yüksek | Orta | Haftalık koç değeri döngüsü; iptal anketi; 4. özellik (hatim) hızlandırma |
| 8 | Kur/enflasyon fiyatı eritir | Orta | Orta (TR) | Yıllık paket ağırlığı; dönemsel fiyat güncellemesi (yeni abonelere; mevcutlar korunur) |
| 9 | Reklam bütçesi yanlış kitleye gider | Orta (1.500 TL yanar) | Orta | Küçük testler (kanal başına ≤250 TL ilk test); kalite metrikleriyle (onboarding completion, paid D7) erken teşhis; haftalık kontrol gününde durdurma |
| 10 | Install gelir ama retention düşük | Orta | Orta-Yüksek | Ölçüt install değil "cost per activated user" + paid D7 (§17); eşik altı kohort getiren kreatif anında kapatılır |
| 11 | Paid CAC çok yüksek çıkar | Orta | Orta | CAC ≤150 TL eşiği; payback ≤3 ay kuralı; eşik aşımında ölçekleme yok, bütçe organiğe döner |
| 12 | Reklam mesajı dini hassasiyeti zedeler | **Yüksek (itibar)** | Düşük-Orta | §14.3 etik reklam kuralları + yayın öncesi kontrol listesi (§25); şüpheli kreatif yayınlanmaz — "viral olur" gerekçesi geçersiz |
| 13 | Founder reklam optimizasyonunda zaman kaybeder | Orta | Orta | Haftada TEK reklam kontrol günü (≤1 saat, §22); günlük panel bakma yasağı; reklam işi founder zamanının %5'ini aşamaz |
| 14 | Paid growth organik stratejinin yerine geçer | Yüksek (strateji kayması) | Düşük | §1 kuralları: paid yalnız organikte kanıtlanmış mesajı büyütür; bütçe tavanı sabit 1.500 TL; 90. gün "ölçekle ya da durdur" karar noktası |

---

## 25. Business QA Kontrol Listesi

**Etik çizgi** — [ ] §18'in 12 kuralı her paywall/metin/kampanyada denetlendi · [ ] Yasaklı sözlük taraması temiz · [ ] Recovery/kırılganlık anlarında paywall yok
**Ücretsiz kapsam** — [ ] §4 listesi eksiksiz canlı · [ ] Hiçbir özellik geriye dönük kilitlenmedi
**Fiyat** — [ ] Deneme şartları paywall'da açık · [ ] İptal 2 dokunuş · [ ] Erken destekçi fiyat koruması çalışıyor
**Huni** — [ ] 6 dönüşüm noktası (§8) doğru anlarda · [ ] Paywall frekans tavanı uygulanıyor
**Ölçüm** — [ ] MRR/ARPPU/churn/LTV panoda · [ ] Abonelik eventleri sunucudan · [ ] AI cost/user izleniyor
**Store** — [ ] IAP şeffaflığı listede · [ ] Premium ekran görüntüleri rozetli
**CR takibi** — [ ] §19'daki 7 change request ilgili dokümanlara uygulandı
**Paid growth (v1.1)** — [ ] Reklam metinleri §14.3 etik kontrolünden geçti · [ ] Yasaklı dini baskı dili taraması temiz · [ ] Paid CAC ölçülüyor ve eşikle karşılaştırılıyor · [ ] Paid D7 retention kohort bazlı izleniyor · [ ] Haftalık harcama limiti platformda kilitli (~375 TL) · [ ] Eşik aşan kampanya durduruldu · [ ] Boost edilen her içerik organikte kanıtlanmış · [ ] Aylık toplam ≤1.500 TL

---

## 26. Kabul Kriterleri

1. 10.000 TL/ay hedefi üç senaryoyla ve brüt/net ayrımıyla işlenmiş (§2)
2. Ücretsiz kapsam kalıcı listeyle sabitlenmiş (§4)
3. Bismillah+ kapsamı ve launch paketi net (§5, §20)
4. MVP monetizasyon kararı (launch'ta paywall) gerekçeli (§6)
5. Fiyat varsayımları paketleriyle tanımlı (§7)
6. Dönüşüm noktaları ve paywall yasak listesi net (§8–9)
7. RevenueCat entitlement yaklaşımı net (§10)
8. 90 günlük plan dönem hedefleri ve çıkış kriterleriyle yazılı (§13)
9. Büyüme kanalları ve founder ritmi somut (§14, §22)
10. Retention ve monetizasyon metrikleri hedefli (§16–17)
11. Etik kurallar bağlayıcı ve gelir hedefinden üstün ilan edilmiş (§18)
12. 7 dokümana change request listesi çıkarılmış (§19)
13. AI maliyet dengesi tavanlarla tanımlı (§21)
14. Finansal varsayımlar ve başabaş noktası yazılı (§23)
15. Aylık 1.500 TL paid growth test bütçesi; dağılımı (§14.2), metrik eşikleri (§17), founder ritmi (§22), finansal etkisi (§23) ve etik reklam kuralları (§14.3) ile birlikte işlenmiş

---

## 27. Nihai İş Yönü

Bismillah'ın iş modeli tek cümleye sığar:

> **İbadeti asla satmayan, derinliği dürüstçe satan ve bu dürüstlüğü en güçlü pazarlaması yapan bir uygulama.**

10.000 TL/ay hedefi bir başlangıç çizgisidir — ürünün kendi maliyetini karşılayıp geleceğini finanse ettiği an. Bu hedefe giden yolda üç şey birbirinden ayrılamaz: **ücretsiz çekirdeğin cömertliği** (güvenin kaynağı), **premium'un gerçek değeri** (gelirin kaynağı) ve **etik çizginin görünür tutarlılığı** (ikisini birbirine bağlayan harç). Kısa vadede geliri artıracak ama bu üçlüden birini zedeleyecek her taktik, uzun vadede hepsini birden yok eder — bu yüzden §18, §2'den üstündür.

Ve bir gün bir kullanıcı "bu uygulamaya para vermek iyi hissettiriyor, çünkü kimseyi din üzerinden sıkıştırmadan ayakta duruyor" diye yorum yazdığında — işte o, bu dokümandaki bütün sayılardan daha değerli metriktir.

---

*Dokümanın sonu. §19 change request'leri (CR-01…CR-08) TASK 009 ile uygulanmıştır; çelişki hâlinde sıra: CLAUDE.md → 01 → 02 → … → bu doküman (monetizasyon operasyonu konularında birincil kaynak).*
