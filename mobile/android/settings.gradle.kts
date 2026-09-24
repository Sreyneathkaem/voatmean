// Disable Flutter Gradle version validation check
System.setProperty("flutter.skipGradleVersionCheck", "true")
extra["flutter.skipGradleVersionCheck"] = true

// Fix for AGP AndroidLocationsException when both ANDROID_PREFS_ROOT and ANDROID_USER_HOME are set in environment
runCatching {
    val envClass = Class.forName("java.lang.ProcessEnvironment")
    val envField = envClass.getDeclaredField("theEnvironment").apply { isAccessible = true }
    (envField.get(null) as? MutableMap<String, String>)?.remove("ANDROID_PREFS_ROOT")

    val ciEnvField = envClass.getDeclaredField("theCaseInsensitiveEnvironment").apply { isAccessible = true }
    (ciEnvField.get(null) as? MutableMap<String, String>)?.remove("ANDROID_PREFS_ROOT")
}

pluginManagement {
    val flutterSdkPath =
        run {
            file("local.properties").inputStream().use { 
                val properties = java.util.Properties()
                properties.load(it)
                properties.getProperty("flutter.sdk")
            } ?: throw IllegalStateException("flutter.sdk not set in local.properties")
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.3" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.4.4") apply false
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
