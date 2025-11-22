// هذا الجزء خاص بتحديد مكان مجلد البناء (Build Directory) خارج مجلد Android
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    // التأكد من تقييم مشروع :app أولاً في الترتيب
    project.evaluationDependsOn(":app")
}

// تعريف مهمة 'clean' لحذف مجلد البناء كاملاً
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// إعدادات البناء الرئيسية (Build Script Configuration)
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // *** هذا هو التعديل المطلوب: تحديث AGP إلى 8.9.1 أو أعلى ***
        // الإصدار 8.9.1 يحل مشكلة التوافق مع androidx.core:core-ktx:1.17.0
        classpath("com.android.tools.build:gradle:8.9.1")
        
        // باقي الـ Classpath Dependencies الخاصة بـ Firebase و Google Services
        classpath("com.google.gms:google-services:4.3.15")
        classpath("com.google.firebase:firebase-crashlytics-gradle:2.9.7")
    }
}

// هذا البلوك يحدد الـ Repositories لكل المشاريع الفرعية (Flutter modules, app)
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ملاحظة: لإتمام عملية الترقية، قد تحتاج أيضاً إلى تحديث إصدار Gradle نفسه
// في ملف gradle/wrapper/gradle-wrapper.properties ليناسب AGP 8.9.1.
// تأكد من أن distributionUrl يستخدم إصدار Gradle 8.7 أو أحدث.