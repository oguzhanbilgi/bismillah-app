import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:flutter/material.dart';

/// Rahle üzerinde açık Kur'an kompozisyonu (TASK 054) — DEKORATİFTİR.
///
/// Bağlayıcı kurallar:
/// - Dış asset/bitmap/network YOK: tamamen [CustomPainter] ile çizilir.
/// - GERÇEK ayet metni ÇİZİLMEZ ve SAHTE Arapça yazı KULLANILMAZ. Sayfalarda
///   yalnız soyut satır çizgileri vardır — bunlar yazı taklidi değil, "dolu
///   sayfa" ritmini veren nötr çizgilerdir.
/// - Belirli bir marka veya gerçek bir mushaf kapağı TAKLİT EDİLMEZ.
/// - `ExcludeSemantics` + `IgnorePointer`: ekran okuyucuya girmez, dokunma
///   hedeflerini engellemez.
/// - Animasyon YOKTUR.
/// - Liste satırlarında KULLANILMAZ (her satırda painter kurmak pahalıdır);
///   yalnız hero/bölüm başı gibi TEK örneklik alanlarda kullanılır.
class QuranOnRehalIllustration extends StatelessWidget {
  const QuranOnRehalIllustration({super.key, this.opacity, this.color});

  /// Token varsayılanını geçersiz kılan opaklık (0–1 aralığına sıkışır).
  final double? opacity;

  /// Token varsayılanını geçersiz kılan çizim rengi.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    // Siluetle aynı görsel ağırlık ailesinde kalır: arka plandadır.
    final effectiveOpacity = (opacity ?? tokens.geometricPatternOpacity * 3.0)
        .clamp(0.0, 1.0);

    return ExcludeSemantics(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _QuranOnRehalPainter(
            color: color ?? tokens.mosqueSilhouette,
            opacity: effectiveOpacity,
          ),
        ),
      ),
    );
  }
}

class _QuranOnRehalPainter extends CustomPainter {
  const _QuranOnRehalPainter({required this.color, required this.opacity});

  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0 || size.isEmpty) {
      return;
    }

    // Kompozisyon alanın kısa kenarına göre ölçeklenir — responsive kalır
    // ve dar ekranda taşmaz.
    final unit = size.shortestSide;
    if (unit <= 0) {
      return;
    }
    final w = unit * 1.5;
    final h = unit * 0.95;

    canvas.save();
    // Kompozisyon merkezlenir; alan taşarsa kırpma çağıranın kabındadır.
    canvas.translate((size.width - w) / 2, (size.height - h) / 2);

    final fill = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final stroke = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = unit * 0.012
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    _drawRehal(canvas, stroke, w, h);
    _drawOpenBook(canvas, fill, stroke, w, h);

    canvas.restore();
  }

  /// Rahle: çapraz kesişen iki ayak (klasik X formu) + taban çizgisi.
  void _drawRehal(Canvas canvas, Paint stroke, double w, double h) {
    final topY = h * 0.52;
    final bottomY = h * 0.98;

    canvas
      ..drawLine(Offset(w * 0.28, topY), Offset(w * 0.68, bottomY), stroke)
      ..drawLine(Offset(w * 0.72, topY), Offset(w * 0.32, bottomY), stroke)
      // Ayakları birbirine bağlayan sakin taban.
      ..drawLine(Offset(w * 0.30, bottomY), Offset(w * 0.70, bottomY), stroke);
  }

  /// Açık kitap: ortada cilt sırtı, iki yana açılan sayfalar. Sayfa
  /// içindeki çizgiler SOYUTTUR — harf/yazı taklidi DEĞİLDİR.
  void _drawOpenBook(
    Canvas canvas,
    Paint fill,
    Paint stroke,
    double w,
    double h,
  ) {
    final spineX = w * 0.5;
    final spineTop = h * 0.30;
    final spineBottom = h * 0.56;
    final pageOuterY = h * 0.20;
    final pageEdgeY = h * 0.50;

    // Sol ve sağ sayfa: sırttan dışa doğru hafifçe yükselen dörtgenler.
    for (final direction in const [-1.0, 1.0]) {
      final outerX = spineX + direction * w * 0.34;
      final page = Path()
        ..moveTo(spineX, spineTop)
        ..lineTo(outerX, pageOuterY)
        ..lineTo(outerX, pageEdgeY)
        ..lineTo(spineX, spineBottom)
        ..close();
      canvas
        ..drawPath(
          page,
          Paint()
            ..color = fill.color.withValues(alpha: fill.color.a * 0.35)
            ..style = PaintingStyle.fill
            ..isAntiAlias = true,
        )
        ..drawPath(page, stroke);

      // Soyut satır ritmi — üç kısa çizgi. Yazı DEĞİLDİR.
      for (var i = 1; i <= 3; i++) {
        final t = i / 4;
        final startX = spineX + direction * w * 0.07;
        final endX = spineX + direction * w * 0.28;
        final y =
            spineTop +
            (pageOuterY - spineTop) * 0.35 +
            (spineBottom - spineTop) * t * 0.55;
        canvas.drawLine(Offset(startX, y), Offset(endX, y), stroke);
      }
    }

    // Cilt sırtı.
    canvas.drawLine(
      Offset(spineX, spineTop),
      Offset(spineX, spineBottom),
      stroke,
    );
  }

  @override
  bool shouldRepaint(_QuranOnRehalPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.opacity != opacity;
}
