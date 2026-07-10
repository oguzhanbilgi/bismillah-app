import 'package:bismillah_app/core/domain/classified.dart';
import 'package:bismillah_app/core/domain/supported_language.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/settings/domain/value_objects/settings_enums.dart';

/// Kullanıcı tercihleri (10_DATA_MODEL §4 `AppSettings`).
///
/// Domain katmanında tek tipli aggregate'tir; scope bazlı bölme
/// (`users/{uid}/settings/{scope}`) ve alan bazlı LWW data katmanının
/// eşleme işidir (§14). Cihaz-özel alanlar (haptik) local-only'dir —
/// sync'e ÇIKMAZ (§4 not).
final class AppSettings implements Classified {
  const AppSettings({
    required this.themeMode,
    required this.language,
    required this.notificationsEnabled,
    required this.hapticsEnabled,
    required this.analyticsConsent,
    required this.updatedAt,
  });

  /// Güvenli varsayılanlar — ilk kurulum durumu.
  factory AppSettings.defaults({required UtcDateTime now}) {
    return AppSettings(
      themeMode: AppThemeMode.system,
      language: SupportedLanguage.tr,
      notificationsEnabled: true,
      hapticsEnabled: true,
      analyticsConsent: false,
      updatedAt: now,
    );
  }

  /// Display scope.
  final AppThemeMode themeMode;
  final SupportedLanguage language;

  /// Notifications scope.
  final bool notificationsEnabled;

  /// Display scope — CİHAZ-ÖZEL (isDeviceLocal): sync'e çıkmaz.
  final bool hapticsEnabled;

  /// Privacy scope — telemetri onayı.
  final bool analyticsConsent;

  final UtcDateTime updatedAt;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    SupportedLanguage? language,
    bool? notificationsEnabled,
    bool? hapticsEnabled,
    bool? analyticsConsent,
    UtcDateTime? updatedAt,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      analyticsConsent: analyticsConsent ?? this.analyticsConsent,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Tercihler Düşük hassasiyettir (10_DATA_MODEL §19) — loglanabilir,
  /// analytics'e kova olarak gidebilir.
  @override
  SensitivityClass get sensitivityClass => SensitivityClass.low;
}
