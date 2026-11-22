allprojects {
    repositories {
        google()
        mavenCentral()
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

// AGP lint crashes (NoSuchMethodError in its Java parser) while analysing the
// webview_flutter_android plugin pulled in by google_mobile_ads. Skip the release
// "lintVital" tasks; they only run lint, not compilation or packaging.
subprojects {
    tasks.matching { it.name.startsWith("lintVital") }.configureEach { enabled = false }
}
