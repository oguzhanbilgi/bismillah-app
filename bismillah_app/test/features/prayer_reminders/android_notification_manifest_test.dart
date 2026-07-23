import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Android manifest sözleşme (contract) regresyon testleri.
///
/// flutter_local_notifications, zamanlanmış bildirimlerin tetiklenmesi ve
/// yeniden başlatma / uygulama güncellemesi sonrası yeniden kurulması için
/// uygulamanın KENDİ manifest'inde şu bileşenleri bildirmesini gerektirir:
///   * ScheduledNotificationReceiver       (zamanlanmış teslim)
///   * ScheduledNotificationBootReceiver   (reboot/güncelleme sonrası yeniden kurulum)
///   * RECEIVE_BOOT_COMPLETED izni
///
/// Bu testler bu sözleşmenin sessizce kaybolmamasını garanti eder. Karşılaştırma
/// öncesi XML yorumları kaldırılır; böylece yorum metni gerçek declaration gibi
/// sayılmaz.
void main() {
  // Manifest'i çalışma dizininden başlayıp yukarı çıkarak bulur (repo kökünden
  // veya paket kökünden çalıştırılabilsin diye). Absolute path gömülmez.
  File findManifest() {
    var dir = Directory.current;
    for (var i = 0; i < 8; i++) {
      final candidate = File(
        '${dir.path}/android/app/src/main/AndroidManifest.xml',
      );
      if (candidate.existsSync()) {
        return candidate;
      }
      final parent = dir.parent;
      if (parent.path == dir.path) {
        break;
      }
      dir = parent;
    }
    fail('AndroidManifest.xml bulunamadı (cwd: ${Directory.current.path})');
  }

  final raw = findManifest().readAsStringSync();

  // Yorumları kaldır — comment metni gerçek declaration olarak sayılmasın.
  final manifest = raw.replaceAll(RegExp(r'<!--[\s\S]*?-->'), '');

  // Bir receiver'ın açılış etiketini (android:name'i içeren) döndürür.
  String openingTagOf(String receiverClass) {
    final nameIdx = manifest.indexOf(receiverClass);
    expect(
      nameIdx,
      greaterThanOrEqualTo(0),
      reason: '$receiverClass manifest\'te bulunamadı',
    );
    final start = manifest.lastIndexOf('<receiver', nameIdx);
    final end = manifest.indexOf('>', nameIdx);
    expect(start, greaterThanOrEqualTo(0));
    expect(end, greaterThan(start));
    return manifest.substring(start, end + 1);
  }

  int countOccurrences(String needle) => needle.allMatches(manifest).length;

  // Gerçek bir uses-permission declaration'ı var mı (yorum değil)?
  bool hasPermissionDecl(String permission) => manifest.contains(
    '<uses-permission android:name="android.permission.$permission"',
  );

  const schedulingReceiver =
      'com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver';
  const bootReceiver =
      'com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver';

  group('Android scheduled-notification manifest contract', () {
    test(
      'scheduling receiver tam bir kez ve exported=false olarak bildirilir',
      () {
        // Not: bootReceiver adı schedulingReceiver alt dizesini içermediğinden
        // ("BootReceiver" farklı) count doğrudur.
        expect(
          countOccurrences('$schedulingReceiver"'),
          1,
          reason: 'ScheduledNotificationReceiver tam bir kez bildirilmeli',
        );

        final tag = openingTagOf(schedulingReceiver);
        expect(
          tag.contains('android:exported="false"'),
          isTrue,
          reason: 'ScheduledNotificationReceiver exported=false olmalı',
        );

        // <application> içinde olmalı.
        final appOpen = manifest.indexOf('<application');
        final appClose = manifest.indexOf('</application>');
        final recIdx = manifest.indexOf(schedulingReceiver);
        expect(appOpen, greaterThanOrEqualTo(0));
        expect(appClose, greaterThan(appOpen));
        expect(
          recIdx > appOpen && recIdx < appClose,
          isTrue,
          reason: 'ScheduledNotificationReceiver <application> içinde olmalı',
        );
      },
    );

    test('boot-restore sözleşmesi (izin + receiver + tüm action\'lar)', () {
      expect(
        countOccurrences(
          '<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"',
        ),
        1,
        reason: 'RECEIVE_BOOT_COMPLETED tam bir kez bildirilmeli',
      );

      expect(
        countOccurrences('$bootReceiver"'),
        1,
        reason: 'ScheduledNotificationBootReceiver tam bir kez bildirilmeli',
      );

      final tag = openingTagOf(bootReceiver);
      expect(
        tag.contains('android:exported="false"'),
        isTrue,
        reason: 'ScheduledNotificationBootReceiver exported=false olmalı',
      );

      const actions = <String>[
        'android.intent.action.BOOT_COMPLETED',
        'android.intent.action.MY_PACKAGE_REPLACED',
        'android.intent.action.QUICKBOOT_POWERON',
        'com.htc.intent.action.QUICKBOOT_POWERON',
      ];
      for (final action in actions) {
        expect(
          manifest.contains('<action android:name="$action"'),
          isTrue,
          reason: 'Boot receiver intent-filter $action içermeli',
        );
      }
    });

    test('izin guardrail\'leri korunur (yorumlar hariç)', () {
      expect(
        hasPermissionDecl('SCHEDULE_EXACT_ALARM'),
        isTrue,
        reason: 'SCHEDULE_EXACT_ALARM gerçek declaration olarak bulunmalı',
      );
      expect(
        hasPermissionDecl('POST_NOTIFICATIONS'),
        isTrue,
        reason: 'POST_NOTIFICATIONS gerçek declaration olarak bulunmalı',
      );

      // Yasak izinler gerçek declaration olarak BULUNMAMALI.
      expect(
        hasPermissionDecl('USE_EXACT_ALARM'),
        isFalse,
        reason: 'USE_EXACT_ALARM eklenmemeli',
      );
      expect(
        hasPermissionDecl('USE_FULL_SCREEN_INTENT'),
        isFalse,
        reason: 'USE_FULL_SCREEN_INTENT eklenmemeli',
      );

      // Plugin'e ait bir foreground-service declaration eklenmemeli.
      expect(
        manifest.contains(
          'com.dexterous.flutterlocalnotifications.ForegroundService',
        ),
        isFalse,
        reason: 'Plugin foreground service declaration eklenmemeli',
      );
    });
  });
}
