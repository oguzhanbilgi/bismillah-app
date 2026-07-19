import 'package:bismillah_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// İslami görsel kimlik token'ları (TASK 051).
///
/// Mevcut [ThemeExtension] mimarisini bozmadan AYRI bir uzantı olarak yaşar:
/// `AppThemeExtension` (marka temeli) olduğu gibi kalır, bu uzantı yalnız
/// atmosfer/görsel katmanı için semantik token sağlar.
///
/// Kurallar:
/// - Widget'lar hex/`AppColors` DEĞİL, yalnız bu uzantıyı okur.
/// - Kutsal metin (Arapça ayet / meal) okunabilirliği bu token'larla ASLA
///   düşürülmez: desen opaklığı düşüktür ve ayet yüzeyleri düz renktir.
/// - `quranAccent` altın DEĞİLDİR; altın yalnız kazanılmış an/premium içindir.
@immutable
class IslamicVisualTokens extends ThemeExtension<IslamicVisualTokens> {
  const IslamicVisualTokens({
    required this.sacredSurface,
    required this.sacredSurfaceMuted,
    required this.spiritualGreen,
    required this.spiritualGreenStrong,
    required this.mosqueSilhouette,
    required this.quranAccent,
    required this.warmBackground,
    required this.imageOverlayLight,
    required this.imageOverlayDark,
    required this.verseCardSurface,
    required this.geometricPatternOpacity,
    required this.heroGradientStart,
    required this.heroGradientEnd,
    required this.sandSurface,
    required this.sageSurface,
    required this.sectionSurface,
    required this.surfaceBorder,
    required this.nightCalm,
  });

  /// Ayet/meal gibi kutsal içeriğin oturduğu TEMİZ yüzey — arkasına yoğun
  /// görsel veya desen girmez.
  final Color sacredSurface;

  /// Kutsal içeriğe eşlik eden ikincil sakin yüzey (ör. kaynak satırı alanı).
  final Color sacredSurfaceMuted;

  final Color spiritualGreen;
  final Color spiritualGreenStrong;

  /// Dekoratif cami/mimari siluetlerin dolgu rengi.
  final Color mosqueSilhouette;

  /// Kur'an bağlamına özel sakin vurgu rengi.
  final Color quranAccent;

  final Color warmBackground;

  /// Açık görsellerin üzerine binen yumuşak scrim.
  final Color imageOverlayLight;

  /// Metin okunabilirliğini garanti eden koyu scrim (hero görselleri).
  final Color imageOverlayDark;

  /// Ayet kartı zemini — düz renktir, desen/görsel ile karartılmaz.
  final Color verseCardSurface;

  /// Geometrik desenin maksimum opaklığı (0–1). Düşük tutulur: desen
  /// atmosfer içindir, içerikle YARIŞMAZ.
  final double geometricPatternOpacity;

  final Color heroGradientStart;
  final Color heroGradientEnd;

  // ---------------------------------------------------------------------
  // Sıcak yüzey ailesi (TASK 054)
  //
  // Amaç: art arda dizilen aynı beyaz kart hissini kırmak. Kartlar rolüne
  // göre farklı tonal aileden yüzey alır; hepsine ağır gölge VERİLMEZ.
  // ---------------------------------------------------------------------

  /// Sıcak kum yüzeyi — karşılama/devam ettirme gibi davetkâr kartlar.
  final Color sandSurface;

  /// Sakin adaçayı yüzeyi — Kur'an ve manevi bölümler.
  final Color sageSurface;

  /// Ekran içi tonal bölüm zemini (kart değil, grup ayracı).
  final Color sectionSurface;

  /// Gölge yerine çizgiyle ayrılan kart varyantının kenar rengi.
  final Color surfaceBorder;

  /// Kontrollü gece laciverti — sakin derinlik vurgusu (neon değil).
  final Color nightCalm;

  /// Hero alanlarında görsel yoksa kullanılan güvenli gradient fallback.
  LinearGradient get heroGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [heroGradientStart, heroGradientEnd],
  );

  /// Kur'an bölümleri için sıcak, düşük kontrastlı tonal gradient.
  /// Hero gradient'inden DAHA AÇIKTIR: üzerine koyu metin gelir.
  LinearGradient get warmSectionGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sandSurface, sageSurface],
  );

  static const IslamicVisualTokens _light = IslamicVisualTokens(
    sacredSurface: AppColors.sacredSurfaceLight,
    sacredSurfaceMuted: AppColors.sacredSurfaceMutedLight,
    spiritualGreen: AppColors.spiritualGreenLight,
    spiritualGreenStrong: AppColors.spiritualGreenStrongLight,
    mosqueSilhouette: AppColors.mosqueSilhouetteLight,
    quranAccent: AppColors.quranAccentLight,
    warmBackground: AppColors.warmBackgroundLight,
    imageOverlayLight: AppColors.imageOverlayLight,
    imageOverlayDark: AppColors.imageOverlayDark,
    verseCardSurface: AppColors.verseCardSurfaceLight,
    geometricPatternOpacity: 0.05,
    heroGradientStart: AppColors.heroGradientStartLight,
    heroGradientEnd: AppColors.heroGradientEndLight,
    sandSurface: AppColors.sandSurfaceLight,
    sageSurface: AppColors.sageSurfaceLight,
    sectionSurface: AppColors.sectionSurfaceLight,
    surfaceBorder: AppColors.surfaceBorderLight,
    nightCalm: AppColors.nightCalmLight,
  );

  static const IslamicVisualTokens _dark = IslamicVisualTokens(
    sacredSurface: AppColors.sacredSurfaceDark,
    sacredSurfaceMuted: AppColors.sacredSurfaceMutedDark,
    spiritualGreen: AppColors.spiritualGreenDark,
    spiritualGreenStrong: AppColors.spiritualGreenStrongDark,
    mosqueSilhouette: AppColors.mosqueSilhouetteDark,
    quranAccent: AppColors.quranAccentDark,
    warmBackground: AppColors.warmBackgroundDark,
    imageOverlayLight: AppColors.imageOverlayLight,
    imageOverlayDark: AppColors.imageOverlayDark,
    verseCardSurface: AppColors.verseCardSurfaceDark,
    // Koyu zeminde desen daha hızlı kaybolduğu için bir tık yüksek.
    geometricPatternOpacity: 0.07,
    heroGradientStart: AppColors.heroGradientStartDark,
    heroGradientEnd: AppColors.heroGradientEndDark,
    sandSurface: AppColors.sandSurfaceDark,
    sageSurface: AppColors.sageSurfaceDark,
    sectionSurface: AppColors.sectionSurfaceDark,
    surfaceBorder: AppColors.surfaceBorderDark,
    nightCalm: AppColors.nightCalmDark,
  );

  static IslamicVisualTokens light() => _light;

  /// Koyu tema karşılığı — `AppTheme.dark()` (V2) bağlandığında hazırdır.
  static IslamicVisualTokens dark() => _dark;

  /// Kısa erişim. Uzantı kayıtlı değilse (ör. çıplak `ThemeData` kullanan
  /// testler) açık tema varsayılanına düşer — widget ASLA crash etmez.
  static IslamicVisualTokens of(BuildContext context) =>
      Theme.of(context).extension<IslamicVisualTokens>() ?? _light;

  @override
  IslamicVisualTokens copyWith({
    Color? sacredSurface,
    Color? sacredSurfaceMuted,
    Color? spiritualGreen,
    Color? spiritualGreenStrong,
    Color? mosqueSilhouette,
    Color? quranAccent,
    Color? warmBackground,
    Color? imageOverlayLight,
    Color? imageOverlayDark,
    Color? verseCardSurface,
    double? geometricPatternOpacity,
    Color? heroGradientStart,
    Color? heroGradientEnd,
    Color? sandSurface,
    Color? sageSurface,
    Color? sectionSurface,
    Color? surfaceBorder,
    Color? nightCalm,
  }) {
    return IslamicVisualTokens(
      sacredSurface: sacredSurface ?? this.sacredSurface,
      sacredSurfaceMuted: sacredSurfaceMuted ?? this.sacredSurfaceMuted,
      spiritualGreen: spiritualGreen ?? this.spiritualGreen,
      spiritualGreenStrong: spiritualGreenStrong ?? this.spiritualGreenStrong,
      mosqueSilhouette: mosqueSilhouette ?? this.mosqueSilhouette,
      quranAccent: quranAccent ?? this.quranAccent,
      warmBackground: warmBackground ?? this.warmBackground,
      imageOverlayLight: imageOverlayLight ?? this.imageOverlayLight,
      imageOverlayDark: imageOverlayDark ?? this.imageOverlayDark,
      verseCardSurface: verseCardSurface ?? this.verseCardSurface,
      geometricPatternOpacity:
          geometricPatternOpacity ?? this.geometricPatternOpacity,
      heroGradientStart: heroGradientStart ?? this.heroGradientStart,
      heroGradientEnd: heroGradientEnd ?? this.heroGradientEnd,
      sandSurface: sandSurface ?? this.sandSurface,
      sageSurface: sageSurface ?? this.sageSurface,
      sectionSurface: sectionSurface ?? this.sectionSurface,
      surfaceBorder: surfaceBorder ?? this.surfaceBorder,
      nightCalm: nightCalm ?? this.nightCalm,
    );
  }

  @override
  IslamicVisualTokens lerp(
    covariant ThemeExtension<IslamicVisualTokens>? other,
    double t,
  ) {
    if (other is! IslamicVisualTokens) {
      return this;
    }
    return IslamicVisualTokens(
      sacredSurface: Color.lerp(sacredSurface, other.sacredSurface, t)!,
      sacredSurfaceMuted: Color.lerp(
        sacredSurfaceMuted,
        other.sacredSurfaceMuted,
        t,
      )!,
      spiritualGreen: Color.lerp(spiritualGreen, other.spiritualGreen, t)!,
      spiritualGreenStrong: Color.lerp(
        spiritualGreenStrong,
        other.spiritualGreenStrong,
        t,
      )!,
      mosqueSilhouette: Color.lerp(
        mosqueSilhouette,
        other.mosqueSilhouette,
        t,
      )!,
      quranAccent: Color.lerp(quranAccent, other.quranAccent, t)!,
      warmBackground: Color.lerp(warmBackground, other.warmBackground, t)!,
      imageOverlayLight: Color.lerp(
        imageOverlayLight,
        other.imageOverlayLight,
        t,
      )!,
      imageOverlayDark: Color.lerp(
        imageOverlayDark,
        other.imageOverlayDark,
        t,
      )!,
      verseCardSurface: Color.lerp(
        verseCardSurface,
        other.verseCardSurface,
        t,
      )!,
      geometricPatternOpacity:
          geometricPatternOpacity +
          (other.geometricPatternOpacity - geometricPatternOpacity) * t,
      heroGradientStart: Color.lerp(
        heroGradientStart,
        other.heroGradientStart,
        t,
      )!,
      heroGradientEnd: Color.lerp(heroGradientEnd, other.heroGradientEnd, t)!,
      sandSurface: Color.lerp(sandSurface, other.sandSurface, t)!,
      sageSurface: Color.lerp(sageSurface, other.sageSurface, t)!,
      sectionSurface: Color.lerp(sectionSurface, other.sectionSurface, t)!,
      surfaceBorder: Color.lerp(surfaceBorder, other.surfaceBorder, t)!,
      nightCalm: Color.lerp(nightCalm, other.nightCalm, t)!,
    );
  }
}
