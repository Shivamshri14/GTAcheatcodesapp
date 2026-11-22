import java.util.Properties

val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}

val admob = Properties().apply {
    val f = rootProject.file("admob.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}
val adsProd = System.getenv("ADS_MODE") == "prod"

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.shivamshri.cheatcodes"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Same package as the existing Play listing (old app), so this ships as an update.
        applicationId = "com.saksham.gtacodes"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 36
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["admobAppId"] =
            admob.getProperty(if (adsProd) "appId.prod" else "appId.test")
                ?: "ca-app-pub-3940256099942544~3347511713"
    }

    signingConfigs {
        create("upload") {
            if (keystoreProperties.containsKey("storeFile")) {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    // WhatsApp reads stickers through AssetFileDescriptor, so they must stay uncompressed.
    androidResources {
        noCompress += listOf("webp", "png", "json")
    }

    buildTypes {
        release {
            // Keep the AAB small: native debug symbols are not embedded (Play shows an optional warning).
            ndk { debugSymbolLevel = "NONE" }
            signingConfig = if (keystoreProperties.containsKey("storeFile"))
                signingConfigs.getByName("upload") else signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
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
