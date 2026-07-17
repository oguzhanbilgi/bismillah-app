import 'dart:async';

import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_search_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:bismillah_app/features/quran/domain/entities/quran_search_result.dart';

/// Oku sekmesi arama durumu (TASK 048): sorgu + sonuç + sakin hata.
final class QuranSearchState {
  const QuranSearchState({
    this.query = '',
    this.response,
    this.isLoading = false,
    this.failed = false,
  });

  final String query;

  /// Son başarılı yanıt; yeni sorgu yüklenirken önceki sonuç gösterimde
  /// kalabilir (ekran zıplamaz).
  final QuranSearchResponse? response;
  final bool isLoading;
  final bool failed;

  bool get isActive => query.trim().isNotEmpty;
}

/// Debounce'lu offline arama controller'ı (TASK 048).
///
/// ~300 ms debounce ile her tuşta arama ÇALIŞTIRILMAZ; jenerasyon sayacı
/// eski async sonucun yeni sorguyu ezmesini engeller. Sorgular hiçbir
/// yere gönderilmez/loglanmaz; indeks repository'de oturum boyunca
/// cache'lidir. autoDispose — sekmeden çıkınca durum sıfırlanır.
final quranSearchControllerProvider =
    NotifierProvider.autoDispose<QuranSearchController, QuranSearchState>(
      QuranSearchController.new,
    );

final class QuranSearchController extends Notifier<QuranSearchState> {
  static const Duration debounce = Duration(milliseconds: 300);

  Timer? _debounceTimer;
  int _generation = 0;

  @override
  QuranSearchState build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    return const QuranSearchState();
  }

  void setQuery(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      _generation++;
      state = const QuranSearchState();
      return;
    }
    state = QuranSearchState(
      query: query,
      response: state.response,
      isLoading: true,
    );
    _debounceTimer = Timer(debounce, () => _run(query));
  }

  /// Klavye arama aksiyonu: debounce beklemeden hemen arar.
  void submit() {
    _debounceTimer?.cancel();
    if (state.isActive) {
      unawaited(_run(state.query));
    }
  }

  void clear() => setQuery('');

  /// Sakin hata sonrası tekrar dene — yalnız arama yeniden çalışır.
  Future<void> retry() => _run(state.query);

  Future<void> _run(String query) async {
    final generation = ++_generation;
    state = QuranSearchState(
      query: query,
      response: state.response,
      isLoading: true,
    );
    final result = await ref.read(quranSearchRepositoryProvider).search(query);
    if (generation != _generation) {
      return; // eski sonuç yeni sorgunun durumunu EZMEZ
    }
    state = result.fold(
      onSuccess: (response) =>
          QuranSearchState(query: query, response: response),
      onFailure: (_) => QuranSearchState(query: query, failed: true),
    );
  }
}
