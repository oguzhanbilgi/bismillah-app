import 'dart:async';

import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/today/data/daily_plan_envelope_codec.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/repositories/daily_plan_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [DailyPlanRepository]'nin SharedPreferences tabanlı implementasyonu.
///
/// **GEÇİCİ YEREL ADAPTÖR — NİHAİ VERİTABANI BİRLEŞTİRMESİNDEN ÖNCE
/// MİGRATION GEREKİR.**
///
/// Kanonik hedef mimari `DailyPlan`'ı `dayKey` unique index'li bir Drift
/// tablosuna eşler (10_DATA_MODEL §7; 11_LOCAL_DB §3 — "18 koleksiyon
/// birebir Drift tablosuna eşlenir"). Drift şema değişikliği bu görevde
/// açıkça kapsam dışı olduğu için (TASK 066 toolchain blocker'ı; ilk
/// migration TASK 075 G8 kapısına bağlı), planlar geçici olarak tek
/// anahtarlı sürümlü bir JSON zarfında saklanır. TASK 047'de Kur'an
/// günlük ilerlemesi için alınan kararın aynısıdır.
///
/// Kanonik model DEĞİŞMEZ: `DailyPlan` bir **güne** aittir; 30 günlük çatı
/// 30 ayrı `DailyPlan` kaydından oluşur. İkinci bir toplu (aggregate)
/// model eklenmemiştir.
///
/// Veri YALNIZ cihazda kalır — uzak senkronizasyon yoktur.
final class SharedPrefsDailyPlanRepository implements DailyPlanRepository {
  SharedPrefsDailyPlanRepository();

  /// Tüm günlük planların tek kalıcılık anahtarı.
  ///
  /// `bismillah.` öneki bilinçlidir: tam yerel sıfırlama
  /// (`SharedPrefsLocalDataResetRepository.clearAllExceptLocale`) bu
  /// önekteki her anahtarı sildiği için planlar sıfırlamayla otomatik
  /// temizlenir. Anahtar hiçbir kullanıcı/cihaz/profil kimliği taşımaz.
  static const String storageKey = 'bismillah.daily_plans';

  /// Kaydedilen planları dinleyicilere yayınlar. Yayın (broadcast) —
  /// çok dinleyici desteklenir.
  final StreamController<DailyPlan> _saved =
      StreamController<DailyPlan>.broadcast();

  bool _disposed = false;

  /// İzlenen gün için kaydedilen planları yayar.
  ///
  /// **Sözleşme notu (geçici davranış):** abone olunduğunda mevcut değer
  /// YAYINLANMAZ; akış yalnız sonraki `savePlan` çağrılarını taşır. Bu,
  /// projedeki mevcut kalıp ile birebir aynıdır
  /// (`SharedPrefsQuranDailyProgressRepository.watchToday`). Anlık ilk
  /// değer için çağıran [getPlan] kullanır. Gerçek reaktif sorgu, plan
  /// verisi Drift'e taşındığında gelir.
  @override
  Stream<DailyPlan?> watchPlan(DayKey dayKey) =>
      _saved.stream.where((plan) => plan.dayKey == dayKey);

  @override
  ResultFuture<DailyPlan?> getPlan(DayKey dayKey) async {
    final plans = await _readAll();
    return plans.fold(
      onSuccess: (all) => Result.success(all[dayKey]),
      onFailure: Result<DailyPlan?>.failure,
    );
  }

  @override
  ResultFuture<List<DailyPlan>> getRange(DayKey from, DayKey to) async {
    if (from.compareTo(to) > 0) {
      // Ters aralık çağıran hatasıdır; mevcut aralık sözleşmesi
      // (Kur'an `loadRange`) ile aynı biçimde raporlanır.
      return const Result.failure(StorageFailure());
    }
    final plans = await _readAll();
    return plans.map((all) {
      final selected =
          all.entries
              .where(
                (entry) =>
                    entry.key.compareTo(from) >= 0 &&
                    entry.key.compareTo(to) <= 0,
              )
              .toList()
            ..sort((a, b) => a.key.compareTo(b.key));
      return [for (final entry in selected) entry.value];
    });
  }

  @override
  ResultFuture<void> savePlan(DailyPlan plan) async {
    final existing = await _readAll();
    // Bozuk depo SESSİZCE EZİLMEZ — bozulma çağırana bildirilir ve
    // kurtarma kararı (yeniden üretim/temizleme) sonraki görevlere kalır.
    // Okuma hatasının TÜRÜ korunur: bozulma `StorageCorruptionFailure`,
    // geçici okuma hatası `StorageFailure` olarak yukarı taşınır.
    final existingFailure = existing.failureOrNull;
    if (existingFailure != null) {
      return Result.failure(existingFailure);
    }

    final updated = Map<DayKey, DailyPlan>.from(
      existing.valueOrNull ?? const {},
    )..[plan.dayKey] = plan;

    final String encoded;
    try {
      encoded = DailyPlanEnvelopeCodec.encode(updated);
    } on FormatException {
      // Kodlama hatası ÇAĞIRAN/domain durumundan doğar (ör. gün içinde
      // tekrar eden öğe kimliği) — saklanan veri bozulması DEĞİLDİR.
      return const Result.failure(StorageFailure());
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final written = await prefs.setString(storageKey, encoded);
      if (!written) {
        return const Result.failure(StorageFailure());
      }
    } on Exception {
      return const Result.failure(StorageFailure());
    }

    if (!_disposed && _saved.hasListener) {
      _saved.add(plan);
    }
    return const Result.success(null);
  }

  /// Birden çok günü tek zarf yazımıyla kaydeder (TASK 083A).
  ///
  /// Akış: mevcut zarfı oku → bellekte birleştir → **bir kez** kodla →
  /// **bir kez** yaz. Kodlama veya yazma başarısız olursa depoya hiç
  /// dokunulmamış olur, bu yüzden kısmi bir aralık kalamaz. Kalıcılık
  /// sürümü ve depolama anahtarı DEĞİŞMEZ.
  @override
  ResultFuture<void> savePlans(List<DailyPlan> plans) async {
    if (plans.isEmpty) {
      // Boş toplu yazma çağıran hatasıdır; sessizce başarı DÖNÜLMEZ.
      return const Result.failure(
        ValidationFailure(messageKey: 'errorUnexpected'),
      );
    }
    final incoming = <DayKey, DailyPlan>{};
    for (final plan in plans) {
      if (incoming.containsKey(plan.dayKey)) {
        // Aynı gün iki kez verilmiş — hangisinin kazanacağı tahmin
        // EDİLMEZ, yazma reddedilir.
        return const Result.failure(
          ValidationFailure(messageKey: 'errorUnexpected'),
        );
      }
      incoming[plan.dayKey] = plan;
    }

    final existing = await _readAll();
    final existingFailure = existing.failureOrNull;
    if (existingFailure != null) {
      // Bozuk depo SESSİZCE EZİLMEZ (savePlan ile aynı kural).
      return Result.failure(existingFailure);
    }

    // Toplu yazmada olmayan günler aynen korunur.
    final updated = Map<DayKey, DailyPlan>.from(
      existing.valueOrNull ?? const {},
    )..addAll(incoming);

    final String encoded;
    try {
      encoded = DailyPlanEnvelopeCodec.encode(updated);
    } on FormatException {
      // Kodlama çağıran/domain durumundan düştü; depo değişmedi.
      return const Result.failure(StorageFailure());
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final written = await prefs.setString(storageKey, encoded);
      if (!written) {
        return const Result.failure(StorageFailure());
      }
    } on Exception {
      return const Result.failure(StorageFailure());
    }

    // Bildirim yalnız kalıcı yazma BAŞARILI olduktan sonra yayılır.
    if (!_disposed && _saved.hasListener) {
      final orderedDays = incoming.keys.toList()..sort();
      for (final dayKey in orderedDays) {
        _saved.add(incoming[dayKey]!);
      }
    }
    return const Result.success(null);
  }

  /// Zarfın tamamını okur; istisna çağırana sızmaz ve ham yük hiçbir yere
  /// kopyalanmaz.
  ///
  /// Hata TÜRÜ anlamlıdır (TASK 077):
  /// - **`StorageCorruptionFailure`** — saklanan verinin kendisi
  ///   çözümlenemiyor: değer beklenen tipte değil, JSON bozuk, zarf yapısal
  ///   olarak geçersiz, sürüm eksik/hatalı/desteklenmiyor ya da
  ///   serileştirilmiş plan/öğe/gün/enum verisi geçersiz. Tekrar denemek
  ///   aynı sonucu verir.
  /// - **`StorageFailure`** — depo *işlemi* başarısız (SharedPreferences
  ///   okuma istisnası). Geçicidir; tekrar denemek anlamlıdır.
  Future<Result<Map<DayKey, DailyPlan>>> _readAll() async {
    final Object? raw;
    try {
      final prefs = await SharedPreferences.getInstance();
      raw = prefs.get(storageKey);
    } on Exception {
      return const Result.failure(StorageFailure());
    }

    if (raw == null) {
      return const Result.success(<DayKey, DailyPlan>{});
    }
    if (raw is! String) {
      // Saklanan değer beklenen tipte değil → veri bozulması.
      return const Result.failure(StorageCorruptionFailure());
    }
    try {
      return Result.success(DailyPlanEnvelopeCodec.decode(raw));
    } on FormatException {
      // Bozuk JSON / geçersiz yapı / desteklenmeyen sürüm / geçersiz
      // plan-öğe-gün-enum verisi — hepsi saklanan veri bozulmasıdır.
      return const Result.failure(StorageCorruptionFailure());
    }
  }

  /// Akış denetleyicisini kapatır (DI yaşam döngüsünden çağrılır).
  /// Tekrar çağrılması güvenlidir.
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    await _saved.close();
  }
}
