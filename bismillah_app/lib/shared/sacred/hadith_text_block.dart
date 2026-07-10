import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/app/theme/app_typography.dart';
import 'package:bismillah_app/shared/sacred/sacred_content_source_badge.dart';
import 'package:flutter/material.dart';

/// Hadis metni bloğu (03_DESIGN_SYSTEM §34).
///
/// `source` ve `grading` ZORUNLU parametrelerdir — kaynaksız/derecesiz
/// hadis bu bileşenle render EDİLEMEZ (derlenmez). AI metni bu bileşene
/// bağlanamaz; içerik doğrulanmış kütüphaneden gelir.
class HadithTextBlock extends StatelessWidget {
  const HadithTextBlock({
    super.key,
    required this.text,
    required this.source,
    required this.grading,
  });

  /// Doğrulanmış hadis metni/çevirisi.
  final String text;

  /// Ör: "Buhârî 6018" — içerik verisinden gelir.
  final String source;

  /// Ör: "Sahih" — içerik verisinden gelir; yayın şartıdır.
  final String grading;

  @override
  Widget build(BuildContext context) {
    final ext = AppThemeExtension.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 1,
          color: ext.divider,
          margin: const EdgeInsets.only(bottom: AppSpacing.s4),
        ),
        Text(text, style: AppTypography.body),
        const SizedBox(height: AppSpacing.s4),
        SacredContentSourceBadge(sourceLabel: '$source · $grading'),
      ],
    );
  }
}
