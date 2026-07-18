# UI Denetimi — TASK 051

Mevcut ekranların İslami görsel kimlik açısından kısa teknik değerlendirmesi.
Bu görevde **hiçbir ekran redesign edilmedi**; bulgular sonraki görevler için
sıraya alındı. İlkeler: `12_ISLAMIC_VISUAL_IDENTITY.md`.

## Ekran bazlı bulgular

| Ekran | Bulgu | Öneri (sonraki görev) |
|---|---|---|
| **Today** | Üst alan yalnız metin (selamlama + tek satır); ekranın kimliği kart listesine bırakılmış. Kartlar tutarlı ama atmosfer yok. | `SpiritualHeroCard` ile sakin bir hero; kart yapısı korunur. |
| **Prayer** | 394 satır, 4 ayrı kart; işlevsel ve okunur. Vakit tablosunun okunabilirliği kritik. | Görsel EKLENMEZ; yalnız zemin token'ı (`warmBackground`) hizalaması. |
| **Quran home / Oku** | Arama + hedef + devam + 114 satırlık katalog aynı akışta; yoğun ama işlevsel. Kur'an kimliği zayıf (jenerik liste). | Başlık alanında düşük opaklıklı desen; liste satırları değişmez. |
| **Quran reader** | En güçlü ekran (Tanzil + meal + kaynak atfı doğru). Arka planı temiz kalmalı. | Görsel/desen EKLENMEZ (kural gereği). |
| **Quran progress** | Veri doğru; görsel dil çok nötr (gri barlar). | `spiritualGreen` vurgusu; grafik yapısı değişmez. |
| **Learn** | 21 satır, tek placeholder kart — en boş ekran. | `GentleEmptyState` + illüstrasyon alanı. |
| **Profile** | 195 satır, düz liste; kimlik yok. | Sonraki görevde başlık alanı; öncelik düşük. |
| **Onboarding** | Welcome'da ikon + metin; ilk izlenim jenerik. | `SpiritualHeroCard` en yüksek etkili yer. |
| **Bottom nav** | Tutarlı, token'lara bağlı, sorun yok. | Değişiklik gerekmez. |

## Ortak bileşen / sistem bulguları

- **Tekrar eden ama ortaklaşmamış kalıplar:** "başlık + açıklama + tek buton"
  kartı en az 4 ekranda elle kuruluyor (Today Kur'an merkezi, Quran devam,
  Learn, onboarding). `SpiritualHeroCard` / `GentleEmptyState` bunu
  ortaklaştırmak için eklendi.
- **Token altyapısı sağlam:** hex'ler yalnız `AppColors`'ta; spacing/radius/
  shadow token'ları tutarlı kullanılıyor. Yeni tokenlar bu mimariye ayrı bir
  `ThemeExtension` olarak eklendi (mevcut `AppThemeExtension` bozulmadı).
- **Dark mode:** yalnız `AppTheme.light()` var; `AppTheme.dark()` V2'de
  planlı. Yeni token'ların koyu karşılıkları şimdiden tanımlandı
  (`IslamicVisualTokens.dark()`), tema bağlandığında hazır olacak.
- **Ham `BoxDecoration` kullanımı:** onboarding welcome, quran reader ve
  quran screen'de doğrudan `BoxDecoration` var; renkler token'dan geldiği
  için ihlal değil, ancak ortaklaştırma adayı.
- **Asset altyapısı yok:** `pubspec.yaml`'da yalnız Kur'an JSON asset'leri
  kayıtlı; görsel klasörü/lisans süreci yoktu. TASK 051 ile klasör yapısı ve
  `assets/ASSET_GUIDELINES.md` eklendi (gerçek görsel eklenmedi).

## Risk notları

- **Okunabilirlik:** ayet/meal ve namaz vakti alanlarına desen veya görsel
  girmesi en büyük risk; ilke dokümanında açıkça yasaklandı ve
  `ReferencedVerseCard` düz zemin kullanacak şekilde tasarlandı.
- **Dikkat dağılımı:** hero görselleri kutsal içerikten dikkat çalabilir;
  bu yüzden hero yalnız Today/onboarding/Learn/boş durumlarda önerildi.
- **Performans / boyut:** debug APK hâlihazırda ~223 MB (çoğu Kur'an JSON +
  debug sembolleri). Bitmap görseller bütçeyi hızla şişirebileceği için
  desen `CustomPainter` ile çizilir ve asset bütçesi ≤ 3 MB olarak
  sınırlandı.
- **Erişilebilirlik:** dekoratif katmanların semantics'i kirletmesi riski;
  tüm dekoratif katmanlar `ExcludeSemantics` + `IgnorePointer` ile kapatıldı.
