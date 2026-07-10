import 'package:bismillah_app/core/domain/classified.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_enums.dart';

/// Sohbet mesajı (10_DATA_MODEL §4) — append-only; düzenleme YOKTUR,
/// silme yalnız tombstone'dur (§14).
///
/// `text` Yüksek hassasiyettir: ASLA loglanmaz, analytics'e gitmez.
/// Telemetriye çıkabilen tek alan `topicClass` kovasıdır
/// (`assistant_message_sent{topic_class}` — içerik ASLA; §22).
final class AssistantMessage implements Classified {
  AssistantMessage({
    required this.messageId,
    required this.role,
    required this.text,
    required this.topicClass,
    required this.createdAt,
    this.deleted = false,
  }) {
    if (text.trim().isEmpty) {
      throw ArgumentError.value(text, 'text', 'Boş mesaj olamaz');
    }
    if (!_topicClassPattern.hasMatch(topicClass)) {
      throw ArgumentError.value(
        topicClass,
        'topicClass',
        'topicClass kısa snake_case kova kodu olmalı (PrivacyGuard biçimi)',
      );
    }
  }

  /// Kova biçimi PrivacyGuard bucket kuralıyla aynıdır — topicClass
  /// serbest metin taşıyamaz.
  static final RegExp _topicClassPattern = RegExp(r'^[a-z0-9_.\-]{1,40}$');

  final EntityId messageId;
  final AssistantRole role;
  final String text;

  /// Analytics'e çıkabilen TEK alan (kova kodu, ör. `prayer_habit`).
  final String topicClass;

  final UtcDateTime createdAt;

  /// Tombstone — geçmiş düzenlenmez, yalnız silinebilir.
  final bool deleted;

  /// Append-only tek istisna: silme tombstone'u üretir.
  AssistantMessage asDeleted() {
    return AssistantMessage(
      messageId: messageId,
      role: role,
      text: text,
      topicClass: topicClass,
      createdAt: createdAt,
      deleted: true,
    );
  }

  @override
  SensitivityClass get sensitivityClass => SensitivityClass.high;
}
