import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/features/profile/application/profile_providers.dart';
import 'package:bismillah_app/features/profile/domain/support_contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Destek e-postasını açar; açılamazsa DÜRÜST fallback gösterir (ALPHA-R3A).
///
/// Başarısızlıkta sessiz kalınmaz ve sahte başarı bildirilmez: adres panoya
/// kopyalanır ve kullanıcıya ADRESİ İÇEREN bir mesaj gösterilir, böylece
/// e-posta istemcisi olmayan bir cihazda da iletişim yolu kalır.
///
/// Hesap, giriş veya ağ bağlantısı GEREKTİRMEZ.
Future<void> openSupportContact(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);

  final opened = await ref
      .read(supportContactServiceProvider)
      .openSupportEmail();
  if (opened) {
    return;
  }

  // Mesaj ÖNCE gösterilir: panoya kopyalama bir platform kanalıdır ve
  // askıda kalabilir/başarısız olabilir; bu, kullanıcının adresi görmesini
  // ENGELLEMEMELİDİR. Kopyalama yalnız kolaylıktır ve mesajda İDDİA EDİLMEZ.
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(
          '${l10n.supportEmailUnavailable} ${SupportContact.email}',
        ),
      ),
    );

  try {
    await Clipboard.setData(const ClipboardData(text: SupportContact.email));
  } on Object {
    // Yutulur: iletişim yolu mesajın kendisidir, pano değil.
  }
}
