import 'package:bismillah_app/core/session/session_providers.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/prayer/application/prayer_log_state.dart';
import 'package:bismillah_app/features/prayer/data/prayer_data_providers.dart';
import 'package:bismillah_app/features/prayer/domain/entities/prayer_log_day.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_completion_status.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bugünün namaz kaydı controller'ı (application katmanı).
///
/// UI'ın tek okuma noktası budur; Drift'e ve sync kuyruğuna DOKUNMAZ —
/// yazma `PrayerLogRepository.saveDay`'den geçer, sync op enqueue'su o
/// yolun içindeki tek transaction'da olur (10_DATA_MODEL §12-1/2).
final prayerLogControllerProvider =
    AsyncNotifierProvider<PrayerLogController, PrayerLogState>(
      PrayerLogController.new,
    );

final class PrayerLogController extends AsyncNotifier<PrayerLogState> {
  @override
  Future<PrayerLogState> build() async {
    // Gün anahtarı yazım anındaki YEREL güne kilitlenir (10 §27-11).
    final dayKey = DayKey.fromLocal(ref.watch(clockProvider).nowLocal());
    final repository = ref.watch(prayerLogRepositoryProvider);

    // Lokal watch akışı UI'ın tek besleme kanalıdır (06 §14): bu ekran
    // dışından gelen yazımlar (ileride sync pull) durumu kendiliğinden
    // günceller. saveIssue bayrağı akış emisyonlarında korunur.
    final subscription = repository.watchDay(dayKey).listen((day) {
      final previous = state.value;
      state = AsyncData(
        PrayerLogState(
          day: day ?? _emptyDay(dayKey),
          saveIssue: previous?.saveIssue ?? false,
        ),
      );
    });
    ref.onDispose(subscription.cancel);

    final initial = await repository.getDay(dayKey);
    return initial.fold(
      onSuccess: (day) => PrayerLogState(day: day ?? _emptyDay(dayKey)),
      // Yükleme hatası AsyncError'a taşınır; UI sakin hata durumu +
      // yeniden dene gösterir (ekran çökmez, suçlayıcı dil yok).
      onFailure: (failure) => throw failure,
    );
  }

  /// Vakti işaretler ya da işaretliyse geri alır.
  ///
  /// Geri alma AÇIK `undone` tombstone'u yazar — deterministik merge'de
  /// tamamlanmış kaydı geri alabilen TEK yol budur (TASK 012B, 10 §14-1).
  /// Gerçek vakit motoru henüz yok: işaretleme daima `onTime` kaydeder;
  /// late/qada çıkarımı yapılmaz.
  Future<void> toggle(PrayerName prayerName) async {
    final current = state.value;
    if (current == null) {
      return; // Yükleme bitmeden/başarısızken sessizce yok say.
    }

    final now = UtcDateTime(ref.read(clockProvider).nowUtc());
    final wasCompleted = current.isCompleted(prayerName);
    final toggled = wasCompleted
        ? PrayerEntry(
            prayerName: prayerName,
            status: PrayerCompletionStatus.none,
            loggedAt: now,
            undone: true,
          )
        : PrayerEntry(
            prayerName: prayerName,
            status: PrayerCompletionStatus.onTime,
            loggedAt: now,
          );

    final updatedDay = PrayerLogDay(
      dayKey: current.dayKey,
      // TODO(auth): placeholder kimlikler anonim Firebase auth geldiğinde
      // gerçek kaynağa bağlanacak; placeholder-local-user verisi remap
      // edilecek (TASK 015 kararı).
      deviceId: ref.read(currentDeviceIdProvider),
      updatedAt: now,
      entries: [
        for (final name in PrayerName.values)
          if (name == prayerName) toggled else ?current.day.entryFor(name),
      ],
    );

    final result = await ref
        .read(prayerLogRepositoryProvider)
        .saveDay(updatedDay);
    state = AsyncData(
      result.isFailure
          // Kayıt başarısız: önceki durum KORUNUR, yalnız sakin not düşer.
          ? current.copyWith(saveIssue: true)
          : PrayerLogState(day: updatedDay),
    );
  }

  /// Kayıtsız günün sakin varsayılanı: boş entry listesi (5 satır UI'da
  /// `PrayerName.values` üzerinden türetilir; "boş = başarısızlık" değildir).
  PrayerLogDay _emptyDay(DayKey dayKey) {
    return PrayerLogDay(
      dayKey: dayKey,
      deviceId: ref.read(currentDeviceIdProvider),
      updatedAt: UtcDateTime(ref.read(clockProvider).nowUtc()),
      entries: const [],
    );
  }
}
