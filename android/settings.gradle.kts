pluginManagement {
    val localPropsFile = rootDir.resolve("local.properties")
    if (localPropsFile.exists()) {
        val properties = java.util.Properties()
        localPropsFile.inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        if (!flutterSdkPath.isNullOrBlank()) {
            includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
        } else {
            println("local.properties found but flutter.sdk not set — skipping includeBuild")
        }
    } else {
        println("local.properties not found — skipping includeBuild")
    }

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    // *** تم التحديث من 8.6.0 إلى 8.9.1 ليتوافق مع الـ Dependencies ***
    id("com.android.application") version "8.9.1" apply false 
    
    // إصدار Kotlin DSL
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    
    // Flutter Plugin Loader
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
}

include(":app")