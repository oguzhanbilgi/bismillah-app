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
/// Ayet metni boyut varyantı (TASK 037) — yalnız tipografi token'larına
/// eşlenir; keyfi font boyutu bu bileşene giremez.
enum QuranTextBlockSize { small, medium, large }

class QuranTextBlock extends StatelessWidget {
  const QuranTextBlock({
    super.key,
    required this.arabicText,
    required this.sourceLabel,
    this.translation,
    this.size = QuranTextBlockSize.medium,
    this.footerAction,
  });

  /// Doğrulanmış ayet metni (Arapça, tam hareke).
  final String arabicText;

  /// Zorunlu kaynak etiketi (sure:ayet + meal adı).
  final String sourceLabel;

  /// Opsiyonel meal metni — ayetten görsel olarak ayrı render edilir.
  final String? translation;

  /// YALNIZ Arapça ayet metnini ölçekler (TASK 037) — kaynak rozeti ve
  /// meal metni sabit kalır.
  final QuranTextBlockSize size;

  /// Alt bilgi satırındaki sakin opsiyonel aksiyon (ör. ayet kaydetme).
  final Widget? footerAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final arabicStyle = switch (size) {
      QuranTextBlockSize.small => AppTypography.quranSmall,
      QuranTextBlockSize.medium => AppTypography.quran,
      QuranTextBlockSize.large => AppTypography.quranLarge,
    };
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
              style: arabicStyle,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              // maxLines yok — ayet kırpılamaz.
            ),
            if (translation != null) ...[
              const SizedBox(height: AppSpacing.s4),
              // Meal LTR ve doğal Türkçe hizasında — Arapça ayet
              // tipografisinden ayrı (TASK 040).
              Text(
                translation!,
                style: AppTypography.body,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
              ),
            ],
            const SizedBox(height: AppSpacing.s4),
            // Kaynak satırı ve aksiyonlar AYRI satırlarda (TASK 044):
            // rozet hiçbir genişlikte aksiyonlarla yarışıp sıkışmaz;
            // aksiyonlar dar ekranda kendi satırında güvenle kırılır.
            SacredContentSourceBadge(sourceLabel: sourceLabel),
            if (footerAction != null) ...[
              const SizedBox(height: AppSpacing.s2),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: footerAction!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
