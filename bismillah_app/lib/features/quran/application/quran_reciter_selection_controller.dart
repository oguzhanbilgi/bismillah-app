import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter_recitation.dart';
import 'package:bismillah_app/features/quran/domain/services/quran_audio_session_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Seçili kâri kaynağı (TASK 049): kayıtlı readId katalogda çözülür;
/// eksik/bozuk/katalogda olmayan seçim varsayılan read 5'e düşer.
/// Tercih değişince kendini tazeler. autoDispose — yalnız reader/panel
/// açıkken yaşar; mini player bu provider'ı KULLANMAZ (katalog çağrısı
/// yapmaz), kâri adını global ses durumundan okur.
final quranSelectedReciterProvider =
    FutureProvider.autoDispose<QuranRecitationSource>((ref) async {
      final preferences = ref.watch(quranAudioPreferencesRepositoryProvider);
      final subscription = preferences.watchSelectedReadId().listen(
        (_) => ref.invalidateSelf(),
      );
      ref.onDispose(subscription.cancel);
      final catalog = ref.watch(quranReciterCatalogRepositoryProvider);
      final selectedReadId = await preferences.loadSelectedReadId();
      final reciters = await catalog.getAvailableReciters();
      for (final source in reciters) {
        if (source.readId == selectedReadId) {
          return source;
        }
      }
      return catalog.defaultSource;
    });

/// Kâri seçim sayfası durumu (TASK 049).
final class QuranReciterSelectionState {
  const QuranReciterSelectionState({
    required this.reciters,
    required this.selectedReadId,
    this.catalogDegraded = false,
    this.saveFailed = false,
    this.isSaving = false,
  });

  final List<QuranRecitationSource> reciters;
  final int selectedReadId;

  /// Katalog ağdan/cache'ten yüklenemedi — yalnız varsayılan görünür,
  /// sakin "yüklenemedi + tekrar dene" gösterilir.
  final bool catalogDegraded;

  /// Son seçim kalıcılaştırılamadı — eski seçim korunur.
  final bool saveFailed;
  final bool isSaving;

  QuranReciterSelectionState copyWith({
    List<QuranRecitationSource>? reciters,
    int? selectedReadId,
    bool? catalogDegraded,
    bool? saveFailed,
    bool? isSaving,
  }) => QuranReciterSelectionState(
    reciters: reciters ?? this.reciters,
    selectedReadId: selectedReadId ?? this.selectedReadId,
    catalogDegraded: catalogDegraded ?? this.catalogDegraded,
    saveFailed: saveFailed ?? this.saveFailed,
    isSaving: isSaving ?? this.isSaving,
  );
}

/// Kâri seçim controller'ı (TASK 049).
///
/// Seçim akışı deterministiktir: tercih ÖNCE kalıcılaştırılır; ancak
/// kayıt başarılıysa ve o anda ses aktifse (loading/playing/paused)
/// oturum `stop()` ile tamamen kapatılır — yeni ses KENDİLİĞİNDEN
/// başlamaz, iki ses üst üste binemez. Kayıt hatasında eski seçim
/// korunur ve mevcut oynatma DURDURULMAZ; sakin hata gösterilir.
final quranReciterSelectionControllerProvider =
    AsyncNotifierProvider.autoDispose<
      QuranReciterSelectionController,
      QuranReciterSelectionState
    >(QuranReciterSelectionController.new);

final class QuranReciterSelectionController
    extends AsyncNotifier<QuranReciterSelectionState> {
  @override
  Future<QuranReciterSelectionState> build() => _load(forceRefresh: false);

  Future<QuranReciterSelectionState> _load({required bool forceRefresh}) async {
    final catalog = ref.read(quranReciterCatalogRepositoryProvider);
    final selectedReadId = await ref
        .read(quranAudioPreferencesRepositoryProvider)
        .loadSelectedReadId();
    final reciters = await catalog.getAvailableReciters(
      forceRefresh: forceRefresh,
    );
    return QuranReciterSelectionState(
      reciters: reciters,
      selectedReadId: selectedReadId,
      // Tek kayıtlı (yalnız fallback) katalog pratikte "yüklenemedi"
      // demektir — resmî timed-reads listesi her zaman birden fazladır.
      catalogDegraded: reciters.length <= 1,
    );
  }

  /// Katalog yeniden denemesi (yalnız katalog yenilenir).
  Future<void> retryCatalog() async {
    state = const AsyncLoading();
    state = AsyncData(await _load(forceRefresh: true));
  }

  /// Kâri seçimi; başarıda `true` döner (sheet kapanır). Aynı kâri
  /// yeniden seçilirse hiçbir şey yapılmaz.
  Future<bool> select(int readId) async {
    final current = state.value;
    if (current == null || current.isSaving) {
      return false;
    }
    if (readId == current.selectedReadId) {
      return true;
    }
    state = AsyncData(current.copyWith(isSaving: true, saveFailed: false));
    final result = await ref
        .read(quranAudioPreferencesRepositoryProvider)
        .saveSelectedReadId(readId);
    return result.fold(
      onSuccess: (_) {
        // Tercih kalıcılaştı: aktif ses varsa tamamen durdurulur —
        // bildirim/mini player temizlenir, yeni ses otomatik BAŞLAMAZ.
        final session = ref.read(quranAudioSessionServiceProvider);
        if (session.currentState.status != QuranVerseAudioStatus.idle) {
          session.stop();
        }
        state = AsyncData(
          current.copyWith(selectedReadId: readId, isSaving: false),
        );
        return true;
      },
      onFailure: (_) {
        // Eski seçim korunur, mevcut oynatma DURDURULMAZ.
        state = AsyncData(current.copyWith(isSaving: false, saveFailed: true));
        return false;
      },
    );
  }
}
