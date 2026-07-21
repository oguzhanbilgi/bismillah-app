# Görsel Varlık Rehberi (ASSET_GUIDELINES)

TASK 051 ile oluşturuldu. Bu dosya, Bismillah'a eklenecek **her** görsel
varlık için bağlayıcıdır. Kutsal içerik ve insan görselleri söz konusu
olduğu için kurallar isteğe bağlı değildir.

## 1. Lisans ve kaynak kaydı (zorunlu)

Bir varlık ancak şu üç durumdan biriyle eklenebilir:

1. **Açık lisanslı** (ör. CC0 / CC-BY / uygun bir açık lisans),
2. **Satın alınmış** (ticari kullanım ve uygulama içi dağıtım hakkı dahil),
3. **Özgün üretilmiş** (bu proje için çizilmiş/üretilmiş).

Her varlık için `assets/ASSET_REGISTRY.md` dosyasına şu satırlar eklenir:

- dosya yolu
- kaynak URL'si
- lisans adı ve sürümü
- yazar / hak sahibi
- eklenme tarihi
- attribution gerekiyor mu (evet/hayır)

**Lisans bilgisi olmayan hiçbir görsel commit edilmez.** Doldurma
(placeholder/dummy) görseli de commit edilmez — varlık hazır değilse
bileşenler zaten gradient/ikon fallback'iyle çalışır.

Attribution gerekiyorsa, atıf Profil → "Kaynaklar ve lisanslar" ekranında
gösterilir; kutsal metin okuma alanına atıf yerleştirilmez.

## 2. AI ile üretilen varlıklar

AI ile üretilen bir varlık kullanılırsa kayıtta **dahili olarak** belirtilir:
üretim aracı, tarih ve istem özeti. AI üretimi varlıklar:

- Kur'an metni, hat (kaligrafi) veya dinî sembol üretmek için KULLANILMAZ,
- gerçek bir cami/kişi/olayı temsil ediyormuş gibi sunulmaz.

## 3. Kur'an, cami ve insan görselleri için sınırlar

**Kur'an / kutsal metin**

- Ayet metni dekorasyon olarak kullanılmaz.
- Görsel üzerine okunamayacak kadar küçük ayet yazılmaz.
- Arapça metin kırpılmaz, eğilmez, dekoratif şekle sokulmaz.
- Ayet gösterilen her yerde sure/ayet referansı ve kaynak bulunur.

**Cami / mimari**

- Silüet ve geometrik motifler tercih edilir.
- Belirli bir mezhep/cemaat/kurum sembolü öne çıkarılmaz.
- Üçüncü taraf logo veya marka kullanılmaz.

**İnsan görselleri**

- Çeşitlilik içerir; tek bir etnisite/coğrafya temsili dayatılmaz.
- Doğal ve saygılıdır; performatif dindarlık hissi vermez.
- Yüz aşırı öne çıkarılmaz; ibadet eden kişiler reklam malzemesi gibi
  kullanılmaz.
- Mahremiyet ve kültürel hassasiyet gözetilir; tanınabilir kişiler için
  model izni (release) olmadan kullanılmaz.

## 4. Yerleşim sınırları

Yoğun görsel **kullanılmaz**:

- ayet okuma alanının arkasında,
- meal metninin arkasında,
- ses kontrollerinin altında,
- namaz vakti tablosunun okunabilirliğini bozacak alanlarda,
- küçük ve sık kullanılan işlem ekranlarında.

Görsel **kullanılabilir**: Today hero, onboarding, Learn içerikleri, boş
durumlar ve öneri kartları.

## 5. Format, boyut ve çözünürlük

- Fotoğrafik içerik: **WebP** (tercihen), gerekiyorsa AVIF.
- Çizim/ikon/motif: **SVG kaynaklı vector** veya `CustomPainter` ile çizim.
  Geometrik desenler için bitmap yerine çizim tercih edilir
  (`IslamicPatternBackground` bunu yapar).
- Telefon çözünürlükleri: `1x` temel, `2x` ve `3x` varyantları
  (`assets/images/islamic/2.0x/`, `3.0x/`) Flutter kuralına göre.
- Boyut hedefleri:
  - hero fotoğraf: **≤ 150 KB** (1x), toplam ≤ 400 KB (tüm varyantlar)
  - illüstrasyon: ≤ 80 KB
  - ikon/motif: ≤ 20 KB
  - toplam görsel bütçesi: **≤ 3 MB** (APK büyümesi izlenir)
- Çok büyük bitmap yüklenmez; `cacheWidth`/`cacheHeight` ile bellek sınırlanır.

## 6. Koyu tema

- Koyu temada okunabilirliği düşen görseller için `_dark` sonekli alternatif
  hazırlanır (ör. `today_hero_dark.webp`).
- Alternatif yoksa scrim (`imageOverlayDark`) ile kontrast korunur.
- Renk seçimleri `IslamicVisualTokens` üzerinden yapılır; hex hard-code edilmez.

## 7. Klasör yapısı

```
assets/
  images/islamic/   # fotoğrafik veya illüstratif İslami sahneler
  patterns/         # geometrik desen kaynakları
  illustrations/    # boş durum / onboarding illüstrasyonları
  icons/            # özel ikonlar (Material dışı)
```

Klasörler şimdilik boştur ve **pubspec.yaml'a kayıtlı değildir**. Gerçek
varlık eklendiğinde ilgili yol `pubspec.yaml` altındaki `assets:` listesine
eklenir ve bu dosyadaki kayıt zorunluluğu uygulanır.

## 8. Erişilebilirlik

- Dekoratif görseller `ExcludeSemantics` ile ekran okuyucudan gizlenir.
- Anlam taşıyan görsellere `semanticLabel` verilir.
- Görsel yüklenemezse bileşen sakin fallback gösterir; asla crash etmez.
