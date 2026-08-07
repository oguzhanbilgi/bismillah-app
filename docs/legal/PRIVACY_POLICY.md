# Bismillah — Privacy Policy / Gizlilik Politikası / سياسة الخصوصية

**Status:** canonical source file for the Android alpha (ALPHA-R3A).
**Last updated:** 2026-08-07 · **App stage:** alpha (active development)
**Support contact:** bismillahappsupport@gmail.com

This file is the single canonical privacy policy for the Bismillah app. It is
written **strictly from the app's actual current behaviour**. When behaviour
changes, this file must change in the same task.

The Turkish text is **canonical**; the English and Arabic texts are faithful
translations of it. The in-app policy screen renders the same content in all
three languages.

**Publication note:** this document is intended to be published at a public
HTTPS URL for Google Play. That URL is **not yet decided** and is deliberately
not written here.

---

## 1. Türkçe (kanonik)

### Bismillah Gizlilik Politikası

**Son güncelleme:** 7 Ağustos 2026 · **Sürüm:** Android alpha

#### Kısaca

Bismillah **önce-cihaz (local-first)** çalışır. Planın, ilerlemen, tercihlerin
ve Asistan geçmişin öncelikle **kendi cihazında** saklanır. Uygulamanın
çalışması için hesap açman veya giriş yapman gerekmez.

Bu, "hiçbir veri cihazından çıkmaz" demek değildir. Kur'an sesi internetten
akıtılır, resmî kaynak bağlantıları tarayıcıda açılır ve uygulama Firebase
anonim kimlik doğrulaması için Google servisleriyle iletişim kurabilir. Aşağıda
her biri ayrı ayrı açıklanmıştır.

#### Cihazında saklananlar

- Onboarding tercihlerin ve türetilen plan profilin
- 30 günlük plan kayıtların ve görev tamamlama durumların
- Namaz takip geçmişin
- Kur'an okuma konumun, yer imlerin ve tercihlerin
- Öğrenme kayıtların (kaydedilen, tamamlanan, son okunan)
- Dil, hesaplama yöntemi ve hatırlatıcı tercihlerin
- Asistan sohbet geçmişin (en fazla son 20 mesaj)

Bunlar cihazının uygulama deposunda tutulur.

#### Asistan ve hassas sorular

Bismillah Asistanı **tamamen cihaz üzerinde** çalışır. Soruların **hiçbir dış
üretken yapay zekâ servisine gönderilmez**; cevaplar uygulamayla birlikte gelen,
kaynağı doğrulanmış içerikten üretilir.

Hüküm (helal/haram), kişisel durum ve ibadet kuralı niteliğindeki hassas
sorular ile bunlara verilen cevaplar **cihazda saklanmaz**. Bu ayrım metin
üzerinde anahtar kelimeye dayalı yapılır; bu yüzden zaman zaman zararsız bir
soru da saklanmayan gruba girebilir. Asistan geçmişini istediğin an uygulama
içinden silebilirsin.

#### Bulut yedekleme ve hesap

Şu anda **etkin bir bulut yedekleme veya hesap senkronizasyonu yoktur.**
Verilerin başka bir cihaza taşınmaz.

Bunun doğrudan sonucu: **uygulamayı kaldırırsan veya uygulama verilerini
temizlersen yerel ilerlemen kalıcı olarak silinir** ve geri getirilemez.

#### İzinler

- **Konum (yalnız uygulama açıkken):** namaz vakitlerini ve kıble yönünü
  cihazında hesaplamak için kullanılır. Konumun bir sunucuya gönderilmez ve
  arka planda toplanmaz. İzni vermezsen uygulama sakin bir "konum yok" durumu
  gösterir.
- **Bildirimler:** namaz hatırlatıcıları için kullanılır. Hatırlatıcılar
  cihazda planlanır; içerikleri bir sunucuya gitmez.
- **Tam zamanlı alarm (exact alarm):** Android sürümüne göre hatırlatıcıların
  tam vaktinde gelmesi için gerekebilir. İzin yoksa uygulama daha esnek
  (yaklaşık) zamanlamaya döner ve bunu sana açıkça söyler.

#### Ağ kullanılan yerler

- **Kur'an sesi:** kayıtlar **MP3Quran.net** üzerinden akıtılır; ses dosyaları
  uygulamayla birlikte gelmez. Bir kaydı çaldığında cihazın IP adresi teknik
  olarak o servise ulaşır.
- **Kaynak bağlantıları:** Tanzil, QuranEnc, MP3Quran ve resmî Diyanet
  bağlantılarını açtığında sistem tarayıcın ilgili siteye bağlanır. Bu siteler
  kendi gizlilik politikalarına tabidir.
- **Firebase:** uygulama, Firebase **anonim kimlik doğrulaması** başlatır; bu
  sırada cihaz Google servisleriyle iletişim kurabilir ve cihaza özel anonim
  bir kimlik oluşturulur. Bu kimlik adına, e-postana veya rehberine bağlı
  değildir. Uygulama paketinde standart Firebase istemci yapılandırması
  bulunur; bu bir sır değildir.

#### Reklam, ölçümleme ve ödeme

- **Hiçbir reklam SDK'sı entegre değildir.**
- **Etkin bir analitik veya çökme raporlama arka ucu yoktur.** Uygulamadaki
  analitik arayüzü hiçbir şey göndermez.
- **Etkin bir ödeme veya abonelik sistemi yoktur.** Alpha sürümünde satın alma
  yapılamaz.

#### Çocuklar

Bismillah çocuklara yönelik bir ürün olarak tasarlanmamıştır ve **çocuklara
özel bir veri toplama uygulaması yürütmez.** Yaşa dayalı profilleme yapılmaz.

#### Kontrolün sende

Uygulama içinden öğrenme verilerini veya tüm yerel verilerini sıfırlayabilir,
Asistan geçmişini silebilirsin. Cihaz ayarlarından uygulama verilerini
temizlemek de aynı sonucu verir.

#### İletişim

Soru, geri bildirim veya gizlilik talebi için: **bismillahappsupport@gmail.com**

---

## 2. English

### Bismillah Privacy Policy

**Last updated:** 7 August 2026 · **Version:** Android alpha

#### In short

Bismillah is **local-first**. Your plan, progress, preferences and Assistant
history are stored primarily **on your own device**. You do not need an account
or a login to use the app.

This does not mean "no data ever leaves the device". Quran audio is streamed
over the internet, official source links open in your browser, and the app may
contact Google services for Firebase anonymous authentication. Each of these is
explained below.

#### Stored on your device

- Your onboarding preferences and the plan profile derived from them
- Your 30-day plan records and task completion state
- Your prayer tracking history
- Your Quran reading position, bookmarks and preferences
- Your learning records (saved, completed, last read)
- Language, calculation-method and reminder preferences
- Your Assistant conversation history (at most the last 20 messages)

These are kept in your device's app storage.

#### Assistant and sensitive questions

The Bismillah Assistant runs **entirely on your device**. Your questions are
**never sent to any external generative-AI service**; answers are produced from
source-verified content shipped inside the app.

Sensitive questions — rulings (halal/haram), personal cases and worship-rule
questions — and their answers are **not stored on the device**. This distinction
is made with keyword matching on the text, so occasionally a harmless question
may also fall into the not-stored group. You can delete your Assistant history
from inside the app at any time.

#### Cloud backup and accounts

There is currently **no active cloud backup and no account sync.** Your data is
not carried to another device.

The direct consequence: **if you uninstall the app or clear its app data, your
local progress is permanently deleted** and cannot be recovered.

#### Permissions

- **Location (foreground only):** used to compute prayer times and the Qibla
  direction on your device. Your location is not sent to a server and is not
  collected in the background. If you decline, the app shows a calm "no
  location" state.
- **Notifications:** used for prayer reminders. Reminders are scheduled on the
  device; their contents do not go to a server.
- **Exact alarm:** depending on your Android version this may be needed for
  reminders to arrive exactly on time. Without it the app falls back to
  inexact scheduling and tells you so plainly.

#### Where the network is used

- **Quran audio:** recitations are streamed from **MP3Quran.net**; audio files
  are not bundled with the app. When you play a recitation, your device's IP
  address technically reaches that service.
- **Source links:** when you open Tanzil, QuranEnc, MP3Quran or official
  Diyanet links, your system browser connects to that site. Those sites are
  governed by their own privacy policies.
- **Firebase:** the app starts Firebase **anonymous authentication**; during
  this the device may contact Google services and a device-specific anonymous
  identifier is created. That identifier is not tied to your name, e-mail or
  contacts. The app package contains standard Firebase client configuration;
  this is not a secret.

#### Advertising, measurement and payments

- **No advertising SDK is integrated.**
- **No analytics or crash-reporting backend is active.** The app's analytics
  interface sends nothing.
- **No payment or subscription system is active.** No purchase can be made in
  the alpha.

#### Children

Bismillah is not designed as a children's product and **does not run any
children-specific data collection.** No age-based profiling is performed.

#### You stay in control

From inside the app you can reset your learning data or all your local data,
and delete your Assistant history. Clearing app data from device settings has
the same effect.

#### Contact

For questions, feedback or privacy requests: **bismillahappsupport@gmail.com**

---

## 3. العربية

### سياسة خصوصية Bismillah

**آخر تحديث:** ٧ أغسطس ٢٠٢٦ · **الإصدار:** ألفا لأندرويد

#### باختصار

يعمل Bismillah **محليًا أولًا**. تُحفظ خطتك وتقدّمك وتفضيلاتك وسجل المساعد
بصورة أساسية **على جهازك أنت**. ولا تحتاج إلى حساب أو تسجيل دخول لاستخدام
التطبيق.

هذا لا يعني أنّ "أيّ بيانات لا تغادر الجهاز أبدًا". فصوت القرآن يُبثّ عبر
الإنترنت، وروابط المصادر الرسمية تُفتح في المتصفّح، وقد يتّصل التطبيق بخدمات
Google من أجل مصادقة Firebase المجهولة. وكلّ ذلك موضّح أدناه.

#### ما يُحفظ على جهازك

- تفضيلات التهيئة وملفّ الخطة المشتقّ منها
- سجلات خطة الثلاثين يومًا وحالة إتمام المهامّ
- سجل متابعة الصلاة
- موضع القراءة في القرآن والإشارات المرجعية والتفضيلات
- سجلات التعلّم (المحفوظ، المكتمل، آخر ما قُرئ)
- تفضيلات اللغة وطريقة الحساب والتذكيرات
- سجل محادثة المساعد (عشرون رسالة كحدّ أقصى)

تُحفظ هذه البيانات في مساحة تخزين التطبيق على جهازك.

#### المساعد والأسئلة الحسّاسة

يعمل مساعد Bismillah **على جهازك بالكامل**. ولا تُرسل أسئلتك **إلى أيّ خدمة
ذكاء اصطناعي توليدي خارجية**؛ بل تُبنى الإجابات من محتوى مُتحقَّق من مصدره
ومضمَّن داخل التطبيق.

أمّا الأسئلة الحسّاسة — أسئلة الحكم (حلال/حرام) والحالات الشخصية وأحكام
العبادة — وإجاباتها فإنّها **لا تُحفظ على الجهاز**. ويجري هذا التمييز بمطابقة
كلمات مفتاحية في النصّ، ولذلك قد يقع أحيانًا سؤال غير حسّاس ضمن المجموعة التي
لا تُحفظ. ويمكنك حذف سجل المساعد من داخل التطبيق في أيّ وقت.

#### النسخ الاحتياطي السحابي والحسابات

لا يوجد حاليًا **نسخ احتياطي سحابي فعّال ولا مزامنة حساب.** ولا تُنقل بياناتك
إلى جهاز آخر.

والنتيجة المباشرة: **إذا أزلت التطبيق أو مسحت بياناته، يُحذف تقدّمك المحلي
نهائيًا** ولا يمكن استرجاعه.

#### الأذونات

- **الموقع (أثناء استخدام التطبيق فقط):** يُستخدم لحساب أوقات الصلاة واتجاه
  القبلة على جهازك. ولا يُرسل موقعك إلى خادم ولا يُجمع في الخلفية. وإن رفضت
  الإذن يعرض التطبيق حالة هادئة تفيد بعدم توفّر الموقع.
- **الإشعارات:** تُستخدم لتذكيرات الصلاة. وتُجدوَل التذكيرات على الجهاز ولا
  يذهب محتواها إلى خادم.
- **المنبّه الدقيق:** قد يلزم بحسب إصدار أندرويد كي تصل التذكيرات في وقتها
  تمامًا. وبدونه يتحوّل التطبيق إلى جدولة تقريبية ويوضّح لك ذلك صراحةً.

#### مواضع استخدام الشبكة

- **صوت القرآن:** تُبثّ التلاوات من **MP3Quran.net**، وملفات الصوت غير مضمّنة
  في التطبيق. وعند تشغيل تلاوة يصل عنوان IP الخاصّ بجهازك تقنيًا إلى تلك
  الخدمة.
- **روابط المصادر:** عند فتح روابط Tanzil أو QuranEnc أو MP3Quran أو روابط
  ديانت الرسمية يتّصل متصفّح النظام بذلك الموقع، وتخضع تلك المواقع لسياسات
  الخصوصية الخاصّة بها.
- **Firebase:** يبدأ التطبيق **مصادقة Firebase المجهولة**، وقد يتّصل الجهاز
  خلالها بخدمات Google ويُنشأ معرّف مجهول خاصّ بالجهاز. وهذا المعرّف غير مرتبط
  باسمك أو بريدك أو جهات اتصالك. ويحتوي التطبيق على إعدادات عميل Firebase
  القياسية، وهي ليست سرًّا.

#### الإعلانات والقياس والمدفوعات

- **لا توجد أيّ حزمة إعلانات مدمجة.**
- **لا يوجد خادم تحليلات أو تقارير أعطال فعّال.** وواجهة التحليلات في التطبيق
  لا ترسل شيئًا.
- **لا يوجد نظام دفع أو اشتراك فعّال.** ولا يمكن إجراء أيّ شراء في نسخة ألفا.

#### الأطفال

لم يُصمَّم Bismillah منتجًا موجَّهًا للأطفال، و**لا يُجري أيّ جمع بيانات خاصّ
بالأطفال.** ولا تُجرى أيّ تصنيفات قائمة على العمر.

#### التحكّم بيدك

يمكنك من داخل التطبيق إعادة تعيين بيانات التعلّم أو جميع بياناتك المحلية، وحذف
سجل المساعد. ومسح بيانات التطبيق من إعدادات الجهاز يؤدّي إلى النتيجة نفسها.

#### التواصل

للأسئلة أو الملاحظات أو طلبات الخصوصية: **bismillahappsupport@gmail.com**
