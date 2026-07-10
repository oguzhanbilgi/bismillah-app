# Bismillah — Tasarım Sistemi (Design System)

| | |
|---|---|
| **Doküman** | 03_DESIGN_SYSTEM.md |
| **Versiyon** | 1.0 |
| **Tarih** | 2026-07-08 |
| **Durum** | Onaylı temel — tüm UI üretimi bu dokümana uyar |
| **Bağlı dokümanlar** | [CLAUDE.md](../CLAUDE.md) · [01_PRODUCT_PRD.md](01_PRODUCT_PRD.md) · [02_BRAND_GUIDELINES.md](02_BRAND_GUIDELINES.md) |

---

## İçindekiler

1. [Tasarım Sistemi Genel Bakış](#1-tasarım-sistemi-genel-bakış)
2. [Çekirdek Tasarım İlkeleri](#2-çekirdek-tasarım-i̇lkeleri)
3. [Görsel Temel](#3-görsel-temel)
4. [Renk Sistemi](#4-renk-sistemi)
5. [Tipografi Sistemi](#5-tipografi-sistemi)
6. [Boşluk (Spacing) Sistemi](#6-boşluk-spacing-sistemi)
7. [Köşe Yarıçapı (Radius) Sistemi](#7-köşe-yarıçapı-radius-sistemi)
8. [Yükseklik ve Gölge Sistemi](#8-yükseklik-ve-gölge-sistemi)
9. [Yerleşim Izgarası ve Ekran Yapısı](#9-yerleşim-izgarası-ve-ekran-yapısı)
10. [Bileşen Felsefesi](#10-bileşen-felsefesi)
11. [Butonlar](#11-butonlar)
12. [Kartlar](#12-kartlar)
13. [Navigasyon Sistemi](#13-navigasyon-sistemi)
14. [Today (Bugün) Panosu Bileşenleri](#14-today-bugün-panosu-bileşenleri)
15. [Namaz UI Bileşenleri](#15-namaz-ui-bileşenleri)
16. [Kur'an UI Bileşenleri](#16-kuran-ui-bileşenleri)
17. [Zikir UI Bileşenleri](#17-zikir-ui-bileşenleri)
18. [Dua UI Bileşenleri](#18-dua-ui-bileşenleri)
19. [Öğrenme (Learn) UI Bileşenleri](#19-öğrenme-learn-ui-bileşenleri)
20. [Profil ve İstatistik Bileşenleri](#20-profil-ve-i̇statistik-bileşenleri)
21. [Oyunlaştırma UI Bileşenleri](#21-oyunlaştırma-ui-bileşenleri)
22. [AI Asistan UI Bileşenleri](#22-ai-asistan-ui-bileşenleri)
23. [Bildirim ve İzin UI](#23-bildirim-ve-i̇zin-ui)
24. [Formlar ve Girdiler](#24-formlar-ve-girdiler)
25. [Onboarding Bileşenleri](#25-onboarding-bileşenleri)
26. [Boş Durumlar (Empty States)](#26-boş-durumlar-empty-states)
27. [Hata Durumları (Error States)](#27-hata-durumları-error-states)
28. [Yükleme Durumları (Loading States)](#28-yükleme-durumları-loading-states)
29. [Hareket (Motion) Sistemi](#29-hareket-motion-sistemi)
30. [Haptik Sistemi](#30-haptik-sistemi)
31. [Ses Sistemi](#31-ses-sistemi)
32. [Erişilebilirlik Sistemi](#32-erişilebilirlik-sistemi)
33. [Yerelleştirme ve RTL Tasarım Kuralları](#33-yerelleştirme-ve-rtl-tasarım-kuralları)
34. [Kutsal İçerik UI Kuralları](#34-kutsal-i̇çerik-ui-kuralları)
35. [Koyu Tema Planlaması](#35-koyu-tema-planlaması)
36. [Design Token Tablosu](#36-design-token-tablosu)
37. [Flutter Uygulama Rehberi](#37-flutter-uygulama-rehberi)
38. [Bileşen Kabul Kriterleri](#38-bileşen-kabul-kriterleri)
39. [Tasarım QA Kontrol Listesi](#39-tasarım-qa-kontrol-listesi)
40. [Nihai Tasarım Sistemi Yönü](#40-nihai-tasarım-sistemi-yönü)

---

## 1. Tasarım Sistemi Genel Bakış

Bu doküman, Bismillah'ın **UI sistem seviyesindeki tek doğruluk kaynağıdır**. Marka Kılavuzu'nun (02) stratejik kararlarını — zümrüt kimlik, merhamet dili, kutsal içerik hiyerarşisi — **yeniden kullanılabilir, ölçülebilir ve Flutter'a çevrilebilir kurallara** dönüştürür.

**Rolü zincirin içinde:** PRD *ne* yapılacağını söyler → Marka Kılavuzu *nasıl hissettireceğini* söyler → **Tasarım Sistemi *nasıl inşa edileceğini* söyler.** Çelişki hâlinde öncelik sırası: `CLAUDE.md` → `01_PRODUCT_PRD.md` → `02_BRAND_GUIDELINES.md` → bu doküman.

**Bağlayıcılık:** Bundan sonra üretilecek her ekran, her bileşen ve her Flutter widget'ı bu dokümandaki token'ları ve kuralları kullanmak zorundadır. "Bir kerelik istisna" tasarım borcudur; istisna gerekiyorsa önce bu doküman güncellenir, sonra ekran yapılır. Hedef: **200 ekran sonra bile tek elden çıkmış gibi görünen bir ürün.**

---

## 2. Çekirdek Tasarım İlkeleri

1. **Her ekran "Şimdi ne yapmalıyım?" sorusuna cevap verir.** Ekranda görsel olarak en baskın öğe, kullanıcının *şu an* yapması gereken tek şeydir. Cevabı olmayan ekran tasarıma iade edilir.
2. **Gürültü değil, sükûnet.** Aynı anda dikkat isteyen ikinci öğe yoktur: tek vurgu rengi alanı, tek birincil buton, tek kutlama. Boşluk bir süs değil, tasarım malzemesidir.
3. **Ekran başına tek birincil eylem.** İki "birincil" buton görüldüğü an biri ikincilleştirilir. Karar veremiyorsak ekran ikiye bölünür.
4. **Merhamet temelli durumlar.** "Kaçırılmış", "eksik", "bozulmuş" durumların hepsi nötr ve davetkâr tasarlanır. Utandıran hiçbir görsel durum yoktur; geri dönüş yolları en özenli akışlardır.
5. **Premium boşluk.** Sıkışıklık ucuzluktur. Şüphede kalınca boşluk artırılır, öğe eksiltilir — asla tersi.
6. **Önce kutsal içerik.** Kur'an metni her ekranın görsel hiyerarşisinde en üsttedir; hiçbir rozet, buton veya dekor onunla yarışamaz (bkz. §34).
7. **Erişilebilirlik varsayılandır.** AA kontrast, 48dp dokunma hedefi, ekran okuyucu etiketi ve RTL, bileşenin "bitti" tanımının parçasıdır — sonradan eklenen özellik değildir (bkz. §32, §38).
8. **Kişiselleştirme arayüzde görünür.** Kullanıcının adı, hedefi ve seviyesi arayüzün dokusuna işler: selamlama kişisel, plan kartları profile göre, boş durumlar hedefe göre konuşur. İki farklı kullanıcının Today ekranı yan yana konduğunda fark *görülmelidir*.

---

## 3. Görsel Temel

Bismillah'ın görsel dünyası beş katmandan oluşur; hepsi Marka Kılavuzu §12–§17'den türetilmiştir:

| Katman | Kural |
|---|---|
| **Zemin** | Sıcak beyaz (`#FAF8F4`) her ekranın varsayılan zeminidir; saf beyaz yalnızca kart yüzeyidir. Koyu orman zemini yalnızca özel anlarda (kutlama, premium, Ramazan gecesi). |
| **Kimlik** | Zümrüt (`#0B6E4F`) markanın bedenidir: birincil eylem, aktif durum, ilerleme. Ekran alanının ~%10'unu geçmez. |
| **Yüzeyler** | Yumuşak kartlar: beyaz yüzey + 20px köşe + dağınık hafif gölge. Kart, Bismillah'ın ana UI dilidir. |
| **Doku** | İslami geometri fısıltı dozunda: %3–6 opaklık, yalnızca zemin, asla Kur'an gövde metninin arkasında. |
| **Vurgu** | Altın (`#C9A24B`) yalnızca kazanılmış anlarda; ekran başına en fazla bir altın öğe. |

**Mutlak yasaklar:** ibadet durumlarında sert kırmızı; varsayılan Material görünümü (mor ColorScheme, sert elevation, Roboto hissi); ekran başına birden fazla dekor dili; bağıran rozet/badge yığını; altının dekor/buton/link olarak kullanımı.

---

## 4. Renk Sistemi

Tüm renkler token üzerinden kullanılır; hex değeri koda asla elle yazılmaz (bkz. §37).

| Token | Hex | Kullanım | Erişilebilirlik notu | Yap ✅ / Yapma ❌ |
|---|---|---|---|---|
| `color.primary` | `#0B6E4F` | Birincil butonlar, aktif sekme, ilerleme dolgusu, marka vurgusu | Beyaz metinle kontrast ≈ 5.9:1 (AA ✓, büyük metinde AAA ✓) | ✅ Ekran başına tek birincil vurgu alanı · ❌ Gövde metni rengi, geniş zemin dolgusu |
| `color.primaryDark` | `#08503A` | Basılı (pressed) durum, degrade ucu, kutlama/premium zeminleri | Beyaz metinle ≈ 8.7:1 (AAA ✓) | ✅ `primary` ile 135° hafif degrade · ❌ Uzun okuma zemini |
| `color.primarySoft` | `#DCEDE4` | Seçili durum zemini, bilgi çipi, tamamlanmış kart dolgusu | Üzerine `textPrimary` veya `primary` metin (AA ✓); **beyaz metin yasak** | ✅ Sakin "tamamlandı" hissi · ❌ Beyaz metinle kullanım |
| `color.background` | `#FAF8F4` | Ana uygulama zemini | Nötr zemin; metin daima `textPrimary/Secondary` | ✅ Her ekranın varsayılanı · ❌ Kart yüzeyi olarak (kart = `surface`) |
| `color.surface` | `#FFFFFF` | Kart ve yükseltilmiş yüzeyler | `textPrimary` ile ≈ 13.8:1 (AAA ✓) | ✅ Daima `shadow.card` ile · ❌ Gölgesiz dev beyaz bloklar |
| `color.surfaceAlt` | `#F3EEE5` | İkincil yüzey: giriş alanı, pasif kart, bölüm zemini | Üzerine `textPrimary` (AA ✓); `textTertiary` yalnız ipucu | ✅ Katman derinliği · ❌ Üçten fazla krem katmanı üst üste |
| `color.accentGold` | `#C9A24B` | YALNIZCA: başarı rozeti, seviye atlama, hatim kutlaması, premium işareti | Küçük vurgu içindir; üzerine metin koyulmaz, `textPrimary` yanında ikon/çizgi olarak kullanılır | ✅ Kazanılmış an, ekranda tek öğe · ❌ Buton, link, ayraç, ikon rengi |
| `color.textPrimary` | `#1E2B26` | Başlıklar ve gövde metni | `background` üzerinde ≈ 12.9:1 (AAA ✓) | ✅ Tüm ana metin · ❌ Saf siyah `#000000` kullanımı |
| `color.textSecondary` | `#5C6B64` | İkincil metin, alt yazılar, meta bilgi | `background` üzerinde ≈ 5.4:1 (AA ✓) | ✅ Destek bilgisi · ❌ Ana içerik metni |
| `color.textTertiary` | `#93A29A` | Placeholder, ipucu, en düşük vurgu | ≈ 2.9:1 — **yalnız dekoratif/ipucu**; kritik bilgide yasak | ✅ Placeholder · ❌ Kullanıcının okuması gereken herhangi bir bilgi |
| `color.divider` | `#E9E4DA` | 1px ayraçlar, kart sınırları | Dekoratif; anlam taşımaz | ✅ İnce, sessiz · ❌ Kalın/koyu ayraç |
| `color.success` | `#2E9E6B` | Kısa süreli onay geri bildirimi | Beyaz metinle AA sınırında → yalnız ikon/kısa rozet, uzun metinde `textPrimary` eşlik eder | ✅ Anlık onay · ❌ Kalıcı durum rengi (kalıcı tamamlanma = `primarySoft`) |
| `color.warning` | `#D99A3D` | Nazik teknik dikkat: senkron bekliyor, izin eksik | Üzerine koyu metin (`textPrimary`) | ✅ Bilgilendirme tonu · ❌ İbadet durumları için ("namaz uyarısı" yok) |
| `color.error` | `#C25E5E` | YALNIZCA teknik hata: ağ, ödeme, form doğrulama | Beyaz metinle ≈ 4.6:1 (AA ✓) | ✅ İnsani hata metniyle · ❌ **Kaçırılan ibadet/bozulan seri için ASLA** |
| `color.disabled` | `#C7CFC9` | Pasif buton, kapalı durum | Kasıtlı düşük kontrast; devre dışılık ikon+etiketle de belirtilir | ✅ Sessiz pasiflik · ❌ Hata gibi gösterme |

**Kritik kurallar (bağlayıcı):**

1. **Kaçırılan ibadet nötrdür:** kılınmamış namaz/kaçırılan gün `textTertiary` ton + boş kontur ile gösterilir; asla `error`, asla `warning`.
2. **Altın dozu:** bir ekranda birden fazla altın öğe = tasarım hatası.
3. **`success` geçicidir:** onay animasyonu biter, kalıcı "tamamlandı" durumu `primarySoft` zemine döner.

---

## 5. Tipografi Sistemi

Yazı tipleri (Marka Kılavuzu §14): **Plus Jakarta Sans** (başlık/UI), **Inter** (gövde), **IBM Plex Sans Arabic** (Arapça UI), **KFGQPC Uthmanic Hafs** (Kur'an), **Amiri** (dua/zikir Arapçası). Tüm boyutlar `sp` cinsindendir ve sistem yazı ölçeklemesiyle büyür.

| Token | Font / Ağırlık | Boyut | Satır yüks. | Kullanım | Flutter notu |
|---|---|---|---|---|---|
| `type.display` | Plus Jakarta Sans / 700 | 32sp | 1.25 | Onboarding karşılama, kutlama başlıkları | `TextTheme.displaySmall` eşlemesi |
| `type.h1` | Plus Jakarta Sans / 600 | 24sp | 1.3 | Ekran başlıkları, selamlama | `headlineMedium` |
| `type.h2` | Plus Jakarta Sans / 600 | 20sp | 1.35 | Bölüm başlıkları, kart başlıkları | `titleLarge` |
| `type.h3` | Plus Jakarta Sans / 600 | 17sp | 1.4 | Alt başlık, liste başlığı | `titleMedium` |
| `type.body` | Inter / 400 | 16sp | 1.55 | Gövde metni, açıklamalar | `bodyLarge`; satır uzunluğu ~60–70 karakter |
| `type.bodySmall` | Inter / 400 | 14sp | 1.5 | Yoğun listelerde ikincil satır | `bodyMedium` |
| `type.caption` | Inter / 400 | 13sp | 1.4 | Meta bilgi, zaman damgası, kaynak satırı | `bodySmall`; renk `textSecondary`; kritik bilgi taşımaz |
| `type.button` | Plus Jakarta Sans / 600 | 16sp | 1.2 | Buton etiketi | Cümle düzeni; TÜMÜ BÜYÜK yasak; Türkçe İ dönüşümü test edilir |
| `type.navLabel` | Plus Jakarta Sans / 500 | 11sp | 1.2 | Alt navigasyon etiketleri | Daima ikonla birlikte; kısaltma yok |
| `type.stat` | Plus Jakarta Sans / 600, tabular | 28sp | 1.2 | İstatistik sayıları | `FontFeature.tabularFigures()`; yanında `type.caption` etiket |
| `type.statLarge` | Plus Jakarta Sans / 700, tabular | 40sp | 1.1 | Zikir sayacı, halka merkezi | Tek ekranda tek kez |
| `type.quran` | KFGQPC Uthmanic Hafs / 400 | 28sp başlangıç | 1.9 | Kur'an ayet metni | Kullanıcı 22–40sp aralığında ölçekler (bağımsız ayar); tam hareke; asla kırpılmaz; `TextDirection.rtl` |
| `type.dua` | Amiri / 400 | 23sp | 1.8 | Dua/zikir Arapça metni | Tam hareke; `quran`dan görünür şekilde farklı yüz |
| `type.duaLatin` | Inter / 400 italic | 15sp | 1.5 | Transliterasyon satırı | Renk `textSecondary`; Arapçanın altında |
| `type.arabicUI` | IBM Plex Sans Arabic / 400–600 | Latin eşiyle dengeli | 1.5 | Arapça yerelde tüm arayüz metni | Latin karşılığından ~1sp büyük ayarlanır (x-yükseklik dengesi, *varsayım: görsel testte ince ayar*) |

**Ölçekleme kuralları:** tüm stiller %200 sistem ölçeklemesine kadar kırılmadan büyür (kartlar uzar, metin kırpılmaz); `type.quran` sistem ölçeklemesinden bağımsız kendi kontrolüne sahiptir; sabit yükseklikli metin kutusu yasaktır (min-height + esneme kullanılır).

---

## 6. Boşluk (Spacing) Sistemi

4'lük tabanlı ölçek. Token dışı boşluk değeri (örn. 13px) kullanılamaz.

| Token | Değer | Kullanım |
|---|---|---|
| `space.1` | 4 | Mikro boşluk: ikon–metin arası, çip iç dikeyi |
| `space.2` | 8 | Sıkı ilişkili öğeler: etiket–değer, satır içi öğe arası |
| `space.3` | 12 | Bileşen iç dolgusu (kompakt): çip, küçük buton yatayı |
| `space.4` | 16 | **Standart birim:** kart iç dolgusu, liste öğesi dolgusu, ekran yatay kenarı (min) |
| `space.5` | 20 | Ferah kart iç dolgusu (içerik kartları), ekran yatay kenarı (standart) |
| `space.6` | 24 | Kartlar arası dikey boşluk, form alanları arası |
| `space.7` | 32 | Bölümler arası boşluk, başlık–içerik arası |
| `space.8` | 40 | Büyük bölüm ayrımı, boş durum üst boşluğu |
| `space.9` | 48 | Hero alanı iç boşluğu, onboarding soru üstü |
| `space.10` | 64 | Tören boşluğu: kutlama modali, plan oluşturma ekranı |

**Kullanım aralıkları:** mikro (4–8) bileşen içi ilişki · iç dolgu (12–20) bileşen nefesi · kart arası (24) liste ritmi · bölüm (32–40) sayfa yapısı · ekran kenarı (20 standart, küçük ekranda 16) · hero/tören (48–64) özel anlar. **Şüphede kalınca bir üst token'a çık** (premium boşluk ilkesi).

---

## 7. Köşe Yarıçapı (Radius) Sistemi

| Token | Değer | Kullanım |
|---|---|---|
| `radius.sm` | 8 | Çipler, küçük etiketler, sınıf rozetleri (AI/Kur'an/Hadis çipi) |
| `radius.md` | 12 | Giriş alanları, küçük kartlar, sohbet balonları (uçlarda 4'e düşen konuşma köşesi) |
| `radius.lg` | 20 | **Standart kart yarıçapı** — Bismillah kartının imzası |
| `radius.xl` | 28 | Modal bottom sheet üst köşeleri, kutlama modali, hero kartlar |
| `radius.pill` | 999 | Butonlar (birincil/ikincil), segment kontrol, arama alanı |
| `radius.full` | %50 | Avatar, ilerleme halkası, ikon butonlar, FAB |

**His hedefi:** kartlar `lg` ile yumuşak ve modern; butonlar `pill` ile sakin ve davetkâr. Aynı bileşen ailesinde karışık yarıçap yasaktır; sert köşe (0–4px) markada yoktur.

---

## 8. Yükseklik ve Gölge Sistemi

Gölge dili: **alçak, dağınık, sıcak.** Material'ın sert, koyu, kısa gölgeleri yasaktır. Gölge rengi saf siyah değil, mürekkep tonudur (`#1E2B26`).

| Token | Tanım | Kullanım |
|---|---|---|
| `shadow.none` | Gölgesiz | Zemin üstü düz öğeler, `surfaceAlt` yüzeyler, ayraçlı listeler |
| `shadow.xs` | y:1, blur:4, opaklık %4 | Çipler, küçük etkileşimli öğeler (isteğe bağlı) |
| `shadow.card` | y:4, blur:16, opaklık %6 | **Standart kart gölgesi** — tüm `surface` kartlar |
| `shadow.floating` | y:6, blur:20, opaklık %10 | Yüzen asistan düğmesi, yapışkan alt eylem çubuğu |
| `shadow.celebration` | y:12, blur:40, opaklık %14 | Kutlama modali, plan oluşturma sahnesi — en derin gölge |

**Kurallar:** gölge hiyerarşi anlatır, dekor değildir — aynı ekranda en fazla iki gölge seviyesi; basılı durumda kart gölgesi `xs`e iner (yaklaşma hissi); koyu temada gölgeler opaklık yerine yüzey tonuyla ifade edilir (bkz. §35).

---

## 9. Yerleşim Izgarası ve Ekran Yapısı

- **Güvenli alanlar:** tüm ekranlar `SafeArea` içinde; çentik/home-indicator bölgesine içerik taşmaz.
- **Ekran kenar boşluğu:** yatay `space.5` (20); 360dp altı ekranlarda `space.4` (16).
- **Kart genişliği:** tam genişlik − 2×kenar boşluğu; kartlar yatayda hizalıdır, farklı genişlikte kart karışımı yoktur (yatay kaydırmalı raflar hariç).
- **Maksimum içerik genişliği:** 480dp — geniş ekranda (tablet/katlanabilir) içerik ortalanır, kenarlarda zemin nefes alır. *(Varsayım: MVP telefon odaklı; tablet düzeni V2'de bu kural üstüne kurulur.)*
- **Kaydırma davranışı:** dikey tek yönlü akış; iç içe kaydırma yasak (yatay raf istisnası); üst başlık küçülerek sabitlenebilir (pinned, alçak profil); aşırı kaydırmada platform doğal davranışı (iOS bounce).
- **Tek el erişimi:** günlük çekirdek eylemler (namaz işaretleme, plan tamamlama, sayaç) ekranın alt %60'ında; kritik butonlar başparmak yayı içinde; ekran üstü yalnız bilgi/başlık taşır.
- **Alt navigasyon alanı:** 64dp + alt güvenli alan; içerik listelerinin altına `space.8` + nav yüksekliği kadar padding (son kart navın altında ezilmez).
- **Yüzen asistan düğmesi:** 56dp, alt navigasyonun `space.6` üstünde, **okuma yönü tarafında** (LTR'de sağ, RTL'de sol); kaydırma sırasında yarı saydamlaşır, durunca döner; zikir sayacı ve Kur'an okuma yüzeyinde gizlenir.
- **RTL aynalama:** tüm yerleşim `start/end` ile kurulur (`left/right` yasak); Arapça yerelde tüm akış aynalanır — geri oku, ilerleme yönü, kaydırma göstergeleri dahil; pusula/kıble gibi fiziksel yön öğeleri aynalanmaz.
- **Tablet/katlanabilir gelecek notu:** grid 4 kolona (telefon) tasarlanır; token'lar yoğunluk değiştirmeden 8 kolona genişleyebilir; hiçbir bileşen sabit ekran genişliği varsaymaz.

---

## 10. Bileşen Felsefesi

Her bileşen şu altı sıfatı taşımak zorundadır: **yeniden kullanılabilir** (feature'a değil sisteme ait), **erişilebilir** (etiket, kontrast, hedef boyutu içeride), **durum farkındalıklı** (tüm durumları tasarlanmış), **kişiselleştirmeye hazır** (metin/içerik dışarıdan gelir, sabit yazı yok), **marka tutarlı** (token dışı değer yok), **Flutter dostu** (widget sınırları net, parametreleri öngörülebilir).

**Her bileşen dokümantasyonu beş bölüm içerir:**

1. **Amaç** — hangi kullanıcı işini çözer (PRD'ye iz)
2. **Anatomi** — parçaları ve zorunlu/opsiyonel alanları
3. **Durumlar** — default / pressed / selected / completed / disabled / loading / error / empty (geçerli olanlar)
4. **Erişilebilirlik** — semantik etiket, dokunma hedefi, okuyucu davranışı
5. **Yap/Yapma** — en az iki somut kural

Aşağıdaki bileşen bölümleri (§11–§28) bu şablonun uygulanmış halidir; Flutter'da her bileşen `core/ui/` altında tek widget ailesi olarak yaşar (bkz. §37).

---

## 11. Butonlar

Genel kurallar: yükseklik **52dp** (birincil/ikincil), min genişlik 120dp; yarıçap `radius.pill`; etiket `type.button`, fiil + kısa ("Başlayalım", "Kaydet"); ekran başına **tek birincil buton**; altın buton **yoktur**; ibadet eylemleri asla yıkıcı görsel dil kullanmaz.

| Buton | Görsel | Kullanım | Durumlar | Yap ✅ / Yapma ❌ |
|---|---|---|---|---|
| **Primary** | `color.primary` dolgu + beyaz etiket | Ekranın tek ana eylemi | pressed: `primaryDark` + gölge iner · disabled: `color.disabled` + `textTertiary` etiket · loading: etiket yerine 20dp beyaz progress, genişlik sabit kalır | ✅ "Şimdi ne yapmalıyım?"ın cevabı bu buton · ❌ Aynı ekranda ikincisi |
| **Secondary** | 1.5px `color.primary` kontur, şeffaf zemin, zümrüt etiket | Birincilin yanındaki alternatif ("Daha sonra") | pressed: `primarySoft` zemin dolar | ✅ Birincille yan yana/altında · ❌ Tek başına ana eylem olarak |
| **Tertiary / Ghost** | `surfaceAlt` dolgu, `textPrimary` etiket | Kart içi hafif eylemler, filtreler | pressed: bir ton koyu krem | ✅ Kart içinde sessiz eylem · ❌ Kritik yolda tek başına |
| **Text Button** | Yalnız zümrüt metin | Satır içi eylem ("Tümünü gör", "Düzenle") | pressed: %70 opaklık | ✅ İkincil gezinme · ❌ Ana eylem; 48dp dokunma alanı korunur |
| **Icon Button** | 44–48dp daire, kontur ikon | Araç eylemleri (favori, paylaş, ayar) | pressed: `primarySoft` daire belirir · selected (favori): `primary` dolgulu ikon | ✅ Daima semantik etiketle · ❌ Etiketiz kritik eylem |
| **Destructive** | `color.error` **kontur** (dolgu değil) + kırmızı etiket | YALNIZCA teknik/hesap: "Hesabı sil", "Verileri temizle" | onay diyaloğu zorunlu; pressed: hafif kırmızı zemin | ✅ Hesap/veri işlemleri · ❌ İbadet verisiyle ilgili herhangi bir eylemde kırmızı ("kaydı sil" bile nötr Ghost olur) |
| **Disabled** | `color.disabled` dolgu | Koşul sağlanana dek | — | ✅ Neden pasif olduğu yakın metinle açıklanır · ❌ Sebepsiz pasif buton |
| **Loading** | Primary'nin yükleme durumu | Ağ bekleyen eylemler | dokunma kilitli; 400ms'den kısa işlemde gösterilmez | ✅ Genişlik sabit tutulur (zıplama yok) · ❌ Tüm ekranı kilitleyen overlay (gerekmedikçe) |

---

## 12. Kartlar

Kart = Bismillah'ın ana UI dili. Ortak anatomi: `surface` zemin, `radius.lg`, `shadow.card`, iç dolgu `space.5`; başlık `type.h3`, gövde `type.body/bodySmall`; dokunulabilir kartlarda tüm yüzey hedeftir (min 48dp yükseklik).

| Kart | Amaç | Anatomi | Durumlar / Kurallar |
|---|---|---|---|
| **Today Action Card** | Günlük planın tek adımı | Sol: alan ikonu (namaz/Kur'an/zikir) · başlık + tek satır alt metin · sağ: tamamlama dokunuşu (32dp halka) | default → pressed → **completed**: zemin `primarySoft`a yumuşar, halka dolar, metin kalır (üstü çizilmez — yapılan iş silinmez); kart başına tek eylem |
| **Prayer Card** | Vakit bilgisi + kılındı işareti | Vakit adı + saat (`type.h3` + `type.stat` küçük boy) · durum halkası | current: zümrüt sol şerit + hafif `primarySoft` zemin · prayed: dolu halka · geçmiş-boş: **nötr boş kontur** (kırmızı yasak) · gelecek: sessiz |
| **Quran Card** | Okuma hedefi/ilerleme | Başlık, kaldığı yer (sure:ayet), ilerleme çubuğu, devam butonu (Ghost) | Kart üzerinde XP/oyunlaştırma göstergesi yok (§16, §34) |
| **Dhikr Card** | Zikir setine giriş | Set adı, kısa Arapça önizleme (`type.dua` küçük boy), adet hedefi, ilerleme | completed: `primarySoft` + "Allah kabul etsin" mikro metni |
| **Dua Card** | Kategori/az içerik önizleme | Kategori ikonu + ad + dua sayısı; detayda tam blok yapısı (§18) | Kaynak satırı önizlemede bile görünür |
| **Learn Card** | Ders/yol adımı | İlerleme çipi ("2/5"), başlık, süre tahmini ("4 dk") | locked yok — sıradaki ders "sıradaki" diye işaretlenir, kilit ikonografisi kullanılmaz |
| **Achievement Card** | Kazanım vitrini | Sekiz köşeli rozet + ad + tarih | earned: altın kontur rozet · unearned: silüet, `textTertiary`, utandırmayan ("yolda" hissi) |
| **Stats Card** | Tek metrik anlatımı | `type.stat` sayı + `type.caption` etiket + mini eğri/çubuk | Sayı asla kırmızıya dönmez; düşüş nötr dille ("geçen haftadan farklı") |
| **Premium Card** | Bismillah+ daveti | Koyu orman zemin istisnası + ince altın vurgu + davet metni | Kilit ikonu yasak; kapatma (✕) daima görünür ve 48dp |
| **AI Insight Card** | Asistanın içgörüsü/önerisi | Asistan mini ikonu + içgörü metni + "AI" sınıf çipi (`radius.sm`) + opsiyonel eylem | AI çipi olmadan render edilemez (şema zorunluluğu, §34) |
| **Empty State Card** | Boş durumu davete çevirme | Küçük illüstrasyon/ikon + tek cümle umut + tek eylem butonu | Asla çıplak "veri yok"; metin hedefe göre kişisel (bkz. §26) |

### 12.1 Premium / Paywall Bileşenleri *(v1.1 — 08_BUSINESS_MODEL CR-03; Bismillah+ launch günü satışta)*

| Bileşen | Amaç | Anatomi | Durumlar | Erişilebilirlik | Etik kısıtlar |
|---|---|---|---|---|---|
| `PremiumPaywallScreen` | Tek ekranlık Bismillah+ daveti | Koyu orman zemin + başlık ("Yolculuğunu derinleştir") + 3–4 `PremiumFeatureCard` + `PricingPlanCard` seti + `TrialInfoRow` + Primary CTA + büyük görünür ✕ | default, loading (satın alma), error | ✕ 48dp; tüm içerik okuyucuda sıralı; fiyatlar metin olarak okunur | TEK ekran (çok adımlı satış tüneli yasak); kilit ikonu yasak; geri sayım/kıtlık öğesi yasak; recovery/kutsal içerik bağlamından açılamaz |
| `PremiumFeatureCard` | Tek premium faydanın anlatımı | İkon + fayda başlığı + tek satır açıklama | default | Kart tek semantik düğüm | Fayda dili (ne kazanır); eksiklik diliyle yazılamaz ("bunsuz kalırsın" ❌) |
| `PricingPlanCard` | Paket seçimi (aylık/yıllık/erken destekçi) | Paket adı + fiyat (`type.stat` küçük) + dönem + tasarruf notu + radio seçim | default, selected, disabled | Radio group semantiği; fiyat + dönem tam cümleyle okunur | Gerçek fiyat, gerçek tasarruf; sahte üstü çizili fiyat yasak; varsayılan seçim dürüst (yıllık öne çıkabilir, gizli ön-seçim oyunu yasak) |
| `TrialInfoRow` | Deneme şartlarının şeffaf özeti | "7 gün ücretsiz · sonra 399,99 TL/yıl · istediğin an iptal" tek satırı | default | Tam metin okunur; kısaltılmaz | Paywall'da ZORUNLU öğedir — deneme şartsız CTA render edilemez (required param) |
| `RestorePurchaseButton` | Satın alımı geri yükleme | Text Button ("Satın alımı geri yükle") | default, loading, success, error | 48dp hedef; sonuç duyurulur | Paywall'da ve `/settings/subscription`'da daima görünür |
| `SubscriptionManagementRow` | Abonelik durumu + yönetim girişi | Durum etiketi (aktif/deneme/yok) + yönetim chevron → store abonelik sayfası | active, trial, none, expired | Durum tam cümleyle okunur | İptal yolu gizlenmez; iptal edene "verilerin ve ücretsiz deneyimin aynen durur" güvencesi eşlik eder |
| `BismillahPlusBadge` | Premium özelliğin şeffaf işareti | Küçük "+" rozeti (`radius.sm`, ince altın kontur) + "Bismillah+" etiketi | default | "Bismillah plus özelliği" olarak okunur | KİLİT İKONU DEĞİLDİR ve asla kilit metaforuna dönüşemez; kutsal içerik kartlarında kullanılamaz (hiçbir ayet/hadis/dua premium rozeti taşıyamaz) |

**Paywall tasarım kuralları (bağlayıcı):**

- Paywall tek ekrandır; kapatma (✕) daima görünür ve 48dp'dir.
- Kilit ikonu hiçbir premium yüzeyde kullanılmaz.
- Altın yalnız sınırlı premium vurgu içindir (ekranda tek altın öğe kuralı, §4); **premium CTA butonu altın DEĞİLDİR** — standart Primary (zümrüt) kullanılır.
- Kutsal içerik ekranlarında premium banner/rozet gösterilmez (§34 ile bağlı).
- Recovery modu kompozisyonunda Premium Card / paywall daveti gösterilmez (§14 ile bağlı).
- Fiyat, deneme süresi ve iptal kolaylığı paywall'da açık ve tam yazılır (`TrialInfoRow` zorunlu).
- Paywall onboarding yığını içinde ve ilk 14 günde otomatik olarak açılamaz (08 §9).

**Paid growth kreatif görsel kuralları (v1.1):** reklam kreatifleri bu tasarım sisteminin uzantısıdır — korku/ceza çağrışımlı görsel yok; kırmızı aciliyet dili/sayaç yok; ayet-hadis metni satış banner'ına dönüştürülmez; kreatifler uygulamanın sakin/premium görsel dilini (zümrüt-krem palet, ferah boşluk, yumuşak köşe) korur; gerçek UI gösterimi tercih edilir (sahte ekran/abartılı vaat görseli yasak).

---

## 13. Navigasyon Sistemi

- **Alt navigasyon:** 5 sekme — **Today, Namaz, Kur'an, Öğren, Profil** (PRD §25). Yükseklik 64dp + güvenli alan; pasif: kontur ikon + `type.navLabel` `textSecondary`; aktif: dolgulu ikon + `color.primary` etiket; kırmızı bildirim noktası alt navda yasak; sekmeye yeniden dokunma kendi yığınını köke döndürür.
- **Sekme yapısı:** her sekme kendi navigasyon yığınını korur (GoRouter `StatefulShellRoute` yaklaşımı, bkz. §37); sekmeler arası geçişte durum kaybolmaz.
- **Yüzen asistan düğmesi:** 56dp, `color.primary` zemin + beyaz filiz-mim ikonu, `shadow.floating`; yerleşim §9; asistan bir sekme **değildir** — her yerden erişilen eşlikçi giriştir; dokunuş bağlamsal sheet açar (§22).
- **Geri navigasyon:** üst başlıkta `start` hizalı geri ikonu (RTL'de aynalanır); iOS swipe-back korunur; Android predictive back desteklenir; iç ekrandan sistem geri tuşu uygulamayı kapatmaz.
- **Modal bottom sheet:** `radius.xl` üst köşe, üstte 32×4dp sürükleme tutamacı, zemin `surface`; hızlı işler için: namaz kaydı, hedef düzenleme, asistan bağlam sohbeti, seri onarımı; arka plan %40 mürekkep karartma.
- **Tam ekran modal akışlar:** tören anları — onboarding, zikir sayacı, kutlama, aylık özet, (V2) paywall; alt navigasyon gizlenir; çıkış daima görünür (✕ veya "Kapat").
- **Bildirim deep-link davranışı:** her bildirim tam hedef ekrana/sheet'e iner (namaz bildirimi → tek dokunuş kayıt sheet'i); deep-link soğuk açılışta da doğru sekme yığınını kurar; giriş yapılmamışsa akış korunup kimlik sonrası devam eder.

---

## 14. Today (Bugün) Panosu Bileşenleri

Ürünün kalbi. Kompozisyon kişiselleştirme motorundan gelir (PRD §23); ekran en fazla **4 kart + başlık bölgesi** gösterir.

| Bileşen | Tasarım |
|---|---|
| **Selamlama başlığı** | "Selamünaleyküm, Yusuf" (`type.h1`) + hicri/miladi tarih (`type.caption`); vakte duyarlı alt satır ("Hayırlı sabahlar"); sağ üstte sessiz seri göstergesi |
| **Günlük ilerleme halkası** | 96dp halka, `color.primary` dolgu, krem ray, merkezde tamamlanan/toplam (`type.stat`); %0 durumda bile zarif (boş ray + davet metni); dolum animasyonu `motion.ringFill` |
| **Sıradaki namaz kartı** | En üst kart (vakit yaklaşınca): vakit adı, kalan süre ("İkindiye 1 sa 12 dk"), tek dokunuş kayıt; vakit girince nazikçe vurgulanır (`primarySoft` nefes animasyonu, bir kez) |
| **Kişisel plan kartları** | Today Action Card dizisi (§12); sıralama motor kararı; kart sayısı profile göre 1–4 |
| **Günlük ayet kartı** | `type.quran` küçük boy (22sp) Arapça + çeviri + kaynak satırı; sınıf görseli Kur'an kartı dilinde (§34); dokunuş → tam görünüm + yansıma |
| **Günlük yansıma kartı** | Akşam saatlerinde belirir; tek soru + metin girişi; tamamen opsiyonel görsel dil (birincil vurgu almaz) |
| **Seri / süreklilik görseli** | Filiz-halka zinciri (§21): son 7 gün minik halkalar; bugün nefes alan boş halka; kaçırılan gün nötr boşluk |
| **Recovery (toparlanma) modu durumu** | 3+ boş gün sonrası pano sadeleşir: tek büyük sıcak kart ("Bugün: bir ayet"), seri görseli gizlenir, selamlama daha yumuşak; hiçbir "kaçırdın" ibaresi yok |
| **Plan tamamlandı durumu** | Tüm kartlar `primarySoft`; halka dolu; sakin kutlama bandı ("Bugünün planı tamam — Allah kabul etsin"); ekranın geri kalanı sessizleşir, yeni görev *itilmez* (isteğe bağlı "biraz daha?" Ghost butonu) |

---

## 15. Namaz UI Bileşenleri

| Bileşen | Tasarım |
|---|---|
| **Vakit listesi** | 5 (+opsiyonel sünnet satırları) Prayer Card (§12) dikey; bugünün tarihi + hicri karşılığı üstte; yarın önizlemesi altta sessiz |
| **Şimdiki vakit durumu** | Aktif kart: zümrüt sol şerit + `primarySoft` zemin + kalan süre; ezan vaktinde tek yumuşak vurgu animasyonu (tekrarlamaz) |
| **Kılındı işareti (toggle)** | 32dp halka: boş kontur → dokunuşta dolar (`motion.complete` + haptik `haptic.prayer`); geri alma: tekrar dokunuş + "geri alındı" mikro onayı; dokunma hedefi kartın tüm sağ bölgesi |
| **Kaza / geç durumu** | Vakit çıktıktan sonra kart nötr kalır; "Kılındı olarak işaretle" seçeneği kaybolmaz; kaza kaydı ayrı sessiz etiketle ("kaza") — **kırmızı yok, üstü çizili yok, uyarı ikonu yok** |
| **Haftalık namaz özeti** | 7×5 nokta matrisi: dolu nokta (kılındı) zümrüt, boş nokta nötr kontur; altında tek cümle teşvik ("Bu hafta 19 vakit — istikrar büyüyor") |
| **Kıble kartı** | Minimal pusula: tek ok + Kâbe yön açısı; kalibrasyon ipucu `type.caption`; pusula RTL'de aynalanmaz (fiziksel yön) |
| **Hatırlatma izni kartı** | Bağlamsal eğitim kartı (§23): fayda cümlesi + "İzin ver" Primary + "Şimdi değil" Text Button; reddedilirse bir daha kendiliğinden çıkmaz (ayarlardan erişilir) |

**Dil kuralı:** bu ekranın tüm metinleri Marka Kılavuzu §9 ton kurallarına tabidir; "kaçırdın/eksik/borç" kelimeleri arayüzde kullanılamaz.

---

## 16. Kur'an UI Bileşenleri

| Bileşen | Tasarım |
|---|---|
| **İlerleme kartı** | Genel ilerleme (sayfa/cüz görselleştirmesi, ince segment çubuğu) + bu haftaki tutarlılık noktaları |
| **Okuma takipçisi** | Bugünün hedefi (sayfa/ayet/dakika) + "Okudum" kaydı (manuel MVP); kayıt sheet'i: miktar + tek dokunuş onay |
| **Yer imi / devam kartı** | "Kaldığın yer: Yâsîn 12. sayfa" + Devam (Primary küçük boy); tek yer imi MVP (PRD §27.6) |
| **Günlük ayet kartı** | §14'teki kart; arşiv görünümünde liste hâli |
| **Kur'an metni gösterim ilkeleri** | `type.quran`, tam hareke, `background` üzerinde **tamamen temiz zemin**; ayet numarası geleneksel âyet işareti (۝) ile; satır kırılımı kelime bütünlüğüne saygılı; metin seçilebilir ama kes-kopyala menüsü edepli (yalnız kopyala + kaynakla paylaş) |
| **Çeviri gösterimi** | Ayetin altında `type.body`, `textSecondary`ye yakın ama okunur ton; çeviri adı görünür ("Diyanet Meali"); Arapça ile çeviri arasında `space.4` |
| **Yansıma istemi** | Okuma sonrası tek soru kartı ("Bugün okuduklarından aklında ne kaldı?") — opsiyonel, sessiz görsel dil |
| **Tamamlama geri bildirimi** | Okuma yüzeyinin **dışında**: yüzeyden çıkınca küçük onay ("Bugünün okuması tamam ✓"); XP tiki Today'e döner — **okuma yüzeyinde XP/rozet/halka gösterilmez** |

**Bağlayıcı:** Kur'an gövde metninin arkasında desen/görsel yasak (§17-Marka, §34); ayet asla yerleşim uğruna kırpılmaz; bu yüzeyde asistan düğmesi gizlenir.

---

## 17. Zikir UI Bileşenleri

| Bileşen | Tasarım |
|---|---|
| **Zikir seti kartı** | §12 Dhikr Card; sabah/akşam setleri vakit bağlamında öne çıkar |
| **Tam ekran sayaç** | En sade ekran: koyu orman zemini (istisna kullanımı) + merkezde `type.statLarge` sayı + üstte zikir metni (`type.dua`) + transliterasyon/çeviri (kapatılabilir); alt navigasyon ve asistan gizli; ekranın tamamı sayma hedefi |
| **Sayma butonu** | Buton yok — **tüm ekran dokunma yüzeyidir**; her dokunuş: sayı artışı + `haptic.dhikr` + 150ms yumuşak ölçek nabzı; yanlışlıkla çift sayma koruması (80ms debounce) |
| **Haptik rehberi** | Her sayım: hafif tık (`selectionClick`); hedefe 3 kala: belirgin tık; hedef tamam: `haptic.completion` çift vuruş (bkz. §30); ses yok (bkz. §31) |
| **Tamamlanma durumu** | Sayı yerine yumuşak açık-zümrüt ışıma + "Allah kabul etsin" + sonraki set önerisi (Ghost); otomatik geçiş yok — kullanıcı yönetir |
| **Özel zikir kartı** | Kullanıcı metni + hedef adet; Arapça girişi desteklenir; kaynak alanı opsiyonel ama teşvik edilir |
| **Sabah/akşam ezkâr kartı** | Set içi ilerleme ("4/7 zikir"); her zikrin kaynağı görünür (§34); set yarım kalırsa kaldığı yerden devam |

**His hedefi:** bu ekran uygulamanın en huzurlu yeridir — göz kapalı, tek elle, cepte bile kullanılabilir olmalıdır.

---

## 18. Dua UI Bileşenleri

Dua detayının **blok sırası sabittir** (şema zorunluluğu): **Arapça → transliterasyon → çeviri → kaynak.**

| Bileşen | Tasarım |
|---|---|
| **Kategori kartı** | İkon + kategori adı + dua adedi; 2 kolonlu grid; kategori ikonları §16-Marka diliyle |
| **Dua detay kartı** | Tek dua tek kart; bloklar arası `space.4`; uzun dualarda kaydırma kart içinde değil sayfa akışında |
| **Arapça metin bloğu** | `type.dua` (Amiri), tam hareke, RTL, temiz zemin; blok arkasında dekor yasak |
| **Transliterasyon bloğu** | `type.duaLatin`; ayarlardan kapatılabilir (Arapça okuyanlar için) |
| **Çeviri bloğu** | `type.body`; dil yereline göre TR/EN/AR |
| **Kaynak bloğu** | `type.caption` + küçük kaynak ikonu: "Müslim 2723" / "Kur'an 2:201"; **hiçbir dua kaynaksız render edilemez** — kaynak alanı boşsa içerik yayına çıkamaz (CMS kuralı, §34) |
| **Favori butonu** | Icon Button (kalp kontur → zümrüt dolgu); haptik `selectionClick`; favoriler çevrimdışı |
| **Arama alanı** | `radius.pill`, `surfaceAlt` zemin, üç dilde arama; sonuç boşsa Empty State (§26) davet diliyle |

---

## 19. Öğrenme (Learn) UI Bileşenleri

His: yapılandırılmış ama akademik-ağır değil — "5 dakikalık sohbet" tonu.

| Bileşen | Tasarım |
|---|---|
| **Ders kartı** | Başlık + süre çipi ("4 dk") + ilerleme durumu; ders içi: kısa metin blokları + tek kavram odağı |
| **Öğrenme yolu kartı** | Yol adı ("Temeller") + adım göstergesi (5 nokta) + sıradaki ders vurgusu; kilit ikonografisi yok — gelecek dersler sessiz silüet |
| **Günlük hadis kartı** | Hadis metni (`type.body`, tırnaksız blok) + **kaynak ve derece satırı zorunlu** ("Buhârî 6018 · Sahih") + sınıf görseli (§34) |
| **Yansıma kartı** | Editoryal içerik; "Yansıma" sınıf çipi ile hadisten görsel olarak ayrılır |
| **Yeni başlayan temel modülü** | Adım-adım akış: bir kavram → bir görsel → bir mikro-özet; ilerleme kullanıcı hızında, süre baskısı yok |
| **Tamamlanma durumu** | Ders bitişi: sakin onay + "sıradaki" önerisi; yol bitişi: rozet kazanımı (§21 kutlama diliyle) |

---

## 20. Profil ve İstatistik Bileşenleri

İlke: **istatistik motive eder, utandırmaz** — düşüş nötr anlatılır, kıyas yalnız kullanıcının kendi geçmişiyledir.

| Bileşen | Tasarım |
|---|---|
| **Profil başlığı** | İsim + seviye adı ("İstikrar yolunda") + seri özeti; avatar opsiyonel (baş harf varsayılan) |
| **Haftalık tutarlılık grafiği** | 7 kolon yumuşak çubuk; dolu gün zümrüt, boş gün nötr; altında insani özet cümlesi — çıplak grafik bırakılmaz |
| **Aylık ilerleme kartı** | Ay içi ısı noktaları (takvim matrisi) + 2–3 `Stats Card`; ay sonu "aylık özet" törenine bağlanır |
| **Başarı ızgarası** | 3 kolonlu rozet grid'i; kazanılan altın konturlu, kazanılmayan sessiz silüet; rozet detayında kazanım hikâyesi ("12 Mart — ilk tam hafta") |
| **Hedef ayarları kartı** | Mevcut plan boyutu + düzenleme girişi; değişiklik yarının planına uygulanır notu görünür |
| **Dil/ayarlar listesi** | Standart liste satırları: ikon + etiket + değer + chevron; 48dp satır; bölüm başlıkları `type.caption` |
| **Hesap yönetimi kartı** | Giriş yöntemi, veri dışa aktarma, **hesap silme** (Destructive kontur buton, onaylı akış); silme akışı suçlayıcı "bizi neden bırakıyorsun" ekranı içermez |

---

## 21. Oyunlaştırma UI Bileşenleri

Marka Kılavuzu §21'in sistemleştirilmiş hali. **Yasaklar: alev/ateş serisi görseli, çocuksu efektler, liderlik tablosu (MVP'de ve sonrasında kıyas), suçluluk görselleri.**

| Bileşen | Tasarım |
|---|---|
| **XP göstergesi** | Tamamlama anında "+10" mikro yükselme (0.6s, `motion.gentle`) → kaybolur; kalıcı XP yalnız Profil'de ince çubuk; Today'de XP görünmez |
| **Seviye göstergesi** | Seviye adı (manevi yolculuk dili: Niyet → Devam → İstikrar → Kökleşme…) + ince ilerleme çubuğu; sayı ikincil, ad birincil |
| **Seri / süreklilik zinciri** | **Filiz-halka zinciri:** 7 günlük minik halkalar; dolu = zümrüt yaprak dolgusu; kaçırılan = nötr boşluk (kararma yok); onarılan gün = açık zümrüt "yaprak yaması" (onarım dürüstçe görünür, sahte doluluk yok) |
| **Başarı rozeti** | Sekiz köşeli yumuşak yıldız formu; kazanım anı: altın kontur + `shadow.celebration` modal + içten tek cümle; kazanılmamış: silüet, kilit ikonu yok |
| **Aylık hedef ilerlemesi** | Yumuşak yay (yarım halka) + kalan gün; hedef aşımı sessiz kutlanır, hedef altı nötr kapanır ("Bu ay 18 gün — geçen aydan iki fazla") |
| **Ramazan meydan okuma rozeti (V2)** | Ay temalı ayrı rozet ailesi; aynı ağırbaşlı dil; gece zemin varyantı |
| **Toparlanma rozeti** | "Güçlü Dönüş" — aradan sonra dönüşü onurlandırır; kutlaması normal rozetle eş değerde (dönüş, seri kadar değerlidir) |

---

## 22. AI Asistan UI Bileşenleri

Görsel ilke: asistan **mütevazı bir eşlikçi** gibi görünür — otorite kürsüsü gibi değil. İnsan avatarı yok, robot yok, hoca imgesi yok; yalnız filiz-mim ikonu.

| Bileşen | Tasarım |
|---|---|
| **Yüzen asistan düğmesi** | §13'te tanımlı; uzun basış: hızlı eylem menüsü ("Soru sor", "Planımı ayarla") |
| **Bağlamsal sheet** | Yarım yükseklik modal (§13); açılışta bulunduğu ekrana uygun tek öneri ("Yâsîn hakkında konuşalım mı?") + giriş alanı; tam ekrana genişleme tutamacı |
| **Tam ekran sohbet** | Standart sohbet düzeni; üstte "Bismillah Asistanı" başlığı + sınır hatırlatıcısı alt başlık ("Öğrenmene yardım ederim — hüküm vermem"); geçmiş erişimi üst menüde |
| **Kullanıcı balonu** | `primarySoft` zemin, `radius.md` (gönderen köşesi 4), `end` hizalı |
| **Asistan balonu** | `surfaceAlt` zemin, `start` hizalı; yazıyor durumu: üç yumuşak nokta nabzı |
| **AI açıklama etiketi** | Dini içerik taşıyan her asistan balonunun altında kalıcı çip: "AI açıklaması" (`radius.sm`, `textTertiary` kontur) — kapatılamaz, kaydırılınca kaybolmaz |
| **Sohbet içi kaynak kartları** | Asistan ayet/hadis/dua alıntılarsa içerik **balon içinde değil**, balonlar arasında bağımsız kaynak kartı olarak render edilir (§34 sınıf görseliyle: Kur'an kartı, hadis kartı, dua kartı); "asistanın sözü" ile "kaynak" fiziksel olarak ayrışır |
| **Reddediş / âlime yönlendirme stili** | Normal balon + ayırt edici küçük pusula ikonu; kalıp: anlayış → sınır → yapabileceği → yönlendirme; görsel olarak "hata" gibi değil, "yol gösterme" gibi durur |
| **Plan önerisi kartı** | Asistan plan değişikliği önerdiğinde: öneri kartı (mevcut → önerilen, fark vurgusu) + "Uygula" Primary + "Kalsın" Text; uygulama onayı kullanıcıdadır — asistan kendiliğinden plan değiştirmez |

---

## 23. Bildirim ve İzin UI

| Bileşen | Tasarım |
|---|---|
| **Bildirim izni eğitim ekranı** | İzin diyaloğundan ÖNCE bağlam kartı: tek fayda cümlesi ("Namaz vakitlerini nazikçe hatırlatalım mı?") + illüstrasyon + "İzin ver" Primary + "Şimdi değil" Text; sistem diyaloğu ancak olumlu niyetten sonra açılır (izin hakkı yakılmaz) |
| **Namaz hatırlatma ayarları** | Vakit başına toggle + ezan öncesi süre seçimi (segment: yok/5/15/30 dk); tümü tek ekranda, karmaşık alt menü yok |
| **Nazik hatırlatma kartları** | Ayarlar içi önizleme: her bildirim türünün örnek metni görünür — kullanıcı neye izin verdiğini *okur* |
| **Sessiz saat ayarları** | Başlangıç–bitiş saat seçici + "namaz bildirimleri istisna" toggle'ı (varsayılan açık) |
| **Bildirim önizleme örnekleri** | §23-Marka metin kütüphanesinden gerçek örnekler; ton seçimine göre önizleme değişir (kişiselleştirme görünürlüğü, §2/8) |

---

## 24. Formlar ve Girdiler

Ortak kurallar: yükseklik 52dp (çok satırlı hariç); `surfaceAlt` zemin + `radius.md`; odak: 1.5px `color.primary` kontur; hata: `color.error` kontur + altında insani mesaj (`type.caption` kırmızı) — alan asla yalnız renkle "hatalı" bırakılmaz; etiketler alanın üstünde kalıcı (placeholder etiket olarak kullanılmaz); RTL'de metin hizası ve ikon konumu aynalanır.

| Girdi | Kural |
|---|---|
| **Text input** | Üst etiket + alan + yardım/hata satırı; temizle (✕) ikonu doluyken |
| **Arama alanı** | `radius.pill`; büyüteç `start` tarafında; canlı sonuç; boş sonuç Empty State diliyle |
| **Dropdown/select** | Bottom sheet ile açılır (yerleşik dropdown menü değil — dokunma hedefi ve RTL güvenliği); seçili değer alanda görünür |
| **Slider** | Zümrüt dolu ray + 28dp başparmak; değer üstte canlı (`type.h3`); onboarding vakit sorusunda adımlı (5/10/20/30+) |
| **Toggle** | 52×32dp; açık: `color.primary`; kapalıya dönüş nötr (kapalı ≠ hata); etiket toggle'ın `start` tarafında |
| **Segmented control** | `radius.pill` kapsül; seçili segment `surface` + gölge, kapsül zemini `surfaceAlt`; 2–4 seçenek |
| **Checkbox** | 24dp, `radius.sm`; çoklu seçim listelerinde; dokunma hedefi tüm satır |
| **Radio option card** | Onboarding'in ana deseni (§25): tam genişlik kart + seçilince `primarySoft` zemin + zümrüt kontur; radio dairesi `end` tarafında |
| **Tarih/saat seçici** | Platform doğal seçicileri (iOS wheel / Android picker) tema renkleriyle; hicri gösterim gereken yerde çift satır |

---

## 25. Onboarding Bileşenleri

His: sıcak bir sohbet (PRD §22). Görsel dil: bol boşluk (`space.9` soru üstü), tek soru ekranda, yumuşak ilerleme.

| Bileşen | Tasarım |
|---|---|
| **Karşılama ekranı** | `type.display` selam + tek vaat cümlesi + dil seçimi (3 büyük Radio option card) + "Başlayalım" Primary; alt bölgede %5 geometrik desen |
| **Soru ekranı** | Soru `type.h1` + "neden soruyoruz" satırı `type.caption` + cevap bileşeni + alt eylem bölgesi; klavye açılınca eylem butonu klavye üstünde kalır |
| **İlerleme göstergesi** | Üstte ince yumuşak yay (dolan çizgi) — "3/16" sayacı **yok** (baskı hissi); geri ok her soruda var |
| **Seçenek kartları** | Radio option card (§24); cevaplar yargısız eş görsel ağırlıkta ("Yeni başlıyorum" ile "Beş vakit, elhamdülillah" aynı boyda) |
| **Slider sorusu** | Günlük süre için adımlı slider + seçimin insani karşılığı canlı metin ("Günde 10 dakika — gayet gerçekçi") |
| **Çoklu seçim sorusu** | Checkbox kartlar; "bitti" butonu seçim sayısını yansıtır ("2 hedefle devam et") |
| **Atla butonu** | Her soruda `end` üstte Text Button "Atla" — görünür ama sessiz; atlanan soru varsayılan değerle işaretlenir |
| **Plan oluşturma ekranı** | Tören anı: koyu orman zemin + `space.10` boşluk + yumuşak halka animasyonu + aşamalı mikro metinler ("Cevaplarını okuyorum… Planını şekillendiriyorum…") + özet cümle; süre 2.5–3.5s |
| **Tamamlama ekranı** | Plan özeti insan diliyle ("Günde 10 dakika, namaz odaklı, gerçekçi bir yol") + "Panoma git" Primary; kimlik isteği bu ekrandan SONRA gelir (PRD §22) |

---

## 26. Boş Durumlar (Empty States)

Şablon: **küçük illüstrasyon/ikon (soyut-botanik, §18-Marka) + tek cümle umut + tek eylem.** Asla suçlama, asla çıplak "veri yok". Metinler kullanıcının onboarding hedefine göre kişiselleşir.

| Durum | Örnek metin (TR) | Eylem |
|---|---|---|
| Kur'an ilerlemesi yok | "İlk sayfa hâlâ en güzel sayfadır. Bugün bir ayetle başlayalım mı?" | "İlk okumayı kaydet" |
| Zikir tamamlanmamış | "Kalbin bir dakikalık sükûnu hak ediyor." | "Sabah zikirlerine başla" |
| Favori dua yok | "Sana iyi gelen duaları burada biriktirebilirsin." | "Duaları keşfet" |
| Başarı yok | "Rozetlerin yolda — ilk adım en değerlisi." | "Bugünün planına git" |
| AI sohbeti yok | "Merak ettiğin bir şey mi var? Sormaktan çekinme — burada yargı yok." | "İlk soruyu sor" |
| İstatistik yok | "Birkaç gün sonra burada yolculuğun görünmeye başlayacak." | "Bugünün planına git" |

---

## 27. Hata Durumları (Error States)

Ortak dil: **ne oldu (insani) + verin güvende teyidi (yerinde) + tek çözüm eylemi.** Teknik jargon ve hata kodu kullanıcı metninde görünmez (loglara gider).

| Hata | Metin yaklaşımı (TR) | Eylem |
|---|---|---|
| Ağ hatası | "Bağlantı kurulamadı. Çevrimdışı da çalışmaya devam edebilirsin — kayıtların telefonunda güvende." | "Tekrar dene" + çevrimdışı devam |
| Senkron hatası | "Kayıtların telefonunda güvende; bağlantı gelince kendiliğinden eşitlenecek." | Sessiz banner, eylem gerektirmez |
| Konum izni hatası | "Namaz vakitleri için konumuna ihtiyacımız var — ya da şehrini elle seçebilirsin." | "Şehir seç" + "İzin ver" |
| Vakit hesaplama hatası | "Vakitleri hesaplayamadık. Şehrini ve hesaplama yöntemini kontrol edelim mi?" | "Ayarları aç" |
| AI kullanılamıyor | "Asistan şu an ulaşılamıyor. Dilersen dualar ve zikirler her zaman yanında." | "Duaları aç" + "Tekrar dene" |
| İçerik yüklenemedi | "Bu içeriğe şu an ulaşamadık. Az sonra tekrar deneyelim mi?" | "Tekrar dene" |
| Ödeme hatası | "Ödeme tamamlanamadı; hesabından ücret alınmadı. Dilediğinde tekrar deneyebilirsin." | "Tekrar dene" + "Yardım al" |
| Kimlik doğrulama hatası | "Giriş yapamadık. Bağlantını kontrol edip bir daha deneyelim mi?" | "Tekrar dene" + alternatif giriş yöntemi |

---

## 28. Yükleme Durumları (Loading States)

İlke: **genel spinner son çaredir.** Yükleme, içeriğin geleceği yerin iskeletiyle anlatılır.

| Durum | Desen |
|---|---|
| **Skeleton kartlar** | Kartın gerçek anatomisinde krem bloklar + yumuşak parlaklık süpürmesi (1.2s döngü); en fazla 3 iskelet kart |
| **Plan oluşturma** | Tören animasyonu (§25) — bu bir "yükleme" değil, ürün anıdır |
| **AI düşünüyor** | Balon içinde üç nokta nabzı + 4s'i aşarsa mikro metin ("Düşünüyorum…"); stream başlayınca metin akar |
| **İçerik yükleme** | Skeleton; 400ms altı işlemde hiçbir gösterge (titreşim önleme) |
| **Senkron durumu** | Ayarlar'da sessiz satır ("Eşitlendi ✓ / Eşitleniyor…"); ana akışta gösterilmez |
| **Çevrimdışı durum** | Üstte ince sessiz şerit ("Çevrimdışısın — her şey çalışıyor"); kapatılabilir; kırmızı değil `surfaceAlt` |

---

## 29. Hareket (Motion) Sistemi

Karakter: **su gibi — yumuşak giren, yumuşak duran.** Sıçrama (bounce/overshoot) yalnız kutlamalarda ve çok hafif.

| Token | Değer | Kullanım |
|---|---|---|
| `motion.instant` | 100ms · easeOut | Basılma geri bildirimi, toggle |
| `motion.quick` | 200ms · easeOutCubic | Durum değişimi, çip seçimi, ikon dolması |
| `motion.standard` | 300ms · easeInOutCubic | Sayfa geçişleri, sheet açılışı, kart durum geçişi |
| `motion.gentle` | 500ms · easeOutQuart | Halka dolumu, XP yükselmesi, tamamlanma yumuşaması |
| `motion.celebration` | 800ms · easeOutBack (hafif, 1.02 aşım) | Rozet kazanımı, plan tamamlama bandı |

**Desenler:** sayfa geçişi — platform doğal geçişi + hafif paralel soluklaşma; kart tamamlama — halka `motion.gentle` ile dolar, zemin `primarySoft`a `motion.standard` ile geçer; buton basımı — 0.97 ölçek `motion.instant`; ilerleme halkası — açılışta mevcut değere `motion.gentle` ile dolar (0'dan her seferinde dolmaz — sadece ilk görünümde); başarı animasyonu — rozet `motion.celebration` ölçek + altın ışıma opaklık nabzı (parçacık patlaması yok).

**Kurallar:** aynı anda en fazla iki animasyon; hiçbir animasyon dokunmayı bloklamaz (kesilebilir); `MediaQuery.disableAnimations` (reduced motion) tüm süreleri 0'a indirir ve opaklık geçişiyle değiştirir — kutlamalar dahil onurlu statik eşdeğer sunulur.

---

## 30. Haptik Sistemi

İlke: haptik **anlam** taşır, süs değildir; nadir kullanım hissi değerli tutar. Tüm haptikler ayarlardan kapatılabilir.

| Token | Platform karşılığı | Kullanım |
|---|---|---|
| `haptic.tap` | selectionClick | Toggle, segment, seçenek kartı seçimi |
| `haptic.dhikr` | selectionClick (hafif) | Zikir sayacında her sayım — ritim hissi; hedefe 3 kala mediumImpact tek vuruş |
| `haptic.prayer` | mediumImpact | Namaz "kılındı" işareti — günün en anlamlı dokunuşu, belirgin ama sert değil |
| `haptic.completion` | mediumImpact ×2 (120ms ara) | Set/plan tamamlanması, halka dolması |
| `haptic.achievement` | heavyImpact + hafif kuyruk | Rozet/seviye kazanımı — en güçlü haptik, nadir |
| `haptic.error` | notificationError (yumuşak) | Yalnız teknik hata; ibadet bağlamında hata haptiği yok |

**Yasaklar:** kaydırma sırasında haptik; bildirimle birlikte özel titreşim deseni (sistem varsayılanı kullanılır); art arda tekrar eden güçlü haptikler.

---

## 31. Ses Sistemi

**Karar: MVP'de UI ses efekti YOKTUR — uygulama varsayılan olarak sessizdir.** Sükûnet markası, ses çıkarmayan bir üründür; haptik + görsel geri bildirim yeterlidir.

İstisnalar ve gelecek kuralları:

- **Ezan/bildirim sesi:** bildirim sesi sistem varsayılanıdır; opsiyonel nazik bildirim tonu (kısa, yumuşak tek nota) V2'de değerlendirilebilir *(varsayım)* — kullanıcı seçimiyle, asla varsayılan zorlamayla.
- **Kur'an tilaveti (V2):** içerik sesidir, UI sesi değil — okuma deneyiminin parçası olarak ayrı tasarlanır.
- **Mutlak yasaklar:** oyun sesleri (coin, fanfar, level-up cıngılı); **kutsal tilavetin UI efekti olarak kullanımı** (tamamlama anında ayet çalmak ❌); beklenmedik otomatik ses.

---

## 32. Erişilebilirlik Sistemi

Bileşen "bitti" tanımının parçasıdır (§38); sürüm engelleyici standartlar:

- **Kontrast:** tüm metin-zemin çiftleri WCAG AA (normal ≥4.5:1, büyük ≥3:1); `textTertiary` yalnız dekoratif/ipucu; token tablosundaki kontrast notları bağlayıcıdır (§4).
- **Büyük metin:** %200 sistem ölçeklemesinde tüm ekranlar işlevsel — kartlar uzar, metin kırpılmaz, buton metni sarabilir; `type.quran` bağımsız ölçek kontrolü.
- **Ekran okuyucu:** her etkileşimli öğede anlamlı semantik etiket; durumlar cümleyle okunur ("İkindi, vaktinde kılındı"); Arapça içerik `lang=ar` işaretli (VoiceOver/TalkBack ses değişimi); zikir sayacı görme olmadan tam kullanılabilir (dokunuş + haptik + sesli sayı bildirimi); dekoratif öğeler (desen, illüstrasyon) okuyucudan gizlenir.
- **RTL:** §33'e tabidir; RTL'de erişilebilirlik odak sırası da aynalanır.
- **Azaltılmış hareket:** §29'a tabidir.
- **Dokunma hedefleri:** min 48×48dp; kritik günlük eylemler (namaz işareti, sayaç) daha büyük; hedefler arası min `space.2`.
- **Renk körlüğü güvenliği:** zümrüt/altın/nötr ayrımı yalnız tonla değil biçimle de taşınır (dolu/boş halka, ikon farkı); kırmızı-yeşil ayrımına dayanan hiçbir bilgi yoktur (kırmızının alanı zaten teknik hatayla sınırlı).
- **Yalnız renkle anlam yasak:** her renk sinyaline ikon/etiket/biçim eşlik eder (kılındı = dolu halka + etiket; hata = ikon + metin).

---

## 33. Yerelleştirme ve RTL Tasarım Kuralları

- **Metin genişlemesi:** Türkçe ve Arapça, İngilizceden ~%20–35 uzun olabilir — tüm bileşenler esnek genişlik/yükseklikle tasarlanır; buton metni tek satıra sığmazsa buton uzar, metin kırpılmaz; sabit genişlikli metin kutusu yasak.
- **Arapça RTL yerleşimi:** tam ayna (§9); metin hizası, ikon konumu, ilerleme yönü, kaydırma göstergeleri, sohbet balonu hizası dahil; istisna: pusula/kıble, medya oynatma ikonları, rakamlar.
- **Karışık Latin/Arapça dizgiler:** bidi işaretleri doğru kullanılır (Arapça cümle içinde "Bismillah+" Latin logotipi bozulmadan akar); Arapça UI metninde Latin marka adı yön izolasyonu (`⁦…⁩`) ile korunur.
- **Rakamlar:** varsayılan Batı rakamları (0-9) üç dilde de; Arapça yerelde Doğu Arap rakamı (٠-٩) kullanıcı tercihi *(varsayım: ayar V1.x'te)*; namaz saatleri ve istatistikler tabular hizada kalır.
- **Tarih biçimleri:** yerel biçim + hicri karşılık (`type.caption`); hicri tarih yöntem farkı ayarı destekler; hafta başlangıcı yerele göre (TR: Pazartesi, AR bölgeleri: değişken).
- **Namaz adları:** her dilde yerleşik ad kullanılır — TR: Sabah/İmsak, Öğle, İkindi, Akşam, Yatsı · EN: Fajr, Dhuhr, Asr, Maghrib, Isha · AR: الفجر، الظهر، العصر، المغرب، العشاء; çeviri tutarlılığı sözlükle sabitlenir.
- **Font geçişi:** yerel değişince tip sistemi otomatik eşlenir (Latin ↔ IBM Plex Sans Arabic); Kur'an/dua fontları yerelden bağımsız sabittir (Arapça metin her yerelde aynı fontla).
- **Kırpma kuralları:** kutsal metin asla kırpılmaz (§34); UI metni kırpılacaksa üç nokta + tam metne erişim yolu; başlıklar iki satıra sarabilir.

---

## 34. Kutsal İçerik UI Kuralları

Dört içerik sınıfı **şema seviyesinde** ayrışır (PRD §20); her sınıfın sabit görsel imzası vardır ve UI bu imzayı içerik verisinden üretir — elle stil kararı verilmez:

| Sınıf | Görsel imza |
|---|---|
| **Kur'an** | `type.quran` (Uthmanic Hafs) + tamamen temiz zemin + âyet işareti + kaynak satırı ("Yâsîn 36:12" + meal adı); ekranın en itibarlı öğesi |
| **Hadis** | `type.body` blok + **zorunlu kaynak-derece satırı** ("Buhârî 6018 · Sahih") + ince `divider` üst çizgisi + "Hadis" sınıf çipi |
| **Dua** | `type.dua` (Amiri) + sabit blok sırası (Arapça→transliterasyon→çeviri→kaynak, §18) |
| **Zikir** | Dua imzasıyla akraba; sayaç bağlamında adet bilgisi eklenir |
| **İlmî görüş** | `type.body` + "İlmî görüş" çipi + âlim/eser atfı; "birden fazla görüş vardır" kalıbı gerektiğinde görünür |
| **AI açıklaması** | `surfaceAlt` zemin + "AI açıklaması" çipi (`radius.sm`) — kalıcı, kapatılamaz |

**Bağlayıcı kurallar:**

1. **Kur'an ile AI metni asla karıştırılamaz:** farklı font, farklı zemin, farklı çip — üç sinyal birden. AI balonunun içinde ayet metni render edilemez; ayet daima bağımsız Kur'an kartına çıkar (§22).
2. **Hadis kaynaksız-derecesiz render edilemez** — veri eksikse içerik yayına çıkmaz (CMS kuralı).
3. **Kutsal metin dikkatsizce kırpılamaz:** ayet/hadis önizlemede kırpılacaksa anlam bütünlüğü korunur ve tam metne tek dokunuş erişim verilir; ayet ortadan kesilip "…" ile pazarlama kartına konamaz.
4. **Kur'an gövde metninin arkasında dekoratif desen yasak** (Marka §17); dua/hadis bloklarının metin alanında da geçerli.
5. **Allah lafzı ve salavat:** metin kısaltma/kırpma algoritmaları bu ifadelerin ortasından kesemez; TR metinde "(c.c.)", "(s.a.v.)" yazımları içerik sözlüğüyle standarttır.

---

## 35. Koyu Tema Planlaması

Koyu tema MVP'de yayınlanmaz (PRD §28) ama sistem ilk günden hazırlanır:

- **Felsefe:** koyu tema "renkleri ters çevirme" değil, **gece sükûneti** temasıdır — yatsı sonrası zikir, sahur öncesi Kur'an bağlamına hizmet eder.
- **Ön renk yönü** *(varsayım — V2 tasarım aşamasında doğrulanır)*: zemin `#12201B` (koyu yeşil-mürekkep, saf siyah değil) · yüzey `#1A2B24` · primary açılır `#3FA37E` (koyu zeminde AA) · `primarySoft` karşılığı `#1F3A30` · metin `#ECF2EE` / `#9FB0A7` · altın hafif kısılır `#B8964A`.
- **Uygulamada dikkat:** gölgeler koyu temada opaklıkla değil yüzey ton farkıyla anlatılır; geometrik desen opaklığı %5–8'e çıkar; Kur'an metni koyu zeminde kontrast yeniden doğrulanır; kutlama/premium koyu-orman ekranları koyu temada da ayırt edilebilir kalmalıdır.
- **Kodda kural:** hiçbir widget doğrudan hex/renk sabiti kullanmaz — her şey `ColorScheme`/token üzerinden gelir; `Brightness` koşullu tek satır bile yazılmaz (tema nesnesi çözer); ikinci tema, token tablosuna ikinci kolon eklemekle açılabilir olmalıdır.

---

## 36. Design Token Tablosu

Flutter'a birebir çevrilecek konsolide tablo (kaynak: §4–§9, §29):

**Renk** — §4'teki 15 token (`color.primary` → `color.disabled`) aynen.

**Tipografi** — §5'teki 15 token (`type.display` → `type.arabicUI`) aynen.

**Boşluk** — `space.1`(4) `space.2`(8) `space.3`(12) `space.4`(16) `space.5`(20) `space.6`(24) `space.7`(32) `space.8`(40) `space.9`(48) `space.10`(64).

**Yarıçap** — `radius.sm`(8) `radius.md`(12) `radius.lg`(20) `radius.xl`(28) `radius.pill`(999) `radius.full`(daire).

**Gölge** — `shadow.none` · `shadow.xs`(y1/b4/%4) · `shadow.card`(y4/b16/%6) · `shadow.floating`(y6/b20/%10) · `shadow.celebration`(y12/b40/%14); gölge rengi `#1E2B26`.

**Hareket** — `motion.instant`(100ms/easeOut) `motion.quick`(200ms/easeOutCubic) `motion.standard`(300ms/easeInOutCubic) `motion.gentle`(500ms/easeOutQuart) `motion.celebration`(800ms/easeOutBack-hafif).

**Bileşen boyutları:**

| Token | Değer |
|---|---|
| `size.touchTarget` | 48dp min |
| `size.buttonHeight` | 52dp |
| `size.inputHeight` | 52dp |
| `size.bottomNav` | 64dp + safe area |
| `size.fab` | 56dp |
| `size.iconSm / md / lg` | 16 / 24 / 32dp |
| `size.progressRing` | 96dp (Today), 32dp (kart içi) |
| `size.prayerToggle` | 32dp görsel / 48dp+ hedef |
| `size.avatar` | 40dp |
| `size.badgeGrid` | 3 kolon, 96dp rozet |
| `size.maxContentWidth` | 480dp |

---

## 37. Flutter Uygulama Rehberi

*(Kod yok — mimari yön var.)*

- **Tema mimarisi:** tüm token'lar tek `AppTheme` katmanında yaşar: `ColorScheme` (renk token'ları) + `TextTheme` (tip token'ları) + `ThemeExtension` sınıfları (spacing/radius/shadow/motion gibi Material'ın kapsamadığı token setleri). Widget'lar yalnızca `Theme.of(context)` / extension üzerinden okur.
- **Sabit değer yasağı:** `Color(0xFF...)`, elle `EdgeInsets.all(13)`, elle `Duration(milliseconds: 250)` — hepsi lint kuralıyla engellenir; tek meşru kaynak token dosyalarıdır. Bu kural koyu temanın (§35) sigortasıdır.
- **Bileşen kütüphanesi:** tasarım sistemi bileşenleri `core/ui/` (veya `shared/widgets/`) altında feature'lardan bağımsız yaşar; feature ekranları bunları **kompoze eder**, yeniden tanımlamaz. Buton/kart/çip ailesi tek dosya ailesi — kopyala-yapıştır varyant yasak.
- **Feature-first yapı:** Clean Architecture + feature-first klasörleme (Constitution) — `features/today/`, `features/prayer/`… her biri kendi presentation katmanında sistem bileşenlerini kullanır.
- **Metin ve yerelleştirme:** tüm dizgiler ARB üzerinden (sabit yazı lint engelli); `start/end` yerleşim zorunlu (`left/right` lint engelli); RTL, her PR'da Arapça yerelle ekran görüntüsü testiyle doğrulanır.
- **Tipografi uygulaması:** `TextTheme` eşlemesi §5 tablosundaki Flutter notlarına göre; Kur'an/dua fontları `FontLoader` ile paketlenir, lisansları repo'da belgelenir; tabular rakamlar `FontFeature.tabularFigures()`.
- **Duyarlı yerleşim:** `size.maxContentWidth` merkezli `LayoutBuilder` yardımcıları; hiçbir ekran sabit piksel genişliği varsaymaz; küçük ekran (320dp) smoke testi.
- **Erişilebilirlik testi:** her bileşen PR'ında: Semantics ağacı denetimi, %200 metin ölçeği görüntü testi, TalkBack/VoiceOver manuel duman testi; golden testlere büyük-metin ve RTL varyantı dahil edilir.
- **Hareket uygulaması:** `motion.*` token'ları merkezi sabitlerden; `MediaQuery.disableAnimations` kontrolü animasyon yardımcı katmanında tek yerden çözülür.

---

## 38. Bileşen Kabul Kriterleri

Bir bileşen ancak şu 10 koşulun TAMAMI sağlanınca "bitti"dir:

1. **Token uyumu** — renk/boşluk/yarıçap/gölge/hareket yalnız token'lardan; tek sabit değer = ret.
2. **Durum bütünlüğü** — geçerli tüm durumları (default/pressed/selected/completed/disabled/loading/error/empty) tasarlanmış ve uygulanmış.
3. **Yerelleştirme** — TR/EN/AR üç dilde taşan/kırpılan metin olmadan çalışır; sabit yazı içermez.
4. **RTL** — Arapça yerelde doğru aynalanır (gereken istisnalar belgelenmiş).
5. **Erişilebilirlik** — semantik etiket, ≥48dp hedef, AA kontrast, büyük metin ve azaltılmış hareket desteği.
6. **Premium görünüm** — §3 görsel temeliyle uyum; "default Material" gibi duran bileşen ret.
7. **Merhamet dili** — hiçbir durumu suçlayıcı görsel/metin içermez; ibadet bağlamında kırmızı/alarm yok.
8. **Kutsal içerik kuralları** — içerik sınıfı taşıyorsa §34 imzaları eksiksiz (kaynak, çip, font).
9. **Yeniden kullanılabilirlik** — `core/ui` içinde, feature bağımsız, parametreleri belgeli.
10. **Dokümantasyon** — amaç/anatomi/durumlar/erişilebilirlik/yap-yapma beş bölümü yazılmış.

---

## 39. Tasarım QA Kontrol Listesi

Her ekran yayına çıkmadan önce:

**Görsel tutarlılık**
- [ ] Tüm renk/boşluk/yarıçap/gölge değerleri token'lardan mı?
- [ ] Ekranda tek birincil eylem mi var? "Şimdi ne yapmalıyım?" 3 saniyede cevaplanıyor mu?
- [ ] Altın öğe en fazla bir tane mi? Zümrüt alanı ~%10 sınırında mı?
- [ ] Aynı ekranda en fazla iki gölge seviyesi mi var?

**Tipografi & boşluk**
- [ ] Tip hiyerarşisi §5'e uygun mu; satır uzunluğu ~60–70 karakter mi?
- [ ] Kartlar arası `space.6`, bölümler arası `space.7+` ritmi korunmuş mu?

**Erişilebilirlik**
- [ ] AA kontrast, 48dp hedefler, semantik etiketler tamam mı?
- [ ] %200 metin ölçeğinde ekran kırılmıyor mu? Azaltılmış hareket eşdeğeri var mı?

**Yerelleştirme & RTL**
- [ ] TR/EN/AR üçünde taşma/kırpılma yok mu? Türkçe İ dönüşümü doğru mu?
- [ ] Arapça yerelde tam ayna + bidi doğruluğu görüntüyle doğrulandı mı?

**Kutsal içerik**
- [ ] Sınıf imzaları (font/çip/kaynak) eksiksiz mi? Hadislerde derece var mı?
- [ ] Kur'an metni temiz zeminde, kırpılmamış, en itibarlı öğe mi?
- [ ] AI metni her yerde etiketli mi?

**Durumlar & hareket**
- [ ] Empty/error/loading durumları tasarlandı mı (çıplak durum yok)?
- [ ] Animasyonlar `motion.*` token'larında ve kesilebilir mi?

**Marka sesi & merhamet**
- [ ] Metinler Marka Kılavuzu §8–11 tonunda mı? Yasaklı kelime yok mu (kaçırdın/son şans…)?
- [ ] Kaçırılan ibadet/boş gün nötr mü (kırmızı yok, alarm yok)?

**Performans**
- [ ] Liste kaydırma akıcı mı (60fps hedef)? Görseller boyutlandırılmış mı? İskelet 400ms kuralına uyuyor mu?

---

## 40. Nihai Tasarım Sistemi Yönü

Bu tasarım sistemi tek bir işe hizmet eder: **Bismillah'ı dünyanın en yüksek kaliteli İslami yaşam uygulaması yapan görsel ve davranışsal tutarlılığı, ölçekte garanti etmek.**

Sistem üç sözü kodlar:

- **Sükûnet ölçeklenir.** Bir ekran huzurlu tasarlamak kolaydır; bu sistem, iki yüzüncü ekranın da ilk ekran kadar sakin, ferah ve odaklı olmasını token'larla, kurallarla ve kabul kriterleriyle güvence altına alır.
- **Merhamet pikseldedir.** "Asla suçlama" bir metin ilkesi olarak kalmaz — nötr kaçırılmış-vakit rengi, onarılan halka, toparlanma modu paneli olarak sistemin dokusuna işlenmiştir. Bu sistemle yapılmış bir ekran, isteseniz de kullanıcıyı utandıramaz.
- **Edep şemadadır.** Kur'an'ın fontundan AI çipinin köşe yarıçapına kadar kutsal içerik hiyerarşisi bileşenlere gömülüdür; saygı, tasarımcının o günkü dikkatine değil, sistemin kendisine emanettir.

Bundan sonra üretilecek her ekran için ölçüt şudur: **Calm'ın yanında premium, bir mushafın yanında edepli, bir dostun yanında sıcak.** Üçünü birden sağlamayan hiçbir arayüz Bismillah değildir.

---

*Dokümanın sonu. Flutter tema uygulaması, bileşen kütüphanesi ve tüm ekran tasarımları bu dokümana dayanır; çelişki hâlinde sıralama: CLAUDE.md → 01_PRODUCT_PRD.md → 02_BRAND_GUIDELINES.md → bu doküman.*
