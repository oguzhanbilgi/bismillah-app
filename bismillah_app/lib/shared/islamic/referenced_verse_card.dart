import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/shared/sacred/sacred_content_source_badge.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Kaynak künyesinin nasıl SUNULACAĞI (RDX-02B).
///
/// Künyenin kendisi her iki modda da ZORUNLUDUR — bu enum yalnız sunumu
/// seçer, veriyi değil. "No source, no render" kuralı değişmedi.
enum VerseSourceDisclosure {
  /// Künye ayetin hemen altında sürekli görünür (mevcut davranış).
  /// Tüm eski çağıranlar için VARSAYILAN budur.
  inline,

  /// Künye satır olarak çizilmez; sessiz bir bilgi eylemi ile açılır.
  /// Çağıran [ReferencedVerseCard.onShowSource] vermek ZORUNDADIR — aksi
  /// hâlde künye kullanıcı için erişilemez olurdu.
  compact,
}

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
///
/// RDX-02B: [sourceDisclosure] eklendi. İKİNCİ bir ayet kartı üretmek yerine
/// bu kart genişletildi; varsayılan [VerseSourceDisclosure.inline] olduğu için
/// mevcut çağıranların görünümü BİREBİR aynı kalır.
class ReferencedVerseCard extends StatelessWidget {
  const ReferencedVerseCard({
    super.key,
    required this.arabicText,
    required this.reference,
    required this.sourceLabel,
    this.translation,
    this.actions,
    this.sourceDisclosure = VerseSourceDisclosure.inline,
    this.onShowSource,
  }) : assert(
         sourceDisclosure == VerseSourceDisclosure.inline ||
             onShowSource != null,
         'compact künye modu, künyeyi açacak bir eylem OLMADAN kullanılamaz: '
         'kaynak kullanıcı tarafından doğrulanabilir kalmalıdır.',
       );

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

  /// Künye sunumu. Varsayılan, mevcut görünür rozet davranışıdır.
  final VerseSourceDisclosure sourceDisclosure;

  /// [VerseSourceDisclosure.compact] modunda künyeyi gösteren eylem.
  /// Çağıran, [sourceLabel]'ın TAM metnini kullanıcıya ulaştırmakla yükümlüdür.
  final VoidCallback? onShowSource;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    final ext = AppThemeExtension.of(context);

    // TASK 054: kutsal içerik kabı diğer kartlardan GÖRSEL OLARAK ayrışır —
    // sıcak yüzey + belirgin kenarlık, gölge ise hafifletilir. Zemin hâlâ
    // DÜZ renktir: ayetin arkasına desen/görsel konmaz.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.verseCardSurface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: tokens.surfaceBorder),
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
            const SizedBox(height: AppSpacing.s4),
            // Arapça metin — RTL, kırpma YOK. Kendi yönünde hizalanır.
            Directionality(
              textDirection: TextDirection.rtl,
              child: AppText(arabicText, token: AppTextStyleToken.h3),
            ),
            if (translation != null) ...[
              // Ayet ile meal arasında NET boşluk + ince ayraç: iki metin
              // birbirine karışmaz, meal ayetin devamı gibi okunmaz.
              const SizedBox(height: AppSpacing.s5),
              Divider(color: tokens.surfaceBorder, height: 1),
              const SizedBox(height: AppSpacing.s4),
              // Meal KENDİ dilinin yönünde kalır (Türkçe/İngilizce LTR).
              Directionality(
                textDirection: TextDirection.ltr,
                child: AppText(
                  translation!,
                  token: AppTextStyleToken.bodySmall,
                  secondary: true,
                ),
              ),
            ],
            // Kaynak ATIFI her iki modda da zorunludur; yalnız sunumu
            // değişir. `compact` modda künye satır olarak çizilmez, sessiz
            // bir bilgi eylemiyle açılır — böylece Today'in ayet kartı
            // sağlayıcı adlarıyla sürekli dolu görünmez ama künye kullanıcı
            // için bir dokunuş uzakta kalır.
            if (sourceDisclosure == VerseSourceDisclosure.inline) ...[
              const SizedBox(height: AppSpacing.s4),
              SacredContentSourceBadge(sourceLabel: sourceLabel),
              if (actions != null) ...[
                const SizedBox(height: AppSpacing.s3),
                actions!,
              ],
            ] else ...[
              const SizedBox(height: AppSpacing.s3),
              Row(
                children: [
                  if (actions != null) Expanded(child: actions!),
                  if (actions == null) const Spacer(),
                  _CompactSourceAction(onPressed: onShowSource!),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// `compact` künye modundaki sessiz bilgi eylemi (RDX-02B).
///
/// Sağlayıcı adını GÖSTERMEZ; künyeyi AÇAR. Dolu buton değildir, altın
/// kullanmaz ve ayetle görsel olarak yarışmaz — ama tam 48dp dokunma
/// hedefindedir, çünkü kaynağı doğrulamak isteyen kullanıcı için tek yoldur.
class _CompactSourceAction extends StatelessWidget {
  const _CompactSourceAction({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ext = AppThemeExtension.of(context);
    return IconButton(
      onPressed: onPressed,
      tooltip: l10n.verseSourceAction,
      icon: const Icon(Icons.info_outline),
      iconSize: AppSizes.iconMd,
      color: ext.textTertiary,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: AppSizes.touchTarget,
        minHeight: AppSizes.touchTarget,
      ),
    );
  }
}
