
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")

    // Flutter Gradle plugin must come after Android and Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load production signing credentials from android/key.properties.
val keystorePropertiesFile = rootProject.file("key.properties")
val hasKeystoreProperties = keystorePropertiesFile.exists()
val keystoreProperties = Properties()

if (hasKeystoreProperties) {
    FileInputStream(keystorePropertiesFile).use {
        keystoreProperties.load(it)
    }
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
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")

            // Resolve relative paths from the android/ directory.
            storeFile = keystoreProperties.getProperty("storeFile")
                ?.let { rootProject.file(it) }

            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

// Fail release builds if the signing properties file is missing.
gradle.taskGraph.whenReady {
    val buildingRelease = allTasks.any {
        it.name.contains("Release", ignoreCase = true)
    }

    if (buildingRelease && !hasKeystoreProperties) {
        throw GradleException(
            "Missing android/key.properties. " +
            "Configure your release keystore before building for release."
        )
    }
}

flutter {
    source = "../.."
}

dependencies {
    // NotificationCompat.CallStyle / ServiceCompat for the ongoing-call
    // notification (CallForegroundService.kt).
    implementation("androidx.core:core-ktx:1.13.1")
}
