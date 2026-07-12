/// Bildirim izni durumu — paket-bağımsız (flutter_local_notifications
/// tiplerinden bağımsız). `permanentlyDenied` yalnız sistem ayarlarından
/// açılabilir (yeniden istenemez).
enum NotificationPermissionStatus { granted, denied, permanentlyDenied }
