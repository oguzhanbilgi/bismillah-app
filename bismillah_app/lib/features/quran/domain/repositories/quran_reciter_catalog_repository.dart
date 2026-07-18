import 'package:bismillah_app/features/quran/domain/entities/quran_chapter_recitation.dart';

/// Ayet zamanlamalı (timed) MP3Quran kâri kataloğu sözleşmesi (TASK 049).
///
/// Yalnız resmî `/api/v3/ayat_timing/reads` kayıtlarından, doğrulanmış
/// 114 surelik Hafs an Asım okumaları döner. Katalog hiçbir koşulda boş
/// olmaz — ağ/cache tamamen başarısızsa yalnız [defaultSource] (read 5,
/// Ahmed el-Acemi) döner ve mevcut oynatma davranışı bozulmaz.
abstract interface class QuranReciterCatalogRepository {
  /// Deterministik sıralı (kâri adı, sonra readId) doğrulanmış katalog.
  /// Bellek → yerel cache (7 gün TTL) → ağ sırasıyla çözülür;
  /// [forceRefresh] yalnız ağ denemesini zorlar. ASLA fırlatmaz.
  Future<List<QuranRecitationSource>> getAvailableReciters({
    bool forceRefresh = false,
  });

  /// Her zaman mevcut varsayılan kaynak (read 5).
  QuranRecitationSource get defaultSource;
}
