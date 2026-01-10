// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';

@JS('flutterCanvasKit')
external JSAny? get flutterCanvasKit;

bool isCanvasKitRenderer() {
  return flutterCanvasKit != null;
}
