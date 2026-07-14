/**
 * Bismillah Cloud Functions girişi (TASK 039).
 *
 * Güvenlik: secret yalnız bu function'a bağlanır; CORS'lu açık HTTP
 * endpoint YOK (callable). Kullanıcı UID'si upstream'e GÖNDERİLMEZ;
 * meal içeriği analytics'e gitmez.
 */

import { defineSecret } from "firebase-functions/params";
import { onCall } from "firebase-functions/v2/https";
import { createDiyanetClient } from "./diyanet";
import { handleGetQuranChapterTranslation } from "./handler";

/** Diyanet Kuran API tokenı — YALNIZ Secret Manager'da yaşar. */
const dibKuranApiToken = defineSecret("DIB_KURAN_API_TOKEN");

export const getQuranChapterTranslation = onCall(
  {
    region: "europe-west1",
    secrets: [dibKuranApiToken],
    // Maliyet/istismar sınırı: proxy hafiftir, düşük tavan yeterli.
    maxInstances: 5,
    timeoutSeconds: 30,
    memory: "256MiB",
    // TODO(App Check): Native App Check kurulumu tamamlandığında
    // `enforceAppCheck: true` etkinleştirilecek (TASK 039 kapsamı dışı);
    // o zamana kadar koruma Firebase Authentication zorunluluğudur.
  },
  (request) =>
    handleGetQuranChapterTranslation(
      request,
      createDiyanetClient({ token: dibKuranApiToken.value() })
    )
);
