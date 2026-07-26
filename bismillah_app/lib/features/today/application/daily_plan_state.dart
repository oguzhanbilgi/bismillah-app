import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';

/// Seçili bir günün plan durumu (TASK 077).
///
/// Sakin durumlar (plan yok / bozuk depo / geçici hata) **hata değil veri**
/// olarak modellenir — `PrayerTimesState` ile aynı desen (CLAUDE.md ton
/// kuralları: suçlayıcı/kırmızı durum yok).
///
/// Her durum **istenen** [dayKey]'i taşır: yükleme, boşluk, bozulma ve hata
/// hâllerinde bile hangi günün konuşulduğu belirsiz kalmaz.
///
/// Bu tipler ham JSON, depolama anahtarı, istisna metni, yığın izi, UID,
/// konum veya Firebase verisi TAŞIMAZ.
///
/// **"Üretildi" durumu YOKTUR** — plan üretimi bu görevde uygulanmadı
/// (TASK 079).
sealed class DailyPlanState {
  const DailyPlanState({required this.dayKey});

  /// Durumun ait olduğu gün — her zaman en son seçilen gün.
  final DayKey dayKey;
}

/// Seçilen gün için okuma sürüyor.
final class DailyPlanLoading extends DailyPlanState {
  const DailyPlanLoading({required super.dayKey});
}

/// Depoda bu güne ait plan yok. Eksiklik değildir — henüz üretilmemiştir.
final class DailyPlanEmpty extends DailyPlanState {
  const DailyPlanEmpty({required super.dayKey});
}

/// Geçerli plan yüklendi.
///
/// `dayKey` planın kendi gününden TÜRETİLİR (`super(dayKey: plan.dayKey)`);
/// bu yüzden "gösterilen plan seçili güne aittir" kuralı yapısal olarak
/// garantidir — ayrı bir doğrulamayla korunması gerekmez, farklı bir güne
/// ait plan bu durumda temsil EDİLEMEZ.
final class DailyPlanAvailable extends DailyPlanState {
  DailyPlanAvailable({required this.plan, this.isSaving = false})
    : super(dayKey: plan.dayKey);

  final DailyPlan plan;

  /// Kaydetme işlemi sürüyor (UI kilidi/spinner için); plan gösterimde kalır.
  final bool isSaving;

  DailyPlanAvailable copyWith({DailyPlan? plan, bool? isSaving}) =>
      DailyPlanAvailable(
        plan: plan ?? this.plan,
        isSaving: isSaving ?? this.isSaving,
      );
}

/// Saklanan veri çözümlenemiyor (bozuk JSON, desteklenmeyen sürüm, geçersiz
/// kayıt). Tekrar denemek aynı sonucu verir; kurtarma ayrı bir karardır ve
/// bu görevde UYGULANMADI — depo kendiliğinden temizlenmez.
final class DailyPlanCorrupt extends DailyPlanState {
  const DailyPlanCorrupt({required super.dayKey});

  /// Yeniden okuma bozulmayı çözmez; çağıran boşuna denememelidir.
  bool get canRetry => false;
}

/// Geçici/sıradan bir depo işlemi hatası. Tekrar denemek anlamlıdır.
final class DailyPlanFailure extends DailyPlanState {
  const DailyPlanFailure({required super.dayKey});

  bool get canRetry => true;
}
