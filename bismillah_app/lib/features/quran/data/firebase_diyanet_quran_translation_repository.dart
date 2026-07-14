import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_verse_translation.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_translation_repository.dart';
// `hide Result`: cloud_functions'ın Result'ı core Result ile çakışır.
import 'package:cloud_functions/cloud_functions.dart' hide Result;

/// Firebase callable üzerinden Diyanet meali (TASK 040).
///
/// Doğrudan HTTP/Authorization YOK — kimlik Firebase SDK'sındadır, API
/// tokenı yalnız backend'de yaşar. Yanıt sözleşmesi İSTEMCİDE DE
/// doğrulanır; UID/token/meal içeriği/yanıt LOGLANMAZ. Başarılı sonuçlar
/// oturum boyunca bellekte cache edilir (disk cache YOK).
final class FirebaseDiyanetQuranTranslationRepository
    implements QuranTranslationRepository {
  FirebaseDiyanetQuranTranslationRepository({FirebaseFunctions? functions})
    : _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'europe-west1');

  /// Backend'in döndürmesi beklenen kaynak künyesi — farklıysa yanıt
  /// reddedilir (kullanıcıya rastgele kaynak adı GÖSTERİLMEZ).
  static const String expectedSource = 'Diyanet İşleri Başkanlığı Meali';

  final FirebaseFunctions _functions;
  final Map<int, QuranChapterTranslation> _cache = {};

  @override
  ResultFuture<QuranChapterTranslation> getChapterTranslation(
    int chapterId,
  ) async {
    if (chapterId < 1 || chapterId > 114) {
      return const Result.failure(
        ValidationFailure(messageKey: 'errorUnexpected'),
      );
    }
    final cached = _cache[chapterId];
    if (cached != null) {
      return Result.success(cached);
    }
    try {
      final response = await _functions
          .httpsCallable('getQuranChapterTranslation')
          .call<Object?>({'chapterId': chapterId});
      final translation = _parseAndValidate(chapterId, response.data);
      _cache[chapterId] = translation;
      return Result.success(translation);
    } on FirebaseFunctionsException catch (error) {
      // Yalnız hata KODU eşlenir — mesaj/detay/yanıt loglanmaz, taşınmaz.
      return Result.failure(switch (error.code) {
        'unauthenticated' => const AuthFailure(),
        'unavailable' || 'deadline-exceeded' => const NetworkFailure(),
        _ => const UnexpectedFailure(),
      });
    } on FormatException {
      return const Result.failure(UnexpectedFailure()); // sözleşme ihlali
    } on ArgumentError {
      return const Result.failure(UnexpectedFailure()); // entity doğrulaması
    } on Exception {
      return const Result.failure(NetworkFailure());
    }
  }

  @override
  void invalidateChapter(int chapterId) {
    _cache.remove(chapterId);
  }

  /// Backend sözleşmesini istemci tarafında da doğrular: beklenen kaynak
  /// künyesi, uyumlu verseKey, pozitif/sıralı/duplicate'siz ayetler ve
  /// boş olmayan meal (entity kurucuları + sabit kontroller).
  static QuranChapterTranslation _parseAndValidate(
    int requestedChapterId,
    Object? data,
  ) {
    if (data is! Map) {
      throw const FormatException('meal yanıtı nesne değil');
    }
    if (data['chapterId'] != requestedChapterId) {
      throw const FormatException('meal yanıtı farklı sureye ait');
    }
    final source = data['source'];
    if (source != expectedSource) {
      throw const FormatException('beklenmeyen meal kaynağı');
    }
    final rawVerses = data['verses'];
    if (rawVerses is! List || rawVerses.isEmpty) {
      throw const FormatException('meal ayet listesi eksik');
    }
    final verses = <QuranVerseTranslation>[];
    for (final raw in rawVerses) {
      if (raw is! Map) {
        throw const FormatException('meal ayet kaydı nesne değil');
      }
      final verseNumber = raw['verseNumber'];
      final verseKey = raw['verseKey'];
      final translationText = raw['translationText'];
      if (verseNumber is! int ||
          verseKey is! String ||
          translationText is! String) {
        throw const FormatException('meal ayet alanları eksik/bozuk');
      }
      verses.add(
        QuranVerseTranslation(
          chapterId: requestedChapterId,
          verseNumber: verseNumber,
          verseKey: verseKey,
          translationText: translationText,
        ),
      );
    }
    return QuranChapterTranslation(
      chapterId: requestedChapterId,
      source: source as String,
      verses: verses,
    );
  }
}
