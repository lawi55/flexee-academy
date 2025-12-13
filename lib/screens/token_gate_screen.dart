import 'package:flexeeacademy_webview/main.dart';
import 'package:flutter/material.dart';
import '../services/mock_token_validation.dart';

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
