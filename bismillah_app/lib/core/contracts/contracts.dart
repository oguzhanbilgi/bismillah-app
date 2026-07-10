import 'package:bismillah_app/core/result/result.dart';

/// Lokal veri sözleşmelerinin ortak imza tipleri (06_FLUTTER_ARCH §22).
///
/// Repository interface'leri istisna fırlatmak yerine [Result] döner;
/// watch akışları Isar-first mimaride hata değil son bilinen durumu
/// taşır (hata durumu ayrı okuma yoluyla raporlanır).
library;

typedef ResultFuture<T> = Future<Result<T>>;
typedef ResultStream<T> = Stream<Result<T>>;
