import 'dart:math' as math;

import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:flutter/material.dart';

/// Sakin geometrik İslami desen arka planı (TASK 051).
///
/// Kurallar:
/// - DEKORATİFTİR: `ExcludeSemantics` ile ekran okuyucudan gizlenir ve
///   `IgnorePointer` ile dokunma hedeflerini ENGELLEMEZ.
/// - Opaklık token'dan gelir ve düşüktür — içerikle yarışmaz.
/// - Bitmap YOKTUR: `CustomPainter` ile çizilir (bellek/asset maliyeti yok).
/// - Animasyon YOKTUR (sonsuz animasyon eklenmez, reduced-motion güvenli).
/// - Ayet/meal okuma alanının ARKASINA konulmamalıdır (bkz.
///   `docs/12_ISLAMIC_VISUAL_IDENTITY.md`).
class IslamicPatternBackground extends StatelessWidget {
  const IslamicPatternBackground({
    super.key,
    this.child,
    this.tileSize = 56,
    this.opacity,
  });

  /// Desenin üzerine çizileceği içerik (opsiyonel).
  final Widget? child;

  /// Tek motif hücresinin kenar uzunluğu (dp).
  final double tileSize;

  /// Token varsayılanını geçersiz kılan opaklık (0–1 aralığına sıkıştırılır).
  final double? opacity;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    final effectiveOpacity = (opacity ?? tokens.geometricPatternOpacity).clamp(
      0.0,
      1.0,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: ExcludeSemantics(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _IslamicPatternPainter(
                  color: tokens.mosqueSilhouette,
                  opacity: effectiveOpacity,
                  tileSize: tileSize <= 0 ? 56 : tileSize,
                ),
              ),
            ),
          ),
        ),
        ?child,
      ],
    );
  }
}

/// Sekiz köşeli yıldız (rub el hizb esinli) döşeme çizimi — sade, dengeli
/// ve düşük kontrastlı.
class _IslamicPatternPainter extends CustomPainter {
  const _IslamicPatternPainter({
    required this.color,
    required this.opacity,
    required this.tileSize,
  });

  final Color color;
  final double opacity;
  final double tileSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0 || size.isEmpty) {
      return;
    }
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final radius = tileSize / 2.8;
    for (var y = tileSize / 2; y < size.height + tileSize; y += tileSize) {
      for (var x = tileSize / 2; x < size.width + tileSize; x += tileSize) {
        _drawStar(canvas, paint, Offset(x, y), radius);
      }
    }
  }

  /// İki kare üst üste 45° döndürülerek sekiz köşeli yıldız oluşturur.
  void _drawStar(Canvas canvas, Paint paint, Offset center, double radius) {
    for (final rotation in [0.0, math.pi / 4]) {
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final angle = rotation + i * math.pi / 2;
        final point = Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        );
        i == 0
            ? path.moveTo(point.dx, point.dy)
            : path.lineTo(point.dx, point.dy);
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_IslamicPatternPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.opacity != opacity ||
      oldDelegate.tileSize != tileSize;
}
