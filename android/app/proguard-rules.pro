# Add project-specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in C:\Workspace\flutter\packages\flutter_tools\gradle\flutter_proguard_rules.pro
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.

# Mapbox specific rules if needed (usually handled by the library's consumer ProGuard)
-keep class com.mapbox.** { *; }
-dontwarn com.mapbox.**
