import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Sessiz bilgi rozeti (03_DESIGN_SYSTEM §12).
///
/// KIRMIZI BİLDİRİM NOKTASI DEĞİLDİR — alt navigasyonda rozet yasaktır
/// (03_DESIGN_SYSTEM §13); bu bileşen kart içi sakin meta bilgiler içindir.
class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.label, this.emphasized = false});

  final String label;

  /// Vurgulu durum: açık zümrüt zemin (asla kırmızı, asla altın).
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final ext = AppThemeExtension.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s3,
        vertical: AppSpacing.s1,
      ),
      decoration: BoxDecoration(
        color: emphasized ? ext.primarySoft : ext.surfaceAlt,
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: emphasized ? scheme.primary : ext.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
