plugins {
    kotlin("jvm") version "1.9.22"
    `java-library`
}

group = "com.example"
version = "0.1.13"

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(kotlin("test"))
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.0")
}

kotlin {
    jvmToolchain(17)
}

tasks.test {
    useJUnitPlatform()
}
