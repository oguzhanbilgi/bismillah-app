import 'package:bismillah_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Tipografi token'ları (03_DESIGN_SYSTEM §5).
///
/// Not: marka yazı tipleri (Plus Jakarta Sans, Inter, IBM Plex Sans Arabic,
/// KFGQPC Uthmanic Hafs, Amiri) sonraki asset görevinde paketlenecek;
/// scaffold aşamasında boyut/ağırlık/satır yüksekliği token'ları sistem
/// fontuyla kurulur — aile adları bağlandığında yalnız bu dosya değişir.
abstract final class AppTypography {
  static const TextStyle display = TextStyle(
    fontSize: 32,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 17,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    height: 1.55,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle navLabel = TextStyle(
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle stat = TextStyle(
    fontSize: 28,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle statLarge = TextStyle(
    fontSize: 40,
    height: 1.1,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Kur'an ayet metni (tam hareke, RTL). Boyut kullanıcı ayarıyla
  /// 22–40 aralığında ölçeklenecek; başlangıç 28 (03_DESIGN_SYSTEM §5).
  static const TextStyle quran = TextStyle(
    fontSize: 28,
    height: 1.9,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Dua/zikir Arapça metni.
  static const TextStyle dua = TextStyle(
    fontSize: 23,
    height: 1.8,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Transliterasyon satırı.
  static const TextStyle duaLatin = TextStyle(
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    color: AppColors.textSecondary,
  );

  /// Material TextTheme eşlemesi (03_DESIGN_SYSTEM §5 Flutter notları).
  static TextTheme textTheme() => const TextTheme(
    displaySmall: display,
    headlineMedium: h1,
    titleLarge: h2,
    titleMedium: h3,
    bodyLarge: body,
    bodyMedium: bodySmall,
    bodySmall: caption,
    labelLarge: button,
    labelSmall: navLabel,
  );
}
