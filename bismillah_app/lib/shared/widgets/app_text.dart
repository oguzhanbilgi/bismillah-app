import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Tipografi token'larına bağlı metin bileşeni (03_DESIGN_SYSTEM §5).
/// Token dışı font boyutu kullanımını engellemenin ana yolu budur.
enum AppTextStyleToken {
  display,
  h1,
  h2,
  h3,
  body,
  bodySmall,
  caption,
  stat,
  statLarge,
}

/// Metin vurgu kademesi (RDX-01B). Referans tasarımdaki üç kademeli
/// hiyerarşiyi (başlık → meta → sönük sayaç) token'la ifade eder; ekranlar
/// kendi renklerini üretmez.
enum AppTextTone {
  /// Başlık ve gövde mürekkebi.
  primary,

  /// Açıklama, meta satırı.
  secondary,

  /// En sönük kademe — sayaç, yardımcı etiket. Dekoratiftir; TEK BAŞINA
  /// taşınan kritik bilgi için kullanılmaz.
  tertiary,
}

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.token = AppTextStyleToken.body,
    this.secondary = false,
    this.tone,
    this.textAlign,
    this.maxLines,
    this.color,
  });

  final String text;
  final AppTextStyleToken token;

  /// İkincil metin rengi (`textSecondary`) kullanılsın mı?
  ///
  /// Korunan eski API. [tone] verildiğinde bu alan yok sayılır.
  final bool secondary;

  /// Vurgu kademesi (RDX-01B). Verilmezse [secondary] ve token'ın kendi
  /// varsayılanı kullanılır.
  final AppTextTone? tone;

  final TextAlign? textAlign;

  /// Satır sınırı; verildiğinde taşan metin ellipsis ile kırpılır
  /// (dar alanlarda RenderFlex taşması yerine güvenli daralma).
  final int? maxLines;

  /// Token renklerini geçersiz kılan açık renk (TASK 054). Yalnız
  /// `IslamicVisualTokens` gibi TEMA kaynaklarından beslenmelidir —
  /// widget içinde hex renk üretmek yasaktır. [secondary] ile birlikte
  /// verilirse bu kazanır.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ext = AppThemeExtension.of(context);
    final base = switch (token) {
      AppTextStyleToken.display => AppTypography.display,
      AppTextStyleToken.h1 => AppTypography.h1,
      AppTextStyleToken.h2 => AppTypography.h2,
      AppTextStyleToken.h3 => AppTypography.h3,
      AppTextStyleToken.body => AppTypography.body,
      AppTextStyleToken.bodySmall => AppTypography.bodySmall,
      AppTextStyleToken.caption => AppTypography.caption,
      AppTextStyleToken.stat => AppTypography.stat,
      AppTextStyleToken.statLarge => AppTypography.statLarge,
    };
    // RDX-01B: renk ARTIK HER ZAMAN temadan çözülür. Daha önce varsayılan
    // durumda `AppTypography` sabitinin kendi rengi (açık tema mürekkebi)
    // olduğu gibi kalıyordu; koyu temada bu, koyu zemin üstünde koyu metin
    // demekti. Paylaşılan bir bileşen açık tema rengini SABİTLEYEMEZ.
    final effectiveTone =
        tone ?? (secondary ? AppTextTone.secondary : _defaultTone(token));
    final effectiveColor =
        color ??
        switch (effectiveTone) {
          AppTextTone.primary => ext.textPrimary,
          AppTextTone.secondary => ext.textSecondary,
          AppTextTone.tertiary => ext.textTertiary,
        };
    final style = base.copyWith(color: effectiveColor);
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }

  /// `caption` zaten ikincil mürekkeple tanımlıdır (03_DESIGN_SYSTEM §5);
  /// bu eşleme o davranışı token tarafında korur.
  static AppTextTone _defaultTone(AppTextStyleToken token) =>
      token == AppTextStyleToken.caption
      ? AppTextTone.secondary
      : AppTextTone.primary;
}
