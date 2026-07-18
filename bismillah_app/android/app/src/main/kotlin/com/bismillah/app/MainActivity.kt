package com.bismillah.app

import com.ryanheise.audioservice.AudioServiceActivity

// TASK 045: audio_service, Flutter engine'ini media session'a bağlamak
// için activity tabanının AudioServiceActivity olmasını ister. Önceki
// FlutterActivity'nin özel davranışı yoktu; FragmentActivity gerektiren
// eklenti de bulunmadığından AudioServiceFragmentActivity GEREKMEZ.
class MainActivity : AudioServiceActivity()
