/**
 * getQuranChapterTranslation iş mantığı (TASK 039) — onCall sarmalından
 * bağımsız, test edilebilir. Token bu katmana HİÇ girmez (client kapalı
 * kutu); hata mesajları sabit ve gizli bilgi içermez.
 */

import { HttpsError } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import {
  InvalidUpstreamResponseError,
  mapDiyanetChapterResponse,
  QuranChapterTranslation,
} from "./contract";
import { DiyanetClient, DiyanetUpstreamError } from "./diyanet";

/** Callable isteğinin bu handler'ın umursadığı kısmı (test edilebilirlik). */
export interface CallableLikeRequest {
  auth?: { uid: string } | null;
  data?: unknown;
}

function extractChapterId(data: unknown): number | null {
  if (typeof data !== "object" || data === null) {
    return null;
  }
  const value = (data as Record<string, unknown>).chapterId;
  if (
    typeof value !== "number" ||
    !Number.isInteger(value) ||
    value < 1 ||
    value > 114
  ) {
    return null;
  }
  return value;
}

export async function handleGetQuranChapterTranslation(
  request: CallableLikeRequest,
  client: DiyanetClient
): Promise<QuranChapterTranslation> {
  // Firebase Authentication zorunlu — ANONİM kullanıcı da auth taşır ve
  // kabul edilir; auth yoksa istek reddedilir.
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Oturum gerekli.");
  }

  const chapterId = extractChapterId(request.data);
  if (chapterId === null) {
    throw new HttpsError(
      "invalid-argument",
      "chapterId 1–114 arasında bir tam sayı olmalı."
    );
  }

  let payload: unknown;
  try {
    payload = await client.fetchChapter(chapterId);
  } catch (error) {
    if (error instanceof DiyanetUpstreamError) {
      // Yalnız tür/durum loglanır — token, başlık veya yanıt gövdesi ASLA.
      logger.warn("diyanet upstream failure", {
        chapterId,
        kind: error.kind,
        status: error.status ?? null,
      });
      throw new HttpsError(
        error.kind === "timeout" ? "deadline-exceeded" : "unavailable",
        error.kind === "timeout"
          ? "Meal kaynağı zaman aşımına uğradı."
          : "Meal kaynağına şu an ulaşılamıyor."
      );
    }
    if (error instanceof InvalidUpstreamResponseError) {
      logger.warn("diyanet invalid response", { chapterId });
      throw new HttpsError("internal", "Meal kaynağı yanıtı doğrulanamadı.");
    }
    // Bilinmeyen hata: orijinal mesaj (gizli bilgi içerebilir) istemciye
    // ve loga TAŞINMAZ.
    logger.error("diyanet unexpected failure", { chapterId });
    throw new HttpsError("internal", "Beklenmeyen bir hata oluştu.");
  }

  try {
    return mapDiyanetChapterResponse(chapterId, payload);
  } catch (error) {
    logger.warn("diyanet response mapping failed", {
      chapterId,
      reason:
        error instanceof InvalidUpstreamResponseError
          ? error.message // sabit doğrulama mesajı — içerik/gizli bilgi yok
          : "unknown",
    });
    throw new HttpsError("internal", "Meal kaynağı yanıtı doğrulanamadı.");
  }
}
