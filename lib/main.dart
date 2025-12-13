import 'package:flexeeacademy_webview/screens/education/home_education_screen.dart';
import 'package:flexeeacademy_webview/services/home_bootstrap_service.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FlexeeAcademyApp());
}

class FlexeeAcademyApp extends StatelessWidget {
  const FlexeeAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flexee Academy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.grey[100],
        useMaterial3: false,
      ),
      home: const BootstrapScreen(),
    );
  }
}

///
/// This screen is ONLY responsible for:
/// - receiving the token (later from Max it / WebView)
/// - fetching initial data (stories + videos)
/// - redirecting to HomeNewScreen
///
class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  bool _loading = true;

  // TEMP — later injected from Max it
  final String token = "REPLACE_WITH_REAL_TOKEN";

  List<dynamic> stories = [];
  List<dynamic> videos = [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      // 👉 reuse your existing APIs
      final storiesRes = await fetchStories(token);
      final videosRes = await fetchVideos(token);

      setState(() {
        stories = storiesRes;
        videos = videosRes;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return HomeNewScreen(
      token: token,
      stories: stories,
      videos: videos,
    );
  }
}
