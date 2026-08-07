import 'package:flutter/material.dart';

/// Renk token'ları — hex değerlerinin projede yaşadığı TEK yer
/// (03_DESIGN_SYSTEM §4; 06_FLUTTER_ARCHITECTURE §9).
///
/// Widget'lar bu sınıfı DOĞRUDAN kullanmaz; `Theme.of(context)` ve
/// `AppThemeExtension` üzerinden erişir. Kurallar:
/// - `accentGold` yalnız kazanılmış an/premium vurgusu; buton/link/dekor değil.
/// - `error` yalnız teknik hatalar; kaçırılan ibadet ASLA error rengi almaz.
///
/// RDX-01A — premium palet temeli. Açık tema sıcak krem zemin + yumuşak taş
/// yüzeyler + DERİN zümrüt eylem rengi üzerine kuruludur; koyu tema ise gri
/// değil, derin zümrüt/petrol ailesindedir. Her iki temada da altın ölçülü
/// kalır: neon, parlama (glow) ve doygun vurgu YOKTUR.
///
/// Kontrast (WCAG 2.1, kendi zemini üzerinde ölçülmüştür):
/// - açık: birincil metin ~12:1, ikincil ~6.2:1, üçüncül ~4.5:1
/// - koyu: birincil metin ~12.7:1, ikincil ~8.6:1, üçüncül ~5.3:1
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // AÇIK TEMA — çekirdek marka
  // ---------------------------------------------------------------------------

  // Kimlik: derin zümrüt. Eylem/marka rengidir; parlak yeşil DEĞİLDİR.
  static const Color primary = Color(0xFF21483D); // Derin zümrüt
  static const Color primaryDark = Color(0xFF16342B); // Koyu orman
  static const Color primarySoft = Color(0xFFDDE8E2); // Zümrüt yıkaması

  // Zeminler: sıcak krem zemin, üzerinde daha AÇIK yüzey (kart yükselir).
  static const Color background = Color(0xFFF7F3EA); // Sıcak krem
  static const Color surface = Color(0xFFFFFDF8); // Kırık beyaz kart
  static const Color surfaceAlt = Color(0xFFF0EADC); // Yumuşak taş/bej

  /// Yüzey üstünde bir kademe daha yükselen katman (sheet, seçili satır).
  static const Color surfaceElevated = Color(0xFFFBF7EE);

  /// Vurgu: sıcak, ölçülü altın.
  ///
  /// Yön olarak verilen parlak altın (#C89543) sıcak krem zemin üzerinde
  /// yalnız **2.4:1** kontrast verir — küçük bir rozet/ikon olarak
  /// seçilemezdi. Bu yüzden aynı sıcak aileden bir tık DERİN antik altın
  /// seçildi (~3.4:1, metin dışı öğeler için WCAG 3:1 eşiğinin üstü).
  /// Koyu temada zemin koyu olduğu için parlak altın korunur.
  static const Color accentGold = Color(0xFFAB7C2C);

  // Metin
  static const Color textPrimary = Color(0xFF20342E); // Mürekkep
  static const Color textSecondary = Color(0xFF4F5F57); // Duman (~6.2:1)
  static const Color textTertiary = Color(0xFF66746C); // Sis (~4.5:1)

  // Çizgi ve durumlar
  static const Color divider = Color(0xFFE7DDCC);
  static const Color success = Color(0xFF2E7D5B);
  static const Color warning = Color(0xFFB8802F);
  static const Color error = Color(0xFFB4534F); // Yalnız teknik hata
  static const Color disabled = Color(0xFFC3CCC6);

  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Gölge mürekkebi — saf siyah DEĞİL (03_DESIGN_SYSTEM §8).
  static const Color shadowInk = textPrimary;

  // ---------------------------------------------------------------------------
  // KOYU TEMA — çekirdek marka
  //
  // Koyu tema NÖTR GRİ DEĞİLDİR: zemin de yüzeyler de derin zümrüt/petrol
  // ailesindendir. Eylem rengi koyu zeminde okunabilmek için açılır; bu bir
  // "parlama" değil, kontrast gereğidir.
  // ---------------------------------------------------------------------------

  static const Color primaryOnDark = Color(0xFF4FBF95); // Okunur zümrüt
  static const Color primaryStrongOnDark = Color(0xFF35A67C);
  static const Color primarySoftDark = Color(0xFF10534A); // Zümrüt konteyner

  /// Açık zümrüt üzerine gelen metin/ikon — koyu zeminde beyaz kullanılmaz.
  static const Color onPrimaryDark = Color(0xFF04231F);

  static const Color backgroundDark = Color(0xFF032F2C); // Derin petrol
  static const Color surfaceDark = Color(0xFF073A36); // Hafif yükselmiş
  static const Color surfaceAltDark = Color(0xFF0D4540); // Daha yükselmiş
  static const Color surfaceElevatedDark = Color(0xFF104E48);

  static const Color accentGoldDark = Color(0xFFD6A451);

  static const Color textPrimaryDark = Color(0xFFF5EFE4); // Sıcak kırık beyaz
  static const Color textSecondaryDark = Color(0xFFC2C9BD); // (~8.6:1)
  static const Color textTertiaryDark = Color(0xFF93A096); // (~5.3:1)

  static const Color dividerDark = Color(0xFF14514B);
  static const Color successDark = Color(0xFF4FBE8E);
  static const Color warningDark = Color(0xFFD9A85A);
  static const Color errorDark = Color(0xFFE08C88);
  static const Color disabledDark = Color(0xFF4A5C57);

  /// Koyu temada gölge, zeminden DAHA KOYU olmalıdır; mürekkep tonu koyu
  /// zeminde görünmez kalırdı.
  static const Color shadowInkDark = Color(0xFF01100F);

  // ---------------------------------------------------------------------------
  // İslami görsel kimlik paleti (TASK 051) — `IslamicVisualTokens` üzerinden
  // okunur; widget'lar bu sabitleri DOĞRUDAN kullanmaz. Amaç sıcak, sakin ve
  // güvenilir bir atmosfer; kutsal metin okunabilirliği ASLA düşürülmez.
  // ---------------------------------------------------------------------------

  // Açık tema
  // Saf beyaz DEĞİL (TASK 054): kâğıt hissi veren çok hafif sıcak kırık
  // beyaz — kontrastı düşürmez, "jenerik beyaz kart" hissini kırar.
  static const Color sacredSurfaceLight = surface;
  static const Color sacredSurfaceMutedLight = Color(0xFFF4EFE3);
  static const Color spiritualGreenLight = primary;
  static const Color spiritualGreenStrongLight = primaryDark;

  /// Cami/mimari siluet çizimlerinin dolgu rengi (dekoratif).
  static const Color mosqueSilhouetteLight = Color(0xFF1C4034);

  /// Kur'an bağlamına özel sakin vurgu — `accentGold` DEĞİLDİR
  /// (altın yalnız kazanılmış an/premium içindir).
  static const Color quranAccentLight = Color(0xFF16705C);
  static const Color warmBackgroundLight = background;
  static const Color verseCardSurfaceLight = Color(0xFFFCF9F2);
  static const Color heroGradientStartLight = Color(0xFF21483D);
  static const Color heroGradientEndLight = Color(0xFF16342B);

  // Sıcak yüzey katmanı (TASK 054) — beyaz kart monotonluğunu kırar.
  // Kartlar artık tek bir "surface" yerine üç tonal aileden birini kullanır:
  // kum (sıcak/karşılama), adaçayı (sakin/manevi) ve düz surface.

  /// Sıcak kum yüzeyi — karşılama ve devam ettirme kartları.
  static const Color sandSurfaceLight = Color(0xFFF5EDDF);

  /// Sakin adaçayı yüzeyi — Kur'an ve manevi bölümler.
  static const Color sageSurfaceLight = Color(0xFFE6EEE8);

  /// Tonal bölüm zemini — ekran içi grupları ayırır (kart DEĞİL).
  static const Color sectionSurfaceLight = Color(0xFFF2ECE0);

  /// Border'lı kart varyantının kenar rengi — gölge yerine çizgi.
  static const Color surfaceBorderLight = divider;

  /// Kontrollü gece laciverti — akşam/yatsı hissi ve derinlik vurgusu.
  /// Neon veya parlak DEĞİLDİR; yalnız sakin kontrast içindir.
  static const Color nightCalmLight = Color(0xFF23384A);

  // Koyu tema karşılıkları — `AppTheme.dark()` tarafından bağlanır.
  static const Color sacredSurfaceDark = surfaceDark;
  static const Color sacredSurfaceMutedDark = surfaceAltDark;
  static const Color spiritualGreenDark = primaryOnDark;
  static const Color spiritualGreenStrongDark = primaryStrongOnDark;
  static const Color mosqueSilhouetteDark = Color(0xFF9FC4B5);
  static const Color quranAccentDark = Color(0xFF5FCFAA);
  static const Color warmBackgroundDark = backgroundDark;
  static const Color verseCardSurfaceDark = Color(0xFF08423C);
  static const Color heroGradientStartDark = Color(0xFF0A4A42);
  static const Color heroGradientEndDark = Color(0xFF032823);

  // Sıcak yüzey katmanının koyu karşılıkları (TASK 054): koyu temada
  // "sıcaklık" parlaklıkla değil, hafif kırmızı/sarı kayması ile verilir.
  static const Color sandSurfaceDark = Color(0xFF123F35);
  static const Color sageSurfaceDark = Color(0xFF0B3E39);
  static const Color sectionSurfaceDark = Color(0xFF05332F);
  static const Color surfaceBorderDark = dividerDark;
  static const Color nightCalmDark = Color(0xFF9DB4C6);

  /// Görsel üzerine metin okunabilirliği için scrim'ler (her iki temada da
  /// aynı amaçla kullanılır; alfa değeri kontrastı garanti eder).
  static const Color imageOverlayLight = Color(0x40FFFFFF);
  static const Color imageOverlayDark = Color(0x99042320);
}
