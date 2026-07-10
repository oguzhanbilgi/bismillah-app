import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_typography.dart';
import 'package:bismillah_app/shared/sacred/sacred_content_source_badge.dart';
import 'package:flutter/material.dart';

/// Dua bloğu — sabit blok sırası: Arapça → transliterasyon → çeviri →
/// kaynak (03_DESIGN_SYSTEM §18). `source` zorunludur: kaynaksız dua
/// render edilemez.
class DuaTextBlock extends StatelessWidget {
  const DuaTextBlock({
    super.key,
    required this.arabicText,
    required this.source,
    this.transliteration,
    this.translation,
  });

  final String arabicText;

  /// Ör: "Müslim 2723" — içerik verisinden gelir.
  final String source;

  final String? transliteration;
  final String? translation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          arabicText,
          style: AppTypography.dua,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
        ),
        if (transliteration != null) ...[
          const SizedBox(height: AppSpacing.s3),
          Text(transliteration!, style: AppTypography.duaLatin),
        ],
        if (translation != null) ...[
          const SizedBox(height: AppSpacing.s3),
          Text(translation!, style: AppTypography.body),
        ],
        const SizedBox(height: AppSpacing.s4),
        SacredContentSourceBadge(sourceLabel: source),
      ],
    );
  }
}
