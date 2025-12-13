import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'story_detail_screen.dart';

class StoriesListScreen extends StatefulWidget {
  final String token;
  const StoriesListScreen({Key? key, required this.token}) : super(key: key);

  @override
  _StoriesListScreenState createState() => _StoriesListScreenState();
}

class _StoriesListScreenState extends State<StoriesListScreen> {
  List<dynamic> _stories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchStories();
  }

  Future<void> fetchStories() async {
    try {
      final response = await http.get(
        Uri.parse("https://flexee-pay-backend.onrender.com/edu"),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Handle different response formats
        List<dynamic> stories = [];

        if (responseData is List) {
          stories = responseData;
        } else if (responseData is Map && responseData['modules'] is List) {
          stories = responseData['modules'];
        } else if (responseData is Map && responseData['data'] is List) {
          stories = responseData['data'];
        } else if (responseData is Map && responseData['stories'] is List) {
          stories = responseData['stories'];
        }

        // Handle empty case
        if (stories.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Aucune story éducative disponible"),
              ),
            );
          }
          setState(() {
            _loading = false;
          });
          return;
        }

        setState(() {
          _stories = stories;
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Impossible de récupérer les stories éducatives"),
            ),
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Flexee Stories",
          style: TextStyle(color: Colors.white),
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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _stories.isEmpty
              ? const Center(child: Text("Aucune story disponible"))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Découvrez nos stories",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B014A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Une situation = une solution. Apprenez à gérer vos finances au quotidien avec Flexee Stories.",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio:
                                  0.6, // More height for the cards
                            ),
                        itemCount: _stories.length,
                        itemBuilder: (context, index) {
                          final story = _stories[index];
                          final storyId = story["id"]?.toString();
                          final title = story["title"];
                          final description = story["description"];
                          final category = story["category"];
                          final duration = story["estimatedDuration"];
                          final coverImage = story["coverImage"];

                          return _buildStoryCard(
                            storyId: storyId!,
                            title: title,
                            description: description,
                            category: category,
                            duration: duration,
                            coverImage: coverImage,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildStoryCard({
    required String storyId,
    required String? title,
    required String? description,
    required String? category,
    required int? duration,
    required String? coverImage,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => StoryDetailScreen(
                  token: widget.token,
                  storyId: storyId,
                  storyTitle: title ?? "Story",
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background Image
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B29A4).withOpacity(0.1),
                  image:
                      coverImage != null
                          ? DecorationImage(
                            image: NetworkImage(coverImage),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    coverImage == null
                        ? Center(
                          child: Icon(
                            Icons.menu_book_rounded,
                            size: 50,
                            color: const Color(0xFF1B29A4).withOpacity(0.6),
                          ),
                        )
                        : null,
              ),

              // Gradient Overlay at Bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Content Overlay
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "Profile Picture" and Title
                    Row(
                      children: [
                        // "Profile Picture" - using category icon
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getCategoryColor(category),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              _getCategoryIcon(category),
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Title
                        Expanded(
                          child: Text(
                            title ?? "Flexee Story",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'budgeting':
        return const Color(0xFF4CAF50); // Green
      case 'saving':
        return const Color(0xFF2196F3); // Blue
      case 'digital_money':
        return const Color(0xFF9C27B0); // Purple
      default:
        return const Color(0xFF1B29A4); // Default blue
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'budgeting':
        return Icons.account_balance_wallet_rounded;
      case 'saving':
        return Icons.savings_rounded;
      case 'digital_money':
        return Icons.phone_iphone_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }
}
