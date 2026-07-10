import 'package:flutter/material.dart';

import 'package:bismillah_app/app/theme/app_colors.dart';

/// Gölge token'ları (03_DESIGN_SYSTEM §8): alçak, dağınık, sıcak.
/// Gölge rengi saf siyah değil, mürekkep tonudur.
abstract final class AppShadows {
  static const List<BoxShadow> none = [];

  static final List<BoxShadow> xs = [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.04),
      offset: const Offset(0, 1),
      blurRadius: 4,
    ),
  ];

  /// Standart kart gölgesi — tüm `surface` kartlar.
  static final List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.06),
      offset: const Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  /// Yüzen asistan düğmesi, yapışkan eylem çubuğu.
  static final List<BoxShadow> floating = [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.10),
      offset: const Offset(0, 6),
      blurRadius: 20,
    ),
  ];

  /// Kutlama modali — en derin gölge.
  static final List<BoxShadow> celebration = [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.14),
      offset: const Offset(0, 12),
      blurRadius: 40,
    ),
  ];
}
