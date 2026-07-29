import 'dart:convert';

import 'package:flutter/services.dart';

/// Boş-kategori senaryosu için TEST-YEREL asset fikstürü.
///
/// Neden gerekli: Learn kütüphanesi CP11 paketleriyle büyüyor ve TASK 090
/// kalan kategorileri de doldurabilir. Boş-durum kapsamını gerçek bir
/// üretim kategorisinin boş kalmasına bağlamak kırılgandır; bu bundle,
/// üretim `categories.json` çıktısına YALNIZ testte görünen sentetik bir
/// kategori ekler.
///
/// Sınırlar:
/// - üretim JSON dosyaları DEĞİŞTİRİLMEZ,
/// - sentetik kimlik `cat-` öneki taşımadığı için üretim kimlikleriyle
///   çakışamaz,
/// - hiçbir makale bu kategoriye referans vermez, dolayısıyla kategori
///   tanımı gereği boştur.
final class EmptyCategoryFixtureBundle extends AssetBundle {
  EmptyCategoryFixtureBundle(this._inner);

  final AssetBundle _inner;

  static const String _categoriesPath = 'assets/content/learn/categories.json';

  /// Üretimde bulunmayan sentetik kategori kimliği.
  static const String categoryId = 'test-fixture-empty-category';

  /// Rota testleri için sentetik slug.
  static const String slug = 'test-fixture-bos-kategori';

  @override
  Future<ByteData> load(String key) => _inner.load(key);

  @override
  Future<T> loadStructuredData<T>(
    String key,
    Future<T> Function(String value) parser,
  ) async => parser(await loadString(key));

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final raw = await _inner.loadString(key, cache: cache);
    if (key != _categoriesPath) {
      return raw;
    }
    final decoded = json.decode(raw) as Map<String, Object?>;
    final categories = List<Object?>.from(
      decoded['categories']! as List<Object?>,
    );
    categories.add(<String, Object?>{
      'id': categoryId,
      'slug': slug,
      'iconKey': 'start',
      'sortOrder': categories.length + 1,
      'title': <String, Object?>{
        'tr': 'Test fikstür kategorisi',
        'en': 'Test fixture category',
        'ar': 'فئة اختبارية',
      },
      'shortDescription': <String, Object?>{
        'tr': 'Yalnız test içindir.',
        'en': 'For tests only.',
        'ar': 'للاختبار فقط.',
      },
    });
    decoded['categories'] = categories;
    return json.encode(decoded);
  }
}
