import 'package:bismillah_app/core/analytics/analytics_event.dart';
import 'package:bismillah_app/core/privacy/privacy_guard.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PrivacyGuard.validateAnalyticsEvent', () {
    test('accepts a bucket-only event from the typed dictionary', () {
      final event = AnalyticsEvent.screenViewed(screenId: 'today_home');

      expect(PrivacyGuard.validateAnalyticsEvent(event).isSuccess, isTrue);
    });

    test('rejects forbidden PII-like param keys', () {
      final event = AnalyticsEvent.unsafeForValidation(
        name: 'test_event',
        params: {'email': const BucketValue('someone_example_com')},
      );

      expect(PrivacyGuard.validateAnalyticsEvent(event).isFailure, isTrue);
    });

    test('rejects free-text-looking bucket values', () {
      final event = AnalyticsEvent.unsafeForValidation(
        name: 'test_event',
        params: {
          'source': const BucketValue('Bu serbest bir metin gibi görünüyor!'),
        },
      );

      expect(PrivacyGuard.validateAnalyticsEvent(event).isFailure, isTrue);
    });
  });

  group('SensitivityClass rules', () {
    test('restricted data is never storable', () {
      expect(PrivacyGuard.canStore(SensitivityClass.restricted), isFalse);
    });

    test('high sensitivity data is never loggable', () {
      expect(PrivacyGuard.canLog(SensitivityClass.high), isFalse);
      expect(PrivacyGuard.canLog(SensitivityClass.low), isTrue);
    });
  });
}
