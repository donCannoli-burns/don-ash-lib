plugins {
    id("com.android.library")
    kotlin("android")
}

android {
    namespace = "dev.kolmafia.ash"
    compileSdk = 36

    defaultConfig {
        minSdk = 23
    }

    sourceSets["main"].jniLibs.srcDir("src/main/jniLibs")
}

kotlin {
    jvmToolchain(17)
}
