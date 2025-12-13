import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'video_player_screen.dart';

class VideosListScreen extends StatefulWidget {
  final String token;
  const VideosListScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<VideosListScreen> createState() => _VideosListScreenState();
}

class _VideosListScreenState extends State<VideosListScreen> {
  List<dynamic> _videos = [];
  bool _loading = true;
  String _selectedCategory = "all";

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    try {
      final response = await http.get(
        Uri.parse("https://flexee-pay-backend.onrender.com/video/all/"),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      print("VIDEOS STATUS: ${response.statusCode}");
      print("VIDEOS BODY: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        List<dynamic> videos = [];
        if (responseData is List) {
          videos = responseData;
        } else if (responseData is Map && responseData['videos'] is List) {
          videos = responseData['videos'];
        } else if (responseData is Map && responseData['data'] is List) {
          videos = responseData['data'];
        }

        setState(() {
          _videos = videos;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Impossible de récupérer les vidéos")),
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

  List<dynamic> get _filteredVideos {
    if (_selectedCategory == "all") return _videos;
    return _videos.where((v) => v["category"] == _selectedCategory).toList();
  }

  Set<String> get _categories {
    final set = <String>{"all"};
    for (final v in _videos) {
      final c = v["category"];
      if (c is String && c.isNotEmpty) set.add(c);
    }
    return set;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Vidéos Flash",
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
              : _videos.isEmpty
              ? const Center(child: Text("Aucune vidéo disponible"))
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Apprenez en quelques secondes",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B014A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Des vidéos courtes pour maîtriser les notions clés de la finance.",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),

                    // Category chips
                    SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children:
                            _categories.map((cat) {
                              final isSelected = cat == _selectedCategory;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(_prettyCategory(cat)),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    setState(() => _selectedCategory = cat);
                                  },
                                  selectedColor: const Color(0xFF1B29A4),
                                  labelStyle: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child: ListView.separated(
                        itemCount: _filteredVideos.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final video = _filteredVideos[index];

                          final title = video["title"] ?? "Vidéo Flexee";
                          final description = video["description"] ?? "";
                          final category = video["category"];
                          final duration =
                              video["estimatedDuration"]; // minutes maybe
                          final videoUrl = video["videoUrl"]; // Cloudinary mp4
                          final thumbnailUrl =
                              video["thumbnailUrl"] ??
                              _cloudinaryThumb(videoUrl);

                          return _buildVideoCard(
                            title: title,
                            description: description,
                            category: category,
                            duration: duration,
                            thumbnailUrl: thumbnailUrl,
                            onTap: () {
                              final videoUrl = video["videoUrl"];

                              if (videoUrl == null ||
                                  videoUrl.toString().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Vidéo indisponible"),
                                  ),
                                );
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => VideoPlayerScreen(
                                        title: title,
                                        description: description,
                                        videoUrl: videoUrl.toString(),
                                      ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  // Generate Cloudinary thumbnail from video URL
  String? _cloudinaryThumb(String? videoUrl) {
    if (videoUrl == null) return null;
    // Insert transformation after /upload/
    return videoUrl.replaceFirst(
      "/upload/",
      "/upload/so_0,w_600,h_360,c_fill,q_auto,f_jpg/",
    );
  }

  Widget _buildVideoCard({
    required String title,
    required String description,
    required String? category,
    required dynamic duration,
    required String? thumbnailUrl,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(14),
              ),
              child: Stack(
                children: [
                  Container(
                    width: 140,
                    height: 110,
                    color: const Color(0xFF1B29A4).withOpacity(0.08),
                    child:
                        thumbnailUrl != null
                            ? Image.network(thumbnailUrl, fit: BoxFit.fill)
                            : const Icon(
                              Icons.play_circle_fill_rounded,
                              size: 40,
                              color: Color(0xFF1B29A4),
                            ),
                  ),
                  if (duration != null)
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _formatDuration(duration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B014A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(
                                category,
                              ).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _prettyCategory(category),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: _getCategoryColor(category),
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF1B29A4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(dynamic duration) {
    if (duration is int) return "${duration} min";
    if (duration is String) return duration;
    return "";
  }

  String _prettyCategory(String category) {
    switch (category) {
      case "all":
        return "Tout";
      case "budgeting":
        return "Budget";
      case "saving":
        return "Épargne";
      case "credit":
        return "Crédit";
      case "digital_money":
        return "Paiement digital";
      default:
        return category;
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'budgeting':
        return const Color(0xFF4CAF50);
      case 'saving':
        return const Color(0xFF2196F3);
      case 'credit':
        return const Color(0xFFF57C00);
      case 'digital_money':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF1B29A4);
    }
  }
}
