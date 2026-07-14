/**
 * Diyanet Kuran API istemcisi (TASK 039).
 *
 * Token yalnız Authorization başlığında kullanılır; HİÇBİR hata
 * mesajına, loga veya dönen değere yazılmaz. Hatalar paket bağımsız
 * [DiyanetUpstreamError] türlerine indirgenir.
 */

import { InvalidUpstreamResponseError } from "./contract";

export type UpstreamFailureKind = "timeout" | "http" | "network";

export class DiyanetUpstreamError extends Error {
  constructor(
    readonly kind: UpstreamFailureKind,
    readonly status?: number
  ) {
    // Mesajlar sabittir — istek/başlık içeriği taşımaz.
    super(
      kind === "timeout"
        ? "meal kaynağı zaman aşımına uğradı"
        : kind === "http"
          ? `meal kaynağı hata döndürdü (HTTP ${status ?? "?"})`
          : "meal kaynağına ulaşılamadı"
    );
    this.name = "DiyanetUpstreamError";
  }
}

export interface DiyanetClient {
  fetchChapter(chapterId: number): Promise<unknown>;
}

export interface DiyanetClientOptions {
  token: string;
  baseUrl?: string;
  timeoutMs?: number;
  fetchImpl?: typeof fetch;
}

function isAbortError(error: unknown): boolean {
  return (
    error instanceof Error &&
    (error.name === "AbortError" || error.name === "TimeoutError")
  );
}

export function createDiyanetClient(
  options: DiyanetClientOptions
): DiyanetClient {
  const {
    token,
    baseUrl = "https://api.diyanet.gov.tr",
    timeoutMs = 10_000,
    fetchImpl = fetch,
  } = options;

  return {
    async fetchChapter(chapterId: number): Promise<unknown> {
      const controller = new AbortController();
      const timer = setTimeout(() => controller.abort(), timeoutMs);
      try {
        let response: Response;
        try {
          response = await fetchImpl(
            `${baseUrl}/api/v1/chapters/${chapterId}`,
            {
              headers: {
                Authorization: `Bearer ${token}`,
                Accept: "application/json",
              },
              signal: controller.signal,
            }
          );
        } catch (error) {
          // Orijinal fetch hatası (URL/başlık içerebilir) DIŞARI TAŞINMAZ.
          throw new DiyanetUpstreamError(
            isAbortError(error) ? "timeout" : "network"
          );
        }
        if (!response.ok) {
          throw new DiyanetUpstreamError("http", response.status);
        }
        try {
          return await response.json();
        } catch {
          throw new InvalidUpstreamResponseError("yanıt JSON değil");
        }
      } finally {
        clearTimeout(timer);
      }
    },
  };
}
