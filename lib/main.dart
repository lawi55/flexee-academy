import 'package:flexeeacademy_webview/screens/education/home_education_screen.dart';
import 'package:flexeeacademy_webview/services/home_bootstrap_service.dart';
import 'package:flexeeacademy_webview/services/mock_token_validation.dart';
import 'package:flexeeacademy_webview/web/token_reader.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FlexeeAcademyApp());
}

class FlexeeAcademyApp extends StatelessWidget {
  const FlexeeAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final token = "hello"; // TokenReader.getTokenFromUrl();
    final phoneNumber = "+1234567890"; // TokenReader.getPhoneNumberFromUrl();

    return MaterialApp(
      title: 'Flexee Academy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.grey[100],
        useMaterial3: false,
      ),
      home:
          token == null
              ? const MissingTokenScreen()
              : TokenGateScreen(token: token),
    );
  }
}

class TokenGateScreen extends StatelessWidget {
  final String token;

  const TokenGateScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    final status = mockValidateToken(token);

    switch (status) {
      case TokenStatus.valid:
        return BootstrapScreen(token: token);

      case TokenStatus.expired:
        return const TokenExpiredScreen();

      case TokenStatus.invalid:
      default:
        return const TokenInvalidScreen();
    }
  }
}

class BootstrapScreen extends StatefulWidget {
  final String token;
  final String? phoneNumber;

  const BootstrapScreen({super.key, required this.token, this.phoneNumber});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  bool _loading = true;

  List<dynamic> stories = [];
  List<dynamic> videos = [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final storiesRes = await fetchStories(widget.token);
      final videosRes = await fetchVideos(widget.token);

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
      token: widget.token,
      phoneNumber: widget.phoneNumber ?? '',
      stories: stories,
      videos: videos,
    );
  }
}


class MissingTokenScreen extends StatelessWidget {
  const MissingTokenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Cette page doit être ouverte depuis l’application Max it.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class TokenExpiredScreen extends StatelessWidget {
  const TokenExpiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Votre session a expiré.\nVeuillez retourner à l’application Max it.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class TokenInvalidScreen extends StatelessWidget {
  const TokenInvalidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Accès non autorisé.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
