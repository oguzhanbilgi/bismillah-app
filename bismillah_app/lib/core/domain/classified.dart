import 'package:bismillah_app/core/privacy/sensitivity_class.dart';

/// Hassasiyet sınıfı bildirimi (10_DATA_MODEL §2-2, §19).
///
/// Privacy-by-design: her saklanan domain entity'si sınıf düzeyinde
/// hassasiyetini bildirir; sınıfsız alan/entity şemaya giremez.
/// `PrivacyGuard.canLog/canStore` bu bildirimi tüketir — Yüksek sınıf
/// veri asla loglanamaz, Restricted hiçbir katmanda saklanamaz.
abstract interface class Classified {
  SensitivityClass get sensitivityClass;
}
