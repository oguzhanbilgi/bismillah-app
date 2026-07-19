import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/app/theme/app_typography.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
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
    this.highlighted = false,
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

  /// Aktif (ör. sesle okunan) ayet vurgusu (TASK 055): zemin sakin
  /// spiritualGreen tonal yüzeye döner. Metin ve tipografi DEĞİŞMEZ;
  /// vurgu yalnız renkle bırakılmaz — çağıran taraf semantik durumu da
  /// (`Semantics(selected: ...)`) işaretlemelidir.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final ext = AppThemeExtension.of(context);
    final tokens = IslamicVisualTokens.of(context);
    final arabicStyle = switch (size) {
      QuranTextBlockSize.small => AppTypography.quranSmall,
      QuranTextBlockSize.medium => AppTypography.quran,
      QuranTextBlockSize.large => AppTypography.quranLarge,
    };
    return ColoredBox(
      // Kur'an metni daima temiz, DÜZ zeminde (03_DESIGN_SYSTEM §34-4).
      // TASK 055: saf beyaz yerine sıcak `verseCardSurface`; aktif ayette
      // sakin spiritualGreen tonal (`primarySoft`). Desen/görsel giremez.
      color: highlighted ? ext.primarySoft : tokens.verseCardSurface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1) Ayet referansı + Tanzil etiketi ÖNCE gelir (TASK 055):
            // okuyucu neyi okuduğunu ayetten önce bilir. Rozet kendi
            // satırındadır — hiçbir aksiyon metniyle sıkışmaz (TASK 044).
            SacredContentSourceBadge(sourceLabel: sourceLabel),
            const SizedBox(height: AppSpacing.s3),
            // 2) Arapça ayet — kutsal içeriğin ana odağı.
            Text(
              arabicText,
              style: arabicStyle,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              // maxLines yok — ayet kırpılamaz.
            ),
            if (translation != null) ...[
              // 3) İnce, sakin ayraç: meal ayetin devamı gibi OKUNMAZ.
              const SizedBox(height: AppSpacing.s4),
              Divider(color: tokens.surfaceBorder, height: 1),
              const SizedBox(height: AppSpacing.s4),
              // 4) Meal LTR ve doğal Türkçe hizasında — Arapça ayet
              // tipografisinden ayrı (TASK 040). Meal kırpılmaz.
              Text(
                translation!,
                style: AppTypography.body,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
              ),
            ],
            // 5) Aksiyonlar en altta kendi satırında — dar ekranda
            // güvenle kırılır, kaynak rozetiyle yarışmaz.
            if (footerAction != null) ...[
              const SizedBox(height: AppSpacing.s3),
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
