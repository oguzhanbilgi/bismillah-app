import 'package:bismillah_app/features/learn/data/url_launcher_external_link_service.dart';
import 'package:bismillah_app/features/learn/domain/entities/knowledge_source.dart';
import 'package:bismillah_app/features/learn/domain/services/external_link_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Resmî kaynak bağlantısı açma davranışı (TASK 056A §7).
///
/// GERÇEK tarayıcı AÇILMAZ ve gerçek platform kanalı çağrılmaz: servis
/// bir `launcher` dikişi kabul eder, testler bu dikişi kullanır.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Çağrılan adresleri kaydeden sahte launcher.
  ({UrlLaunchCallback callback, List<Uri> calls}) fakeLauncher({
    bool succeeds = true,
    bool throwsError = false,
  }) {
    final calls = <Uri>[];
    return (
      calls: calls,
      callback: (Uri uri) async {
        calls.add(uri);
        if (throwsError) {
          throw PlatformException(code: 'ACTIVITY_NOT_FOUND');
        }
        return succeeds;
      },
    );
  }

  group('Alan adı güvenliği', () {
    test('izin verilen Diyanet adresi allowlist\'ten GEÇER', () {
      expect(
        OfficialSourceDomains.isAllowed(
          'https://kurul.diyanet.gov.tr/tr/fetvalar',
        ),
        isTrue,
      );
      expect(
        OfficialSourceDomains.isAllowed('https://diyanet.gov.tr/'),
        isTrue,
      );
    });

    test('benzer SAHTE alan adı reddedilir ve tarayıcı ÇAĞRILMAZ', () async {
      final fake = fakeLauncher();
      final service = UrlLauncherExternalLinkService(launcher: fake.callback);

      // Son ek benzerliğiyle allowlist atlatılamaz.
      expect(
        await service.openOfficialSource('https://notdiyanet.gov.tr/x'),
        isFalse,
      );
      // Alt alan adı gibi görünen sahte host da reddedilir.
      expect(
        await service.openOfficialSource('https://diyanet.gov.tr.evil.com/x'),
        isFalse,
      );
      expect(fake.calls, isEmpty);
    });

    test('HTTPS dışı şema reddedilir ve tarayıcı ÇAĞRILMAZ', () async {
      final fake = fakeLauncher();
      final service = UrlLauncherExternalLinkService(launcher: fake.callback);

      expect(
        await service.openOfficialSource('http://kurul.diyanet.gov.tr/'),
        isFalse,
      );
      expect(await service.openOfficialSource('javascript:alert(1)'), isFalse);
      expect(fake.calls, isEmpty);
    });

    test('bozuk/boş adres reddedilir', () async {
      final fake = fakeLauncher();
      final service = UrlLauncherExternalLinkService(launcher: fake.callback);

      expect(await service.openOfficialSource(''), isFalse);
      expect(await service.openOfficialSource('   '), isFalse);
      expect(fake.calls, isEmpty);
    });
  });

  group('Bağlantı açma', () {
    test('resmî adres tarayıcıya İLETİLİR ve true döner', () async {
      final fake = fakeLauncher();
      final service = UrlLauncherExternalLinkService(launcher: fake.callback);

      final opened = await service.openOfficialSource(
        'https://kurul.diyanet.gov.tr/tr/fetvalar',
      );

      expect(opened, isTrue);
      expect(fake.calls.single.toString(), contains('kurul.diyanet.gov.tr'));
    });

    test('açma başarısızsa false döner — CRASH YOK', () async {
      final fake = fakeLauncher(succeeds: false);
      final service = UrlLauncherExternalLinkService(launcher: fake.callback);

      expect(
        await service.openOfficialSource('https://kuran.diyanet.gov.tr/'),
        isFalse,
      );
      // canLaunchUrl'e güvenip vazgeçmez: gerçekten denemiş olmalı.
      expect(fake.calls, hasLength(1));
    });

    test('platform istisnası YUTULUR — CRASH YOK', () async {
      final fake = fakeLauncher(throwsError: true);
      final service = UrlLauncherExternalLinkService(launcher: fake.callback);

      expect(
        await service.openOfficialSource('https://kuran.diyanet.gov.tr/'),
        isFalse,
      );
      expect(fake.calls, hasLength(1));
    });
  });

  group('ExternalLinkService sözleşmesi', () {
    test('servis soyut arayüz üzerinden kullanılabilir', () async {
      final fake = fakeLauncher();
      final ExternalLinkService abstracted = UrlLauncherExternalLinkService(
        launcher: fake.callback,
      );

      expect(
        await abstracted.openOfficialSource('https://diyanet.gov.tr/'),
        isTrue,
      );
    });

    test('varsayılan servis launcher dikişi OLMADAN kurulabilir', () {
      // Üretimde gerçek `launchUrl` kullanılır; burada yalnız kurulum
      // doğrulanır (platform çağrısı YAPILMAZ).
      const service = UrlLauncherExternalLinkService();
      expect(service, isA<ExternalLinkService>());
    });
  });
}
