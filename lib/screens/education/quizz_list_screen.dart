import 'package:flutter/material.dart';
import 'quizz_detail_screen.dart';

class QuizzesListScreen extends StatefulWidget {
  final String token;
  const QuizzesListScreen({Key? key, required this.token}) : super(key: key);

  @override
  _QuizzesListScreenState createState() => _QuizzesListScreenState();
}

class _QuizzesListScreenState extends State<QuizzesListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Power Quiz", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0B014A), Color(0xFF1B29A4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Testez vos connaissances",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              "Choisissez votre niveau et devenez un pro de la finance !",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            _buildDifficultyButton(
              context,
              title: "Défi Découverte 💡",
              subtitle: "Idéal pour démarrer en douceur",
              difficulty: "Facile",
              difficultyColor: const Color(0xFF4CAF50),
            ),
            const SizedBox(height: 20),

            _buildDifficultyButton(
              context,
              title: "Défi Maîtrise 🔥",
              subtitle: "Un vrai test de vos connaissances",
              difficulty: "Moyen",
              difficultyColor: const Color(0xFFFF9800),
            ),
            const SizedBox(height: 20),

            _buildDifficultyButton(
              context,
              title: "Défi Expert ⚡",
              subtitle: "Pour les champions de la finance !",
              difficulty: "Difficile",
              difficultyColor: const Color(0xFFE53935),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String difficulty,
    required Color difficultyColor,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => QuizDetailScreen(
                  token: widget.token,
                  difficulty: mapDifficulty(difficulty),
                  quizTitle: title,
                ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.25), width: 1),

            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFFF7F7FA), // clean neutral background
          ),
          child: Row(
            children: [
              // Icon box
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: difficultyColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.bolt_rounded,
                  size: 32,
                  color: difficultyColor,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[900],
                            ),
                          ),
                        ),

                        // Difficulty tag (small colored pill)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: difficultyColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            difficulty.toUpperCase(),
                            style: TextStyle(
                              color: difficultyColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.black45,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String mapDifficulty(String difficulty) {
  switch (difficulty.toLowerCase()) {
    case "facile":
      return "easy";
    case "moyen":
      return "medium";
    case "difficile":
      return "hard";
    default:
      return "easy"; // fallback
  }
}
