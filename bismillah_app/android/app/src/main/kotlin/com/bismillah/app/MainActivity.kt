package com.bismillah.app

import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

// TASK 045: audio_service, Flutter engine'ini media session'a bağlamak
// için activity tabanının AudioServiceActivity olmasını ister. Önceki
// FlutterActivity'nin özel davranışı yoktu; FragmentActivity gerektiren
// eklenti de bulunmadığından AudioServiceFragmentActivity GEREKMEZ.
class MainActivity : AudioServiceActivity() {

    // TASK 095: kıble pusulası için EventChannel. Yaşam döngüsüne
    // bağlanır — arka planda sensör açık bırakılmaz.
    private var compassHandler: QiblaCompassStreamHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val handler = QiblaCompassStreamHandler(applicationContext)
        compassHandler = handler
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            QiblaCompassStreamHandler.CHANNEL_NAME,
        ).setStreamHandler(handler)
    }

    override fun onPause() {
        compassHandler?.pause()
        super.onPause()
    }

    override fun onResume() {
        super.onResume()
        compassHandler?.resume()
    }

    override fun onDestroy() {
        compassHandler?.pause()
        compassHandler = null
        super.onDestroy()
    }
}
