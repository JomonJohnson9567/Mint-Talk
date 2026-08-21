# Flutter's own engine/embedding classes are already kept via the default
# proguard-android-optimize.txt + Flutter Gradle plugin — no extra rules
# needed for Flutter itself.

# Agora RTC engine: keep its Java bindings so the native (JNI) side can find
# them by name after obfuscation.
-keep class io.agora.** { *; }
-dontwarn io.agora.**

# socket_io_client / engine.io / okhttp: reflection-based (de)serialization
# and websocket handling breaks under aggressive obfuscation.
-keep class io.socket.** { *; }
-dontwarn io.socket.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# flutter_secure_storage: uses reflection to pick the platform Keystore/
# Keychain implementation.
-keep class com.it_nomads.fluttersecurestorage.** { *; }
