import 'package:bismillah_app/features/assistant/domain/entities/assistant_query.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_response.dart';

/// Bismillah Asistanı cevap sözleşmesi (TASK 059 §6).
///
/// UI'dan ve sağlayıcıdan BAĞIMSIZDIR: ilk implementasyon tamamen yerel ve
/// kaynağa dayalıdır. Gelecekte uzak bir AI sağlayıcısı EKLENEBİLECEK
/// biçimde sözleşme temiz tutulur — ancak bu görevde sahte/boş remote
/// provider EKLENMEZ.
///
/// Cevap hiçbir koşulda istisna fırlatmaz: hata hâlinde bile güvenli bir
/// "doğrulanmış kaynak yok" cevabı döner (asistan çökmez, uydurmaz).
abstract interface class BismillahAssistantRepository {
  Future<AssistantResponse> answer(AssistantQuery query);
}
