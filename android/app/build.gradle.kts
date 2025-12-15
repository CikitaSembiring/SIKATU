import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Firebase
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// --- BAGIAN 1: MEMUAT KUNCI DARI KEY.PROPERTIES ---
val keystoreProperties = Properties()
// Mencari file key.properties di folder android/
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
// --------------------------------------------------

android {
    namespace = "com.example.sikatu"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.example.sikatu"
        minSdk = flutter.minSdkVersion // Minimal untuk Firebase
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    // --- BAGIAN 2: KONFIGURASI SIGNING ---
    signingConfigs {
        create("release") {
            // Mengambil nilai dari key.properties
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storePassword = keystoreProperties["storePassword"] as String?

            // Logika mencari file .jks
            val storeFileName = keystoreProperties["storeFile"] as String?
            if (storeFileName != null) {
                storeFile = file(storeFileName)
            }
        }
    }
    // -------------------------------------

    buildTypes {
        getByName("release") {
            // Menggunakan konfigurasi 'release' yang dibuat di atas
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
