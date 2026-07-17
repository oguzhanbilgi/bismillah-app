import 'dart:convert';

import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter_recitation.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_reciter_catalog_repository.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// MP3Quran timed-read kâri kataloğu (TASK 049).
///
/// Yalnız resmî HTTPS `/api/v3/ayat_timing/reads` endpoint'i kullanılır;
/// yanıt LOGLANMAZ, UID/token/analytics YOK. Sıra: bellek cache → geçerli
/// yerel cache (7 gün TTL) → ağ; ağ hatasında süresi geçmiş cache bile
/// kullanılır, hiç cache yoksa yalnız varsayılan read 5 döner — mevcut
/// oynatma davranışı hiçbir koşulda bozulmaz. Bozuk cache yalnız bu
/// anahtar için temizlenir.
final class Mp3QuranReciterCatalogRepository
    implements QuranReciterCatalogRepository {
  Mp3QuranReciterCatalogRepository({required this._clock, http.Client? client})
    : _client = client ?? http.Client();

  static const String _readsUrl =
      'https://www.mp3quran.net/api/v3/ayat_timing/reads';
  static const String _cacheKey = 'bismillah.quran_reciter_catalog';
  static const Duration _cacheTtl = Duration(days: 7);
  static const Duration _timeout = Duration(seconds: 10);
  static const int _maxNameLength = 120;

  final AppClock _clock;
  final http.Client _client;

  List<QuranRecitationSource>? _memoryCache;

  /// Her zaman mevcut fallback: read 5 — Ahmed el-Acemi, Hafs an Asım.
  /// Etiketler uygulamada TASK 041'den beri kullanılan doğrulanmış
  /// değerlerdir.
  static final QuranRecitationSource read5Default = QuranRecitationSource(
    readId: 5,
    reciterName: 'Ahmed el-Acemi',
    rewayaName: 'Hafs an Asım',
    folderUrl: 'https://server10.mp3quran.net/ajm/',
    chapterCount: 114,
    isDefault: true,
  );

  @override
  QuranRecitationSource get defaultSource => read5Default;

  @override
  Future<List<QuranRecitationSource>> getAvailableReciters({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final memory = _memoryCache;
      if (memory != null) {
        return memory;
      }
      final local = await _readLocalCache(requireFresh: true);
      if (local != null) {
        return _memoryCache = local;
      }
    }
    try {
      final fetched = await _fetchAndValidate();
      await _writeLocalCache(fetched);
      return _memoryCache = fetched;
    } on Exception {
      // Ağ/parse hatası: süresi geçmiş yerel cache bile tercih edilir;
      // o da yoksa yalnız varsayılan read 5.
      final stale = await _readLocalCache(requireFresh: false);
      return _memoryCache = stale ?? [defaultSource];
    }
  }

  /// Resmî reads yanıtını doğrular: pozitif tekil id, kontrol karaktersiz
  /// makul uzunlukta adlar, HTTPS folder_url, soar_count == 114 ve Hafs
  /// an Asım rivayeti. Geçmeyen kayıt SESSİZCE atlanır — katalog yalnız
  /// güvenli kayıtları taşır.
  Future<List<QuranRecitationSource>> _fetchAndValidate() async {
    final response = await _client.get(Uri.parse(_readsUrl)).timeout(_timeout);
    if (response.statusCode != 200) {
      throw http.ClientException('HTTP ${response.statusCode}');
    }
    final decoded = json.decode(utf8.decode(response.bodyBytes));
    if (decoded is! List) {
      throw const FormatException('reads yanıtı liste değil');
    }
    final byId = <int, QuranRecitationSource>{};
    for (final raw in decoded) {
      if (raw is! Map) {
        continue;
      }
      final id = raw['id'];
      final name = raw['name'];
      final rewaya = raw['rewaya'];
      final folderUrl = raw['folder_url'];
      final chapterCount = raw['soar_count'];
      if (id is! int ||
          id < 1 ||
          byId.containsKey(id) ||
          name is! String ||
          rewaya is! String ||
          folderUrl is! String ||
          chapterCount is! int ||
          chapterCount != 114 ||
          !_isSafeName(name) ||
          !_isSafeName(rewaya) ||
          !folderUrl.startsWith('https://') ||
          !_isHafsAnAsim(rewaya)) {
        continue;
      }
      byId[id] = QuranRecitationSource(
        readId: id,
        reciterName: name.trim(),
        rewayaName: rewaya.trim(),
        folderUrl: folderUrl,
        chapterCount: chapterCount,
        isDefault: id == defaultSource.readId,
      );
    }
    // Varsayılan kâri her koşulda katalogda bulunur.
    byId.putIfAbsent(defaultSource.readId, () => defaultSource);
    final sources = byId.values.toList()
      ..sort((a, b) {
        final byName = a.reciterName.compareTo(b.reciterName);
        return byName != 0 ? byName : a.readId.compareTo(b.readId);
      });
    return List.unmodifiable(sources);
  }

  static bool _isSafeName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > _maxNameLength) {
      return false;
    }
    for (final rune in trimmed.runes) {
      if (rune < 0x20 || rune == 0x7F) {
        return false; // kontrol karakteri
      }
    }
    return true;
  }

  /// Yalnız Hafs an Asım rivayeti kabul edilir (Arapça veya Latin yazım).
  static bool _isHafsAnAsim(String rewaya) {
    final lower = rewaya.toLowerCase();
    return (rewaya.contains('حفص') && rewaya.contains('عاصم')) ||
        lower.contains('hafs');
  }

  Future<List<QuranRecitationSource>?> _readLocalCache({
    required bool requireFresh,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.get(_cacheKey);
      if (raw == null) {
        return null;
      }
      if (raw is! String) {
        throw const FormatException('cache String değil');
      }
      final decoded = json.decode(raw);
      if (decoded is! Map<String, Object?> || decoded['v'] != 1) {
        throw const FormatException('cache sürümü bozuk');
      }
      final fetchedAtRaw = decoded['fetchedAtUtc'];
      final fetchedAt = fetchedAtRaw is String
          ? DateTime.tryParse(fetchedAtRaw)
          : null;
      final rawReads = decoded['reads'];
      if (fetchedAt == null || rawReads is! List) {
        throw const FormatException('cache alanları bozuk');
      }
      if (requireFresh &&
          _clock.nowUtc().difference(fetchedAt.toUtc()) > _cacheTtl) {
        return null; // süresi geçmiş — ağ denenir, cache SİLİNMEZ
      }
      final sources = <QuranRecitationSource>[];
      for (final raw in rawReads) {
        if (raw is! Map) {
          throw const FormatException('cache kaydı nesne değil');
        }
        sources.add(
          // Entity kurucusu HTTPS/114/isim kurallarını yeniden doğrular.
          QuranRecitationSource(
            readId: raw['id'] as int,
            reciterName: raw['name'] as String,
            rewayaName: raw['rewaya'] as String,
            folderUrl: raw['folderUrl'] as String,
            chapterCount: raw['chapterCount'] as int,
            isDefault: raw['id'] == defaultSource.readId,
          ),
        );
      }
      return sources.isEmpty ? null : List.unmodifiable(sources);
    } on Exception {
      await _clearLocalCache();
      return null;
    } on TypeError {
      await _clearLocalCache();
      return null;
    } on ArgumentError {
      await _clearLocalCache();
      return null;
    }
  }

  Future<void> _writeLocalCache(List<QuranRecitationSource> sources) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey,
        json.encode({
          'v': 1,
          'fetchedAtUtc': _clock.nowUtc().toIso8601String(),
          'reads': [
            for (final source in sources)
              {
                'id': source.readId,
                'name': source.reciterName,
                'rewaya': source.rewayaName,
                'folderUrl': source.folderUrl,
                'chapterCount': source.chapterCount,
              },
          ],
        }),
      );
    } on Exception {
      // Cache yazılamazsa katalog yine bellekte kullanılır — sessiz.
    }
  }

  /// Bozuk cache YALNIZ bu anahtar için temizlenir — başka veri silinmez.
  Future<void> _clearLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
    } on Exception {
      // Temizleme hatası sessiz — sonraki okuma yeniden dener.
    }
  }
}
