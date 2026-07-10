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
}
