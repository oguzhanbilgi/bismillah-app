import 'package:bismillah_app/features/quran/data/asset_quran_content_repository.dart';
import 'package:bismillah_app/features/quran/data/bundled_quran_search_repository.dart';
import 'package:bismillah_app/features/quran/data/bundled_quranenc_translation_repository.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_search_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// İndeks asset'inin yüklenemediği durumu taklit eder: `loadString` bir
/// FlutterError (Error) fırlatır — bu, `on Exception`'ın kaçırdığı gerçek
/// hata türüdür (HOTFIX).
class _MissingIndexBundle extends AssetBundle {
  _MissingIndexBundle(this._delegate);
  final AssetBundle _delegate;
  static const _index = 'assets/quran/search/quran_search_index_v1.json';

  @override
  Future<ByteData> load(String key) => _delegate.load(key);

  @override
  Future<String> loadString(String key, {bool cache = true}) {
    if (key == _index) {
      throw FlutterError('Unable to load asset: "$key".');
    }
    return _delegate.loadString(key, cache: cache);
  }

  @override
  Future<T> loadStructuredData<T>(
    String key,
    Future<T> Function(String) parser,
  ) => _delegate.loadStructuredData(key, parser);
}

/// TASK 048 offline arama — gerçek bundled asset'lerle uçtan uca (HOTFIX).
///
/// rootBundle testte pubspec asset manifest'inden okur; bu yüzden test
/// gerçek indeks + içerik + meal katmanlarını birlikte doğrular ve boş
/// sonuç üreten katmanı ortaya çıkarır.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BundledQuranSearchRepository repository;

  setUp(() {
    repository = BundledQuranSearchRepository(
      contentRepository: AssetQuranContentRepository(bundle: rootBundle),
      translationRepository: BundledQuranEncTranslationRepository(
        bundle: rootBundle,
      ),
      bundle: rootBundle,
    );
  });

  Future<QuranSearchResponse> search(String query) async {
    final result = await repository.search(query);
    return result.fold(
      onSuccess: (response) => response,
      onFailure: (failure) =>
          fail('arama başarısız döndü (failure): $failure — sorgu: "$query"'),
    );
  }

  test('kesin sure adları sonuç döner', () async {
    for (final query in ['Fatiha', 'Fâtiha', 'Bakara', 'Yasin']) {
      final response = await search(query);
      expect(
        response.chapters,
        isNotEmpty,
        reason: '"$query" için sure sonucu bekleniyordu',
      );
    }
  });

  test('sure numarası ile arama', () async {
    final response = await search('36');
    expect(response.chapters, isNotEmpty);
    expect(response.chapters.first.chapterId, 36);
  });

  test('ayet referansı 2:255', () async {
    final response = await search('2:255');
    expect(response.verses, isNotEmpty);
    expect(response.verses.first.verseKey, '2:255');
  });

  test('referans alias "ayetel kürsi" → 2:255', () async {
    final response = await search('ayetel kürsi');
    expect(response.verses, isNotEmpty);
    expect(response.verses.first.verseKey, '2:255');
  });

  test('Türkçe meal kelimesi "sabır" sonuç döner', () async {
    final response = await search('sabır');
    expect(response.verses, isNotEmpty);
  });

  test('Arapça sorgu sonuç döner', () async {
    final response = await search('الرحمن');
    expect(response.verses, isNotEmpty);
  });

  test('indeks yüklenemezse fırlatmaz, sakin failure döner', () async {
    final broken = BundledQuranSearchRepository(
      contentRepository: AssetQuranContentRepository(bundle: rootBundle),
      translationRepository: BundledQuranEncTranslationRepository(
        bundle: rootBundle,
      ),
      bundle: _MissingIndexBundle(rootBundle),
    );
    // FlutterError (Error) fırlatmamalı; sakin failure'a düşmeli.
    final result = await broken.search('fatiha');
    expect(
      result.fold(onSuccess: (_) => false, onFailure: (_) => true),
      isTrue,
      reason:
          'asset yüklenemediğinde controller\'ı kilitleyecek '
          'yakalanmamış Error yerine failure beklenir',
    );
  });
}
