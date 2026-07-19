import 'package:bismillah_app/features/learn/data/shared_prefs_learning_progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Yerel öğrenme ilerlemesi kalıcılığı (TASK 056 §14 Persistence).
///
/// Firebase KULLANILMAZ; her şey cihaz-lokaldir.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const repository = SharedPrefsLearningProgressRepository();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('başlangıçta ilerleme boştur', () async {
    final progress = (await repository.load()).valueOrNull!;
    expect(progress.bookmarkedArticleIds, isEmpty);
    expect(progress.completedArticleIds, isEmpty);
    expect(progress.lastOpenedArticleId, isNull);
  });

  test('bookmark RESTART sonrası korunur', () async {
    await repository.toggleBookmark('art-abdest-nasil-alinir');

    // Yeni instance = yeniden açılan uygulama.
    const reopened = SharedPrefsLearningProgressRepository();
    final progress = (await reopened.load()).valueOrNull!;
    expect(progress.isBookmarked('art-abdest-nasil-alinir'), isTrue);
  });

  test('bookmark geri alınabilir ve kalıcılaşır', () async {
    await repository.toggleBookmark('art-x');
    await repository.toggleBookmark('art-x');

    const reopened = SharedPrefsLearningProgressRepository();
    final progress = (await reopened.load()).valueOrNull!;
    expect(progress.isBookmarked('art-x'), isFalse);
  });

  test('tamamlandı işareti RESTART sonrası korunur', () async {
    await repository.toggleCompleted('art-imanin-sartlari');

    const reopened = SharedPrefsLearningProgressRepository();
    final progress = (await reopened.load()).valueOrNull!;
    expect(progress.isCompleted('art-imanin-sartlari'), isTrue);
  });

  test('son açılan içerik RESTART sonrası korunur', () async {
    await repository.noteOpened('art-kuran-nedir', sectionIndex: 2);

    const reopened = SharedPrefsLearningProgressRepository();
    final progress = (await reopened.load()).valueOrNull!;
    expect(progress.lastOpenedArticleId, 'art-kuran-nedir');
    expect(progress.lastReadSectionIndex, 2);
    expect(progress.lastOpenedAt, isNotNull);
  });

  test('bookmark ve completed birbirinden BAĞIMSIZDIR', () async {
    await repository.toggleBookmark('art-a');
    await repository.toggleCompleted('art-b');

    final progress = (await repository.load()).valueOrNull!;
    expect(progress.isBookmarked('art-a'), isTrue);
    expect(progress.isCompleted('art-a'), isFalse);
    expect(progress.isCompleted('art-b'), isTrue);
    expect(progress.isBookmarked('art-b'), isFalse);
  });

  test('kayıtlar locale ANAHTARI taşımaz — dil değişimi silmez', () async {
    // İlerleme, locale'den bağımsız içerik id'leriyle tutulur.
    await repository.toggleBookmark('art-abdest-nasil-alinir');

    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('bismillah.learn'));
    expect(keys, isNotEmpty);
    for (final key in keys) {
      expect(key.contains('_tr'), isFalse);
      expect(key.contains('_en'), isFalse);
      expect(key.contains('_ar'), isFalse);
    }

    // Dil değişimi bu anahtarlara DOKUNMAZ; kayıt aynen durur.
    final progress = (await repository.load()).valueOrNull!;
    expect(progress.isBookmarked('art-abdest-nasil-alinir'), isTrue);
  });

  test('bozuk kayıt sakin biçimde boş duruma düşer (crash yok)', () async {
    SharedPreferences.setMockInitialValues({
      'bismillah.learn_bookmarked_ids': 'bu-bir-liste-degil',
      'bismillah.learn_last_section_index': 'sayi-degil',
    });

    final progress = (await repository.load()).valueOrNull!;
    expect(progress.bookmarkedArticleIds, isEmpty);
    expect(progress.lastReadSectionIndex, isNull);
  });
}
