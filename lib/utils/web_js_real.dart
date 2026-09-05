import 'dart:js' as js;

class WebJs {
  static void callMethod(String method, List<dynamic> args) {
    try {
      js.context.callMethod(method, args);
    } catch (_) {}
  }

  static void openUrl(String url, {String target = '_self'}) {
    try {
      js.context.callMethod('open', [url, target]);
    } catch (_) {}
  }
}
