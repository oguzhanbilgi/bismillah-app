import 'dart:math' as math;

import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

/// Sakin kıble kadranı (TASK 095).
///
/// ## Kurallar
///
/// * **Metin döndürülmez.** Kadranda hiç harf/rakam çizilmez; derece
///   okuması ekranda ayrı, sabit bir metin bileşenidir. Böylece Arapça
///   dahil hiçbir dilde ters duran yazı oluşmaz.
/// * **Sürekli dekoratif animasyon yoktur.** Kadran yalnız gelen veriyle
///   döner; parlama, nabız, konfeti, zıplama YOKTUR.
/// * Kadran RTL'de aynalanmaz: pusula mutlak bir yön aygıtıdır, okuma
///   yönüne göre yer değiştirmesi onu YANLIŞ yapardı.
class QiblaDial extends StatelessWidget {
  const QiblaDial({
    super.key,
    required this.qiblaBearingDegrees,
    required this.headingDegrees,
    required this.aligned,
    this.size = 240,
  });

  /// Gerçek kuzeye göre kıble kerterizi.
  final double qiblaBearingDegrees;

  /// Cihazın baktığı yön. `null` ise pusula okuması yok: kadran kuzeye
  /// sabitlenir ve kıble ibresi ham açıyı gösterir (statik yedek).
  final double? headingDegrees;

  final bool aligned;

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ext = AppThemeExtension.of(context);
    final heading = headingDegrees ?? 0;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _QiblaDialPainter(
          dialRotationDegrees: -heading,
          needleDegrees: qiblaBearingDegrees - heading,
          aligned: aligned,
          live: headingDegrees != null,
          ringColor: ext.textSecondary.withValues(alpha: 0.35),
          tickColor: ext.textSecondary.withValues(alpha: 0.55),
          northColor: scheme.tertiary,
          needleColor: aligned ? scheme.primary : scheme.secondary,
          referenceColor: ext.textSecondary,
        ),
      ),
    );
  }
}

final class _QiblaDialPainter extends CustomPainter {
  const _QiblaDialPainter({
    required this.dialRotationDegrees,
    required this.needleDegrees,
    required this.aligned,
    required this.live,
    required this.ringColor,
    required this.tickColor,
    required this.northColor,
    required this.needleColor,
    required this.referenceColor,
  });

  final double dialRotationDegrees;
  final double needleDegrees;
  final bool aligned;
  final bool live;
  final Color ringColor;
  final Color tickColor;
  final Color northColor;
  final Color needleColor;
  final Color referenceColor;

  static double _rad(double degrees) => degrees * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = ringColor,
    );

    // Kullanıcının baktığı yönü gösteren SABİT üst işaret — kadranla
    // dönmez, referans noktasıdır.
    final reference = Paint()..color = referenceColor;
    final markerTop = center.translate(0, -(radius - 4));
    canvas.drawPath(
      Path()
        ..moveTo(markerTop.dx, markerTop.dy)
        ..lineTo(markerTop.dx - 5, markerTop.dy - 9)
        ..lineTo(markerTop.dx + 5, markerTop.dy - 9)
        ..close(),
      reference,
    );

    // Kadran çentikleri: 30 derecede bir. Kuzey çentiği ayırt edilir ama
    // HARF yazılmaz (dönen metin yasak).
    for (var degree = 0; degree < 360; degree += 30) {
      final isNorth = degree == 0;
      final angle = _rad(degree + dialRotationDegrees - 90);
      final outer = center + Offset(math.cos(angle), math.sin(angle)) * (radius - 8);
      final innerLength = isNorth ? radius - 30 : radius - 20;
      final inner =
          center + Offset(math.cos(angle), math.sin(angle)) * innerLength;
      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..strokeWidth = isNorth ? 3 : 1.5
          ..strokeCap = StrokeCap.round
          ..color = isNorth ? northColor : tickColor,
      );
    }

    // Kıble ibresi — merkezden dışa doğru tek yönlü bir ok.
    final needleAngle = _rad(needleDegrees - 90);
    final direction = Offset(math.cos(needleAngle), math.sin(needleAngle));
    final tip = center + direction * (radius - 34);
    final needlePaint = Paint()
      ..color = needleColor
      ..style = PaintingStyle.fill;
    canvas.drawLine(
      center,
      tip,
      Paint()
        ..color = needleColor
        ..strokeWidth = aligned ? 4 : 3
        ..strokeCap = StrokeCap.round,
    );
    final side = Offset(-direction.dy, direction.dx);
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx + direction.dx * 14, tip.dy + direction.dy * 14)
        ..lineTo(tip.dx + side.dx * 7, tip.dy + side.dy * 7)
        ..lineTo(tip.dx - side.dx * 7, tip.dy - side.dy * 7)
        ..close(),
      needlePaint,
    );
    canvas.drawCircle(center, 4, needlePaint);
  }

  @override
  bool shouldRepaint(_QiblaDialPainter oldDelegate) =>
      oldDelegate.dialRotationDegrees != dialRotationDegrees ||
      oldDelegate.needleDegrees != needleDegrees ||
      oldDelegate.aligned != aligned ||
      oldDelegate.live != live ||
      oldDelegate.needleColor != needleColor;
}
