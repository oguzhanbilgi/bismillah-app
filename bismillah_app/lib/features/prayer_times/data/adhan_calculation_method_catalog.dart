import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:bismillah_app/features/prayer_times/domain/prayer_time_calculation_method.dart';

/// Uygulama yöntemi → adhan_dart preset'i eşlemesinin **TEK** yeri.
///
/// `switch` **tüketicidir** (`default` ve joker YOK): enum'a yeni bir yöntem
/// eklemek derleme HATASI verir — sessizce yanlış bir preset'e düşmez
/// (TASK 094'te sabitlenen disiplin). Parametreler burada ELLE YAZILMAZ;
/// doğrudan `CalculationMethodParameters` fabrikalarından gelir, bu yüzden
/// uygulanan hesap ile kullanıcıya gösterilen açıklama tek kaynaktan okunur.
adhan.CalculationParameters adhanParametersFor(
  PrayerTimeCalculationMethod method,
) => switch (method) {
  PrayerTimeCalculationMethod.turkiyeDiyanet =>
    adhan.CalculationMethodParameters.turkiye(),
  PrayerTimeCalculationMethod.muslimWorldLeague =>
    adhan.CalculationMethodParameters.muslimWorldLeague(),
  PrayerTimeCalculationMethod.egyptian =>
    adhan.CalculationMethodParameters.egyptian(),
  PrayerTimeCalculationMethod.karachi =>
    adhan.CalculationMethodParameters.karachi(),
  PrayerTimeCalculationMethod.northAmerica =>
    adhan.CalculationMethodParameters.northAmerica(),
  PrayerTimeCalculationMethod.ummAlQura =>
    adhan.CalculationMethodParameters.ummAlQura(),
  PrayerTimeCalculationMethod.dubai =>
    adhan.CalculationMethodParameters.dubai(),
  PrayerTimeCalculationMethod.qatar =>
    adhan.CalculationMethodParameters.qatar(),
  PrayerTimeCalculationMethod.kuwait =>
    adhan.CalculationMethodParameters.kuwait(),
  PrayerTimeCalculationMethod.gulfRegion =>
    adhan.CalculationMethodParameters.gulfRegion(),
  PrayerTimeCalculationMethod.moonsightingCommittee =>
    adhan.CalculationMethodParameters.moonsightingCommittee(),
  PrayerTimeCalculationMethod.singapore =>
    adhan.CalculationMethodParameters.singapore(),
  PrayerTimeCalculationMethod.indonesian =>
    adhan.CalculationMethodParameters.indonesian(),
  PrayerTimeCalculationMethod.morocco =>
    adhan.CalculationMethodParameters.morocco(),
  PrayerTimeCalculationMethod.algerian =>
    adhan.CalculationMethodParameters.algerian(),
  PrayerTimeCalculationMethod.tunisia =>
    adhan.CalculationMethodParameters.tunisia(),
  PrayerTimeCalculationMethod.jordan =>
    adhan.CalculationMethodParameters.jordan(),
  PrayerTimeCalculationMethod.france =>
    adhan.CalculationMethodParameters.france(),
  PrayerTimeCalculationMethod.portugal =>
    adhan.CalculationMethodParameters.portugal(),
  PrayerTimeCalculationMethod.russia =>
    adhan.CalculationMethodParameters.russia(),
};

/// Motorun kendi preset'lerinden OKUYAN katalog. Hiçbir açı/dakika değeri
/// burada tekrar tanımlanmaz — parametreler [adhanParametersFor] üzerinden
/// gelir, yani ekranda görünen açıklama hesabın kendisiyle aynı kaynaktır.
final class AdhanPrayerCalculationMethodCatalog
    implements PrayerCalculationMethodCatalog {
  const AdhanPrayerCalculationMethodCatalog();

  @override
  List<PrayerTimeCalculationMethod> get supportedMethods =>
      PrayerTimeCalculationMethod.values;

  @override
  PrayerCalculationMethodParameters parametersFor(
    PrayerTimeCalculationMethod method,
  ) {
    final params = adhanParametersFor(method);
    return PrayerCalculationMethodParameters(
      fajrAngle: params.fajrAngle,
      ishaAngle: params.ishaAngle,
      // Preset kurucusu `ishaInterval`'i her zaman doldurur (varsayılan 0);
      // `??` yalnız tip güvenliği içindir, varsayılan UYDURMAZ.
      ishaIntervalMinutes: params.ishaInterval ?? 0,
      hasMethodMinuteAdjustments: params.methodAdjustments.values.any(
        (minutes) => minutes != 0,
      ),
    );
  }
}
