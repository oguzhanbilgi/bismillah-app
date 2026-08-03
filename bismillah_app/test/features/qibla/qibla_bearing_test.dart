import 'dart:io';

import 'package:bismillah_app/features/qibla/domain/heading_smoother.dart';
import 'package:bismillah_app/features/qibla/domain/kaaba_location.dart';
import 'package:bismillah_app/features/qibla/domain/qibla_alignment.dart';
import 'package:bismillah_app/features/qibla/domain/qibla_bearing.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 095 — kıble matematiği, yumuşatma ve hizalanma (SAF katman).
///
/// Bu dosya hiçbir widget veya eklenti kurmaz: yön hesabının sensörden ve
/// arayüzden bağımsız olarak test edilebildiğinin kanıtıdır. Fiziksel
/// pusula doğruluğu burada ÖLÇÜLMEZ — ölçülemez de.
void main() {
  group('normalizeDegrees', () {
    test('her girdiyi [0, 360) aralığına indirger', () {
      expect(QiblaBearing.normalizeDegrees(0), 0);
      expect(QiblaBearing.normalizeDegrees(151.6), closeTo(151.6, 1e-9));
      expect(QiblaBearing.normalizeDegrees(360), 0);
      expect(QiblaBearing.normalizeDegrees(-10), closeTo(350, 1e-9));
      expect(QiblaBearing.normalizeDegrees(-360), 0);
      expect(QiblaBearing.normalizeDegrees(370), closeTo(10, 1e-9));
      expect(QiblaBearing.normalizeDegrees(720.5), closeTo(0.5, 1e-9));
      expect(QiblaBearing.normalizeDegrees(-725), closeTo(355, 1e-9));
    });

    test('negatif sıfır pozitif sıfıra çevrilir', () {
      final normalized = QiblaBearing.normalizeDegrees(-0.0);
      expect(normalized, 0);
      expect(normalized.isNegative, isFalse);
    });
  });

  group('shortestDifference', () {
    test('sarmalarda kısa yolu seçer', () {
      expect(QiblaBearing.shortestDifference(359, 1), closeTo(2, 1e-9));
      expect(QiblaBearing.shortestDifference(1, 359), closeTo(-2, 1e-9));
      expect(QiblaBearing.shortestDifference(10, 10), 0);
      expect(QiblaBearing.shortestDifference(0, 180), closeTo(180, 1e-9));
      // Tam karşı yönde işaret tutarlı kalır (-180 değil +180 tarafı).
      expect(QiblaBearing.shortestDifference(180, 0), closeTo(180, 1e-9));
    });

    test('sonuç daima (-180, 180] aralığındadır', () {
      for (var from = 0; from < 360; from += 7) {
        for (var to = 0; to < 360; to += 11) {
          final diff = QiblaBearing.shortestDifference(
            from.toDouble(),
            to.toDouble(),
          );
          expect(diff, greaterThan(-180));
          expect(diff, lessThanOrEqualTo(180));
        }
      }
    });
  });

  group('fromCoordinates — bilinen konumlar', () {
    // Beklenen değerler bağımsız olarak yayımlanmış kıble yönleridir
    // (ör. İstanbul ~151.6°, Londra ~118.9°, New York ~58.5°,
    // Jakarta ~295.2°, Kuala Lumpur ~292.5°). Tolerans 1 derecedir:
    // daha dar bir tolerans, telefon pusulasının veremeyeceği bir
    // kesinliği test etmiş olurdu.
    const tolerance = 1.0;

    void expectBearing(
      String label,
      double latitude,
      double longitude,
      double expected,
    ) {
      test('$label yönü ~$expected derece', () {
        final result = QiblaBearing.fromCoordinates(
          latitude: latitude,
          longitude: longitude,
        );
        expect(result, isA<QiblaBearingComputed>());
        final degrees = (result as QiblaBearingComputed).degrees;
        expect(degrees, closeTo(expected, tolerance));
        expect(degrees, greaterThanOrEqualTo(0));
        expect(degrees, lessThan(360));
      });
    }

    expectBearing('İstanbul', 41.0082, 28.9784, 151.6);
    expectBearing('Ankara', 39.9334, 32.8597, 160.2);
    expectBearing('Londra', 51.5074, -0.1278, 118.9);
    expectBearing('New York', 40.7128, -74.0060, 58.5);
    expectBearing('Jakarta', -6.2088, 106.8456, 295.2);
    expectBearing('Kuala Lumpur', 3.1390, 101.6869, 292.5);
    expectBearing('Cape Town', -33.9249, 18.4241, 23.4);
    expectBearing('Sydney', -33.8688, 151.2093, 277.5);

    test('aynı boylamda kuzeydeki konum tam güneye bakar', () {
      final result = QiblaBearing.fromCoordinates(
        latitude: 40,
        longitude: KaabaLocation.longitude,
      );
      expect((result as QiblaBearingComputed).degrees, closeTo(180, 1e-6));
    });

    test('aynı boylamda güneydeki konum tam kuzeye bakar', () {
      final result = QiblaBearing.fromCoordinates(
        latitude: 0,
        longitude: KaabaLocation.longitude,
      );
      expect((result as QiblaBearingComputed).degrees, closeTo(0, 1e-6));
    });

    test('sonuç her zaman normalize edilmiştir', () {
      for (var lat = -80; lat <= 80; lat += 20) {
        for (var lon = -180; lon <= 180; lon += 30) {
          final result = QiblaBearing.fromCoordinates(
            latitude: lat.toDouble(),
            longitude: lon.toDouble(),
          );
          if (result is QiblaBearingComputed) {
            expect(result.degrees, greaterThanOrEqualTo(0));
            expect(result.degrees, lessThan(360));
          }
        }
      }
    });
  });

  group('fromCoordinates — güvenli girdi', () {
    test('geçersiz enlem/boylam tipli başarısızlık döndürür', () {
      for (final pair in <List<double>>[
        [91, 0],
        [-91, 0],
        [0, 181],
        [0, -181],
        [double.nan, 0],
        [0, double.nan],
        [double.infinity, 0],
        [0, double.negativeInfinity],
      ]) {
        final result = QiblaBearing.fromCoordinates(
          latitude: pair[0],
          longitude: pair[1],
        );
        expect(
          result,
          isA<QiblaBearingUnavailable>().having(
            (r) => r.issue,
            'issue',
            QiblaBearingIssue.invalidCoordinates,
          ),
          reason: 'geçersiz girdi için sayı uydurulmamalı: $pair',
        );
      }
    });

    test('Kâbe ile aynı nokta tanımsızdır (0 derece DÖNMEZ)', () {
      final result = QiblaBearing.fromCoordinates(
        latitude: KaabaLocation.latitude,
        longitude: KaabaLocation.longitude,
      );
      expect(
        result,
        isA<QiblaBearingUnavailable>().having(
          (r) => r.issue,
          'issue',
          QiblaBearingIssue.atKaaba,
        ),
      );
    });

    test('karşı-ayak (antipod) nokta tanımsızdır', () {
      final result = QiblaBearing.fromCoordinates(
        latitude: -KaabaLocation.latitude,
        longitude: KaabaLocation.longitude - 180,
      );
      expect(
        result,
        isA<QiblaBearingUnavailable>().having(
          (r) => r.issue,
          'issue',
          QiblaBearingIssue.antipodal,
        ),
      );
    });

    test('Kâbe yakınındaki (aynı olmayan) nokta yine hesaplanır', () {
      final result = QiblaBearing.fromCoordinates(
        latitude: KaabaLocation.latitude + 0.01,
        longitude: KaabaLocation.longitude,
      );
      expect((result as QiblaBearingComputed).degrees, closeTo(180, 1e-3));
    });

    test('uç enlemler (kutuplar) çökme üretmez', () {
      for (final lat in <double>[90, -90]) {
        final result = QiblaBearing.fromCoordinates(latitude: lat, longitude: 0);
        expect(result, isA<QiblaBearingComputed>());
      }
    });
  });

  group('QiblaAlignment', () {
    test('tolerans penceresi içinde hizalı sayılır', () {
      expect(QiblaAlignment.isAligned(heading: 151, qiblaBearing: 151.6), isTrue);
      expect(
        QiblaAlignment.isAligned(heading: 146.7, qiblaBearing: 151.6),
        isTrue,
      );
      expect(
        QiblaAlignment.isAligned(heading: 156.5, qiblaBearing: 151.6),
        isTrue,
      );
    });

    test('pencere dışında hizasızdır', () {
      expect(
        QiblaAlignment.isAligned(heading: 140, qiblaBearing: 151.6),
        isFalse,
      );
      expect(
        QiblaAlignment.isAligned(heading: 331.6, qiblaBearing: 151.6),
        isFalse,
      );
    });

    test('sarmalarda da doğru çalışır', () {
      expect(QiblaAlignment.isAligned(heading: 358, qiblaBearing: 2), isTrue);
      expect(
        QiblaAlignment.offset(heading: 358, qiblaBearing: 2),
        closeTo(4, 1e-9),
      );
      expect(
        QiblaAlignment.offset(heading: 2, qiblaBearing: 358),
        closeTo(-4, 1e-9),
      );
    });
  });

  group('HeadingSmoother', () {
    test('ilk okuma beklemeden yayınlanır', () {
      final smoother = HeadingSmoother();
      expect(smoother.add(120), closeTo(120, 1e-9));
    });

    test('gürültülü küçük oynamalar yayınlanmaz (ibre titremez)', () {
      final smoother = HeadingSmoother();
      smoother.add(100);

      var emitted = 0;
      for (final noisy in <double>[100.4, 99.7, 100.2, 99.9, 100.3, 100.1]) {
        if (smoother.add(noisy) != null) {
          emitted++;
        }
      }
      expect(
        emitted,
        0,
        reason: 'eşik altındaki gürültü yeni kare üretmemeli',
      );
    });

    test('gerçek dönüşte anında tepki verir (gecikme yok)', () {
      final smoother = HeadingSmoother();
      smoother.add(10);
      final snapped = smoother.add(200);
      expect(snapped, closeTo(200, 1e-9));
    });

    test('eşik altı ama süregelen kayma sonunda yayınlanır', () {
      final smoother = HeadingSmoother(
        smoothingFactor: 0.5,
        minimumChangeDegrees: 1,
        snapThresholdDegrees: 30,
      );
      smoother.add(0);
      // 4 derecelik gerçek bir kayma: yumuşatılarak da olsa görünür.
      final result = smoother.add(4);
      expect(result, isNotNull);
      expect(result, closeTo(2, 1e-9));
    });

    test('359 → 1 sarmalında geriye 358 derece dönmez', () {
      final smoother = HeadingSmoother(
        smoothingFactor: 0.5,
        minimumChangeDegrees: 0.1,
        snapThresholdDegrees: 30,
      );
      smoother.add(359);
      final result = smoother.add(1)!;
      // Kısa yol: 359 → 0 yönünde ilerler, 180 civarına SAPMAZ.
      expect(result, closeTo(0, 1e-9));
    });

    test('sonlu olmayan okuma yok sayılır ve durumu bozmaz', () {
      final smoother = HeadingSmoother();
      smoother.add(90);
      expect(smoother.add(double.nan), isNull);
      expect(smoother.add(double.infinity), isNull);
      expect(smoother.emitted, closeTo(90, 1e-9));
    });

    test('reset sonrası ilk okuma yeniden anında yayınlanır', () {
      final smoother = HeadingSmoother()..add(90);
      smoother.reset();
      expect(smoother.emitted, isNull);
      expect(smoother.add(200), closeTo(200, 1e-9));
    });

    test('yumuşatılmış değer daima [0, 360) aralığındadır', () {
      final smoother = HeadingSmoother();
      var value = 0.0;
      for (var i = 0; i < 200; i++) {
        value = (value + 3.7) % 360;
        final emitted = smoother.add(value);
        if (emitted != null) {
          expect(emitted, greaterThanOrEqualTo(0));
          expect(emitted, lessThan(360));
        }
      }
    });
  });

  group('gizlilik — kaynak taraması', () {
    test('kıble modülü kalıcı depo/analitik/ağ kullanmaz', () {
      final directory = Directory('lib/features/qibla');
      expect(directory.existsSync(), isTrue);

      final forbidden = <String>[
        'shared_preferences',
        'core/storage',
        'drift',
        'cloud_functions',
        'firebase',
        'package:http',
        'analytics',
      ];

      for (final file in directory
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final source = file.readAsStringSync();
        for (final needle in forbidden) {
          expect(
            source.contains(needle),
            isFalse,
            reason:
                '${file.path} içinde "$needle" geçiyor — konum/kıble verisi '
                'kalıcılaştırılmamalı veya gönderilmemeli',
          );
        }
      }
    });

    test('Kâbe koordinatı tek ve belgelenmiş bir sabittir', () {
      expect(KaabaLocation.latitude, 21.4225);
      expect(KaabaLocation.longitude, 39.8262);

      final source = File(
        'lib/features/qibla/domain/kaaba_location.dart',
      ).readAsStringSync();
      // Sayı açıklamasız kopyalanmış OLMAMALI: kaynak ve bilinen sınırlar
      // aynı dosyada yazılıdır.
      expect(source.contains('Kaynak ve gerekçe'), isTrue);
      expect(source.contains('Bilinen sınırlar'), isTrue);
    });
  });
}
