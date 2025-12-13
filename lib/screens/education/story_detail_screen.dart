import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class StoryDetailScreen extends StatefulWidget {
  final String token;
  final String storyId;
  final String storyTitle;

  const StoryDetailScreen({
    Key? key,
    required this.token,
    required this.storyId,
    required this.storyTitle,
  }) : super(key: key);

  @override
  _StoryDetailScreenState createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen>
    with TickerProviderStateMixin {
  List<dynamic> _slides = [];
  bool _loading = true;
  int _currentPage = 0;
  List<AnimationController> _progressControllers = [];
  Timer? _autoAdvanceTimer;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    fetchSlides();
  }

  @override
  void dispose() {
    _isClosing = true;
    _autoAdvanceTimer?.cancel();
    for (var controller in _progressControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeProgressBars() {
    // Dispose existing controllers
    for (var controller in _progressControllers) {
      controller.dispose();
    }
    // Create new controllers
    _progressControllers = List.generate(
      _slides.length,
      (index) =>
          AnimationController(vsync: this, duration: const Duration(seconds: 7))
            ..addStatusListener((status) {
              if (status == AnimationStatus.completed && !_isClosing && index == _currentPage) {
                _nextSlide();
              }
            }),
    );
    // Start the first progress bar immediately
    if (_progressControllers.isNotEmpty) {
      _progressControllers[0].forward();
    }
  }

  void _nextSlide() {
    if (_isClosing) return;
    
    if (_currentPage < _slides.length - 1) {
      setState(() {
        _currentPage++;
      });
      // Fill the current progress bar
      if (_currentPage-1 < _progressControllers.length) {
        _progressControllers[_currentPage-1].stop();
        _progressControllers[_currentPage-1].value = 1.0;
        // Prevent the listener from triggering
        
      }
      
      // Start next progress bar
      if (_currentPage < _progressControllers.length) {
        _progressControllers[_currentPage].forward();
      }
    } else {
      _closeStory();
    }
  }

  void _previousSlide() {
    if (_isClosing) return;
    if (_currentPage > 0) {
      // Stop and reset current progress bar
      if (_currentPage < _progressControllers.length) {
        _progressControllers[_currentPage].stop();
        _progressControllers[_currentPage].reset();
      }
      setState(() {
        _currentPage--;
      });
      // Reset all future progress bars and restart current one
      for (int i = _currentPage + 1; i < _progressControllers.length; i++) {
        _progressControllers[i].reset();
      }
      // Restart current progress bar
      if (_currentPage < _progressControllers.length) {
        _progressControllers[_currentPage].reset();
        _progressControllers[_currentPage].forward();
      }
    }
    else if (_currentPage == 0) {
      // Restart the first slide's progress bar
      if (_progressControllers.isNotEmpty) {
        _progressControllers[0].stop();
        _progressControllers[0].reset();
        _progressControllers[0].forward();
      }
    }
  }

  void _closeStory() {
    if (_isClosing) return;
    _isClosing = true;
    _autoAdvanceTimer?.cancel();
    Navigator.pop(context);
  }

  Future<void> fetchSlides() async {
    try {
      final response = await http.get(
        Uri.parse("https://flexee-pay-backend.onrender.com/edu/${widget.storyId}"),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        List<dynamic> slides = [];

        if (responseData is Map && responseData['slides'] is List) {
          slides = responseData['slides'];
        }

        if (slides.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Aucun slide disponible pour cette story"),
              ),
            );
          }
          setState(() {
            _loading = false;
          });
          return;
        }

        setState(() {
          _slides = slides;
          _loading = false;
        });
        _initializeProgressBars();
      } else {
        setState(() {
          _loading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur serveur: ${response.statusCode}")),
          );
        }
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur réseau : ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back button
      onPopInvoked: (didPop) {
        if (!didPop) {
          _closeStory();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body:
            _loading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                : _slides.isEmpty
                ? const Center(
                  child: Text(
                    "Aucun slide disponible",
                    style: TextStyle(color: Colors.white),
                  ),
                )
                : Stack(
                  children: [
                    // Current Slide Content
                    _buildCurrentSlide(),

                    // Progress Bars at Top
                    Positioned(
                      top: 50,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: List.generate(_slides.length, (index) {
                          return Expanded(
                            child: Container(
                              height: 3,
                              margin: EdgeInsets.only(
                                right: index == _slides.length - 1 ? 0 : 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: AnimatedBuilder(
                                animation:
                                    _progressControllers.isNotEmpty &&
                                            index < _progressControllers.length
                                        ? _progressControllers[index]
                                        : AlwaysStoppedAnimation(0.0),
                                builder: (context, child) {
                                  double progress =
                                      _progressControllers.isNotEmpty &&
                                              index <
                                                  _progressControllers.length
                                          ? _progressControllers[index].value
                                          : 0.0;
                                  return Stack(
                                    children: [
                                      // Background
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      // Progress
                                      FractionallySizedBox(
                                        alignment: Alignment.topLeft,
                                        widthFactor: progress,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // Header with title and close button
                    Positioned(
                      top: 70,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: [
                          // Profile circle and title
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: Icon(
                              Icons.menu_book_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.storyTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Close button
                          GestureDetector(
                            onTap: _closeStory,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.3),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tap areas for navigation
                    Positioned.fill(
                      child: Row(
                        children: [
                          // Left 30% for previous
                          Expanded(
                            flex: 3,
                            child: GestureDetector(
                              onTap: _previousSlide,
                              behavior: HitTestBehavior.translucent,
                            ),
                          ),
                          // Middle 40% (no action)
                          Expanded(flex: 4, child: Container()),
                          // Right 30% for next
                          Expanded(
                            flex: 3,
                            child: GestureDetector(
                              onTap: _nextSlide,
                              behavior: HitTestBehavior.translucent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildCurrentSlide() {
  if (_currentPage >= _slides.length) return Container();
  final slide = _slides[_currentPage];
  final imageUrl = slide["imageUrl"];
  final content = slide["content"];

  return Stack(
    children: [
      // 🔥 BACKGROUND — Expanded edges of the image
      if (imageUrl != null)
        Positioned.fill(
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover, // expands to fill screen (edges stretch)
          ),
        ),

      // 🔥 LIGHT BLUR TO SOFTEN THE EDGES
      Positioned.fill(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: Colors.black.withOpacity(0.15), // very light darkening
          ),
        ),
      ),

      // ⭐ FOREGROUND — Real image, not stretched
      if (imageUrl != null)
        Positioned.fill(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain, // keep original aspect ratio
          ),
        ),

      // ⭐ Text content
      Positioned(
        bottom: 110,
        left: 24,
        right: 24,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (content != null)
              Text(
                content,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    ],
  );
  }
}
