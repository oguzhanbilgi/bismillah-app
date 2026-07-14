import 'package:bismillah_app/features/quran/data/shared_prefs_quran_reading_position_repository.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_reading_position.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TASK 036 son okuma konumu deposu: round-trip + bozuk veri güvenliği.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const repository = SharedPrefsQuranReadingPositionRepository();

  Future<QuranReadingPosition?> load() async => (await repository.load())
      .fold(onSuccess: (position) => position, onFailure: (_) => null);

  test('save → load round-trip konumu korur', () async {
    SharedPreferences.setMockInitialValues({});
    final position = QuranReadingPosition(
      chapterId: 2,
      scrollOffset: 1234.5,
      updatedAtUtc: DateTime.utc(2026, 7, 14, 10),
    );
    await repository.save(position);

    final loaded = await load();
    expect(loaded, isNotNull);
    expect(loaded!.chapterId, 2);
    expect(loaded.scrollOffset, 1234.5);
    expect(loaded.updatedAtUtc, DateTime.utc(2026, 7, 14, 10));
  });

  test('bozuk/eksik değerler konum YOK sayılır (crash yok)', () async {
    // Geçersiz sure numarası.
    SharedPreferences.setMockInitialValues({
      'bismillah.quran_last_chapter_id': 999,
      'bismillah.quran_last_scroll_offset': 10.0,
      'bismillah.quran_last_read_at_utc': '2026-07-14T10:00:00Z',
    });
    expect(await load(), isNull);

    // Yanlış tipte offset.
    SharedPreferences.setMockInitialValues({
      'bismillah.quran_last_chapter_id': 2,
      'bismillah.quran_last_scroll_offset': 'bozuk',
      'bismillah.quran_last_read_at_utc': '2026-07-14T10:00:00Z',
    });
    expect(await load(), isNull);

    // Negatif offset ve bozuk tarih.
    SharedPreferences.setMockInitialValues({
      'bismillah.quran_last_chapter_id': 2,
      'bismillah.quran_last_scroll_offset': -5.0,
      'bismillah.quran_last_read_at_utc': 'dün',
    });
    expect(await load(), isNull);

    // Hiç veri yok.
    SharedPreferences.setMockInitialValues({});
    expect(await load(), isNull);
  });

  test('clear kayıtlı konumu siler', () async {
    SharedPreferences.setMockInitialValues({});
    await repository.save(
      QuranReadingPosition(
        chapterId: 1,
        scrollOffset: 10,
        updatedAtUtc: DateTime.utc(2026),
      ),
    );
    expect(await load(), isNotNull);

    await repository.clear();
    expect(await load(), isNull);
  });
}
