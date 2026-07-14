import 'package:bismillah_app/features/quran/application/quran_verse_bookmarks_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TASK 037 bookmark controller'ı: iyimser toggle + hızlı çift dokunuş
/// koruması (duplicate işlem üretilmez).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('toggle kaydeder, ikinci toggle kaldırır; durum kalıcıdır', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(
      quranVerseBookmarksControllerProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);
    await container.read(quranVerseBookmarksControllerProvider.future);
    final controller = container.read(
      quranVerseBookmarksControllerProvider.notifier,
    );

    await controller.toggle('1:1');
    expect(
      container
          .read(quranVerseBookmarksControllerProvider)
          .value!
          .isBookmarked('1:1'),
      isTrue,
    );

    await controller.toggle('1:1');
    expect(
      container
          .read(quranVerseBookmarksControllerProvider)
          .value!
          .isBookmarked('1:1'),
      isFalse,
    );

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getStringList('bismillah.quran_bookmarked_verse_keys'),
      isEmpty,
    );
  });

  test('hızlı çift dokunuş: yazım sürerken ikinci toggle yok sayılır',
      () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(
      quranVerseBookmarksControllerProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);
    await container.read(quranVerseBookmarksControllerProvider.future);
    final controller = container.read(
      quranVerseBookmarksControllerProvider.notifier,
    );

    // Await ETMEDEN iki hızlı dokunuş — in-flight koruması ikincisini
    // yok sayar; sonuç tek kayıttır, toggle geri alınmış olmaz.
    final first = controller.toggle('2:255');
    final second = controller.toggle('2:255');
    await Future.wait([first, second]);

    expect(
      container
          .read(quranVerseBookmarksControllerProvider)
          .value!
          .isBookmarked('2:255'),
      isTrue,
    );
    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getStringList('bismillah.quran_bookmarked_verse_keys'),
      ['2:255'],
    );
  });
}
