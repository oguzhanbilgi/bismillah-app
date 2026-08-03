import 'dart:async';
import 'dart:math' as math;

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/theme/app_motion.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/features/qibla/domain/qibla_bearing.dart';
import 'package:bismillah_app/features/qibla/presentation/widgets/kaaba_emblem.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sakin kıble kadranı (TASK 095).
///
/// ## Katmanlar (alttan üste)
///
/// 1. **Sabit tabla** — katmanlı yüzey, ince kenar, sabit üst referans
///    işareti. Cihaz döndükçe DEĞİŞMEZ, dolayısıyla hiç yeniden boyanmaz.
/// 2. **Dönen halka** — çentikler, yön harfleri ve kıble işareti. Yalnız
///    bu katman hareket eder ve kendi `RepaintBoundary`'si içindedir.
/// 3. **Hizalanma halkası** — hizalanmaya girişte tek seferlik, sönümlenen
///    bir dalga. Kalıcı parlama değildir.
/// 4. **Kâbe** — merkezde, DAİMA DİK, pusulayla dönmez.
///
/// ## Değişmeyen kurallar
///
/// * Yön harfleri ve derece okuması **dik durur**: konumları açıyla
///   hesaplanır, harfin kendisi karşı-döndürülür.
/// * Kadran RTL'de **aynalanmaz**: pusula mutlak bir yön aygıtıdır ve
///   konumlar yalnız açıdan türetilir, okuma yönünden değil.
/// * Sürekli dekoratif animasyon YOKTUR; her hareketin bir sebebi vardır.
class QiblaDial extends StatefulWidget {
  const QiblaDial({
    super.key,
    required this.qiblaBearingDegrees,
    required this.headingDegrees,
    required this.aligned,
    this.size = 268,
  });

  /// Gerçek kuzeye göre kıble kerterizi.
  final double qiblaBearingDegrees;

  /// Cihazın baktığı yön. `null` ise pusula okuması yok: halka kuzeye
  /// sabitlenir ve kıble işareti ham açıyı gösterir (statik yedek).
  final double? headingDegrees;

  final bool aligned;

  final double size;

  /// Dönen halka katmanının anahtarı — testler bu katmanın gerçekten
  /// döndüğünü (ve Kâbe'nin dönmediğini) bu anahtarla doğrular.
  static const Key compassRingKey = Key('qibla-compass-ring');

  @override
  State<QiblaDial> createState() => _QiblaDialState();
}

class _QiblaDialState extends State<QiblaDial> {
  /// Hizalanmaya **her girişte** artar. Alt bileşenler bu sayaca bakar,
  /// `aligned` bayrağına değil — böylece hizalı kalmak süresince vurgu
  /// yeniden tetiklenmez.
  int _alignmentPulse = 0;

  @override
  void didUpdateWidget(QiblaDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.aligned && !oldWidget.aligned) {
      _alignmentPulse++;
      // Hafif dokunsal geri bildirim: giriş başına BİR kez. Azaltılmış
      // hareket ayarına bağlanmaz — bu bir animasyon değil, erişilebilir
      // bir bildirimdir (ekrana bakmadan da anlaşılır).
      unawaited(HapticFeedback.selectionClick());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RepaintBoundary(child: _DialPlate(size: widget.size)),
          _RotatingCompassLayer(
            size: widget.size,
            headingDegrees: widget.headingDegrees,
            qiblaBearingDegrees: widget.qiblaBearingDegrees,
            aligned: widget.aligned,
          ),
          _AlignmentHalo(
            size: widget.size,
            alignmentPulse: _alignmentPulse,
          ),
          KaabaEmblem(
            aligned: widget.aligned,
            alignmentPulse: _alignmentPulse,
            size: widget.size * 0.26,
          ),
        ],
      ),
    );
  }
}

/// Hareket etmeyen taban: katmanlı yüzeyler + sabit üst referans işareti.
final class _DialPlate extends StatelessWidget {
  const _DialPlate({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final ext = AppThemeExtension.of(context);
    final tokens = IslamicVisualTokens.of(context);

    return CustomPaint(
      size: Size.square(size),
      painter: _DialPlatePainter(
        outerSurface: tokens.sectionSurface,
        innerSurface: tokens.sacredSurface,
        borderColor: tokens.surfaceBorder,
        shadowColor: ext.textPrimary,
        referenceColor: ext.textSecondary,
      ),
    );
  }
}

final class _DialPlatePainter extends CustomPainter {
  const _DialPlatePainter({
    required this.outerSurface,
    required this.innerSurface,
    required this.borderColor,
    required this.shadowColor,
    required this.referenceColor,
  });

  final Color outerSurface;
  final Color innerSurface;
  final Color borderColor;
  final Color shadowColor;
  final Color referenceColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Dış tabla — yumuşak, tek yönlü bir derinlik gölgesiyle oturur.
    canvas.drawCircle(
      center.translate(0, 2),
      radius - 6,
      Paint()
        ..color = shadowColor.withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(center, radius - 6, Paint()..color = outerSurface);
    canvas.drawCircle(
      center,
      radius - 6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = borderColor,
    );

    // İç çukur — Kâbe'nin oturduğu sakin yüzey.
    final innerRadius = radius * 0.46;
    canvas.drawCircle(center, innerRadius, Paint()..color = innerSurface);
    canvas.drawCircle(
      center,
      innerRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = borderColor.withValues(alpha: 0.7),
    );

    // Kullanıcının baktığı yönü gösteren SABİT üst işaret — halkayla
    // dönmez, referans noktasıdır.
    final tip = center.translate(0, -(radius - 8));
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - 6, tip.dy - 11)
        ..lineTo(tip.dx + 6, tip.dy - 11)
        ..close(),
      Paint()..color = referenceColor,
    );
  }

  @override
  bool shouldRepaint(_DialPlatePainter oldDelegate) =>
      oldDelegate.outerSurface != outerSurface ||
      oldDelegate.innerSurface != innerSurface ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.shadowColor != shadowColor ||
      oldDelegate.referenceColor != referenceColor;
}

/// Cihaz döndükçe hareket eden tek katman.
///
/// Dönüş **sarmalanmadan biriktirilir**: 359° → 1° geçişinde kısa yoldan
/// 2 derece ilerler, geriye doğru 358 derecelik sahte bir tur atmaz.
/// Süre `AppMotion.tap` kadardır — gözle görülür biçimde akıcı ama fark
/// edilir bir gecikme yaratmayacak kadar kısa.
final class _RotatingCompassLayer extends StatefulWidget {
  const _RotatingCompassLayer({
    required this.size,
    required this.headingDegrees,
    required this.qiblaBearingDegrees,
    required this.aligned,
  });

  final double size;
  final double? headingDegrees;
  final double qiblaBearingDegrees;
  final bool aligned;

  @override
  State<_RotatingCompassLayer> createState() => _RotatingCompassLayerState();
}

class _RotatingCompassLayerState extends State<_RotatingCompassLayer> {
  /// Sarmalanmamış hedef açı (derece). Yalnız artar/azalır, 360'ta
  /// sıfırlanmaz — böylece ara değerler kısa yoldan geçer.
  late double _target = -(widget.headingDegrees ?? 0);

  @override
  void didUpdateWidget(_RotatingCompassLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previous = oldWidget.headingDegrees;
    final next = widget.headingDegrees;
    if (previous == next) {
      return;
    }
    if (previous == null || next == null) {
      // Okuma başladı ya da kesildi: ara değer üretmeden doğrudan geçilir.
      _target = -(next ?? 0);
      return;
    }
    _target -= QiblaBearing.shortestDifference(previous, next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ext = AppThemeExtension.of(context);
    final tokens = IslamicVisualTokens.of(context);
    final scheme = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: _target),
      duration: AppMotion.of(context, AppMotion.tap),
      curve: AppMotion.tapCurve,
      builder: (context, rotation, _) => RepaintBoundary(
        child: CustomPaint(
          key: QiblaDial.compassRingKey,
          size: Size.square(widget.size),
          painter: _CompassRingPainter(
            rotationDegrees: rotation,
            qiblaBearingDegrees: widget.qiblaBearingDegrees,
            aligned: widget.aligned,
            tickColor: ext.textTertiary,
            majorTickColor: ext.textSecondary,
            northColor: scheme.tertiary,
            labelColor: ext.textSecondary,
            markerColor: widget.aligned ? scheme.primary : scheme.secondary,
            markerShadowColor: ext.textPrimary,
            trackColor: tokens.surfaceBorder,
            cardinals: [
              l10n.qiblaCardinalNorth,
              l10n.qiblaCardinalEast,
              l10n.qiblaCardinalSouth,
              l10n.qiblaCardinalWest,
            ],
          ),
        ),
      ),
    );
  }
}

/// Kadran geometrisi — SAF ve test edilebilir.
///
/// Tek varlık sebebi şudur: kadrandaki her konum **yalnız açıdan** türer.
/// Fonksiyon `TextDirection` almaz, dolayısıyla RTL'de aynalanacak bir
/// girdi yoktur — doğu her dilde aynı fiziksel tarafta kalır.
abstract final class QiblaDialGeometry {
  static double toRadians(double degrees) => degrees * math.pi / 180;

  /// [degrees] açısında, merkezden [distance] uzaklıktaki nokta.
  /// 0 derece yukarı (kuzey), 90 derece saat yönünde sağa bakar.
  static Offset pointAt(Offset center, double degrees, double distance) {
    final angle = toRadians(degrees - 90);
    return center + Offset(math.cos(angle), math.sin(angle)) * distance;
  }
}

final class _CompassRingPainter extends CustomPainter {
  _CompassRingPainter({
    required this.rotationDegrees,
    required this.qiblaBearingDegrees,
    required this.aligned,
    required this.tickColor,
    required this.majorTickColor,
    required this.northColor,
    required this.labelColor,
    required this.markerColor,
    required this.markerShadowColor,
    required this.trackColor,
    required this.cardinals,
  });

  final double rotationDegrees;
  final double qiblaBearingDegrees;
  final bool aligned;
  final Color tickColor;
  final Color majorTickColor;
  final Color northColor;
  final Color labelColor;
  final Color markerColor;
  final Color markerShadowColor;
  final Color trackColor;

  /// Kuzey, doğu, güney, batı harfleri — bu sırayla.
  final List<String> cardinals;

  static double _rad(double degrees) => QiblaDialGeometry.toRadians(degrees);

  static Offset _pointAt(Offset center, double degrees, double distance) =>
      QiblaDialGeometry.pointAt(center, degrees, distance);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Çentiklerin üzerinde durduğu ince iz.
    canvas.drawCircle(
      center,
      radius - 20,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = trackColor.withValues(alpha: 0.8),
    );

    for (var degree = 0; degree < 360; degree += 10) {
      final isMajor = degree % 30 == 0;
      final isNorth = degree == 0;
      final rotated = degree + rotationDegrees;
      final outer = _pointAt(center, rotated, radius - 12);
      final inner = _pointAt(
        center,
        rotated,
        radius - (isNorth ? 30 : (isMajor ? 26 : 20)),
      );
      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..strokeWidth = isNorth ? 3 : (isMajor ? 2 : 1)
          ..strokeCap = StrokeCap.round
          ..color = isNorth
              ? northColor
              : (isMajor ? majorTickColor : tickColor),
      );
    }

    // Yön harfleri: konum açıdan gelir, HARF DİK KALIR.
    for (var i = 0; i < cardinals.length; i++) {
      _paintUprightLabel(
        canvas,
        center: center,
        text: cardinals[i],
        degrees: i * 90 + rotationDegrees,
        distance: radius - 44,
        color: i == 0 ? northColor : labelColor,
        bold: i == 0,
      );
    }

    _paintQiblaMarker(canvas, center, radius);
  }

  /// Kıble işareti — sıradan çentiklerden **belirgin biçimde güçlüdür**:
  /// konik bir ibre, halka üzerinde dolu bir ok başı ve yumuşak bir gölge.
  void _paintQiblaMarker(Canvas canvas, Offset center, double radius) {
    final degrees = qiblaBearingDegrees + rotationDegrees;
    final angle = _rad(degrees - 90);
    final direction = Offset(math.cos(angle), math.sin(angle));
    final side = Offset(-direction.dy, direction.dx);

    final base = center + direction * (radius * 0.34);
    final neck = center + direction * (radius - 34);
    final tip = center + direction * (radius - 14);
    final halfWidth = aligned ? 6.0 : 5.0;

    // Konik gövde: tabanda geniş, boyunda dar — düz bir çizgiden daha
    // "ibre" durur ve çentiklerle karışmaz.
    final body = Path()
      ..moveTo(base.dx + side.dx * halfWidth, base.dy + side.dy * halfWidth)
      ..lineTo(neck.dx + side.dx * 2.2, neck.dy + side.dy * 2.2)
      ..lineTo(neck.dx - side.dx * 2.2, neck.dy - side.dy * 2.2)
      ..lineTo(base.dx - side.dx * halfWidth, base.dy - side.dy * halfWidth)
      ..close();

    final head = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(neck.dx + side.dx * 9, neck.dy + side.dy * 9)
      ..lineTo(neck.dx - side.dx * 9, neck.dy - side.dy * 9)
      ..close();

    canvas.drawPath(
      head,
      Paint()
        ..color = markerShadowColor.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawPath(body, Paint()..color = markerColor);
    canvas.drawPath(head, Paint()..color = markerColor);
  }

  void _paintUprightLabel(
    Canvas canvas, {
    required Offset center,
    required String text,
    required double degrees,
    required double distance,
    required Color color,
    required bool bold,
  }) {
    final position = _pointAt(center, degrees, distance);
    // Tek harf; yön bilgisi konumdan gelir, metin yönünden DEĞİL — bu
    // yüzden `ltr` sabittir ve RTL'de hiçbir şey aynalanmaz.
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: bold ? 15 : 13,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      position - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_CompassRingPainter oldDelegate) =>
      oldDelegate.rotationDegrees != rotationDegrees ||
      oldDelegate.qiblaBearingDegrees != qiblaBearingDegrees ||
      oldDelegate.aligned != aligned ||
      oldDelegate.markerColor != markerColor ||
      oldDelegate.labelColor != labelColor ||
      !listEquals(oldDelegate.cardinals, cardinals);
}

/// Hizalanmaya girişte **bir kez** oynayan, sönümlenen halka.
///
/// Kalıcı parlama, yanıp sönme veya konfeti değildir: tek bir dalga
/// dışa doğru açılır ve kaybolur. Azaltılmış hareket açıkken hiç çizilmez.
final class _AlignmentHalo extends StatefulWidget {
  const _AlignmentHalo({required this.size, required this.alignmentPulse});

  final double size;
  final int alignmentPulse;

  @override
  State<_AlignmentHalo> createState() => _AlignmentHaloState();
}

class _AlignmentHaloState extends State<_AlignmentHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.gentle,
  );

  @override
  void didUpdateWidget(_AlignmentHalo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.alignmentPulse == oldWidget.alignmentPulse) {
      return;
    }
    if (AppMotion.isReduced(context)) {
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
    final scheme = Theme.of(context).colorScheme;

    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            if (_controller.value == 0) {
              // Boşta hiçbir şey çizilmez — sürekli animasyon yoktur.
              return SizedBox.square(dimension: widget.size);
            }
            return CustomPaint(
              size: Size.square(widget.size),
              painter: _HaloPainter(
                progress: Curves.easeOutCubic.transform(_controller.value),
                color: scheme.primary,
              ),
            );
          },
        ),
      ),
    );
  }
}

final class _HaloPainter extends CustomPainter {
  const _HaloPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2 - 14;
    final radius = maxRadius * (0.32 + 0.68 * progress);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * (1 - progress) + 0.5
        ..color = color.withValues(alpha: 0.45 * (1 - progress)),
    );
  }

  @override
  bool shouldRepaint(_HaloPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
