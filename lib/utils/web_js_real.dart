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

  static void downloadFile(String filename, String content, {String mimeType = 'text/csv'}) {
    try {
      final encoded = Uri.encodeComponent(content);
      final href = 'data:$mimeType;charset=utf-8,$encoded';
      final document = js.context['document'];
      if (document != null) {
        final anchor = document.callMethod('createElement', ['a']);
        anchor['href'] = href;
        anchor['download'] = filename;
        document['body'].callMethod('appendChild', [anchor]);
        anchor.callMethod('click', []);
        document['body'].callMethod('removeChild', [anchor]);
      }
    } catch (_) {}
  }
}
