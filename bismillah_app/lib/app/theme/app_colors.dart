import 'package:flutter/material.dart';

/// Renk token'ları — hex değerlerinin projede yaşadığı TEK yer
/// (03_DESIGN_SYSTEM §4; 06_FLUTTER_ARCHITECTURE §9).
///
/// Widget'lar bu sınıfı DOĞRUDAN kullanmaz; `Theme.of(context)` ve
/// `AppThemeExtension` üzerinden erişir. Kurallar:
/// - `accentGold` yalnız kazanılmış an/premium vurgusu; buton/link/dekor değil.
/// - `error` yalnız teknik hatalar; kaçırılan ibadet ASLA error rengi almaz.
abstract final class AppColors {
  // Kimlik
  static const Color primary = Color(0xFF0B6E4F); // Zümrüt
  static const Color primaryDark = Color(0xFF08503A); // Koyu orman
  static const Color primarySoft = Color(0xFFDCEDE4); // Açık zümrüt

  // Zeminler
  static const Color background = Color(0xFFFAF8F4); // Sıcak beyaz
  static const Color surface = Color(0xFFFFFFFF); // Kart beyazı
  static const Color surfaceAlt = Color(0xFFF3EEE5); // Krem

  // Vurgu
  static const Color accentGold = Color(0xFFC9A24B); // Yumuşak altın

  // Metin
  static const Color textPrimary = Color(0xFF1E2B26); // Mürekkep
  static const Color textSecondary = Color(0xFF5C6B64); // Duman
  static const Color textTertiary = Color(0xFF93A29A); // Sis

  // Çizgi ve durumlar
  static const Color divider = Color(0xFFE9E4DA);
  static const Color success = Color(0xFF2E9E6B);
  static const Color warning = Color(0xFFD99A3D);
  static const Color error = Color(0xFFC25E5E); // Yalnız teknik hata
  static const Color disabled = Color(0xFFC7CFC9);

  static const Color onPrimary = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // İslami görsel kimlik paleti (TASK 051) — `IslamicVisualTokens` üzerinden
  // okunur; widget'lar bu sabitleri DOĞRUDAN kullanmaz. Amaç sıcak, sakin ve
  // güvenilir bir atmosfer; kutsal metin okunabilirliği ASLA düşürülmez.
  // ---------------------------------------------------------------------------

  // Açık tema
  // Saf beyaz DEĞİL (TASK 054): kâğıt hissi veren çok hafif sıcak kırık
  // beyaz — kontrastı düşürmez, "jenerik beyaz kart" hissini kırar.
  static const Color sacredSurfaceLight = Color(0xFFFDFBF7);
  static const Color sacredSurfaceMutedLight = Color(0xFFF6F2EA);
  static const Color spiritualGreenLight = primary;
  static const Color spiritualGreenStrongLight = primaryDark;

  /// Cami/mimari siluet çizimlerinin dolgu rengi (dekoratif).
  static const Color mosqueSilhouetteLight = Color(0xFF1E4A3C);

  /// Kur'an bağlamına özel sakin vurgu — `accentGold` DEĞİLDİR
  /// (altın yalnız kazanılmış an/premium içindir).
  static const Color quranAccentLight = Color(0xFF12836A);
  static const Color warmBackgroundLight = background;
  static const Color verseCardSurfaceLight = Color(0xFFFBF9F5);
  static const Color heroGradientStartLight = Color(0xFF0B6E4F);
  static const Color heroGradientEndLight = Color(0xFF08503A);

  // Sıcak yüzey katmanı (TASK 054) — beyaz kart monotonluğunu kırar.
  // Kartlar artık tek bir "surface" yerine üç tonal aileden birini kullanır:
  // kum (sıcak/karşılama), adaçayı (sakin/manevi) ve düz surface.

  /// Sıcak kum yüzeyi — karşılama ve devam ettirme kartları.
  static const Color sandSurfaceLight = Color(0xFFF6EFE3);

  /// Sakin adaçayı yüzeyi — Kur'an ve manevi bölümler.
  static const Color sageSurfaceLight = Color(0xFFE8F0EA);

  /// Tonal bölüm zemini — ekran içi grupları ayırır (kart DEĞİL).
  static const Color sectionSurfaceLight = Color(0xFFF4F0E8);

  /// Border'lı kart varyantının kenar rengi — gölge yerine çizgi.
  static const Color surfaceBorderLight = Color(0xFFE4DDD0);

  /// Kontrollü gece laciverti — akşam/yatsı hissi ve derinlik vurgusu.
  /// Neon veya parlak DEĞİLDİR; yalnız sakin kontrast içindir.
  static const Color nightCalmLight = Color(0xFF23384A);

  // Koyu tema karşılıkları (AppTheme.dark() V2'de bağlanacak; token'lar hazır)
  static const Color sacredSurfaceDark = Color(0xFF161D1A);
  static const Color sacredSurfaceMutedDark = Color(0xFF1E2622);
  static const Color spiritualGreenDark = Color(0xFF4FBF95);
  static const Color spiritualGreenStrongDark = Color(0xFF2E9E6B);
  static const Color mosqueSilhouetteDark = Color(0xFF9FC4B5);
  static const Color quranAccentDark = Color(0xFF5FCFAA);
  static const Color warmBackgroundDark = Color(0xFF101614);
  static const Color verseCardSurfaceDark = Color(0xFF17201C);
  static const Color heroGradientStartDark = Color(0xFF0A3D2C);
  static const Color heroGradientEndDark = Color(0xFF06251B);

  // Sıcak yüzey katmanının koyu karşılıkları (TASK 054): koyu temada
  // "sıcaklık" parlaklıkla değil, hafif kırmızı/sarı kayması ile verilir.
  static const Color sandSurfaceDark = Color(0xFF221E19);
  static const Color sageSurfaceDark = Color(0xFF17231D);
  static const Color sectionSurfaceDark = Color(0xFF141A17);
  static const Color surfaceBorderDark = Color(0xFF2C3531);
  static const Color nightCalmDark = Color(0xFF9DB4C6);

  /// Görsel üzerine metin okunabilirliği için scrim'ler (her iki temada da
  /// aynı amaçla kullanılır; alfa değeri kontrastı garanti eder).
  static const Color imageOverlayLight = Color(0x40FFFFFF);
  static const Color imageOverlayDark = Color(0x990E1A15);
}
