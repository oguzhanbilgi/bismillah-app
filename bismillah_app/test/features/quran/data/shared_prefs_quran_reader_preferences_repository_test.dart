import 'package:bismillah_app/features/quran/data/shared_prefs_quran_reader_preferences_repository.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_arabic_text_size.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TASK 037 okuyucu görünüm tercihi: kalıcılık + bozuk değer fallback'i.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const repository = SharedPrefsQuranReaderPreferencesRepository();

  Future<QuranArabicTextSize> size() async =>
      (await repository.loadArabicTextSize()).fold(
        onSuccess: (s) => s,
        onFailure: (_) => throw StateError('okuma başarısız'),
      );

  test('kaydedilen boyut stabil name ile korunur', () async {
    SharedPreferences.setMockInitialValues({});
    await repository.saveArabicTextSize(QuranArabicTextSize.large);
    expect(await size(), QuranArabicTextSize.large);

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString('bismillah.quran_reader_arabic_text_size'),
      'large',
    );
  });

  test('değer yoksa veya bozuksa medium varsayılanına düşer', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await size(), QuranArabicTextSize.medium);

    SharedPreferences.setMockInitialValues({
      'bismillah.quran_reader_arabic_text_size': 'devasa',
    });
    expect(await size(), QuranArabicTextSize.medium);

    SharedPreferences.setMockInitialValues({
      'bismillah.quran_reader_arabic_text_size': 42,
    });
    expect(await size(), QuranArabicTextSize.medium);
  });
}
