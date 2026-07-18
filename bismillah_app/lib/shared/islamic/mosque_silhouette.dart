import 'dart:math' as math;

import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:flutter/material.dart';

/// Özgün, sade cami silueti (TASK 052) — DEKORATİFTİR.
///
/// Kurallar:
/// - Dış asset YOK: tamamen [CustomPainter] ile çizilir (bitmap/network yok).
/// - Gerçek bir caminin birebir kopyası değildir; jenerik kubbe + minare
///   geometrisidir. Marka/logo taklidi içermez.
/// - `ExcludeSemantics` + `IgnorePointer`: ekran okuyucuya girmez, dokunma
///   hedeflerini engellemez.
/// - Animasyon YOKTUR.
/// - Renk ve opaklık token'lardan gelir; hero metninin okunabilirliğini
///   bozmayacak kadar düşüktür.
class MosqueSilhouette extends StatelessWidget {
  const MosqueSilhouette({
    super.key,
    this.opacity,
    this.color,
    this.alignment = Alignment.bottomRight,
  });

  /// Token varsayılanını geçersiz kılan opaklık (0–1 aralığına sıkışır).
  final double? opacity;

  /// Token varsayılanını geçersiz kılan dolgu rengi.
  final Color? color;

  /// Siluetin hizası (varsayılan: sağ alt köşe).
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    // Siluet desenden bir tık belirgindir ama yine de arka plandadır.
    final effectiveOpacity = (opacity ?? tokens.geometricPatternOpacity * 2.4)
        .clamp(0.0, 1.0);

    return ExcludeSemantics(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _MosqueSilhouettePainter(
            color: color ?? tokens.mosqueSilhouette,
            opacity: effectiveOpacity,
            alignment: alignment,
          ),
        ),
      ),
    );
  }
}

class _MosqueSilhouettePainter extends CustomPainter {
  const _MosqueSilhouettePainter({
    required this.color,
    required this.opacity,
    required this.alignment,
  });

  final Color color;
  final double opacity;
  final Alignment alignment;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0 || size.isEmpty) {
      return;
    }
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Siluet, alanın kısa kenarına göre ölçeklenir — responsive kalır.
    final unit = math.min(size.width, size.height) * 0.42;
    if (unit <= 0) {
      return;
    }
    final baseWidth = unit * 2.6;
    final baseHeight = unit * 1.5;
    final left = (size.width - baseWidth) * ((alignment.x + 1) / 2);
    final top = (size.height - baseHeight) * ((alignment.y + 1) / 2);

    canvas.save();
    canvas.translate(left, top);
    _drawMosque(canvas, paint, Size(baseWidth, baseHeight));
    canvas.restore();
  }

  /// Jenerik geometri: iki minare + gövde + soğan kubbe + küçük hilal alanı.
  void _drawMosque(Canvas canvas, Paint paint, Size size) {
    final w = size.width;
    final h = size.height;
    final bodyTop = h * 0.45;

    // Gövde
    final body = Rect.fromLTRB(w * 0.22, bodyTop, w * 0.78, h);
    canvas.drawRect(body, paint);

    // Kubbe (yarım daire + hafif sivri uç)
    final domeWidth = w * 0.42;
    final domeRect = Rect.fromLTWH(
      (w - domeWidth) / 2,
      bodyTop - domeWidth * 0.62,
      domeWidth,
      domeWidth,
    );
    final dome = Path()
      ..moveTo(domeRect.left, domeRect.center.dy)
      ..arcTo(domeRect, math.pi, math.pi, false)
      ..close();
    canvas.drawPath(dome, paint);

    // Kubbe tepesi (küçük alem çubuğu)
    canvas.drawRect(
      Rect.fromLTWH(w * 0.49, domeRect.top - h * 0.10, w * 0.02, h * 0.10),
      paint,
    );

    // Minareler (sol/sağ): gövde + konik külah
    for (final xCenter in [w * 0.12, w * 0.88]) {
      final shaftWidth = w * 0.05;
      final shaftTop = h * 0.18;
      canvas.drawRect(
        Rect.fromLTWH(
          xCenter - shaftWidth / 2,
          shaftTop,
          shaftWidth,
          h - shaftTop,
        ),
        paint,
      );
      final cap = Path()
        ..moveTo(xCenter - shaftWidth, shaftTop)
        ..lineTo(xCenter, shaftTop - h * 0.12)
        ..lineTo(xCenter + shaftWidth, shaftTop)
        ..close();
      canvas.drawPath(cap, paint);
    }
  }

  @override
  bool shouldRepaint(_MosqueSilhouettePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.opacity != opacity ||
      oldDelegate.alignment != alignment;
}
