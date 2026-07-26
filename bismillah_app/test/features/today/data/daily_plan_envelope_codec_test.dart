import 'dart:convert';

import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/today/data/daily_plan_envelope_codec.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';
import 'package:flutter_test/flutter_test.dart';

/// Günlük plan zarfı codec'i (TASK 076): sürümlü serileştirme, deterministik
/// sıra ve bozulma reddi. Testler makine saat diliminden bağımsızdır.
void main() {
  DayKey day(String value) => DayKey(value);

  PlanItem item(
    String id, {
    PlanItemType type = PlanItemType.quran,
    PlanItemStatus status = PlanItemStatus.pending,
    String? targetRef,
    int? sizeParam,
    UtcDateTime? completedAt,
  }) => PlanItem(
    itemId: EntityId(id),
    type: type,
    status: status,
    targetRef: targetRef,
    sizeParam: sizeParam,
    completedAt: completedAt,
  );

  DailyPlan plan(
    String dayValue, {
    List<PlanItem>? items,
    String profileType = 'reconnect',
    int sizeMinutes = 20,
    int weekIndex = 0,
    String generatedBy = 'rule-engine-v1',
  }) => DailyPlan(
    dayKey: day(dayValue),
    items: items ?? [item('item-1')],
    profileType: profileType,
    sizeMinutes: sizeMinutes,
    weekIndex: weekIndex,
    generatedBy: generatedBy,
  );

  /// Zarfı ham haritadan kurup string'e çevirir (bozulma senaryoları için).
  /// `null` verilen alan zarfa HİÇ yazılmaz — "eksik alan" senaryoları
  /// bu yolla kurulur.
  String rawEnvelope(Object? version, Object? plans) =>
      json.encode({'v': ?version, 'plans': ?plans});

  group('encode', () {
    test('boş harita sürüm 1 zarfı üretir', () {
      final encoded = DailyPlanEnvelopeCodec.encode(const {});
      final decoded = json.decode(encoded) as Map<String, Object?>;

      expect(decoded['v'], 1);
      expect(decoded['plans'], isEmpty);
      expect(DailyPlanEnvelopeCodec.currentVersion, 1);
    });

    test('günler deterministik DayKey sırasında yazılır', () {
      final encoded = DailyPlanEnvelopeCodec.encode({
        day('2026-07-28'): plan('2026-07-28'),
        day('2026-07-26'): plan('2026-07-26'),
        day('2026-07-27'): plan('2026-07-27'),
      });

      final plans =
          (json.decode(encoded) as Map<String, Object?>)['plans']!
              as Map<String, Object?>;
      expect(plans.keys.toList(), ['2026-07-26', '2026-07-27', '2026-07-28']);
    });

    test('aynı girdi aynı string üretir (kararlı çıktı)', () {
      final input = {
        day('2026-07-27'): plan('2026-07-27'),
        day('2026-07-26'): plan('2026-07-26'),
      };
      expect(
        DailyPlanEnvelopeCodec.encode(input),
        DailyPlanEnvelopeCodec.encode(input),
      );
    });

    test('harita anahtarı ile plan günü uyuşmazsa reddeder', () {
      expect(
        () => DailyPlanEnvelopeCodec.encode({
          day('2026-07-26'): plan('2026-07-27'),
        }),
        throwsFormatException,
      );
    });

    test('gün içinde tekrar eden öğe kimliği yazılamaz', () {
      expect(
        () => DailyPlanEnvelopeCodec.encode({
          day('2026-07-26'): plan(
            '2026-07-26',
            items: [item('dup'), item('dup')],
          ),
        }),
        throwsFormatException,
      );
    });

    test('enum değerleri stabil ADLARLA yazılır (index değil)', () {
      final encoded = DailyPlanEnvelopeCodec.encode({
        day('2026-07-26'): plan(
          '2026-07-26',
          items: [
            item(
              'a',
              type: PlanItemType.dhikr,
              status: PlanItemStatus.completed,
            ),
          ],
        ),
      });

      expect(encoded, contains('"type":"dhikr"'));
      expect(encoded, contains('"status":"completed"'));
    });
  });

  group('round-trip', () {
    test('boş zarf', () {
      final encoded = DailyPlanEnvelopeCodec.encode(const {});
      expect(DailyPlanEnvelopeCodec.decode(encoded), isEmpty);
    });

    test('tek gün tüm alanlarıyla korunur', () {
      final original = plan(
        '2026-07-26',
        profileType: 'rebuild',
        sizeMinutes: 45,
        weekIndex: 3,
        generatedBy: 'rule-engine-v2',
        items: [item('only', targetRef: 'surah-36', sizeParam: 7)],
      );

      final decoded = DailyPlanEnvelopeCodec.decode(
        DailyPlanEnvelopeCodec.encode({day('2026-07-26'): original}),
      )[day('2026-07-26')]!;

      expect(decoded.dayKey, original.dayKey);
      expect(decoded.profileType, 'rebuild');
      expect(decoded.sizeMinutes, 45);
      expect(decoded.weekIndex, 3);
      expect(decoded.generatedBy, 'rule-engine-v2');
      expect(decoded.items.single.targetRef, 'surah-36');
      expect(decoded.items.single.sizeParam, 7);
    });

    test('çok gün korunur ve diğer günler etkilenmez', () {
      final input = {
        day('2026-07-26'): plan('2026-07-26', sizeMinutes: 10),
        day('2026-07-27'): plan('2026-07-27', sizeMinutes: 20),
        day('2026-07-28'): plan('2026-07-28', sizeMinutes: 30),
      };

      final decoded = DailyPlanEnvelopeCodec.decode(
        DailyPlanEnvelopeCodec.encode(input),
      );

      expect(decoded.length, 3);
      expect(decoded[day('2026-07-26')]!.sizeMinutes, 10);
      expect(decoded[day('2026-07-27')]!.sizeMinutes, 20);
      expect(decoded[day('2026-07-28')]!.sizeMinutes, 30);
    });

    test('öğe sırası korunur', () {
      final items = [item('c'), item('a'), item('b')];
      final decoded = DailyPlanEnvelopeCodec.decode(
        DailyPlanEnvelopeCodec.encode({
          day('2026-07-26'): plan('2026-07-26', items: items),
        }),
      )[day('2026-07-26')]!;

      expect(decoded.items.map((i) => i.itemId.value).toList(), [
        'c',
        'a',
        'b',
      ]);
    });

    test('tamamlanma durumu ve completedAt korunur', () {
      final completedAt = UtcDateTime(DateTime.utc(2026, 7, 26, 14, 30));
      final decoded = DailyPlanEnvelopeCodec.decode(
        DailyPlanEnvelopeCodec.encode({
          day('2026-07-26'): plan(
            '2026-07-26',
            items: [
              item(
                'done',
                status: PlanItemStatus.completed,
                completedAt: completedAt,
              ),
              item('todo'),
            ],
          ),
        }),
      )[day('2026-07-26')]!;

      expect(decoded.items.first.isCompleted, isTrue);
      expect(decoded.items.first.completedAt, completedAt);
      expect(decoded.items.last.status, PlanItemStatus.pending);
      expect(decoded.items.last.completedAt, isNull);
      expect(decoded.completedCount, 1);
    });

    test('tüm PlanItemType değerleri round-trip eder', () {
      final items = [
        for (final type in PlanItemType.values)
          item('item-${type.name}', type: type),
      ];
      final decoded = DailyPlanEnvelopeCodec.decode(
        DailyPlanEnvelopeCodec.encode({
          day('2026-07-26'): plan('2026-07-26', items: items),
        }),
      )[day('2026-07-26')]!;

      expect(decoded.items.map((i) => i.type).toList(), PlanItemType.values);
    });

    test('DayKey saat dilimi dönüşümü olmadan korunur', () {
      // Gün anahtarı yalnız string'dir; UTC/yerel dönüşümü uygulanmaz.
      final decoded = DailyPlanEnvelopeCodec.decode(
        DailyPlanEnvelopeCodec.encode({
          day('2026-01-01'): plan('2026-01-01'),
          day('2026-12-31'): plan('2026-12-31'),
        }),
      );

      expect(decoded.keys.map((k) => k.value).toSet(), {
        '2026-01-01',
        '2026-12-31',
      });
    });
  });

  group('bozulma reddi', () {
    test('geçersiz JSON', () {
      expect(
        () => DailyPlanEnvelopeCodec.decode('{bozuk'),
        throwsFormatException,
      );
    });

    test('kök nesne değil', () {
      expect(
        () => DailyPlanEnvelopeCodec.decode('[1,2,3]'),
        throwsFormatException,
      );
    });

    test('sürüm eksik', () {
      expect(
        () => DailyPlanEnvelopeCodec.decode(
          rawEnvelope(null, <String, Object?>{}),
        ),
        throwsFormatException,
      );
    });

    test('sürüm yanlış tipte', () {
      expect(
        () => DailyPlanEnvelopeCodec.decode(
          rawEnvelope('1', <String, Object?>{}),
        ),
        throwsFormatException,
      );
    });

    test('desteklenmeyen gelecek sürümü sessizce migrate EDİLMEZ', () {
      expect(
        () =>
            DailyPlanEnvelopeCodec.decode(rawEnvelope(2, <String, Object?>{})),
        throwsFormatException,
      );
      expect(
        () =>
            DailyPlanEnvelopeCodec.decode(rawEnvelope(0, <String, Object?>{})),
        throwsFormatException,
      );
    });

    test('plans alanı eksik', () {
      expect(
        () => DailyPlanEnvelopeCodec.decode(rawEnvelope(1, null)),
        throwsFormatException,
      );
    });

    test('plans alanı yanlış tipte', () {
      expect(
        () => DailyPlanEnvelopeCodec.decode(rawEnvelope(1, <Object?>[])),
        throwsFormatException,
      );
    });

    test('geçersiz DayKey harita anahtarı', () {
      expect(
        () => DailyPlanEnvelopeCodec.decode(
          rawEnvelope(1, {'2026-13-45': <String, Object?>{}}),
        ),
        throwsFormatException,
      );
    });

    test('harita anahtarı ile gömülü dayKey uyuşmazlığı', () {
      expect(
        () => DailyPlanEnvelopeCodec.decode(
          rawEnvelope(1, {
            '2026-07-26': {
              'dayKey': '2026-07-27',
              'profileType': 'reconnect',
              'sizeMinutes': 20,
              'weekIndex': 0,
              'generatedBy': 'rule-engine-v1',
              'items': <Object?>[],
            },
          }),
        ),
        throwsFormatException,
      );
    });

    test('plan alanı yanlış tipte', () {
      expect(
        () => DailyPlanEnvelopeCodec.decode(
          rawEnvelope(1, {
            '2026-07-26': {
              'dayKey': '2026-07-26',
              'profileType': 'reconnect',
              'sizeMinutes': 'yirmi',
              'weekIndex': 0,
              'generatedBy': 'rule-engine-v1',
              'items': <Object?>[],
            },
          }),
        ),
        throwsFormatException,
      );
    });

    test('domain doğrulamasına takılan plan reddedilir', () {
      expect(
        () => DailyPlanEnvelopeCodec.decode(
          rawEnvelope(1, {
            '2026-07-26': {
              'dayKey': '2026-07-26',
              'profileType': 'reconnect',
              'sizeMinutes': -5,
              'weekIndex': 0,
              'generatedBy': 'rule-engine-v1',
              'items': <Object?>[],
            },
          }),
        ),
        throwsFormatException,
      );
    });

    test('bilinmeyen enum değeri varsayılana DÜŞMEZ', () {
      expect(
        () => DailyPlanEnvelopeCodec.decode(
          rawEnvelope(1, {
            '2026-07-26': {
              'dayKey': '2026-07-26',
              'profileType': 'reconnect',
              'sizeMinutes': 20,
              'weekIndex': 0,
              'generatedBy': 'rule-engine-v1',
              'items': [
                {'itemId': 'a', 'type': 'telepathy', 'status': 'pending'},
              ],
            },
          }),
        ),
        throwsFormatException,
      );
    });

    test('bozuk plan öğesi reddedilir', () {
      expect(
        () => DailyPlanEnvelopeCodec.decode(
          rawEnvelope(1, {
            '2026-07-26': {
              'dayKey': '2026-07-26',
              'profileType': 'reconnect',
              'sizeMinutes': 20,
              'weekIndex': 0,
              'generatedBy': 'rule-engine-v1',
              'items': [
                {'itemId': '', 'type': 'quran', 'status': 'pending'},
              ],
            },
          }),
        ),
        throwsFormatException,
      );
    });

    test('okumada tekrar eden öğe kimliği reddedilir', () {
      expect(
        () => DailyPlanEnvelopeCodec.decode(
          rawEnvelope(1, {
            '2026-07-26': {
              'dayKey': '2026-07-26',
              'profileType': 'reconnect',
              'sizeMinutes': 20,
              'weekIndex': 0,
              'generatedBy': 'rule-engine-v1',
              'items': [
                {'itemId': 'dup', 'type': 'quran', 'status': 'pending'},
                {'itemId': 'dup', 'type': 'dhikr', 'status': 'pending'},
              ],
            },
          }),
        ),
        throwsFormatException,
      );
    });

    test('hata metni ham yükü/gün anahtarını/hedefi TAŞIMAZ', () {
      const secretTarget = 'surah-super-secret-marker';
      const secretDay = '2026-07-26';
      try {
        DailyPlanEnvelopeCodec.decode(
          rawEnvelope(1, {
            secretDay: {
              'dayKey': secretDay,
              'profileType': 'reconnect',
              'sizeMinutes': 20,
              'weekIndex': 0,
              'generatedBy': 'rule-engine-v1',
              'items': [
                {
                  'itemId': 'a',
                  'type': 'telepathy',
                  'status': 'pending',
                  'targetRef': secretTarget,
                },
              ],
            },
          }),
        );
        fail('bozuk zarf reddedilmeliydi');
      } on FormatException catch (error) {
        final rendered = error.toString();
        expect(rendered, isNot(contains(secretTarget)));
        expect(rendered, isNot(contains(secretDay)));
        expect(rendered, isNot(contains('telepathy')));
      }
    });
  });

  group('bilinmeyen opsiyonel alan politikası', () {
    test('tanınmayan EK alanlar YOK SAYILIR (belgelenmiş politika)', () {
      // Politika: ileri uyumluluk için bilinmeyen ek alanlar sessizce
      // atlanır; ZORUNLU alanların eksikliği ise her zaman hatadır.
      final decoded = DailyPlanEnvelopeCodec.decode(
        rawEnvelope(1, {
          '2026-07-26': {
            'dayKey': '2026-07-26',
            'profileType': 'reconnect',
            'sizeMinutes': 20,
            'weekIndex': 0,
            'generatedBy': 'rule-engine-v1',
            'futureField': 'yok sayılır',
            'items': [
              {
                'itemId': 'a',
                'type': 'quran',
                'status': 'pending',
                'futureItemField': 42,
              },
            ],
          },
        }),
      );

      expect(decoded[day('2026-07-26')]!.items.single.itemId.value, 'a');
    });

    test('zarf kökündeki bilinmeyen alan da yok sayılır', () {
      final decoded = DailyPlanEnvelopeCodec.decode(
        json.encode({'v': 1, 'plans': <String, Object?>{}, 'extra': true}),
      );
      expect(decoded, isEmpty);
    });
  });
}
