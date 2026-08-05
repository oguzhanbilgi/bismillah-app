plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ---------------------------------------------------------------------------
// Release signing (ALPHA-R1)
//
// Credentials are read from the UNTRACKED file `android/key.properties` or,
// when that file is absent, from environment variables. No secret, alias,
// fingerprint or absolute keystore path is ever stored in this tracked file.
//
// Setup guide: docs/setup/ANDROID_RELEASE_SIGNING.md
// Template:    android/key.properties.example
//
// Debug builds are untouched: they keep the standard Android debug keystore.
// Release builds NEVER fall back to the debug certificate — when credentials
// are missing the release build fails with an actionable error instead.
// ---------------------------------------------------------------------------
// Parsed literally, NOT with `java.util.Properties`. In a real .properties file
// `\` is an escape character, which silently corrupts two things on Windows:
// a keystore path (`C:\keys\upload.jks` is read as `C:keysupload.jks`) and any
// password containing a backslash (which then fails as a "wrong password").
// Both failures are silent and hard to diagnose, so these four values are read
// verbatim instead. Consequence: values are trimmed, so a password may not
// begin or end with whitespace. Everything else, including `\`, is literal.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties: Map<String, String> =
    if (keystorePropertiesFile.isFile) {
        keystorePropertiesFile
            .readLines()
            .map { it.trim() }
            .filter { it.isNotEmpty() && !it.startsWith("#") && !it.startsWith("!") }
            .mapNotNull { line ->
                val separator = line.indexOf('=')
                if (separator <= 0) {
                    null
                } else {
                    line.substring(0, separator).trim() to line.substring(separator + 1).trim()
                }
            }.toMap()
    } else {
        emptyMap()
    }

fun releaseSigningInput(
    propertyKey: String,
    environmentKey: String,
): String? =
    (keystoreProperties[propertyKey] ?: System.getenv(environmentKey))
        ?.trim()
        ?.takeIf { it.isNotEmpty() }

val releaseStoreFilePath = releaseSigningInput("storeFile", "BISMILLAH_UPLOAD_STORE_FILE")
val releaseStorePassword = releaseSigningInput("storePassword", "BISMILLAH_UPLOAD_STORE_PASSWORD")
val releaseKeyAlias = releaseSigningInput("keyAlias", "BISMILLAH_UPLOAD_KEY_ALIAS")
val releaseKeyPassword = releaseSigningInput("keyPassword", "BISMILLAH_UPLOAD_KEY_PASSWORD")

// `Project.file` returns an absolute path unchanged and resolves a relative one
// against `android/`, so key.properties may hold either form.
val releaseStoreFile = releaseStoreFilePath?.let { rootProject.file(it) }

// Deliberately reports WHICH input is missing, never its value.
val missingReleaseSigningInputs: List<String> =
    buildList {
        when {
            releaseStoreFilePath == null ->
                add("storeFile (or env BISMILLAH_UPLOAD_STORE_FILE)")
            releaseStoreFile?.isFile != true ->
                add("storeFile — the configured keystore path does not exist on this machine")
        }
        if (releaseStorePassword == null) add("storePassword (or env BISMILLAH_UPLOAD_STORE_PASSWORD)")
        if (releaseKeyAlias == null) add("keyAlias (or env BISMILLAH_UPLOAD_KEY_ALIAS)")
        if (releaseKeyPassword == null) add("keyPassword (or env BISMILLAH_UPLOAD_KEY_PASSWORD)")
    }

val releaseSigningConfigured = missingReleaseSigningInputs.isEmpty()

val missingReleaseSigningMessage =
    buildString {
        appendLine("Release signing is not configured on this machine, so the release build was stopped.")
        appendLine("Bismillah never signs a release build with the Android debug certificate.")
        appendLine()
        appendLine("Missing:")
        missingReleaseSigningInputs.forEach { appendLine("  - $it") }
        appendLine()
        appendLine("Fix: copy android/key.properties.example to android/key.properties and fill in")
        appendLine("the values for your restored upload keystore (or export the environment")
        appendLine("variables listed above).")
        appendLine("Full procedure: docs/setup/ANDROID_RELEASE_SIGNING.md")
        append("Debug builds are unaffected and continue to work.")
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

    signingConfigs {
        // Only created when real credentials are present. When they are not,
        // the release build type is left WITHOUT a signing config, so no
        // debug-signed release artifact can be produced.
        if (releaseSigningConfigured) {
            create("release") {
                storeFile = releaseStoreFile
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig =
                if (releaseSigningConfigured) {
                    signingConfigs.getByName("release")
                } else {
                    null
                }
        }
    }
}

// Fails only when a release packaging task actually runs, so debug builds,
// `flutter pub get`, analyze and test keep working without any credential.
tasks
    .matching { it.name.matches(Regex("^(assemble|bundle|package|sign)[A-Za-z]*Release$")) }
    .configureEach {
        doFirst {
            if (!releaseSigningConfigured) {
                throw GradleException(missingReleaseSigningMessage)
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
