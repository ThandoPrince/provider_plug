buildscript {
    repositories {
        google()
        mavenCentral()
        maven(url = "https://developer.huawei.com/repo/")
    }

    dependencies {
        // Android Gradle Plugin (REQUIRED)
        classpath("com.android.tools.build:gradle:8.11.1")

        // Google services
        classpath("com.google.gms:google-services:4.4.4")

        // Huawei AGConnect
        classpath("com.huawei.agconnect:agcp:1.5.2.300")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven(url = "https://developer.huawei.com/repo/")
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}