import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/shared/sacred/sacred_content_source_badge.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Referanslı ayet kartı (TASK 051) — kutsal içeriğin atmosfer katmanındaki
/// TEK sunum kabı.
///
/// Bağlayıcı kurallar (03_DESIGN_SYSTEM §16/§34 ile uyumlu):
/// - Kaynak ve sure/ayet referansı ZORUNLUDUR ("no source, no render").
/// - Arapça metin KIRPILMAZ: `maxLines` yoktur, dekoratif şekle sokulmaz.
/// - Zemin DÜZ renktir (`verseCardSurface`); ayetin arkasına görsel veya
///   desen KONULMAZ.
/// - Bu bileşen içerik SEÇMEZ; ayeti çağıran taraf verir. Rastgele/AI
///   üretimi ayet buraya giremez.
class ReferencedVerseCard extends StatelessWidget {
  const ReferencedVerseCard({
    super.key,
    required this.arabicText,
    required this.reference,
    required this.sourceLabel,
    this.translation,
    this.actions,
  });

  /// Doğrulanmış Arapça ayet metni (tam hareke, DEĞİŞTİRİLMEDEN).
  final String arabicText;

  /// Sure ve ayet referansı — ör. "Bakara 2:255".
  final String reference;

  /// Kaynak etiketi — ör. "Tanzil · QuranEnc Rowad".
  final String sourceLabel;

  /// Türkçe meal (opsiyonel; verildiğinde ayetten görsel olarak ayrılır).
  final String? translation;

  /// Kaydet/paylaş gibi sakin aksiyonlar için yer (ör. `IconButton` satırı).
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    final ext = AppThemeExtension.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.verseCardSurface,
        borderRadius: AppRadius.lgAll,
        boxShadow: ext.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Referans önce gelir: okuyucu neyi okuduğunu ÖNCE bilir.
            AppText(
              reference,
              token: AppTextStyleToken.caption,
              secondary: true,
            ),
            const SizedBox(height: AppSpacing.s3),
            // Arapça metin — RTL, kırpma YOK.
            Directionality(
              textDirection: TextDirection.rtl,
              child: AppText(arabicText, token: AppTextStyleToken.h3),
            ),
            if (translation != null) ...[
              const SizedBox(height: AppSpacing.s4),
              Directionality(
                textDirection: TextDirection.ltr,
                child: AppText(
                  translation!,
                  token: AppTextStyleToken.bodySmall,
                  secondary: true,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.s4),
            // Kaynak satırı zorunlu — atıf kaldırılamaz.
            SacredContentSourceBadge(sourceLabel: sourceLabel),
            if (actions != null) ...[
              const SizedBox(height: AppSpacing.s3),
              actions!,
            ],
          ],
        ),
      ),
    );
  }
}
