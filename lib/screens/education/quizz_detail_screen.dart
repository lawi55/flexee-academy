import 'package:confetti/confetti.dart';
import 'package:flexeeacademy_webview/services/score_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class QuizDetailScreen extends StatefulWidget {
  final String token;
  final String difficulty;
  final String quizTitle;

  const QuizDetailScreen({
    Key? key,
    required this.token,
    required this.difficulty,
    required this.quizTitle,
  }) : super(key: key);

  @override
  _QuizDetailScreenState createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  List<dynamic> _questions = [];
  bool _loading = true;
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  List<int> _userAnswers = [];
  List<List<int>> _shuffledOptions = [];
  int _quizScore = 0;
  bool _quizCompleted = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    fetchQuiz();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Widget _buildQuitDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        "Quitter le quiz ?",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color((0xFF0B014A)),
        ),
      ),
      content: const Text(
        "Si vous quittez maintenant, toute votre progression sera perdue.\n\nSouhaitez-vous continuer le quiz ou quitter ?",
        style: TextStyle(fontSize: 15, color: Color((0xFF0B014A))),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Continuer"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color((0xFFFF7901)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Quitter",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<bool> _confirmQuit() async {
    // ✅ If quiz is completed, allow exit immediately
    if (_quizCompleted) {
      return true;
    }

    final shouldQuit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _buildQuitDialog(),
    );

    return shouldQuit ?? false;
  }

  Future<void> fetchQuiz() async {
    try {
      final url =
          "https://flexee-pay-backend.onrender.com/quiz/start?difficulty=${widget.difficulty}";

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<dynamic> questions = data["questions"] ?? [];

        if (questions.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Aucune question disponible")),
            );
          }
          setState(() => _loading = false);
          return;
        }

        // Shuffle options for every question
        List<List<int>> shuffledOptions = [];
        for (var question in questions) {
          shuffledOptions.add(_generateShuffledOptions(question));
        }

        setState(() {
          _questions = questions;
          _shuffledOptions = shuffledOptions;
          _userAnswers = List.filled(questions.length, -1);
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erreur lors du chargement du quiz")),
          );
        }
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur réseau : ${e.toString()}")),
        );
      }
    }
  }

  List<int> _generateShuffledOptions(dynamic question) {
    List<int> options = [1, 2, 3];

    if (question['option4'] != null &&
        question['option4'].toString().trim().isNotEmpty) {
      options.add(4);
    }

    if (question['option5'] != null &&
        question['option5'].toString().trim().isNotEmpty) {
      options.add(5);
    }

    options.shuffle(Random());
    return options;
  }

  String _getOptionText(dynamic question, int optionNumber) {
    switch (optionNumber) {
      case 1:
        return question['option1'];
      case 2:
        return question['option2'];
      case 3:
        return question['option3'];
      case 4:
        return question['option4'] ?? '';
      case 5:
        return question['option5'] ?? '';
      default:
        return '';
    }
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _selectedAnswer = answerIndex;
      _userAnswers[_currentQuestionIndex] = answerIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer =
            _userAnswers[_currentQuestionIndex] == -1
                ? null
                : _userAnswers[_currentQuestionIndex];
      });
    } else {
      _calculateScore();
    }
  }

  void _calculateScore() async {
    int correctAnswers = 0;

    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] == _questions[i]['correctOption']) {
        correctAnswers++;
      }
    }

    // ✅ 10 points per correct answer, max 100
    final int calculatedScore = (correctAnswers * 10).clamp(0, 100);

    // ✅ Save to local storage
    await ScoreService.addScore(calculatedScore);

    setState(() {
      _quizScore = calculatedScore; // ⭐ SINGLE SOURCE
      _quizCompleted = true;
    });

    // 🎉 Confetti if passed
    if (_quizScore >= 70) {
      _confettiController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        // ✅ Allow direct pop if quiz completed
        if (_quizCompleted) {
          Navigator.pop(context);
          return;
        }

        final shouldQuit = await _confirmQuit();
        if (shouldQuit && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldQuit = await _confirmQuit();
              if (shouldQuit && mounted) {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            widget.quizTitle,
            style: const TextStyle(color: Colors.white),
          ),
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
        ),
        body:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _questions.isEmpty
                ? const Center(child: Text("Aucune question disponible"))
                : _quizCompleted
                ? _buildResultsScreen()
                : _buildQuestionScreen(),
      ),
    );
  }

  // ---------------------------
  // Build Question Screen
  // ---------------------------

  Widget _buildQuestionScreen() {
    final question = _questions[_currentQuestionIndex];

    final shuffledOptions = _shuffledOptions[_currentQuestionIndex];
    final correctOption = question['correctOption'];
    final explanation = question['explanation'];
    final isLast = _currentQuestionIndex == _questions.length - 1;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color((0xFFFF7901)),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            "Question ${_currentQuestionIndex + 1}/${_questions.length}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color((0xFFFF7901)),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            question['question'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0B014A),
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView.builder(
              itemCount: shuffledOptions.length,
              itemBuilder: (context, index) {
                final optionNumber = shuffledOptions[index];
                final optionLetter = String.fromCharCode(65 + index);

                return Column(
                  children: [
                    _buildOption(
                      optionNumber,
                      correctOption,
                      explanation,
                      optionLetter,
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
          ),

          SizedBox(
            width: double.infinity,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedAnswer != null ? _nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color((0xFFFF7901)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Question suivante",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // Option Tile UI
  // ---------------------------

  Widget _buildOption(
    int optionNumber,
    int correctOption,
    String? explanation,
    String letter,
  ) {
    final question = _questions[_currentQuestionIndex];
    final optionText = _getOptionText(question, optionNumber);
    final isSelected = _selectedAnswer == optionNumber;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color((0xFFFF7901)) : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isSelected ? const Color((0xFFFF7901)) : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          optionText,
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () => _selectAnswer(optionNumber),
      ),
    );
  }

  // ---------------------------
  // Results Screen
  // ---------------------------

  Widget _buildResultsScreen() {
    final passed = _quizScore >= 70;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                passed ? Icons.celebration_rounded : Icons.school_rounded,
                size: 80,
                color: passed ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                passed ? 'Félicitations!' : 'Quiz Terminé',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B014A),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Score : $_quizScore points',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: passed ? Colors.green : Colors.orange,
                ),
              ),

              const SizedBox(height: 8),
              Text(
                passed
                    ? 'Vous avez réussi le quiz!'
                    : 'Continuez à apprendre pour améliorer votre score!',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B29A4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Retour au menu principal',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // CONFETTI 🎉
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          emissionFrequency: 0.05,
          numberOfParticles: 20,
          maxBlastForce: 20,
          minBlastForce: 5,
          gravity: 0.3,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.orange,
            Colors.purple,
            Colors.pink,
            Colors.red,
          ],
        ),
      ],
    );
  }
}
