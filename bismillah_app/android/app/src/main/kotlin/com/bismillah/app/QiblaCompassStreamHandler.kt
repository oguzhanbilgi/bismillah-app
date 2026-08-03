package com.bismillah.app

import android.content.Context
import android.hardware.GeomagneticField
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.plugin.common.EventChannel

/**
 * Kıble ekranı için yön (pusula) akışı — TASK 095.
 *
 * Yeni bir pusula EKLENTİSİ eklenmedi; Android'in kendi `SensorManager`
 * API'si kullanılır. `TYPE_ROTATION_VECTOR` ivmeölçer + manyetometre
 * (varsa jiroskop) füzyonudur, ham manyetometreden belirgin biçimde
 * kararlıdır.
 *
 * Yayınlanan yön GERÇEK KUZEY'e görelidir: `getOrientation` manyetik
 * kuzeye göre azimut verir, üzerine konumun manyetik sapması eklenir.
 * Sapma hesaplanamazsa `trueNorth` alanı `false` gönderilir ve Dart
 * tarafı okumayı güvenilmez sayar — manyetik yön, gerçek yönmüş gibi
 * SUNULMAZ.
 *
 * Gizlilik: konum yalnız sapma hesabı için parametre olarak alınır;
 * saklanmaz, loglanmaz, hiçbir yere gönderilmez. Arka planda çalışmaz —
 * Dart aboneliği iptal ettiğinde ve uygulama arka plana geçtiğinde
 * dinleyici kaydı kaldırılır.
 */
class QiblaCompassStreamHandler(
    private val context: Context,
) : EventChannel.StreamHandler, SensorEventListener {

    companion object {
        const val CHANNEL_NAME = "com.bismillah.app/qibla_compass"
    }

    private val sensorManager: SensorManager? =
        context.getSystemService(Context.SENSOR_SERVICE) as? SensorManager

    private var events: EventChannel.EventSink? = null
    private var sensor: Sensor? = null
    private var declination: Float? = null
    private var registered = false

    private val rotationMatrix = FloatArray(9)
    private val orientation = FloatArray(3)

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
        events = eventSink
        declination = declinationFor(arguments)

        val manager = sensorManager
        // Füzyon sensörü yoksa jeomanyetik varyantına düşülür; o da yoksa
        // cihazda kullanılabilir pusula yok demektir.
        val available = manager?.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
            ?: manager?.getDefaultSensor(Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR)
        if (manager == null || available == null) {
            eventSink?.success(mapOf("type" to "unsupported"))
            eventSink?.endOfStream()
            return
        }
        sensor = available
        register()
    }

    override fun onCancel(arguments: Any?) {
        unregister()
        events = null
        sensor = null
        declination = null
    }

    /** Uygulama arka plana geçtiğinde sensör açık bırakılmaz. */
    fun pause() = unregister()

    /** Ön plana dönüldüğünde, akış hâlâ açıksa dinleme sürdürülür. */
    fun resume() {
        if (events != null && sensor != null) {
            register()
        }
    }

    private fun register() {
        val manager = sensorManager ?: return
        val target = sensor ?: return
        if (registered) return
        registered = manager.registerListener(
            this,
            target,
            SensorManager.SENSOR_DELAY_UI,
        )
    }

    private fun unregister() {
        if (!registered) return
        sensorManager?.unregisterListener(this)
        registered = false
    }

    /**
     * Konumun manyetik sapması (derece). Konum gelmediyse veya hesap
     * başarısızsa `null` döner ve okuma gerçek kuzeye göre işaretlenmez.
     */
    private fun declinationFor(arguments: Any?): Float? {
        val map = arguments as? Map<*, *> ?: return null
        val latitude = (map["latitude"] as? Number)?.toDouble() ?: return null
        val longitude = (map["longitude"] as? Number)?.toDouble() ?: return null
        return try {
            GeomagneticField(
                latitude.toFloat(),
                longitude.toFloat(),
                0f,
                System.currentTimeMillis(),
            ).declination
        } catch (error: IllegalArgumentException) {
            null
        }
    }

    override fun onSensorChanged(event: SensorEvent?) {
        val sink = events ?: return
        val values = event?.values ?: return
        val correction = declination

        SensorManager.getRotationMatrixFromVector(rotationMatrix, values)
        SensorManager.getOrientation(rotationMatrix, orientation)

        // orientation[0] = manyetik kuzeye göre azimut (radyan).
        // Not: cihazın YERE PARALEL tutulduğu varsayılır — ekrandaki
        // rehber de tam olarak bunu söyler.
        val magnetic = Math.toDegrees(orientation[0].toDouble())
        val heading = magnetic + (correction?.toDouble() ?: 0.0)
        val normalized = ((heading % 360) + 360) % 360

        sink.success(
            mapOf(
                "type" to "heading",
                "headingDegrees" to normalized,
                "accuracy" to event.accuracy,
                "trueNorth" to (correction != null),
            ),
        )
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // Doğruluk her olayla birlikte zaten gönderiliyor; burada ek bir
        // yayın yapılmaz (gereksiz kare üretmemek için).
    }
}
