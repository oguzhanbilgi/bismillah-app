import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/features/settings/domain/entities/app_settings.dart';

/// Ayarlar lokal veri sözleşmesi (Isar-first; 10_DATA_MODEL §7).
///
/// Scope bazlı belge bölme ve alan bazlı LWW implementasyonun işidir
/// (TASK 013+); domain tek aggregate okur/yazar.
abstract interface class SettingsRepository {
  ResultFuture<AppSettings> getSettings();

  /// UI'ın tek besleme kanalı — lokal watch akışı (06_FLUTTER_ARCH §14).
  Stream<AppSettings> watchSettings();

  ResultFuture<void> saveSettings(AppSettings settings);
}
