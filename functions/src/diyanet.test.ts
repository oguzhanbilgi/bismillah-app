import { describe, expect, it } from "vitest";
import { createDiyanetClient, DiyanetUpstreamError } from "./diyanet";
import { InvalidUpstreamResponseError } from "./contract";

// Gerçek token TESTLERDE KULLANILMAZ.
const FAKE_TOKEN = "FAKE-TEST-TOKEN-456";

function jsonResponse(body: unknown, ok = true, status = 200): Response {
  return {
    ok,
    status,
    json: async () => body,
  } as unknown as Response;
}

describe("createDiyanetClient", () => {
  it("doğru endpoint'i Bearer başlığıyla çağırır ve JSON döner", async () => {
    let capturedUrl = "";
    let capturedAuth = "";
    const client = createDiyanetClient({
      token: FAKE_TOKEN,
      fetchImpl: (async (url: unknown, init?: RequestInit) => {
        capturedUrl = String(url);
        capturedAuth =
          (init?.headers as Record<string, string>).Authorization ?? "";
        return jsonResponse({ data: [] });
      }) as typeof fetch,
    });

    const payload = await client.fetchChapter(2);
    expect(capturedUrl).toBe("https://api.diyanet.gov.tr/api/v1/chapters/2");
    expect(capturedAuth).toBe(`Bearer ${FAKE_TOKEN}`);
    expect(payload).toEqual({ data: [] });
  });

  it("HTTP hatası tokensız DiyanetUpstreamError üretir", async () => {
    const client = createDiyanetClient({
      token: FAKE_TOKEN,
      fetchImpl: (async () => jsonResponse(null, false, 503)) as typeof fetch,
    });
    const error = await client.fetchChapter(1).catch((e) => e as Error);
    expect(error).toBeInstanceOf(DiyanetUpstreamError);
    expect((error as DiyanetUpstreamError).kind).toBe("http");
    expect((error as DiyanetUpstreamError).status).toBe(503);
    expect(error.message).not.toContain(FAKE_TOKEN);
  });

  it("ağ hatası orijinal mesajı (URL/başlık) DIŞARI taşımaz", async () => {
    const client = createDiyanetClient({
      token: FAKE_TOKEN,
      fetchImpl: (async () => {
        throw new Error(`connect failed Bearer ${FAKE_TOKEN}`);
      }) as typeof fetch,
    });
    const error = await client.fetchChapter(1).catch((e) => e as Error);
    expect(error).toBeInstanceOf(DiyanetUpstreamError);
    expect((error as DiyanetUpstreamError).kind).toBe("network");
    expect(error.message).not.toContain(FAKE_TOKEN);
    expect(error.message).not.toContain("Bearer");
  });

  it("timeout AbortError'ı timeout türüne dönüşür", async () => {
    const client = createDiyanetClient({
      token: FAKE_TOKEN,
      timeoutMs: 5,
      fetchImpl: ((_url: unknown, init?: RequestInit) =>
        new Promise((_resolve, reject) => {
          init?.signal?.addEventListener("abort", () => {
            reject(Object.assign(new Error("aborted"), { name: "AbortError" }));
          });
        })) as typeof fetch,
    });
    const error = await client.fetchChapter(1).catch((e) => e as Error);
    expect(error).toBeInstanceOf(DiyanetUpstreamError);
    expect((error as DiyanetUpstreamError).kind).toBe("timeout");
    expect(error.message).not.toContain(FAKE_TOKEN);
  });

  it("JSON olmayan gövde doğrulama hatası üretir", async () => {
    const client = createDiyanetClient({
      token: FAKE_TOKEN,
      fetchImpl: (async () =>
        ({
          ok: true,
          status: 200,
          json: async () => {
            throw new SyntaxError("Unexpected token");
          },
        }) as unknown as Response) as typeof fetch,
    });
    const error = await client.fetchChapter(1).catch((e) => e as Error);
    expect(error).toBeInstanceOf(InvalidUpstreamResponseError);
    expect(error.message).not.toContain(FAKE_TOKEN);
  });
});
