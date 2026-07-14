import 'package:bismillah_app/features/quran/data/shared_prefs_quran_verse_bookmark_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TASK 037 ayet kaydı deposu: duplicate koruması, bozuk anahtar
/// güvenliği, bağımsız kaldırma.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const repository = SharedPrefsQuranVerseBookmarkRepository();

  Future<Set<String>> keys() async =>
      (await repository.loadBookmarkedVerseKeys()).fold(
        onSuccess: (k) => k,
        onFailure: (_) => throw StateError('okuma başarısız'),
      );

  test('kaydet/kaldır çalışır; aynı durumun tekrarı duplicate üretmez',
      () async {
    SharedPreferences.setMockInitialValues({});
    await repository.setBookmarked('2:255', bookmarked: true);
    await repository.setBookmarked('2:255', bookmarked: true); // tekrar
    expect(await keys(), {'2:255'});

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getStringList('bismillah.quran_bookmarked_verse_keys'),
      ['2:255'],
    );

    await repository.setBookmarked('2:255', bookmarked: false);
    expect(await keys(), isEmpty);
  });

  test('bozuk saklanmış anahtarlar okunurken göz ardı edilir', () async {
    SharedPreferences.setMockInitialValues({
      'bismillah.quran_bookmarked_verse_keys': [
        '1:1',
        'bozuk',
        '0:5', // geçersiz sure
        '115:1', // aralık dışı
        '2:abc',
        '3:4',
      ],
    });
    expect(await keys(), {'1:1', '3:4'});
  });

  test('tek kaydın kaldırılması diğerlerini etkilemez', () async {
    SharedPreferences.setMockInitialValues({});
    await repository.setBookmarked('1:1', bookmarked: true);
    await repository.setBookmarked('2:255', bookmarked: true);
    await repository.setBookmarked('114:6', bookmarked: true);

    await repository.setBookmarked('2:255', bookmarked: false);
    expect(await keys(), {'1:1', '114:6'});

    final flag = (await repository.isBookmarked('1:1')).fold(
      onSuccess: (b) => b,
      onFailure: (_) => false,
    );
    expect(flag, isTrue);
  });
}
