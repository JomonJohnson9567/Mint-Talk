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

// Some third-party plugins (e.g. screen_protector) don't pin their own JVM
// target, so they inherit the Kotlin Gradle plugin's default (whatever JDK
// runs Gradle) instead of matching the app module's Java 17 — causing
// "Inconsistent JVM Target Compatibility" build failures. Force every
// subproject's Java/Kotlin compile tasks to Java 17 to keep them aligned.
// `:app` is evaluated eagerly above (evaluationDependsOn), so guard against
// calling afterEvaluate on a project that's already evaluated.
fun Project.alignJvmTargetTo17() {
    extensions.findByType(com.android.build.gradle.BaseExtension::class.java)?.apply {
        compileOptions {
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17
        }
    }
    tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}

subprojects {
    // :app already declares Java/Kotlin 17 explicitly and is evaluated
    // eagerly above (evaluationDependsOn) — its compileOptions are already
    // finalized by the time this runs, so touching it again would fail.
    // Only third-party plugin modules need the alignment.
    if (name != "app") {
        afterEvaluate { alignJvmTargetTo17() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
