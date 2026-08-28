import 'dart:js' as js;

class WebJs {
  static void callMethod(String method, List<dynamic> args) {
    try {
      js.context.callMethod(method, args);
    } catch (_) {}
  }
}
