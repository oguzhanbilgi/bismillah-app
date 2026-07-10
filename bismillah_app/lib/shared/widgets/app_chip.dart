import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Küçük etiket çipi (03_DESIGN_SYSTEM §7 `radius.sm`) — içerik sınıfı
/// rozetleri ve meta etiketler için temel yapı taşı.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.outlined = true,
    this.borderColor,
  });

  final String label;
  final bool outlined;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final ext = AppThemeExtension.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s2,
        vertical: AppSpacing.s1,
      ),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : ext.surfaceAlt,
        borderRadius: AppRadius.smAll,
        border: outlined
            ? Border.all(color: borderColor ?? ext.textTertiary)
            : null,
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(color: ext.textSecondary),
      ),
    );
  }
}
