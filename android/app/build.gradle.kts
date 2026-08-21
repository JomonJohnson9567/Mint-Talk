import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Production signing credentials, loaded from a git-ignored properties file
// (see android/key.properties.example). Never committed — generate your own
// keystore with:
//   keytool -genkeypair -v -keystore <path>.jks -keyalg RSA -keysize 2048 \
//     -validity 10000 -alias upload
val keystorePropertiesFile = rootProject.file("key.properties")
val hasKeystoreProperties = keystorePropertiesFile.exists()
val keystoreProperties = Properties()
if (hasKeystoreProperties) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

android {
    namespace = "com.minttalk.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.minttalk.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasKeystoreProperties) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // No fallback to the debug keystore. If key.properties isn't
            // present, this build type simply has no signing config — the
            // taskGraph check below turns that into a loud failure the
            // moment a release task is actually requested, instead of
            // silently shipping a debug-signed (or unsigned) artifact.
            if (hasKeystoreProperties) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

// Fail loudly, only for an actual release build, if there's no signing
// config — rather than the previous silent fallback to the debug keystore.
// Gated on the resolved task graph (not configuration time) so `flutter run`
// / `flutter build apk --debug` are unaffected.
gradle.taskGraph.whenReady {
    val buildingRelease = allTasks.any { it.name.contains("Release") }
    if (buildingRelease && !hasKeystoreProperties) {
        throw GradleException(
            "Missing android/key.properties — required to sign a release build.\n" +
                "1. Generate a keystore: keytool -genkeypair -v -keystore <path>.jks " +
                "-keyalg RSA -keysize 2048 -validity 10000 -alias upload\n" +
                "2. Copy android/key.properties.example to android/key.properties and " +
                "fill in the real storeFile/storePassword/keyAlias/keyPassword.\n" +
                "Never commit key.properties or the .jks file — both are git-ignored.",
        )
    }
}

flutter {
    source = "../.."
}
