import 'package:bismillah_app/features/qibla/domain/qibla_bearing.dart';

/// Pusula okumasını sakinleştiren SAF yardımcı (TASK 095).
///
/// Manyetometre okuması doğası gereği gürültülüdür: cihaz hiç hareket
/// etmese bile art arda gelen değerler birkaç derece oynar. İbre bu ham
/// değere doğrudan bağlanırsa gözle görülür biçimde titrer.
///
/// Burada iki mekanizma birlikte çalışır:
///
/// 1. **Dairesel üstel yumuşatma** — yeni değere [smoothingFactor] kadar
///    yaklaşılır. 359° → 1° gibi sarmalarda kısa yoldan gidilir, geriye
///    doğru 358 derecelik sahte bir dönüş üretilmez.
/// 2. **Yayın eşiği** — yumuşatılmış değer, en son yayınlanandan
///    [minimumChangeDegrees] kadar uzaklaşmadıkça yeni bir kare yayınlanmaz.
///
/// Tepkiselliği korumak için bir kaçış yolu vardır: fark
/// [snapThresholdDegrees] değerini aşarsa (kullanıcı telefonu gerçekten
/// çevirmiştir) yumuşatma atlanır ve ibre anında yeni yöne gider. Böylece
/// "titremiyor ama geç kalıyor" hissi oluşmaz.
///
/// Sınıf zaman ölçmez ve `Timer` kullanmaz; yalnız kendisine verilen
/// örneklerle çalışır, dolayısıyla testlerde tamamen belirlenimcidir.
final class HeadingSmoother {
  HeadingSmoother({
    this.smoothingFactor = 0.25,
    this.minimumChangeDegrees = 0.75,
    this.snapThresholdDegrees = 30,
  }) : assert(
         smoothingFactor > 0 && smoothingFactor <= 1,
         'smoothingFactor (0, 1] aralığında olmalıdır',
       );

  /// Her örnekte hedefe yaklaşma oranı (1 = hiç yumuşatma yok).
  final double smoothingFactor;

  /// Bu kadar derecelik değişimin altındaki güncellemeler yayınlanmaz.
  final double minimumChangeDegrees;

  /// Bunu aşan ani değişimlerde yumuşatma atlanır (gerçek dönüş).
  final double snapThresholdDegrees;

  double? _current;
  double? _emitted;

  /// En son yayınlanan yön; hiç yayın olmadıysa `null`.
  double? get emitted => _emitted;

  /// Yeni ham okumayı işler.
  ///
  /// Yayınlanacak yeni bir yön varsa onu, değişim eşiğin altında kaldığı
  /// için yayın gerekmiyorsa `null` döndürür. Sonlu olmayan okuma sessizce
  /// yok sayılır (`null`), iç durum bozulmaz.
  double? add(double rawDegrees) {
    if (!rawDegrees.isFinite) {
      return null;
    }
    final raw = QiblaBearing.normalizeDegrees(rawDegrees);

    final current = _current;
    if (current == null) {
      // İlk okuma beklemeden gösterilir — açılışta boş ibre kalmaz.
      _current = raw;
      _emitted = raw;
      return raw;
    }

    final delta = QiblaBearing.shortestDifference(current, raw);
    final next = delta.abs() >= snapThresholdDegrees
        ? raw
        : QiblaBearing.normalizeDegrees(current + delta * smoothingFactor);
    _current = next;

    final emitted = _emitted;
    if (emitted != null &&
        QiblaBearing.shortestDifference(emitted, next).abs() <
            minimumChangeDegrees) {
      return null;
    }
    _emitted = next;
    return next;
  }

  /// Akış yeniden kurulduğunda geçmişi temizler.
  void reset() {
    _current = null;
    _emitted = null;
  }
}
