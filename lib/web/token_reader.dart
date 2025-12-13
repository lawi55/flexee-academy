import 'dart:html' as html;

String? readTokenFromUrl() {
  final uri = Uri.parse(html.window.location.href);
  return uri.queryParameters['token'];
}