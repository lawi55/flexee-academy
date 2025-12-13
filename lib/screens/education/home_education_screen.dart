import 'package:flutter/material.dart';
import 'story_detail_screen.dart';
import 'video_player_screen.dart';
import 'quizz_detail_screen.dart';

class HomeNewScreen extends StatelessWidget {
  final String token;
  final List<dynamic> stories;
  final List<dynamic> videos;

  const HomeNewScreen({
    super.key,
    required this.token,
    required this.stories,
    required this.videos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // -----------------------
          // STORIES ROW (YOUR WIDGET)
          // -----------------------
          _sectionTitle("Stories du jour 📖"),
          const SizedBox(height: 12),
          buildStoriesRow(stories, token),

          const SizedBox(height: 24),

          // -----------------------
          // VIDEO DE LA SEMAINE
          // -----------------------
          _sectionTitle("Vidéo de la semaine 🎬"),
          const SizedBox(height: 12),
          _buildWeeklyVideos(context),

          const SizedBox(height: 28),

          // -----------------------
          // QUIZZES
          // -----------------------
          _sectionTitle("Power Quiz Actifs du Mois ⚡"),
          const SizedBox(height: 12),

          _buildQuizCard(
            context,
            title: "Défi Découverte 💡",
            subtitle: "Idéal pour démarrer en douceur",
            difficulty: "easy",
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 12),

          _buildQuizCard(
            context,
            title: "Défi Maîtrise 🔥",
            subtitle: "Un vrai test de vos connaissances",
            difficulty: "medium",
            color: const Color(0xFFFF9800),
          ),
          const SizedBox(height: 12),

          _buildQuizCard(
            context,
            title: "Défi Expert ⚡",
            subtitle: "Pour les champions de la finance !",
            difficulty: "hard",
            color: const Color(0xFFE53935),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // -----------------------
  // SECTION TITLE
  // -----------------------
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0B014A),
        ),
      ),
    );
  }

  // -----------------------
  // VIDEO SECTION (CLOUDINARY SAFE)
  // -----------------------
  Widget _buildWeeklyVideos(BuildContext context) {
    final weeklyVideos = videos.take(5).toList();

    return SizedBox(
      height: 160,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: weeklyVideos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final video = weeklyVideos[index];

          final String? thumbnailUrl =
              video["thumbnailUrl"] ?? _cloudinaryThumb(video["videoUrl"]);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => VideoPlayerScreen(
                        title: video["title"] ?? "Vidéo",
                        description: video["description"] ?? "",
                        videoUrl: video["videoUrl"],
                      ),
                ),
              );
            },
            child: Container(
              width: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFF1B29A4).withOpacity(0.08),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Thumbnail (if available)
                    if (thumbnailUrl != null)
                      Positioned.fill(
                        child: Image.network(thumbnailUrl, fit: BoxFit.cover),
                      ),

                    // Semi-transparent dark overlay (optional but nice)
                    Positioned.fill(
                      child: Container(color: Colors.black.withOpacity(0.15)),
                    ),

                    // ▶️ PLAY BUTTON (ALWAYS VISIBLE)
                    const Icon(
                      Icons.play_circle_fill_rounded,
                      size: 56,
                      color: Color(0xFF1B29A4), // blue play button
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuizCard(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String difficulty,
  required Color color,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizDetailScreen(
              token: token,
              difficulty: difficulty,
              quizTitle: title,
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              // Icon
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.bolt_rounded,
                  size: 32,
                  color: color,
                ),
              ),

              const SizedBox(width: 16),

              // Title & subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B014A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // 🔵 PILL BADGE
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B29A4).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999), // capsule
                ),
                child: const Text(
                  "1 quiz actif par mois",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B29A4),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF1B29A4),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


  // -----------------------
  // CLOUDINARY THUMB HELPER (YOURS)
  // -----------------------
  String? _cloudinaryThumb(String? videoUrl) {
    if (videoUrl == null) return null;
    return videoUrl.replaceFirst(
      "/upload/",
      "/upload/so_0,w_600,h_360,c_fill,q_auto,f_jpg/",
    );
  }
}

Widget buildStoriesRow(List<dynamic> stories, String token) {
  return SizedBox(
    height: 110,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: stories.length,
      separatorBuilder: (_, __) => const SizedBox(width: 14),
      itemBuilder: (context, index) {
        final story = stories[index];
        final storyId = story["id"].toString();
        final title = story["title"] ?? "Story";
        final cover = story["coverImage"];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => StoryDetailScreen(
                      token: token,
                      storyId: storyId,
                      storyTitle: title,
                    ),
              ),
            );
          },
          child: Column(
            children: [
              // Story circle
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFF1B29A4), width: 2),
                  image:
                      cover != null
                          ? DecorationImage(
                            image: NetworkImage(cover),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    cover == null
                        ? const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                        )
                        : null,
              ),

              const SizedBox(height: 6),

              // Title under circle
              SizedBox(
                width: 70,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
