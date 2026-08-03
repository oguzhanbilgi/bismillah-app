import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/theme/app_motion.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:flutter/material.dart';

/// Kadranın merkezindeki stilize Kâbe (TASK 095 görsel iyileştirmesi).
///
/// ## Neden kodla çizilir
///
/// Görsel varlık, paket veya ağ kaynağı EKLENMEZ; tamamen `CustomPaint`
/// ile çizilir. Dolayısıyla bu dosyadaki iki renk (örtü ve kuşak) bir
/// **illüstrasyonun kendi paleti**dir — bir görsel varlık gönderilseydi
/// aynı renkler o dosyanın içinde olurdu.
///
/// Bu altın, `AppThemeExtension.accentGold` DEĞİLDİR ve onun yerine
/// geçmez: marka kuralında `accentGold` yalnız kazanılmış an/premium
/// vurgusudur (02_BRAND §13). Buradaki ton, Kâbe örtüsündeki kuşağın
/// **temsilidir**; hiçbir premium/ödül anlamı taşımaz ve başka hiçbir
/// yüzeyde kullanılmaz.
///
/// ## Duruş
///
/// Kâbe **daima diktir ve pusulayla DÖNMEZ**. Kadranın dönen halkası bu
/// bileşenin dışındadır; burada yalnız hizalanma anına ait tek seferlik
/// bir ölçek vurgusu vardır.
class KaabaEmblem extends StatefulWidget {
  const KaabaEmblem({
    super.key,
    required this.aligned,
    required this.alignmentPulse,
    this.size = 68,
  });

  /// Yalnız renk/gölge tonunu belirler — konumu ETKİLEMEZ.
  final bool aligned;

  /// Hizalanmaya **her girişte** bir artan sayaç. Değer değişmedikçe
  /// vurgu yeniden oynatılmaz; hizalı kalmak tek başına animasyon
  /// tetiklemez.
  final int alignmentPulse;

  final double size;

  @override
  State<KaabaEmblem> createState() => _KaabaEmblemState();
}

class _KaabaEmblemState extends State<KaabaEmblem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.stateChange,
  );

  /// Tek geçişlik, tek yönlü bir nefes: 1 → 1.06 → 1. Yay/zıplama YOKTUR.
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1,
        end: 1.06,
      ).chain(CurveTween(curve: AppMotion.stateChangeCurve)),
      weight: 45,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1.06,
        end: 1,
      ).chain(CurveTween(curve: AppMotion.stateChangeCurve)),
      weight: 55,
    ),
  ]).animate(_controller);

  @override
  void didUpdateWidget(KaabaEmblem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.alignmentPulse == oldWidget.alignmentPulse) {
      return;
    }
    if (AppMotion.isReduced(context)) {
      // Azaltılmış hareket: vurgu HİÇ oynatılmaz, durum yine de anında
      // ve tam olarak anlaşılır kalır (renk/gölge değişimi sürer).
      _controller.value = 0;
      return;
    }
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ext = AppThemeExtension.of(context);
    final tokens = IslamicVisualTokens.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: l10n.qiblaKaabaSemantics,
      image: true,
      child: RepaintBoundary(
        child: ScaleTransition(
          scale: _scale,
          child: CustomPaint(
            size: Size.square(widget.size),
            painter: _KaabaPainter(
              aligned: widget.aligned,
              // Koyu küp her iki temada da okunsun diye altına açık bir
              // kaide konur; kaide temadan gelir, küp kendi paletindedir.
              plinthColor: tokens.sacredSurface,
              outlineColor: widget.aligned ? scheme.primary : ext.divider,
              shadowColor: ext.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

final class _KaabaPainter extends CustomPainter {
  const _KaabaPainter({
    required this.aligned,
    required this.plinthColor,
    required this.outlineColor,
    required this.shadowColor,
  });

  final bool aligned;
  final Color plinthColor;
  final Color outlineColor;
  final Color shadowColor;

  /// Kâbe örtüsünün (kisve) koyu tonu. Saf siyah değildir: saf siyah,
  /// koyu temada zeminle birleşip küpü kaybederdi.
  static const Color _kiswah = Color(0xFF141414);
  static const Color _kiswahLit = Color(0xFF232323);

  /// Örtü üzerindeki kuşağın (hizam) temsilî altın tonu — premium
  /// `accentGold` DEĞİLDİR (dosya başındaki nota bakınız).
  static const Color _hizam = Color(0xFFB89355);
  static const Color _hizamLit = Color(0xFFD2B073);

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Kaide: koyu küpün her iki temada da ayrılmasını sağlayan açık disk.
    canvas.drawCircle(
      Offset(width / 2, height / 2),
      width * 0.5,
      Paint()..color = plinthColor,
    );

    final cubeWidth = width * 0.56;
    final cubeHeight = height * 0.5;
    final left = (width - cubeWidth) / 2;
    final top = (height - cubeHeight) / 2 + height * 0.04;
    final body = Rect.fromLTWH(left, top, cubeWidth, cubeHeight);

    // Yumuşak temas gölgesi — kalıcı parlama değil, tek bir derinlik ipucu.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(width / 2, top + cubeHeight + height * 0.045),
        width: cubeWidth * 1.05,
        height: height * 0.07,
      ),
      Paint()
        ..color = shadowColor.withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Üst yüz: hafif perspektif — düz bir dikdörtgenden daha "nesne" durur.
    final topInset = cubeWidth * 0.12;
    final topFace = Path()
      ..moveTo(left, top)
      ..lineTo(left + topInset, top - height * 0.075)
      ..lineTo(left + cubeWidth - topInset, top - height * 0.075)
      ..lineTo(left + cubeWidth, top)
      ..close();
    canvas.drawPath(topFace, Paint()..color = _kiswahLit);

    // Gövde: soldan sağa çok hafif bir ışık geçişi (düz siyah blok değil).
    canvas.drawRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kiswahLit, _kiswah],
        ).createShader(body),
    );

    // Hizam: gövdenin üst üçte birinde ince altın kuşak.
    final bandTop = top + cubeHeight * 0.26;
    final bandHeight = cubeHeight * 0.13;
    canvas.drawRect(
      Rect.fromLTWH(left, bandTop, cubeWidth, bandHeight),
      Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: aligned
                  ? const [_hizamLit, _hizam, _hizamLit]
                  : const [_hizam, _hizamLit, _hizam],
            ).createShader(
              Rect.fromLTWH(left, bandTop, cubeWidth, bandHeight),
            ),
    );

    // Kapı ipucu: alt ortada dar, kısa bir altın dikdörtgen.
    final doorWidth = cubeWidth * 0.16;
    canvas.drawRect(
      Rect.fromLTWH(
        left + cubeWidth * 0.58,
        bandTop + bandHeight + cubeHeight * 0.12,
        doorWidth,
        cubeHeight * 0.36,
      ),
      Paint()..color = _hizam.withValues(alpha: 0.85),
    );

    // İnce dış çizgi: hizalıyken vurgu rengine döner — kalıcı parlama YOK.
    canvas.drawRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = aligned ? 1.6 : 1
        ..color = outlineColor.withValues(alpha: aligned ? 0.9 : 0.5),
    );
  }

  @override
  bool shouldRepaint(_KaabaPainter oldDelegate) =>
      oldDelegate.aligned != aligned ||
      oldDelegate.plinthColor != plinthColor ||
      oldDelegate.outlineColor != outlineColor ||
      oldDelegate.shadowColor != shadowColor;
}
