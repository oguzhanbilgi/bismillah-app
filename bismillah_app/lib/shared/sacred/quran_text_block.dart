import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_typography.dart';
import 'package:bismillah_app/shared/sacred/sacred_content_source_badge.dart';
import 'package:flutter/material.dart';

/// Kur'an ayet metni bloğu (03_DESIGN_SYSTEM §16/§34).
///
/// Bağlayıcı kurallar (06_FLUTTER_ARCHITECTURE §19):
/// - Bu bileşen AI metni KABUL ETMEZ — yalnız doğrulanmış ayet metni
///   (ileride `QuranVerse` domain tipi bağlanacak; scaffold'da alanlar).
/// - `maxLines` parametresi BİLİNÇLİ olarak yoktur: ayet algoritmik
///   olarak kırpılamaz.
/// - Kaynak satırı zorunludur (no source, no render).
/// - Zemin daima temiz — arka planda dekor bu bileşenin altına giremez.
class QuranTextBlock extends StatelessWidget {
  const QuranTextBlock({
    super.key,
    required this.arabicText,
    required this.sourceLabel,
    this.translation,
  });

  /// Doğrulanmış ayet metni (Arapça, tam hareke).
  final String arabicText;

  /// Zorunlu kaynak etiketi (sure:ayet + meal adı).
  final String sourceLabel;

  /// Opsiyonel meal metni — ayetten görsel olarak ayrı render edilir.
  final String? translation;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      // Kur'an metni daima temiz zeminde (03_DESIGN_SYSTEM §34-4).
      color: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              arabicText,
              style: AppTypography.quran,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              // maxLines yok — ayet kırpılamaz.
            ),
            if (translation != null) ...[
              const SizedBox(height: AppSpacing.s4),
              Text(translation!, style: AppTypography.body),
            ],
            const SizedBox(height: AppSpacing.s4),
            SacredContentSourceBadge(sourceLabel: sourceLabel),
          ],
        ),
      ),
    );
  }
}
