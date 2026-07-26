import 'dart:convert';

import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';

/// Günlük plan zarfının saf (I/O'suz) codec'i.
///
/// **GEÇİCİ YEREL ADAPTÖR — NİHAİ VERİTABANI BİRLEŞTİRMESİNDEN ÖNCE
/// MİGRATION GEREKİR.** Kanonik hedef mimari `DailyPlan`'ı Drift tablosuna
/// (`dayKey` unique) eşler (10_DATA_MODEL §7, 11_LOCAL_DB §3); Drift
/// migration'ı şu an ertelenmiş olduğu için plan verisi tek anahtarlı,
/// sürümlü bir JSON zarfında tutulur. Bu, TASK 047'de Kur'an günlük
/// ilerlemesi için alınan kararın aynısıdır ve NİHAİ mimari değildir.
///
/// Zarf biçimi (sürüm 1):
///
/// ```json
/// {
///   "v": 1,
///   "plans": {
///     "2026-07-26": {
///       "dayKey": "2026-07-26",
///       "profileType": "reconnect",
///       "sizeMinutes": 20,
///       "weekIndex": 0,
///       "generatedBy": "rule-engine-v1",
///       "items": [ { "itemId": "…", "type": "quran", "status": "pending" } ]
///     }
///   }
/// }
/// ```
///
/// Gün anahtarı hem harita anahtarı hem de gömülü alandır: gömülü kopya
/// gelecekteki Drift satır taşımasını kendi kendini tanımlar hâle getirir
/// ve harita anahtarı/gömülü anahtar uyuşmazlığını tespit edilebilir bir
/// bozulma yapar.
///
/// Bozuk veri [FormatException] ile reddedilir; istisna metni **asla** ham
/// yükü, gün anahtarını veya öğe hedefini taşımaz (yalnız sabit etiketler).
abstract final class DailyPlanEnvelopeCodec {
  /// Bu görevdeki tek desteklenen kalıcılık sürümü.
  static const int currentVersion = 1;

  static const String _versionField = 'v';
  static const String _plansField = 'plans';

  /// Planları deterministik `DayKey` sırasıyla JSON string'e çevirir.
  ///
  /// Aynı girdi daima aynı string'i üretir (test kararlılığı için gerekli).
  static String encode(Map<DayKey, DailyPlan> plans) {
    final sortedKeys = plans.keys.toList()..sort();
    final encodedPlans = <String, Object?>{};
    for (final dayKey in sortedKeys) {
      final plan = plans[dayKey]!;
      if (plan.dayKey != dayKey) {
        throw const FormatException(
          'plan gün anahtarı harita anahtarıyla uyuşmuyor',
        );
      }
      encodedPlans[dayKey.value] = _encodePlan(plan);
    }
    return json.encode({
      _versionField: currentVersion,
      _plansField: encodedPlans,
    });
  }

  /// JSON string'i planlara çevirir; bozuk/desteklenmeyen veri
  /// [FormatException] fırlatır. Boş/yalnız-boşluk girdi boş harita sayılır.
  static Map<DayKey, DailyPlan> decode(String raw) {
    if (raw.trim().isEmpty) {
      return const {};
    }
    final Object? decoded;
    try {
      decoded = json.decode(raw);
    } on FormatException {
      // Ham yük hata metnine KOPYALANMAZ.
      throw const FormatException('plan zarfı geçerli JSON değil');
    }
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('plan zarfı kökü nesne değil');
    }

    final version = decoded[_versionField];
    if (version == null) {
      throw const FormatException('plan zarfı sürümü eksik');
    }
    if (version is! int) {
      throw const FormatException('plan zarfı sürümü tam sayı değil');
    }
    if (version < 1 || version > currentVersion) {
      // Bilinmeyen sürüm SESSİZCE migrate EDİLMEZ.
      throw const FormatException('plan zarfı sürümü desteklenmiyor');
    }

    final plansRaw = decoded[_plansField];
    if (plansRaw == null) {
      throw const FormatException('plan zarfında plans alanı eksik');
    }
    if (plansRaw is! Map<String, Object?>) {
      throw const FormatException('plans alanı nesne değil');
    }

    final plans = <DayKey, DailyPlan>{};
    for (final entry in plansRaw.entries) {
      final DayKey dayKey;
      try {
        dayKey = DayKey(entry.key);
      } on ArgumentError {
        throw const FormatException('plan harita anahtarı geçerli gün değil');
      }
      plans[dayKey] = _decodePlan(dayKey, entry.value);
    }
    return plans;
  }

  static Map<String, Object?> _encodePlan(DailyPlan plan) {
    _assertUniqueItemIds(plan.items);
    return {
      'dayKey': plan.dayKey.value,
      'profileType': plan.profileType,
      'sizeMinutes': plan.sizeMinutes,
      'weekIndex': plan.weekIndex,
      'generatedBy': plan.generatedBy,
      'items': [for (final item in plan.items) _encodeItem(item)],
    };
  }

  static Map<String, Object?> _encodeItem(PlanItem item) => {
    'itemId': item.itemId.value,
    // Stabil makine adları — index ASLA kullanılmaz (enum sırası değişebilir).
    'type': item.type.name,
    'status': item.status.name,
    if (item.targetRef != null) 'targetRef': item.targetRef,
    if (item.sizeParam != null) 'sizeParam': item.sizeParam,
    if (item.completedAt != null)
      'completedAt': item.completedAt!.value.toIso8601String(),
  };

  static DailyPlan _decodePlan(DayKey dayKey, Object? raw) {
    if (raw is! Map<String, Object?>) {
      throw const FormatException('plan kaydı nesne değil');
    }

    final embeddedDayKey = raw['dayKey'];
    if (embeddedDayKey is! String) {
      throw const FormatException('plan kaydında dayKey eksik/hatalı tipte');
    }
    if (embeddedDayKey != dayKey.value) {
      throw const FormatException(
        'plan gün anahtarı harita anahtarıyla uyuşmuyor',
      );
    }

    final profileType = raw['profileType'];
    final sizeMinutes = raw['sizeMinutes'];
    final weekIndex = raw['weekIndex'];
    final generatedBy = raw['generatedBy'];
    final itemsRaw = raw['items'];

    if (profileType is! String ||
        sizeMinutes is! int ||
        weekIndex is! int ||
        generatedBy is! String ||
        itemsRaw is! List) {
      throw const FormatException('plan kaydı alanları bozuk');
    }

    final items = [for (final item in itemsRaw) _decodeItem(item)];
    _assertUniqueItemIds(items);

    try {
      return DailyPlan(
        dayKey: dayKey,
        items: items,
        profileType: profileType,
        sizeMinutes: sizeMinutes,
        weekIndex: weekIndex,
        generatedBy: generatedBy,
      );
    } on ArgumentError {
      // Domain doğrulaması reddetti (negatif süre, boş generatedBy…).
      throw const FormatException('plan kaydı domain doğrulamasını geçemedi');
    }
  }

  static PlanItem _decodeItem(Object? raw) {
    if (raw is! Map<String, Object?>) {
      throw const FormatException('plan öğesi nesne değil');
    }
    final itemId = raw['itemId'];
    final type = raw['type'];
    final status = raw['status'];
    final targetRef = raw['targetRef'];
    final sizeParam = raw['sizeParam'];
    final completedAtRaw = raw['completedAt'];

    if (itemId is! String ||
        type is! String ||
        status is! String ||
        (targetRef != null && targetRef is! String) ||
        (sizeParam != null && sizeParam is! int)) {
      throw const FormatException('plan öğesi alanları bozuk');
    }

    UtcDateTime? completedAt;
    if (completedAtRaw != null) {
      if (completedAtRaw is! String) {
        throw const FormatException('plan öğesi completedAt alanı bozuk');
      }
      final parsed = DateTime.tryParse(completedAtRaw);
      if (parsed == null) {
        throw const FormatException('plan öğesi completedAt çözümlenemedi');
      }
      completedAt = UtcDateTime(parsed);
    }

    try {
      return PlanItem(
        itemId: EntityId(itemId),
        type: _decodeEnum(type, PlanItemType.values, 'plan öğesi tipi'),
        status: _decodeEnum(status, PlanItemStatus.values, 'plan öğesi durumu'),
        targetRef: targetRef as String?,
        sizeParam: sizeParam as int?,
        completedAt: completedAt,
      );
    } on ArgumentError {
      throw const FormatException('plan öğesi kimliği geçersiz');
    }
  }

  /// Stabil enum adını çözer; bilinmeyen değer bozulma sayılır
  /// (sessizce varsayılana DÜŞÜLMEZ).
  static T _decodeEnum<T extends Enum>(
    String name,
    List<T> values,
    String label,
  ) {
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    // Bilinmeyen adın kendisi hata metnine konmaz.
    throw FormatException('$label tanınmıyor');
  }

  /// Codec düzeyi değişmez kural: bir gün içinde öğe kimlikleri tekildir.
  ///
  /// Domain entity'si bunu bugün zorlamıyor; TASK 076 domain modelini
  /// değiştirmediği için kural burada, hem yazma hem okuma yönünde
  /// simetrik olarak uygulanır (çift kayıt asla yazılamaz ve okunamaz).
  static void _assertUniqueItemIds(List<PlanItem> items) {
    final seen = <String>{};
    for (final item in items) {
      if (!seen.add(item.itemId.value)) {
        throw const FormatException(
          'plan öğesi kimliği gün içinde tekrar ediyor',
        );
      }
    }
  }
}
