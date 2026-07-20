/// Kullanıcının asistana sorduğu doğal dil sorgusu (TASK 059 §5).
final class AssistantQuery {
  const AssistantQuery({
    required this.id,
    required this.text,
    required this.locale,
    required this.createdAt,
  });

  final String id;
  final String text;

  /// Aktif uygulama dili ('tr' | 'en' | 'ar') — retrieval bu dildeki
  /// yayınlanmış içerikte yapılır.
  final String locale;

  final DateTime createdAt;
}
