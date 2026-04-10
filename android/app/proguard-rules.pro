# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# MLKit Text Recognition
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.android.gms.internal.vision.** { *; }
-keep class com.google.mlkit.vision.common.** { *; }
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }

# Keep model classes
-keep class com.google.mlkit.vision.** { *; }

# Keep annotation
-keep class * extends java.lang.annotation.Annotation { *; }
-keep class * implements com.google.android.gms.common.api.Api$ApiOptions { *; }

# Keep Parcelable
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Keep Serializable
-keep class * implements java.io.Serializable { *; }

# Keep enum
-keepclassmembers enum * { *; }

# Keep native methods
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

# Keep inner classes
-keepattributes InnerClasses, EnclosingMethod

# Keep SourceFile and LineNumberTable for stack traces
-keepattributes SourceFile, LineNumberTable
