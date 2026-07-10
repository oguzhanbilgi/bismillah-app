import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/domain/supported_language.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/features/dua/domain/entities/dua.dart';

/// Dua içerik + favori lokal veri sözleşmesi (10_DATA_MODEL §7).
abstract interface class DuaRepository {
  ResultFuture<Dua?> getDua(ContentId duaId, SupportedLanguage language);

  ResultFuture<List<Dua>> getByCategory(
    String category,
    SupportedLanguage language,
  );

  Stream<List<DuaFavorite>> watchFavorites();

  ResultFuture<void> addFavorite(ContentId duaId);

  /// Soft delete — tombstone işareti; fiziksel purge ack sonrası (§15).
  ResultFuture<void> removeFavorite(ContentId duaId);
}
