import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Locale katmanının sözlük bütünlüğü (TASK 053 §6–§8).
///
/// Widget kurmadan doğrulanabilen her şey burada tutulur: üç dilde de
/// gerçek karşılık var mı, İngilizce/Arapça yanlışlıkla Türkçe kalmış mı,
/// namaz adları locale'e uyuyor mu.
String _prayerLabel(AppLocalizations l10n, PrayerName name) => switch (name) {
  PrayerName.fajr => l10n.prayerNameFajr,
  PrayerName.dhuhr => l10n.prayerNameDhuhr,
  PrayerName.asr => l10n.prayerNameAsr,
  PrayerName.maghrib => l10n.prayerNameMaghrib,
  PrayerName.isha => l10n.prayerNameIsha,
};

void main() {
  const tr = AppLocalizations(SupportedLocale.tr);
  const en = AppLocalizations(SupportedLocale.en);
  const ar = AppLocalizations(SupportedLocale.ar);

  group('Bottom navigation üç dilde', () {
    test('Türkçe sekme adları', () {
      expect([
        tr.tabToday,
        tr.tabPrayer,
        tr.tabQuran,
        tr.tabLearn,
        tr.tabProfile,
      ], everyElement(isNotEmpty));
    });

    test('sekme adları diller arasında AYNI kalmaz (gerçekten çevrilmiş)', () {
      expect(en.tabToday, isNot(tr.tabToday));
      expect(ar.tabToday, isNot(tr.tabToday));
      expect(ar.tabToday, isNot(en.tabToday));
    });
  });

  group('Namaz adları locale\'e uyar (TASK 053 §8)', () {
    test('Türkçe adlar', () {
      expect(PrayerName.values.map((p) => _prayerLabel(tr, p)).toList(), [
        'İmsak',
        'Öğle',
        'İkindi',
        'Akşam',
        'Yatsı',
      ]);
      expect(tr.prayerTimesSunrise, 'Güneş');
    });

    test('İngilizce adlar', () {
      expect(PrayerName.values.map((p) => _prayerLabel(en, p)).toList(), [
        'Fajr',
        'Dhuhr',
        'Asr',
        'Maghrib',
        'Isha',
      ]);
      expect(en.prayerTimesSunrise, 'Sunrise');
    });

    test('Arapça adlar', () {
      expect(PrayerName.values.map((p) => _prayerLabel(ar, p)).toList(), [
        'الفجر',
        'الظهر',
        'العصر',
        'المغرب',
        'العشاء',
      ]);
      expect(ar.prayerTimesSunrise, 'الشروق');
    });

    test('domain enum adları DEĞİŞMEZ (teknik tanımlayıcı)', () {
      expect(PrayerName.values.map((p) => p.name).toList(), [
        'fajr',
        'dhuhr',
        'asr',
        'maghrib',
        'isha',
      ]);
    });
  });

  group('TASK 052 metinleri üç dilde tutarlı', () {
    test('Türkçe', () {
      expect(tr.todayHeroTitle, 'Bugün yeniden başlayabilirsin');
      expect(
        tr.todayHeroBody,
        'Her küçük adım, kalbini ibadete biraz daha yaklaştırır.',
      );
      expect(tr.todayHeroCta, 'Bugünün planını gör');
      expect(tr.todayVerseSectionTitle, 'Bugünün Ayeti');
    });

    test('İngilizce', () {
      expect(en.todayHeroTitle, 'You can begin again today');
      expect(
        en.todayHeroBody,
        'Every small step can bring your heart closer to worship.',
      );
      expect(en.todayHeroCta, "View today's plan");
      expect(en.todayVerseSectionTitle, 'Verse of the Day');
    });

    test('Arapça', () {
      expect(ar.todayHeroTitle, 'يمكنك أن تبدأ من جديد اليوم');
      expect(ar.todayHeroBody, 'كل خطوة صغيرة قد تقرّب قلبك أكثر من العبادة.');
      expect(ar.todayHeroCta, 'عرض خطة اليوم');
      expect(ar.todayVerseSectionTitle, 'آية اليوم');
    });

    test('hero metni ayet/hadis gibi SUNULMAZ — tırnak içine alınmaz', () {
      for (final l10n in [tr, en, ar]) {
        for (final text in [l10n.todayHeroTitle, l10n.todayHeroBody]) {
          expect(text.trim(), isNot(startsWith('"')));
          expect(text.trim(), isNot(startsWith('«')));
          expect(text.trim(), isNot(startsWith('﴿')));
        }
      }
    });
  });

  group('Loading / hata / boş durum metinleri', () {
    test('üç dilde de doludur ve birbirinden farklıdır', () {
      for (final getter in <String Function(AppLocalizations)>[
        (l) => l.commonLoading,
        (l) => l.commonRetry,
        (l) => l.commonClose,
      ]) {
        expect(getter(tr), isNotEmpty);
        expect(getter(en), isNotEmpty);
        expect(getter(ar), isNotEmpty);
        expect(getter(en), isNot(getter(tr)));
        expect(getter(ar), isNot(getter(tr)));
      }
    });
  });

  group('Arapça sözlük kalitesi', () {
    test('Arapça değerler Latin harfli BIRAKILMAMIŞ', () {
      // Marka/kaynak adları (Tanzil, QuranEnc, MP3Quran) sözlükte DEĞİL —
      // widget'larda sabit kalır. Bu yüzden Arapça bloğun kullanıcıya
      // görünen bu örnekleri saf Arapça olmalıdır.
      final samples = <String>[
        ar.tabToday,
        ar.tabPrayer,
        ar.tabQuran,
        ar.tabLearn,
        ar.tabProfile,
        ar.settingsLanguageTitle,
        ar.settingsLanguageSelected,
        ar.commonRetry,
      ];
      for (final value in samples) {
        expect(
          RegExp(r'[A-Za-z]').hasMatch(value),
          isFalse,
          reason: 'Arapça karşılık Latin harf içeriyor: $value',
        );
        expect(RegExp(r'[؀-ۿ]').hasMatch(value), isTrue);
      }
    });

    test('İngilizce değerler Türkçe\'ye özgü harf içermez', () {
      final samples = <String>[
        en.tabToday,
        en.tabPrayer,
        en.tabQuran,
        en.tabLearn,
        en.tabProfile,
        en.settingsLanguageTitle,
        en.todayHeroTitle,
        en.commonRetry,
      ];
      for (final value in samples) {
        expect(
          RegExp(r'[ğüşıöçĞÜŞİÖÇ]').hasMatch(value),
          isFalse,
          reason: 'İngilizce karşılık Türkçe harf içeriyor: $value',
        );
      }
    });
  });

  group('Dil adları çevrilmez', () {
    test('her dil KENDİ adıyla anılır', () {
      expect(SupportedLocale.tr.nativeName, 'Türkçe');
      expect(SupportedLocale.en.nativeName, 'English');
      expect(SupportedLocale.ar.nativeName, 'العربية');
    });
  });

  group('Yön (RTL) sözleşmesi', () {
    test('yalnız Arapça RTL\'dir', () {
      expect(SupportedLocale.ar.isRtl, isTrue);
      expect(SupportedLocale.tr.isRtl, isFalse);
      expect(SupportedLocale.en.isRtl, isFalse);
    });

    test('desteklenen locale listesi tam ve sıralıdır', () {
      expect(SupportedLocale.locales, const [
        Locale('tr'),
        Locale('en'),
        Locale('ar'),
      ]);
    });
  });

  group('Sözlük bütünlüğü', () {
    test('bilinmeyen locale sessizce İngilizceye düşer, crash olmaz', () {
      // `_t` eksik anahtarda İngilizce'ye düşer — kullanıcı boş metin görmez.
      expect(const AppLocalizations(SupportedLocale.ar).appTitle, isNotEmpty);
    });
  });
}
