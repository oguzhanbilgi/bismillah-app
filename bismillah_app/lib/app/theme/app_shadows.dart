import 'package:bismillah_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Gölge token'ları (03_DESIGN_SYSTEM §8): alçak, dağınık, sıcak.
/// Gölge rengi saf siyah değil, mürekkep tonudur.
///
/// RDX-01A: koyu tema karşılıkları eklendi. Koyu zeminde mürekkep tonlu bir
/// gölge görünmez kaldığından, koyu varyantlar daha koyu bir mürekkep
/// ([AppColors.shadowInkDark]) ve biraz daha yüksek alfa kullanır. Yükseklik
/// (offset/blur) DEĞİŞMEZ: derinlik hissi iki temada aynıdır ve hiçbir
/// varyant "ağır gölge" seviyesine çıkmaz.
abstract final class AppShadows {
  static const List<BoxShadow> none = [];

  static final List<BoxShadow> xs = _xs(AppColors.shadowInk, 0.04);

  /// Standart kart gölgesi — tüm `surface` kartlar.
  static final List<BoxShadow> card = _card(AppColors.shadowInk, 0.06);

  /// Yüzen asistan düğmesi, yapışkan eylem çubuğu.
  static final List<BoxShadow> floating = _floating(AppColors.shadowInk, 0.10);

  /// Kutlama modali — en derin gölge.
  static final List<BoxShadow> celebration = _celebration(
    AppColors.shadowInk,
    0.14,
  );

  static final List<BoxShadow> xsDark = _xs(AppColors.shadowInkDark, 0.20);
  static final List<BoxShadow> cardDark = _card(AppColors.shadowInkDark, 0.26);
  static final List<BoxShadow> floatingDark = _floating(
    AppColors.shadowInkDark,
    0.34,
  );
  static final List<BoxShadow> celebrationDark = _celebration(
    AppColors.shadowInkDark,
    0.42,
  );

  static List<BoxShadow> _xs(Color ink, double alpha) => [
    BoxShadow(
      color: ink.withValues(alpha: alpha),
      offset: const Offset(0, 1),
      blurRadius: 4,
    ),
  ];

  static List<BoxShadow> _card(Color ink, double alpha) => [
    BoxShadow(
      color: ink.withValues(alpha: alpha),
      offset: const Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  static List<BoxShadow> _floating(Color ink, double alpha) => [
    BoxShadow(
      color: ink.withValues(alpha: alpha),
      offset: const Offset(0, 6),
      blurRadius: 20,
    ),
  ];

  static List<BoxShadow> _celebration(Color ink, double alpha) => [
    BoxShadow(
      color: ink.withValues(alpha: alpha),
      offset: const Offset(0, 12),
      blurRadius: 40,
    ),
  ];
}
