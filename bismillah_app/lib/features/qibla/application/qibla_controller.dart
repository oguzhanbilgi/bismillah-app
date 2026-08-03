import 'dart:async';

import 'package:bismillah_app/features/prayer_times/data/prayer_times_providers.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_location.dart';
import 'package:bismillah_app/features/qibla/application/qibla_state.dart';
import 'package:bismillah_app/features/qibla/data/qibla_providers.dart';
import 'package:bismillah_app/features/qibla/domain/heading_smoother.dart';
import 'package:bismillah_app/features/qibla/domain/qibla_alignment.dart';
import 'package:bismillah_app/features/qibla/domain/qibla_bearing.dart';
import 'package:bismillah_app/features/qibla/domain/qibla_compass_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Okuma gelmediğinde "geçici olarak yön yok" denmeden önce beklenen süre.
const Duration kQiblaHeadingTimeout = Duration(seconds: 5);

final qiblaControllerProvider =
    AsyncNotifierProvider<QiblaController, QiblaState>(QiblaController.new);

/// Kıble controller'ı (TASK 095).
///
/// ## Konum
///
/// Yeni bir konum kaynağı KURULMAZ: uygulamanın namaz vakitlerinde zaten
/// kullandığı `prayerLocationServiceProvider` paylaşılır ve açılışta
/// `currentLocationIfPermitted()` çağrılır — yani **izin zaten verilmişse
/// yeni bir platform izin diyaloğu ÇIKMAZ**. İzin yoksa önce ekranda
/// konumun neden gerektiği anlatılır; platform isteği ancak kullanıcı
/// açıkça [useLocation] dediğinde tetiklenir. Arka plan konumu istenmez.
///
/// Koordinat yalnız kerteriz hesabı ve manyetik sapma düzeltmesi için
/// kullanılır; hiçbir duruma, kalıcı depoya, analitiğe veya kıble geçmişine
/// YAZILMAZ (böyle bir geçmiş yoktur).
///
/// ## Pusula
///
/// Ham okuma doğrudan arayüze verilmez; [HeadingSmoother] üzerinden geçer,
/// böylece ibre titremez ama gerçek dönüşlerde anında tepki verir.
final class QiblaController extends AsyncNotifier<QiblaState> {
  StreamSubscription<QiblaCompassEvent>? _subscription;
  Timer? _headingTimeout;
  final HeadingSmoother _smoother = HeadingSmoother();
  bool _disposed = false;

  @override
  Future<QiblaState> build() async {
    ref.onDispose(() {
      _disposed = true;
      _stopCompass();
    });
    final result = await ref
        .read(prayerLocationServiceProvider)
        .currentLocationIfPermitted();
    return _map(result);
  }

  /// Kullanıcının açık isteği: platform konum iznini İSTER, sonra hesaplar.
  Future<void> useLocation() async {
    _stopCompass();
    state = const AsyncLoading<QiblaState>();
    final result = await ref
        .read(prayerLocationServiceProvider)
        .requestLocation();
    state = AsyncData(_map(result));
  }

  /// İzin verilmiş ama konum/hesap başarısızsa yeniden dener (izin İSTEMEZ).
  Future<void> retry() async {
    _stopCompass();
    state = const AsyncLoading<QiblaState>();
    final result = await ref
        .read(prayerLocationServiceProvider)
        .currentLocationIfPermitted();
    state = AsyncData(_map(result));
  }

  /// Kalıcı reddedilmiş izinde sistem ayarlarını açar.
  Future<void> openSettings() =>
      ref.read(prayerLocationServiceProvider).openAppSettings();

  QiblaState _map(PrayerLocationResult result) {
    switch (result) {
      case PrayerLocationResolved(:final location):
        final bearing = QiblaBearing.fromCoordinates(
          latitude: location.coordinates.latitude,
          longitude: location.coordinates.longitude,
        );
        switch (bearing) {
          case QiblaBearingComputed(:final degrees):
            _scheduleCompass(
              latitude: location.coordinates.latitude,
              longitude: location.coordinates.longitude,
            );
            return QiblaReady(
              bearingDegrees: degrees,
              approximateLocation: location.isApproximate,
              compass: const QiblaCompassWaitingStatus(),
            );
          case QiblaBearingUnavailable(:final issue):
            return QiblaBearingFailed(issue);
        }
      case PrayerLocationPermissionDenied(:final permanentlyDenied):
        return QiblaLocationPermissionNeeded(
          permanentlyDenied: permanentlyDenied,
        );
      case PrayerLocationServiceDisabled():
        return const QiblaLocationServiceDisabledState();
      case PrayerLocationUnavailable():
        return const QiblaLocationUnavailableState();
    }
  }

  /// Aboneliği olay döngüsünün bir sonraki turuna erteler.
  ///
  /// [_map] hem `build()` içinden hem de state atanmadan hemen önce
  /// çağrılır; akış oradan doğrudan açılırsa ilk okuma, durum daha
  /// başlatılmadan gelebilir. `Future(...)` bekleyen tüm microtask'lardan
  /// sonra çalışır, yani durum kesinlikle hazırdır.
  void _scheduleCompass({
    required double latitude,
    required double longitude,
  }) {
    unawaited(
      Future<void>(() {
        if (_disposed) {
          return;
        }
        _startCompass(latitude: latitude, longitude: longitude);
      }),
    );
  }

  void _startCompass({required double latitude, required double longitude}) {
    _stopCompass();
    _smoother.reset();
    _armHeadingTimeout();
    _subscription = ref
        .read(qiblaCompassServiceProvider)
        .headings(latitude: latitude, longitude: longitude)
        .listen(
          _onCompassEvent,
          // Akış hatası ekranı bozmaz; sabit açı görünmeye devam eder.
          onError: (Object _) => _applyCompass(
            const QiblaCompassInterruptedStatus(),
          ),
          onDone: () => _headingTimeout?.cancel(),
        );
  }

  void _stopCompass() {
    _headingTimeout?.cancel();
    _headingTimeout = null;
    final subscription = _subscription;
    _subscription = null;
    if (subscription != null) {
      // İptal hatası yutulur ama YAKALANIR: `unawaited(cancel())` hiçbir
      // şeyi içermez ve başarısız iptal işlenmemiş asenkron hataya döner
      // (TASK 085'te düzeltilen aynı sınıf hata).
      unawaited(subscription.cancel().catchError((Object _) {}));
    }
  }

  /// Okuma akışı sessizleşirse dürüst biçimde "şu an yön yok" denir.
  void _armHeadingTimeout() {
    _headingTimeout?.cancel();
    _headingTimeout = Timer(
      kQiblaHeadingTimeout,
      () => _applyCompass(const QiblaCompassInterruptedStatus()),
    );
  }

  void _onCompassEvent(QiblaCompassEvent event) {
    switch (event) {
      case QiblaCompassUnsupported():
        _headingTimeout?.cancel();
        _headingTimeout = null;
        _applyCompass(const QiblaCompassUnsupportedStatus());
      case QiblaCompassHeadingUnavailable():
        _armHeadingTimeout();
        _applyCompass(const QiblaCompassInterruptedStatus());
      case QiblaCompassHeading(:final degrees, :final confidence):
        _armHeadingTimeout();
        final smoothed = _smoother.add(degrees);
        if (smoothed == null) {
          // Değişim gözle görülmeyecek kadar küçük — kare yayınlanmaz.
          return;
        }
        final current = state.value;
        if (current is! QiblaReady) {
          return;
        }
        _applyCompass(
          QiblaCompassActiveStatus(
            headingDegrees: smoothed,
            offsetDegrees: QiblaAlignment.offset(
              heading: smoothed,
              qiblaBearing: current.bearingDegrees,
            ),
            aligned: QiblaAlignment.isAligned(
              heading: smoothed,
              qiblaBearing: current.bearingDegrees,
            ),
            confidence: confidence,
          ),
        );
    }
  }

  /// Pusula alt-durumunu yalnız [QiblaReady] üzerine uygular; başka bir
  /// durumdayken gelen geç okuma ekranı DEĞİŞTİRMEZ.
  void _applyCompass(QiblaCompassStatus status) {
    final current = state.value;
    if (current is! QiblaReady) {
      return;
    }
    state = AsyncData(current.withCompass(status));
  }
}
