import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// ALPHA-R2A — resource-shrinker keep sözleşmesi regresyon testleri.
///
/// Release derlemesi R8 + resource shrinking ile çalışır. audio_service,
/// medya kontrol ikonlarını çalışma zamanında **isimle** çözer
/// (`getResources().getIdentifier(...)`), bu yüzden shrinker referansı
/// GÖREMEZ ve ikonları siler. Sonuç eksik ikon değil, `CustomAction`
/// kurulurken atılan `IllegalArgumentException`'dır; PlaybackState hiç
/// yayınlanamaz (bildirim ve kilit ekranı kontrolleri kaybolur).
///
/// Bu dosya YALNIZCA bir **yapılandırma** güvencesidir: keep.xml'in var
/// olduğunu ve handler'ın gerçekten yayınladığı her MediaControl için ilgili
/// drawable'ı içerdiğini doğrular. **Release paketlemesini kanıtlamaz** —
/// gerçek kanıt imzalı APK'nın `aapt2 dump resources` çıktısıdır.
void main() {
  /// Depo kökünü cwd'den yukarı çıkarak bulur; absolute path gömülmez.
  Directory findPackageRoot() {
    var dir = Directory.current;
    for (var i = 0; i < 8; i++) {
      if (File('${dir.path}/pubspec.yaml').existsSync() &&
          Directory('${dir.path}/android').existsSync()) {
        return dir;
      }
      final parent = dir.parent;
      if (parent.path == dir.path) {
        break;
      }
      dir = parent;
    }
    fail('Paket kökü bulunamadı (cwd: ${Directory.current.path})');
  }

  final root = findPackageRoot();
  final keepFile = File('${root.path}/android/app/src/main/res/raw/keep.xml');
  final handlerFile = File(
    '${root.path}/lib/features/quran/data/audio_service_quran_handler.dart',
  );

  /// audio_service 0.18.19'un sabit sözleşmesi: MediaControl adı -> drawable.
  /// Kaynak: audio_service/lib/audio_service.dart `androidIcon` alanları.
  const controlToDrawable = <String, String>{
    'stop': 'audio_service_stop',
    'pause': 'audio_service_pause',
    'play': 'audio_service_play_arrow',
    'rewind': 'audio_service_fast_rewind',
    'skipToNext': 'audio_service_skip_next',
    'skipToPrevious': 'audio_service_skip_previous',
    'fastForward': 'audio_service_fast_forward',
  };

  /// keep.xml'de gerçekten korunan drawable adları (yorumlar sayılmaz).
  Set<String> keptDrawables(String keepXml) {
    final withoutComments = keepXml.replaceAll(
      RegExp(r'<!--.*?-->', dotAll: true),
      '',
    );
    final keepAttr = RegExp(
      r'tools:keep\s*=\s*"([^"]*)"',
    ).firstMatch(withoutComments);
    if (keepAttr == null) {
      return const <String>{};
    }
    return keepAttr
        .group(1)!
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.startsWith('@drawable/'))
        .map((entry) => entry.substring('@drawable/'.length))
        .toSet();
  }

  /// Handler'ın gerçekten kullandığı MediaControl'lerden türetilen zorunlu set.
  /// Yeni bir kontrol eklenip keep.xml güncellenmezse bu test kırılır.
  Set<String> requiredDrawables(String handlerSource) {
    final withoutComments = handlerSource
        .replaceAll(RegExp(r'///.*'), '')
        .replaceAll(RegExp(r'//.*'), '');
    final used = RegExp(
      r'MediaControl\.([a-zA-Z]+)',
    ).allMatches(withoutComments).map((m) => m.group(1)!).toSet();
    return {
      for (final control in used)
        if (controlToDrawable.containsKey(control)) controlToDrawable[control]!,
    };
  }

  /// Eksik girdileri döndürür — testin "kaldırınca kırılır" güvencesi budur.
  Set<String> missingEntries(String keepXml, Set<String> required) =>
      required.difference(keptDrawables(keepXml));

  test('keep.xml dosyası VARDIR (silinirse release bildirimi çöker)', () {
    expect(
      keepFile.existsSync(),
      isTrue,
      reason:
          'android/app/src/main/res/raw/keep.xml yok. Resource shrinking '
          'audio_service ikonlarını siler ve CustomAction kurulamaz.',
    );
  });

  test('handler gerçekten MediaControl yayınlıyor (türetme boşa düşmesin)', () {
    final required = requiredDrawables(handlerFile.readAsStringSync());
    expect(
      required,
      isNotEmpty,
      reason:
          'Handler kaynağından hiç MediaControl türetilemedi; bu test o zaman '
          'hiçbir şeyi korumaz. Regex veya handler yapısı değişmiş olabilir.',
    );
  });

  test('kullanılan HER MediaControl için drawable korunuyor', () {
    final required = requiredDrawables(handlerFile.readAsStringSync());
    final missing = missingEntries(keepFile.readAsStringSync(), required);
    expect(
      missing,
      isEmpty,
      reason:
          'Bu drawable(lar) keep.xml içinde yok: $missing. audio_service '
          'bunları çalışma zamanında isimle çözer; eksik olan release '
          "APK'sında silinir ve IllegalArgumentException atılır.",
    );
  });

  test('korunan set gereksiz genişletilmemiş (kullanılmayan ikon yok)', () {
    final required = requiredDrawables(handlerFile.readAsStringSync());
    final kept = keptDrawables(keepFile.readAsStringSync());
    expect(
      kept.difference(required),
      isEmpty,
      reason:
          'keep.xml kullanılmayan drawable koruyor. Kapsam kanıta dayalı '
          've dar tutulmalı (ALPHA-R2A kararı).',
    );
  });

  test('GUARD YÜK TAŞIYOR: bir girdi çıkarılırsa eksik olarak raporlanır', () {
    final keepXml = keepFile.readAsStringSync();
    final required = requiredDrawables(handlerFile.readAsStringSync());
    expect(missingEntries(keepXml, required), isEmpty);

    // Gerçek dosyadan tek tek her zorunlu girdiyi düşür; her seferinde
    // tam olarak o girdi eksik raporlanmalı. Test yalnızca "geçiyor" değil,
    // gerçekten kırılabilir olmalı.
    for (final drawable in required) {
      final mutated = keepXml.replaceFirst('@drawable/$drawable,', '');
      final mutatedTail = mutated == keepXml
          ? keepXml.replaceFirst(',@drawable/$drawable', '')
          : mutated;
      expect(
        mutatedTail,
        isNot(equals(keepXml)),
        reason: '$drawable keep.xml içinde bulunup çıkarılamadı.',
      );
      expect(
        missingEntries(mutatedTail, required),
        equals({drawable}),
        reason:
            '$drawable keep.xml dışına çıkarıldığında test KIRILMALIYDI; '
            'kırılmıyorsa bu guard hiçbir şey korumuyor demektir.',
      );
    }
  });

  test('keep.xml neden var olduğunu açıklıyor (kör silmeye karşı)', () {
    final keepXml = keepFile.readAsStringSync();
    expect(keepXml, contains('getIdentifier'));
    expect(keepXml.toLowerCase(), contains('shrink'));
  });
}
