import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/app/theme/app_typography.dart';
import 'package:bismillah_app/shared/widgets/app_chip.dart';
import 'package:flutter/material.dart';

/// AI açıklama bloğu (03_DESIGN_SYSTEM §22/§34).
///
/// Kutsal içerik bileşenlerinden GÖRSEL ve YAPISAL olarak ayrıdır:
/// `surfaceAlt` zemin + kalıcı "AI açıklaması" çipi. Etiket zorunlu
/// parametredir — etiketiz AI metni render edilemez. Bu bileşen
/// Kur'an/hadis/dua metni taşımak için KULLANILAMAZ; alıntılar bağımsız
/// kutsal içerik bloklarına çıkar (06_FLUTTER_ARCHITECTURE §19).
class AiExplanationBlock extends StatelessWidget {
  const AiExplanationBlock({
    super.key,
    required this.text,
    required this.aiLabel,
  });

  /// AI üretimi açıklama metni.
  final String text;

  /// Kalıcı sınıf çipi metni (ör. "AI açıklaması") — localization'dan gelir.
  final String aiLabel;

  @override
  Widget build(BuildContext context) {
    final ext = AppThemeExtension.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: ext.surfaceAlt,
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: AppTypography.body),
          const SizedBox(height: AppSpacing.s3),
          AppChip(label: aiLabel),
        ],
      ),
    );
  }
}
