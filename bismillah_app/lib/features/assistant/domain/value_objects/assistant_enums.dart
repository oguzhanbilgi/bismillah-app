/// Asistan katmanı enum'ları (10_DATA_MODEL §4 `AssistantMessage`).
library;

/// Mesaj rolü. Sistem/proxy yönergeleri istemci geçmişine YAZILMAZ —
/// bu yüzden yalnız iki rol vardır.
enum AssistantRole { user, assistant }
