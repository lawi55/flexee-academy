import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchStories(String token) async {
  final res = await http.get(
    Uri.parse("https://flexee-pay-backend.onrender.com/edu"),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (res.statusCode != 200) return [];

  final data = jsonDecode(res.body);

  if (data is List) return data;
  if (data is Map && data['modules'] is List) return data['modules'];
  if (data is Map && data['data'] is List) return data['data'];

  return [];
}

Future<List<dynamic>> fetchVideos(String token) async {
  final res = await http.get(
    Uri.parse("https://flexee-pay-backend.onrender.com/video/all/"),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (res.statusCode != 200) return [];

  final data = jsonDecode(res.body);

  if (data is List) return data;
  if (data is Map && data['videos'] is List) return data['videos'];
  if (data is Map && data['data'] is List) return data['data'];

  return [];
}
