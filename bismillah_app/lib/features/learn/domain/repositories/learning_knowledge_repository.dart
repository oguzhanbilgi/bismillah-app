import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/features/learn/domain/entities/knowledge_source.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_article.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_category.dart';

/// Doğrulanmış İslami bilgi tabanının TEK okuma sözleşmesi (TASK 056 §7).
///
/// Bu sözleşme UI'a ÖZEL DEĞİLDİR: Bismillah Assistant tamamlandığında
/// aynı depoyu kullanır — böylece asistan da yalnız kaynaklı, yayınlanmış
/// içeriğe dayanır ve kendi başına dinî hüküm üretmez.
///
/// Tüm okumalar aktif [locale] ile yapılır; depo yalnız
/// `ReviewStatus.published` içerik döner (taslak/incelemedeki içerik
/// uygulamada GÖRÜNMEZ).
abstract interface class LearningKnowledgeRepository {
  /// Sıralı kategoriler + her birinin yayınlanmış içerik sayısı.
  ResultFuture<List<LearningCategorySummary>> getCategories(String locale);

  /// Tek kategori (bulunamazsa `null`).
  ResultFuture<LearningCategory?> getCategoryBySlug(String locale, String slug);

  /// Bir kategorideki yayınlanmış içerikler (zorluk, sonra başlık sırası).
  ResultFuture<List<LearningArticle>> getArticlesByCategory(
    String locale,
    String categoryId,
  );

  /// Slug ile tek içerik (bulunamaz veya yayında değilse `null`).
  ResultFuture<LearningArticle?> getArticleBySlug(String locale, String slug);

  /// Id listesiyle içerik çözümü (ilgili konular / kaydedilenler için).
  /// Bulunamayan veya yayında olmayan id'ler sessizce atlanır.
  ResultFuture<List<LearningArticle>> getArticlesByIds(
    String locale,
    List<String> ids,
  );

  /// Aktif locale'deki TÜM yayınlanmış içerikler (sırasız).
  ///
  /// Bismillah Assistant retrieval'ı bunu aday havuzu olarak kullanır —
  /// asset'i ikinci kez ayrıştırmaz, yalnız `published` içeriği görür.
  ResultFuture<List<LearningArticle>> getAllPublished(String locale);

  /// `beginnerPathOrder` tanımlı içerikler, sıraya göre.
  ResultFuture<List<LearningArticle>> getBeginnerPath(String locale);

  /// Öne çıkan içerikler.
  ResultFuture<List<LearningArticle>> getFeatured(String locale);

  /// Tamamen OFFLINE arama: başlık, özet, anahtar kelime ve kategori adı
  /// üzerinde çalışır. Boş/kısa sorgu boş liste döndürür.
  ResultFuture<List<LearningArticle>> search(String locale, String query);

  /// İçeriğin atıf kartları için kaynak künyeleri.
  ResultFuture<List<KnowledgeSource>> getSourcesForArticle(
    LearningArticle article,
  );

  /// Id ile tek kaynak künyesi (bulunamazsa `null`). Asistan yönlendirme
  /// kaynağını (Din İşleri Yüksek Kurulu vb.) bununla çözer — URL tahmin
  /// edilmez, kaynak modelinden okunur (TASK 059 §10).
  ResultFuture<KnowledgeSource?> getSourceById(String id);
}
