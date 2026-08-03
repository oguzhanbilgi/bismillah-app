import 'dart:async';

import 'package:bismillah_app/features/qibla/domain/qibla_bearing.dart';
import 'package:bismillah_app/features/qibla/domain/qibla_compass_service.dart';
import 'package:flutter/services.dart';

/// Platform yön sensörü implementasyonu (TASK 095).
///
/// Yeni bir pusula paketi EKLENMEDİ: Android tarafında zaten var olan
/// `SensorManager` bir `EventChannel` ile açılır. Böylece bakımsız bir
/// üçüncü parti eklentiye ve onun AGP/namespace sorunlarına bağımlı
/// olunmaz. Kanal adı ve yük biçimi native tarafla birebir eşleşir.
///
/// `MethodChannel`/`EventChannel` tipleri bu dosyanın dışına SIZMAZ.
final class PlatformQiblaCompassService implements QiblaCompassService {
  const PlatformQiblaCompassService([
    this._channel = const EventChannel(channelName),
  ]);

  /// Native taraftaki `EventChannel` adı ile aynı olmak ZORUNDADIR.
  static const String channelName = 'com.bismillah.app/qibla_compass';

  final EventChannel _channel;

  @override
  Stream<QiblaCompassEvent> headings({
    required double latitude,
    required double longitude,
  }) {
    return _channel
        .receiveBroadcastStream(<String, dynamic>{
          'latitude': latitude,
          'longitude': longitude,
        })
        // Platform tarafındaki her hata sakin bir "geçici okuma yok"
        // durumuna indirgenir; ekran çökmez, ham hata metni gösterilmez.
        .transform(
          StreamTransformer<dynamic, QiblaCompassEvent>.fromHandlers(
            handleData: (data, sink) => sink.add(_decode(data)),
            handleError: (error, stackTrace, sink) =>
                sink.add(const QiblaCompassHeadingUnavailable()),
          ),
        );
  }

  /// Native yükü tipli olaya çevirir. Beklenmedik/eksik alanlar geçici
  /// kullanılamazlık sayılır — uydurma bir derece ÜRETİLMEZ.
  static QiblaCompassEvent _decode(dynamic raw) {
    if (raw is! Map) {
      return const QiblaCompassHeadingUnavailable();
    }
    if (raw['type'] == 'unsupported') {
      return const QiblaCompassUnsupported();
    }
    final degrees = raw['headingDegrees'];
    if (degrees is! num || !degrees.toDouble().isFinite) {
      return const QiblaCompassHeadingUnavailable();
    }
    return QiblaCompassHeading(
      degrees: QiblaBearing.normalizeDegrees(degrees.toDouble()),
      confidence: _confidenceOf(raw['accuracy'], raw['trueNorth']),
    );
  }

  /// Android `SensorManager` doğruluk sabitleri → tipli güven seviyesi.
  /// Manyetik sapma uygulanamadıysa okuma gerçek kuzeye göre DEĞİLDİR ve
  /// doğruluk ne olursa olsun güvenilmez sayılır.
  static QiblaHeadingConfidence _confidenceOf(
    dynamic accuracy,
    dynamic trueNorth,
  ) {
    if (trueNorth != true) {
      return QiblaHeadingConfidence.unreliable;
    }
    return switch (accuracy) {
      3 => QiblaHeadingConfidence.high,
      2 => QiblaHeadingConfidence.medium,
      1 => QiblaHeadingConfidence.low,
      _ => QiblaHeadingConfidence.unreliable,
    };
  }
}
