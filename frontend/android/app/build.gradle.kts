plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.frontend"
    compileSdk = 35
    ndkVersion = "27.0.12077973"
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.frontend"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// vvv ADD THIS ENTIRE BLOCK vvv
dependencies {
    // Firebase Bill of Materials (BoM)
    implementation(platform("com.google.firebase:firebase-bom:33.1.2"))

    // Google Mobile Ads SDK (AdMob)
    implementation("com.google.android.gms:play-services-ads:23.2.0")

    // Firebase Analytics (required for the best AdMob integration)
    implementation("com.google.firebase:firebase-analytics")
}
// ^^^ ADD THIS ENTIRE BLOCK ^^^


flutter {
    source = "../.."
}