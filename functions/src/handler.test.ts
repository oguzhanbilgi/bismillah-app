import { describe, expect, it } from "vitest";
import { HttpsError } from "firebase-functions/v2/https";
import { handleGetQuranChapterTranslation } from "./handler";
import { DiyanetClient, DiyanetUpstreamError } from "./diyanet";
import { TRANSLATION_SOURCE } from "./contract";

// Gerçek token TESTLERDE KULLANILMAZ — sahte değer sızıntı testi içindir.
const FAKE_TOKEN = "FAKE-TEST-TOKEN-123";

const auth = { uid: "anon-user" };

function clientReturning(payload: unknown): DiyanetClient {
  return { fetchChapter: async () => payload };
}

function clientThrowing(error: unknown): DiyanetClient {
  return {
    fetchChapter: async () => {
      throw error;
    },
  };
}

function validPayload(count: number): unknown {
  return {
    data: Array.from({ length: count }, (_, i) => ({
      verse_number: i + 1,
      translation: `Meal metni ${i + 1}`,
    })),
  };
}

async function expectHttpsError(
  promise: Promise<unknown>,
  code: string
): Promise<HttpsError> {
  try {
    await promise;
  } catch (error) {
    expect(error).toBeInstanceOf(HttpsError);
    expect((error as HttpsError).code).toBe(code);
    return error as HttpsError;
  }
  throw new Error(`HttpsError(${code}) bekleniyordu, hata fırlatılmadı`);
}

describe("handleGetQuranChapterTranslation", () => {
  it("geçerli chapterId için sözleşmeye uygun yanıt döner", async () => {
    const result = await handleGetQuranChapterTranslation(
      { auth, data: { chapterId: 1 } },
      clientReturning(validPayload(7))
    );
    expect(result.chapterId).toBe(1);
    expect(result.source).toBe(TRANSLATION_SOURCE);
    expect(result.verses).toHaveLength(7);
    expect(result.verses[0]).toEqual({
      verseKey: "1:1",
      verseNumber: 1,
      translationText: "Meal metni 1",
    });
    expect(result.verses[6].verseKey).toBe("1:7");
  });

  it.each([0, 115, -3, 2.5, "2", null, undefined])(
    "geçersiz chapterId reddedilir: %s",
    async (chapterId) => {
      await expectHttpsError(
        handleGetQuranChapterTranslation(
          { auth, data: { chapterId } },
          clientReturning(validPayload(3))
        ),
        "invalid-argument"
      );
    }
  );

  it("data eksikse invalid-argument", async () => {
    await expectHttpsError(
      handleGetQuranChapterTranslation(
        { auth },
        clientReturning(validPayload(3))
      ),
      "invalid-argument"
    );
  });

  it("auth yoksa unauthenticated (anonim auth kabul edilir)", async () => {
    await expectHttpsError(
      handleGetQuranChapterTranslation(
        { auth: null, data: { chapterId: 1 } },
        clientReturning(validPayload(3))
      ),
      "unauthenticated"
    );
    // Anonim Firebase kullanıcısı auth taşır — kabul.
    const result = await handleGetQuranChapterTranslation(
      { auth: { uid: "anonymous-uid" }, data: { chapterId: 1 } },
      clientReturning(validPayload(3))
    );
    expect(result.verses).toHaveLength(3);
  });

  it("alternatif alan adları eşlenir ve HTML düz metne çevrilir", async () => {
    const result = await handleGetQuranChapterTranslation(
      { auth, data: { chapterId: 2 } },
      clientReturning({
        data: {
          verses: [
            {
              ayetNumarasi: 1,
              meal: "<p>Elif, L&acirc;m, M&icirc;m yerine &quot;deneme&quot; &amp; <b>kalın</b></p>",
            },
          ],
        },
      })
    );
    expect(result.verses[0].translationText).toBe(
      'Elif, L&acirc;m, M&icirc;m yerine "deneme" & kalın'
    );
    expect(result.verses[0].verseKey).toBe("2:1");
  });

  it("birebir duplicate deterministik tekilleştirilir", async () => {
    const result = await handleGetQuranChapterTranslation(
      { auth, data: { chapterId: 1 } },
      clientReturning({
        data: [
          { verse_number: 1, translation: "Bir" },
          { verse_number: 1, translation: "Bir" },
          { verse_number: 2, translation: "İki" },
        ],
      })
    );
    expect(result.verses).toHaveLength(2);
  });

  it("çelişen duplicate internal hatasına dönüşür", async () => {
    await expectHttpsError(
      handleGetQuranChapterTranslation(
        { auth, data: { chapterId: 1 } },
        clientReturning({
          data: [
            { verse_number: 1, translation: "Bir" },
            { verse_number: 1, translation: "Farklı" },
          ],
        })
      ),
      "internal"
    );
  });

  it("boş translation reddedilir", async () => {
    await expectHttpsError(
      handleGetQuranChapterTranslation(
        { auth, data: { chapterId: 1 } },
        clientReturning({
          data: [{ verse_number: 1, translation: "<p>   </p>" }],
        })
      ),
      "internal"
    );
  });

  it("kesintisiz olmayan ayet numaraları reddedilir", async () => {
    await expectHttpsError(
      handleGetQuranChapterTranslation(
        { auth, data: { chapterId: 1 } },
        clientReturning({
          data: [
            { verse_number: 1, translation: "Bir" },
            { verse_number: 3, translation: "Üç" },
          ],
        })
      ),
      "internal"
    );
  });

  it("upstream timeout deadline-exceeded olur", async () => {
    await expectHttpsError(
      handleGetQuranChapterTranslation(
        { auth, data: { chapterId: 1 } },
        clientThrowing(new DiyanetUpstreamError("timeout"))
      ),
      "deadline-exceeded"
    );
  });

  it("upstream HTTP/ağ hatası unavailable olur", async () => {
    await expectHttpsError(
      handleGetQuranChapterTranslation(
        { auth, data: { chapterId: 1 } },
        clientThrowing(new DiyanetUpstreamError("http", 503))
      ),
      "unavailable"
    );
    await expectHttpsError(
      handleGetQuranChapterTranslation(
        { auth, data: { chapterId: 1 } },
        clientThrowing(new DiyanetUpstreamError("network"))
      ),
      "unavailable"
    );
  });

  it("bilinmeyen hata mesajındaki gizli değer istemciye SIZMAZ", async () => {
    const leakyError = new Error(
      `fetch failed: Authorization Bearer ${FAKE_TOKEN}`
    );
    const error = await expectHttpsError(
      handleGetQuranChapterTranslation(
        { auth, data: { chapterId: 1 } },
        clientThrowing(leakyError)
      ),
      "internal"
    );
    expect(error.message).not.toContain(FAKE_TOKEN);
    expect(error.message).not.toContain("Bearer");
  });
});
