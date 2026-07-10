import 'package:bismillah_app/core/domain/classified.dart';
import 'package:bismillah_app/core/domain/supported_language.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/profile/domain/value_objects/profile_enums.dart';

/// Kimlik + temel profil (10_DATA_MODEL §4).
///
/// Onboarding ham cevapları BURADA DEĞİLDİR (`OnboardingAnswers` ayrı
/// entity, ayrı belge — §8). Premium alanları (plusStatus vb.) server
/// yazımlıdır ve `PremiumEntitlement` ile temsil edilir — bu entity'ye
/// KONULMAZ (🔒 alan ayrımı, §24).
final class UserProfile implements Classified {
  UserProfile({
    required this.uid,
    required this.language,
    required this.locationMethod,
    required this.tonePreference,
    required this.createdAt,
    required this.accountStatus,
    required this.schemaVersion,
    this.displayName,
    this.city,
    this.country,
    List<String> linkedProviders = const [],
  }) : linkedProviders = List.unmodifiable(linkedProviders) {
    final name = displayName;
    if (name != null && (name.trim().isEmpty || name.length > 30)) {
      throw ArgumentError.value(
        displayName,
        'displayName',
        '1–30 karakter olmalı ya da null (isimsiz hitap)',
      );
    }
    if (schemaVersion < 1) {
      throw ArgumentError.value(schemaVersion, 'schemaVersion', '>= 1 olmalı');
    }
  }

  final UserId uid;
  final SupportedLanguage language;

  /// PII — analytics'e ASLA gitmez; null ise isimsiz hitap kalıpları.
  final String? displayName;

  /// Şehir düzeyi; hassas konum saklanmaz.
  final String? city;

  /// ISO ülke kodu.
  final String? country;

  final LocationMethod locationMethod;
  final TonePreference tonePreference;
  final UtcDateTime createdAt;
  final AccountStatus accountStatus;
  final List<String> linkedProviders;
  final int schemaVersion;

  @override
  SensitivityClass get sensitivityClass => SensitivityClass.medium;
}
