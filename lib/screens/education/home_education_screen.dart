import 'package:flutter/material.dart';
import 'story_detail_screen.dart';
import 'video_player_screen.dart';
import 'quizz_detail_screen.dart';

class HomeNewScreen extends StatelessWidget {
  final String token;
  final String phoneNumber;
  final List<dynamic> stories;
  final List<dynamic> videos;

  const HomeNewScreen({
    super.key,
    required this.token,
    required this.phoneNumber,
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

          // 👤 USER STATS HEADER
          _buildUserStatsHeader(),

          const SizedBox(height: 24),

          _sectionTitle("Stories 📖"),
          const SizedBox(height: 12),
          buildStoriesRow(stories, token),

          const SizedBox(height: 24),
          _sectionTitle("Vidéos 🎬"),
          const SizedBox(height: 12),
          _buildWeeklyVideos(context),

          const SizedBox(height: 28),
          _sectionTitle("Power Quiz Actifs ⚡"),
          const SizedBox(height: 12),

          _buildQuizCard(
            context,
            title: "Défi Découverte 💡",
            subtitle: "Idéal pour démarrer en douceur",
            difficulty: "easy",
            color: const Color(0xFF4CAF50),
            icon: Icons.sentiment_satisfied_rounded,
          ),
          const SizedBox(height: 12),

          _buildQuizCard(
            context,
            title: "Défi Maîtrise 🔥",
            subtitle: "Un vrai test de vos connaissances",
            difficulty: "medium",
            color: const Color(0xFFFF9800),
            icon: Icons.local_fire_department_rounded,
          ),
          const SizedBox(height: 12),

          _buildQuizCard(
            context,
            title: "Défi Expert ⚡",
            subtitle: "Pour les champions de la finance !",
            difficulty: "hard",
            color: const Color(0xFFE53935),
            icon: Icons.psychology_rounded,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

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
    IconData icon = Icons.bolt_rounded, // ✅ default icon
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => QuizDetailScreen(
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
                  child: Icon(icon, size: 32, color: color),
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
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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

Widget _buildUserStatsHeader() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phone number
            Row(
              children: const [
                Icon(Icons.phone_rounded, size: 18, color: Color(0xFF1B29A4)),
                SizedBox(width: 8),
                Text(
                  "+216 ** *** ***",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B014A),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statItem(
                  assetIcon: 'assets/academy/streak.png',
                  label: "Streak",
                  value: "5 jours",
                  color: Colors.orange,
                ),

                _statItem(
                  icon: Icons.star_rounded,
                  label: "Score",
                  value: "1200",
                  color: Colors.amber,
                ),
                _statItem(
                  icon: Icons.emoji_events_rounded,
                  label: "Rang",
                  value: "Bronze",
                  color: Colors.brown,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _statItem({
  IconData? icon,
  String? assetIcon,
  required String label,
  required String value,
  required Color color,
}) {
  return Column(
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.15),
        ),
        child: Center(
          child:
              assetIcon != null
                  ? Container(
                    // 🔥 GLOW EFFECT
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.6),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      assetIcon,
                      width: 22,
                      height: 22,
                      fit: BoxFit.contain,
                    ),
                  )
                  : Icon(icon, color: color, size: 22),
        ),
      ),

      const SizedBox(height: 6),

      Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0B014A),
        ),
      ),

      const SizedBox(height: 2),

      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
    ],
  );
}
