import 'package:html_unescape/html_unescape.dart';

class HtmlEntityDecoder {
  static final _htmlUnescape = HtmlUnescape();

  static String decodeHtmlEntities(String htmlString) {
    return _htmlUnescape.convert(htmlString);
  }
}
