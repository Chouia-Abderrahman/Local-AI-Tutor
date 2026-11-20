# The ML Kit text recognition plugin refers to the Chinese, Devanagari,
# Japanese and Korean recognizers. The app reads Latin script only and
# doesn't bundle them, so R8 must not fail on the missing classes.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# ML Kit creates its component registrars by reflection through their
# no-argument constructors, which R8's full mode removes unless kept by name
# ("Could not instantiate ...CommonComponentRegistrar" at startup).
-keep class com.google.mlkit.**Registrar { <init>(); }
