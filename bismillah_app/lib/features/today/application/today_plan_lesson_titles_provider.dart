import 'package:bismillah_app/features/learn/application/learn_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Plandaki ders öğelerinin başlıklarını **doğrulanmış Learn içerik
/// katmanından** çözer (TASK 083).
///
/// Neden ayrı bir provider: `DailyPlan` yalnız stabil makale kimliği taşır
/// (TASK 082) — başlık, özet ve gövde metni plana ASLA kopyalanmaz. Görünen
/// başlık bu yüzden her açılışta mevcut `LearningKnowledgeRepository`
/// üzerinden, aktif içerik diliyle çözülür. Depo yalnız **yayınlanmış**
/// içerik döner; yayından kalkmış bir kimlik sessizce eşleşmez ve kart nötr
/// etiketine düşer.
///
/// Aile anahtarı, kimliklerin virgülle birleştirilmiş hâlidir — `String`
/// değer eşitliği taşıdığı için her `build` çağrısında yeni bir provider
/// örneği doğmaz (`List` kimlik eşitliğiyle karşılaştırılırdı).
/// Anahtar üretimi için [lessonTitlesKey] kullanılır.
final todayPlanLessonTitlesProvider =
    FutureProvider.family<Map<String, String>, String>((ref, key) async {
      final ids = lessonTitlesKeyToIds(key);
      if (ids.isEmpty) {
        return const <String, String>{};
      }
      final locale = ref.watch(learnContentLocaleProvider);
      final result = await ref
          .watch(learningKnowledgeRepositoryProvider)
          .getArticlesByIds(locale, ids);
      return result.fold(
        onSuccess: (articles) => {
          for (final article in articles) article.id: article.title,
        },
        // Sakin bozulma: içerik okunamazsa Today bloklanmaz, kart nötr
        // etiketle görünür (uydurma başlık ÜRETİLMEZ).
        onFailure: (_) => const <String, String>{},
      );
    });

/// Makale kimliklerinden deterministik aile anahtarı üretir.
///
/// Sıra korunur ve tekrarlar ayıklanır; böylece aynı plan daima aynı
/// anahtarı verir ve gereksiz yeniden çözüm olmaz.
String lessonTitlesKey(Iterable<String> articleIds) {
  final unique = <String>{};
  for (final id in articleIds) {
    final trimmed = id.trim();
    if (trimmed.isNotEmpty) {
      unique.add(trimmed);
    }
  }
  return unique.join(',');
}

/// [lessonTitlesKey] tersi.
List<String> lessonTitlesKeyToIds(String key) =>
    key.isEmpty ? const <String>[] : key.split(',');
