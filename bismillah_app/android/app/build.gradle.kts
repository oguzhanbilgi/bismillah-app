plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Onaylı reverse-domain (docs 06 §34, 07 §4). Flavor son ekleri
    // (.dev/.staging) Gradle product flavor kurulumuyla ayrı görevde eklenir.
    namespace = "com.bismillah.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // flutter_local_notifications (TASK 022) java.time API'leri için
        // core library desugaring gerektirir.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Onaylı production App ID (docs 06 §34, 07 §4). Firebase Android app
        // bu ID ile kaydedilir (FlutterFire configure ayrı görev).
        applicationId = "com.bismillah.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring (flutter_local_notifications gereksinimi).
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
