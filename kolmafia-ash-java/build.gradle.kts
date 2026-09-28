plugins {
    `java-library`
}

group = "dev.doncannoli"
version = "0.1.0"

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
    }
    withSourcesJar()
    withJavadocJar()
}

repositories {
    mavenCentral()
}

tasks.withType<JavaCompile>().configureEach {
    options.release.set(21)
    options.encoding = "UTF-8"
}

tasks.register<JavaExec>("ashrefgen") {
    group = "application"
    description = "Generate Java AshClient wrappers from KoLmafia ashref output"
    classpath = sourceSets.main.get().runtimeClasspath
    mainClass.set("dev.doncannoli.kolmafia.ashrefgen.Main")
}
