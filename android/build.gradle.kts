// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Android Gradle Plugin (AGP)
        classpath("com.android.tools.build:gradle:8.9.1")

        // Firebase & Google Services
        classpath("com.google.gms:google-services:4.3.15")
        classpath("com.google.firebase:firebase-crashlytics-gradle:2.9.7")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// استخدام buildDirectory بشكل صحيح عشان Flutter يلاقي الـ APK
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // لكل subproject، خلي buildDirectory متوافق مع rootProject
    project.layout.buildDirectory.value(rootProject.layout.buildDirectory.dir(project.name))
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
