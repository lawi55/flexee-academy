import 'package:flexeeacademy_webview/services/quiz_cooldown_service.dart';
import 'package:flexeeacademy_webview/services/score_service.dart';
import 'package:flutter/material.dart';
import 'story_detail_screen.dart';
import 'video_player_screen.dart';
import 'quizz_detail_screen.dart';

class HomeNewScreen extends StatefulWidget {
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
  State<HomeNewScreen> createState() => _HomeNewScreenState();
}

class _HomeNewScreenState extends State<HomeNewScreen> {
  int _totalScore = 0;

  @override
  void initState() {
    super.initState();
    _loadScore();
  }

  Future<void> _loadScore() async {
    final score = await ScoreService.getTotalScore();
    if (mounted) {
      setState(() {
        _totalScore = score;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: ListView(
        children: [
          const SizedBox(height: 16),

          // 👤 USER STATS HEADER
          _buildUserStatsHeader(_totalScore, widget.phoneNumber),

          const SizedBox(height: 24),

          _sectionTitle("Stories 📖"),
          const SizedBox(height: 12),
          buildStoriesRow(widget.stories, widget.token),

          const SizedBox(height: 24),
          _sectionTitle("Vidéos 🎬"),
          const SizedBox(height: 12),
          _buildWeeklyVideos(context),

          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Power Quiz Actifs ⚡",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0B014A),
                    ),
                  ),
                ),

                // 🔴 Tiny reset button (ICON ONLY)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      await QuizCooldownService.resetAll();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Quiz cooldowns reset ✅"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }

                      setState(() {});
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4), // 👈 controls ripple size
                      child: Icon(
                        Icons.restart_alt_rounded,
                        size: 20,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          _buildQuizCard(
            context,
            title: "Défi Découverte 💡",
            subtitle: "Idéal pour démarrer en douceur",
            difficulty: "easy",
            color: const Color(0xFF4CAF50),
            icon: Icons.bolt_rounded,
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
    final weeklyVideos = widget.videos.take(5).toList();

    return Column(
      children: [
        SizedBox(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 220,
                      height: 136,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: const Color(0xFF1B29A4).withOpacity(0.08),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (thumbnailUrl != null)
                              Positioned.fill(
                                child: Image.network(
                                  thumbnailUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),

                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withOpacity(0.15),
                              ),
                            ),

                            const Icon(
                              Icons.play_circle_fill_rounded,
                              size: 56,
                              color: Color(0xFFFF7901),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      video["title"] ?? "Vidéo",
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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
        onTap: () async {
          final canPlay = await QuizCooldownService.canPlay(difficulty);

          if (!canPlay) {
            final remaining = await QuizCooldownService.remainingTime(
              difficulty,
            );

            final hours = remaining?.inHours ?? 0;
            final minutes =
                remaining != null ? remaining.inMinutes.remainder(60) : 0;

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Ce quiz sera disponible dans $hours h $minutes min',
                  ),
                ),
              );
            }
            return;
          }

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => QuizDetailScreen(
                    token: widget.token,
                    difficulty: difficulty,
                    quizTitle: title,
                  ),
            ),
          );

          _loadScore(); // refresh score after return
        },
        child: FutureBuilder<bool>(
          future: QuizCooldownService.canPlay(difficulty),
          builder: (context, snapshot) {
            final canPlay = snapshot.data ?? true;

            return Opacity(
              opacity: canPlay ? 1.0 : 0.55,
              child: Card(
                elevation: canPlay ? 2 : 0,
                color: canPlay ? Colors.white : Colors.grey.shade300,
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
                          color:
                              canPlay
                                  ? color.withOpacity(0.15)
                                  : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          icon,
                          size: 32,
                          color: canPlay ? color : Colors.grey,
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color:
                                    canPlay
                                        ? const Color(0xFF0B014A)
                                        : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    canPlay
                                        ? Colors.grey[600]
                                        : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 🔵 PILL BADGE
                      /* Container(
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
                    ), */
                      if (canPlay)
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Color(0xFFFF7901),
                        )
                      else
                        FutureBuilder<Duration?>(
                          future: QuizCooldownService.remainingTime(difficulty),
                          builder: (context, snap) {
                            final remaining = snap.data;

                            final hours = remaining?.inHours ?? 0;
                            final minutes =
                                remaining != null
                                    ? remaining.inMinutes.remainder(60)
                                    : 0;

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.lock_rounded,
                                    size: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${hours}h ${minutes}m',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
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
                    fontSize: 11,
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

Widget _buildUserStatsHeader(int totalScore, String phoneNumber) {
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
              children: [
                Icon(Icons.phone_rounded, size: 18, color: Color(0xFFFF7901)),
                SizedBox(width: 8),
                Text(
                  phoneNumber,
                  style: const TextStyle(
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
                  value: totalScore.toString(),
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
                      width: 30,
                      height: 30,
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
