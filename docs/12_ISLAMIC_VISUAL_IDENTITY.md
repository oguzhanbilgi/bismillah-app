# İslami Görsel Kimlik İlkeleri

TASK 051 ile eklendi. `02_BRAND_GUIDELINES.md` ve `03_DESIGN_SYSTEM.md` ile
birlikte okunur; çakışma halinde bu iki doküman üstündür. Bu dosya, görsel
atmosferin **nasıl** kurulacağını tanımlar.

## 1. Ton

Bismillah'ın görsel ve sözel tonu:

- **sakin** — göz yormayan, yavaş, ferah
- **umut verici** — "yol açık", "her an yeni bir başlangıç"
- **kapsayıcı** — her seviyeden Müslümanı içine alan
- **yargılamayan** — eksik ibadet asla kırmızı/uyarı diliyle sunulmaz
- **güvenilir** — kaynağı belli, abartısız, ölçülü
- **nazikçe teşvik eden** — davet eder, baskı kurmaz

Kullanıcının hissetmesi gereken: *"Biz de bu yoldayız ve Allah'a yaklaşmaya
çalışıyoruz."*

**Yasak dil:** korku, suçluluk, utandırma, dinî baskı, "geride kaldın",
"kaçırdın" vurgusu, rekabetçi kıyas.

## 2. Görsel kullanım alanları

Cami / Kur'an / İslami yaşam görselleri (gerçek veya illüstratif)
**kullanılabilir**:

- Today hero alanı
- Onboarding adımları
- Learn içerikleri
- Boş durumlar
- Öneri / hatırlatma kartları

**Kullanılmaz** (okunabilirlik ve saygı gereği):

- Ayet okuma alanının arkasında
- Meal metninin arkasında
- Ses kontrollerinin altında
- Namaz vakti tablosunun okunabilirliğini bozacak alanlarda
- Küçük ve sık kullanılan işlem ekranlarında

Kural: **atmosfer içeriğin arkasında durur, önüne geçmez.** Desen opaklığı
`geometricPatternOpacity` token'ıyla sınırlıdır.

## 3. İnsan görselleri

- Çeşitlilik içerir (yaş, etnisite, coğrafya).
- Doğal ve saygılıdır; sahnelenmiş "mükemmel dindar" imajı üretmez.
- Performatif dindarlık hissi vermez.
- Yüz aşırı öne çıkarılmaz; portre yerine bağlam/eylem tercih edilir.
- İbadet eden kişiler reklam malzemesi gibi kullanılmaz.
- Mahremiyet ve kültürel hassasiyet gözetilir; tanınabilir kişi için model
  izni olmadan görsel kullanılmaz.

## 4. Kutsal içerik

- Kur'an ayetleri **dekorasyon amacıyla** kullanılmaz.
- Ayet gösterilen her yerde **sure/ayet referansı ve kaynak** bulunur
  ("no source, no render").
- Görsel üzerine okunamayacak kadar küçük ayet yazılmaz.
- Arapça metin kırpılmaz, eğilmez, dekoratif şekle dönüştürülmez.
- Ayet kartının anlam ve kaynak bütünlüğü korunur; meal ile ayet görsel
  olarak ayrılır.
- Ayet seçimi bu katmanın işi değildir: bileşen içerik **almaz, seçmez**.

## 5. Token sözleşmesi

Görsel kimlik renkleri `IslamicVisualTokens` (ThemeExtension) üzerinden
okunur. Ekranlarda hex/`AppColors` doğrudan kullanılmaz.

| Token | Kullanım |
|---|---|
| `sacredSurface` | Ayet/meal gibi kutsal içeriğin temiz zemini |
| `sacredSurfaceMuted` | Kutsal içeriğe eşlik eden ikincil sakin yüzey |
| `spiritualGreen` / `spiritualGreenStrong` | Manevi vurgu, hero gradient tabanı |
| `mosqueSilhouette` | Dekoratif cami/geometri siluet dolgusu |
| `quranAccent` | Kur'an bağlamına özel sakin vurgu (**altın değildir**) |
| `warmBackground` | Sıcak sayfa zemini |
| `imageOverlayLight` / `imageOverlayDark` | Görsel üzeri okunabilirlik scrim'i |
| `verseCardSurface` | Ayet kartı düz zemini |
| `geometricPatternOpacity` | Desen maksimum opaklığı |
| `heroGradientStart` / `heroGradientEnd` | Görselsiz hero fallback gradient'i |

Her token'ın light ve dark karşılığı tanımlıdır. Altın (`accentGold`) yalnız
kazanılmış an/premium içindir; dekor veya Kur'an vurgusu olarak kullanılmaz.

## 6. Ortak bileşenler

- `IslamicPatternBackground` — dekoratif, dokunma ve semantics'e karışmaz,
  animasyonsuz, bitmap'siz.
- `SpiritualHeroCard` — opsiyonel yerel görsel + garanti gradient fallback,
  scrim ile okunabilirlik, tek anlamlı semantic label.
- `ReferencedVerseCard` — Arapça + meal + referans + kaynak; kırpma yok,
  zemin düz.
- `GentleEmptyState` — motif + umut veren tek cümle + tek aksiyon.

## 7. Erişilebilirlik ve performans

- Metin ölçeği 1.0–1.5 aralığında taşma olmaz (sabit yükseklik kullanılmaz).
- Dekoratif katmanlar `ExcludeSemantics` ile gizlenir; anlamlı görseller
  etiketlenir.
- Sonsuz/otomatik animasyon eklenmez (reduced-motion güvenli).
- Görsel bulunamazsa bileşen sakin fallback'e düşer, asla crash etmez.
- Network görsel kullanılmaz; yalnız yerel asset.
