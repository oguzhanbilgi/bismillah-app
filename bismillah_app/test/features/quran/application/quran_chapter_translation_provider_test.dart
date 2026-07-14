import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/quran/application/quran_chapter_translation_provider.dart';
import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_verse_translation.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_translation_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TASK 040 meal provider'ı: tercih varsayılan AÇIK; kapalıyken callable
/// hiç çağrılmaz; retry yalnız ilgili sureyi yeniler.
final class _FakeTranslationRepository implements QuranTranslationRepository {
  int fetchCount = 0;
  final List<int> invalidated = [];
  bool failNext = false;

  @override
  ResultFuture<QuranChapterTranslation> getChapterTranslation(
    int chapterId,
  ) async {
    fetchCount++;
    if (failNext) {
      return const Result.failure(NetworkFailure());
    }
    return Result.success(
      QuranChapterTranslation(
        chapterId: chapterId,
        source: 'Diyanet İşleri Başkanlığı Meali',
        verses: [
          QuranVerseTranslation(
            chapterId: chapterId,
            verseNumber: 1,
            verseKey: '$chapterId:1',
            translationText: 'Meal',
          ),
        ],
      ),
    );
  }

  @override
  void invalidateChapter(int chapterId) => invalidated.add(chapterId);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeTranslationRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeTranslationRepository();
    container = ProviderContainer(
      // Riverpod 3 varsayılan otomatik retry'ı testte kapalı — hata
      // durumu deterministik gözlemlensin.
      retry: (retryCount, error) => null,
      overrides: [
        quranTranslationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  test('tercih yokken varsayılan AÇIK: meal çekilir', () async {
    SharedPreferences.setMockInitialValues({});
    final subscription = container.listen(
      quranChapterTranslationProvider(1),
      (_, _) {},
    );
    addTearDown(subscription.close);

    final translation = await container.read(
      quranChapterTranslationProvider(1).future,
    );
    expect(translation, isNotNull);
    expect(translation!.chapterId, 1);
    expect(repository.fetchCount, 1);
  });

  test('meal kapalıyken callable HİÇ çağrılmaz, null döner', () async {
    SharedPreferences.setMockInitialValues({
      'bismillah.quran_reader_show_translation': false,
    });
    final subscription = container.listen(
      quranChapterTranslationProvider(1),
      (_, _) {},
    );
    addTearDown(subscription.close);

    final translation = await container.read(
      quranChapterTranslationProvider(1).future,
    );
    expect(translation, isNull);
    expect(repository.fetchCount, 0);
  });

  test(
    'hata provider hatasına dönüşür; Arapça içerik akışı etkilenmez',
    () async {
      SharedPreferences.setMockInitialValues({});
      repository.failNext = true;
      final subscription = container.listen(
        quranChapterTranslationProvider(1),
        (_, _) {},
      );
      addTearDown(subscription.close);

      await expectLater(
        container.read(quranChapterTranslationProvider(1).future),
        throwsA(isA<NetworkFailure>()),
      );
    },
  );
}
