# App-level R8 rules. Flutter and most plugins contribute their own consumer
# rules automatically; only add entries here for crashes seen in release builds.

# flutter_local_notifications serializes scheduled notifications with Gson,
# which needs generic type info to survive R8.
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.dexterous.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken

# Keep line numbers for readable crash reports (Sentry / Play vitals).
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Flutter deferred-components references Play Core classes that aren't bundled.
-dontwarn com.google.android.play.core.**
