/**
 * Paket bağımsız meal sözleşmesi (TASK 039).
 *
 * Mobil uygulamaya YALNIZ gerekli alanlar döner; Arapça ayet metni
 * DÖNMEZ — istemci mevcut doğrulanmış Tanzil asset'ini kullanır.
 * Bu dosyada AI çevirisi veya fallback meal ÜRETİLMEZ.
 */

export const TRANSLATION_SOURCE = "Diyanet İşleri Başkanlığı Meali";

export interface QuranTranslationVerse {
  verseKey: string;
  verseNumber: number;
  translationText: string;
}

export interface QuranChapterTranslation {
  chapterId: number;
  source: typeof TRANSLATION_SOURCE;
  verses: QuranTranslationVerse[];
}

/**
 * Upstream yanıt doğrulama hatası. Mesajlar token/başlık/ham yanıt
 * İÇERMEZ — log ve istemciye sızacak hiçbir gizli bilgi taşımaz.
 */
export class InvalidUpstreamResponseError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "InvalidUpstreamResponseError";
  }
}

/** Ayet listesini taşıyabilecek bilinen zarf alanları (tolerant). */
function extractVerseItems(payload: unknown): Record<string, unknown>[] {
  if (typeof payload !== "object" || payload === null) {
    throw new InvalidUpstreamResponseError("yanıt gövdesi nesne değil");
  }
  const root = payload as Record<string, unknown>;
  const data =
    typeof root.data === "object" && root.data !== null
      ? (root.data as Record<string, unknown>)
      : undefined;
  const candidates: unknown[] = [
    root.verses,
    root.ayetler,
    root.data,
    data?.verses,
    data?.ayetler,
  ];
  for (const candidate of candidates) {
    if (Array.isArray(candidate) && candidate.length > 0) {
      return candidate.map((item) => {
        if (typeof item !== "object" || item === null) {
          throw new InvalidUpstreamResponseError("ayet kaydı nesne değil");
        }
        return item as Record<string, unknown>;
      });
    }
  }
  throw new InvalidUpstreamResponseError("ayet listesi bulunamadı");
}

const VERSE_NUMBER_FIELDS = [
  "verseNumber",
  "verse_number",
  "ayetNumarasi",
  "ayet_numarasi",
  "ayetNo",
  "ayet_no",
  "number",
];

const TRANSLATION_TEXT_FIELDS = [
  "translationText",
  "translation_text",
  "translation",
  "meal",
  "mealText",
  "meal_text",
  "ayetMeali",
  "ayet_meali",
  // "text" en sonda: bazı API'lerde Arapça metni taşıyabilir; yalnız
  // diğer alanlar yoksa denenir.
  "text",
];

function extractVerseNumber(item: Record<string, unknown>): number {
  for (const field of VERSE_NUMBER_FIELDS) {
    const value = item[field];
    if (typeof value === "number" && Number.isInteger(value)) {
      return value;
    }
    if (typeof value === "string" && /^\d+$/.test(value.trim())) {
      return Number.parseInt(value.trim(), 10);
    }
  }
  throw new InvalidUpstreamResponseError("ayet numarası alanı bulunamadı");
}

function extractTranslationText(item: Record<string, unknown>): string {
  for (const field of TRANSLATION_TEXT_FIELDS) {
    const value = item[field];
    if (typeof value === "string" && value.trim().length > 0) {
      return value;
    }
  }
  throw new InvalidUpstreamResponseError("meal metni alanı bulunamadı");
}

/**
 * Basit ve güvenli HTML → düz metin dönüşümü: etiketler atılır, yaygın
 * entity'ler çözülür. Meal ANLAMI yeniden yazılmaz.
 */
export function htmlToPlainText(value: string): string {
  return value
    .replace(/<br\s*\/?>/gi, "\n")
    .replace(/<[^>]+>/g, "")
    .replace(/&nbsp;/gi, " ")
    .replace(/&amp;/gi, "&")
    .replace(/&lt;/gi, "<")
    .replace(/&gt;/gi, ">")
    .replace(/&quot;/gi, '"')
    .replace(/&#39;|&apos;/gi, "'")
    .replace(/[ \t]+/g, " ")
    .trim();
}

/**
 * Diyanet yanıtını doğrulayıp sözleşmeye eşler.
 *
 * Kurallar: pozitif ve 1'den kesintisiz sıralı ayet numaraları; boş meal
 * reddedilir; birebir aynı duplicate deterministik tekilleştirilir,
 * çelişen duplicate reddedilir. verseKey her zaman burada üretilir.
 */
export function mapDiyanetChapterResponse(
  chapterId: number,
  payload: unknown
): QuranChapterTranslation {
  const items = extractVerseItems(payload);
  const byNumber = new Map<number, string>();
  for (const item of items) {
    const verseNumber = extractVerseNumber(item);
    if (verseNumber < 1) {
      throw new InvalidUpstreamResponseError("ayet numarası pozitif değil");
    }
    const text = htmlToPlainText(extractTranslationText(item));
    if (text.length === 0) {
      throw new InvalidUpstreamResponseError("boş meal metni");
    }
    const existing = byNumber.get(verseNumber);
    if (existing !== undefined) {
      if (existing !== text) {
        throw new InvalidUpstreamResponseError("çelişen duplicate ayet");
      }
      continue; // birebir duplicate — ilk kayıt korunur
    }
    byNumber.set(verseNumber, text);
  }

  const verses: QuranTranslationVerse[] = [...byNumber.entries()]
    .sort((a, b) => a[0] - b[0])
    .map(([verseNumber, translationText]) => ({
      verseKey: `${chapterId}:${verseNumber}`,
      verseNumber,
      translationText,
    }));
  verses.forEach((verse, index) => {
    if (verse.verseNumber !== index + 1) {
      throw new InvalidUpstreamResponseError(
        "ayet numaraları 1'den kesintisiz değil"
      );
    }
  });

  return { chapterId, source: TRANSLATION_SOURCE, verses };
}
