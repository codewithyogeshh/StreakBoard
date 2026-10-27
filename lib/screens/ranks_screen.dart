import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../widgets/stat_cards.dart';
import '../widgets/app_animations.dart';

class RanksScreen extends StatelessWidget {
  final AppState state;

  const RanksScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monday = AppState.mondayOfWeek(now);
    final userWeekXp = state.weekXp(monday);

    final List<_Rival> rivals = [
      _Rival('jake.miller', 2581),
      _Rival('sofia.reyes', 2070),
      _Rival('daniel.l87', 1644),
      _Rival('ward.aria', 1594),
      _Rival('harper_boyd', 1568),
      _Rival('chase.cook', 1546),
      _Rival('hayes.owen', 1522),
      _Rival('lily.torres', 1494),
      _Rival('deviney', 1480),
      _Rival('justinmo', 1461),
    ];

    final allParticipants = [
      ...rivals,
      _Rival('You', userWeekXp, isUser: true),
    ];
    allParticipants.sort((a, b) => b.xp.compareTo(a.xp));

    final userRank = allParticipants.indexWhere((r) => r.isUser) + 1;
    final totalCheckins = state.done.values.fold(0, (acc, list) => acc + list.length);

    // 12 weeks = 84 days heat-map calculation
    final startDay = monday.subtract(const Duration(days: 77));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Header (Staggered 0)
        StaggeredEntrance(
          index: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PROFILE · LEADERBOARD',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppTheme.textMuted,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Ranks',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Gamification Header (Staggered 1)
        StaggeredEntrance(
          index: 1,
          child: LevelHeaderCard(state: state),
        ),
        const SizedBox(height: 14),

        // Stats Row 1 (Staggered 2)
        StaggeredEntrance(
          index: 2,
          child: Row(
            children: [
              Expanded(child: _RankStatCard(label: 'Total XP', value: '${state.totalXp}', icon: Icons.stars_rounded, color: AppTheme.primaryBlue)),
              const SizedBox(width: 8),
              Expanded(child: _RankStatCard(label: 'Streak', value: '${state.overallStreak()}d', icon: Icons.local_fire_department_rounded, color: AppTheme.primaryOrange)),
              const SizedBox(width: 8),
              Expanded(child: _RankStatCard(label: 'Best Run', value: '${state.bestStreak()}d', icon: Icons.emoji_events_rounded, color: AppTheme.primaryPurple)),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Stats Row 2 (Staggered 3)
        StaggeredEntrance(
          index: 3,
          child: Row(
            children: [
              Expanded(child: _RankStatCard(label: 'This Week', value: '$userWeekXp XP', icon: Icons.bolt_rounded, color: AppTheme.primaryBlue)),
              const SizedBox(width: 8),
              Expanded(child: _RankStatCard(label: 'Perfect Days', value: '${state.perfectDateKeys.length}', icon: Icons.verified_rounded, color: AppTheme.primaryGreen)),
              const SizedBox(width: 8),
              Expanded(child: _RankStatCard(label: 'Check-ins', value: '$totalCheckins', icon: Icons.fact_check_rounded, color: AppTheme.primaryRed)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 12 Weeks Activity Heat Grid (Staggered 4)
        StaggeredEntrance(
          index: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Last 12 Weeks Consistency Grid'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 84,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                        childAspectRatio: 1.8,
                      ),
                      itemBuilder: (context, index) {
                        final weekIndex = index ~/ 7;
                        final dayIndex = index % 7;
                        final day = startDay.add(Duration(days: weekIndex * 7 + dayIndex));
                        final isFuture = day.isAfter(now);
                        final pct = isFuture ? 0.0 : state.pctForDate(day);

                        Color blockColor = AppTheme.surfaceLight;
                        if (pct > 0) {
                          blockColor = Color.lerp(
                            const Color(0xFF3B82F6),
                            const Color(0xFF14B8A6),
                            pct,
                          )!;
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: blockColor,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: pct >= 1.0
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primaryBlue.withOpacity(0.3),
                                      blurRadius: 4,
                                    )
                                  ]
                                : null,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Less', style: TextStyle(fontSize: 10.5, color: AppTheme.textMuted)),
                        const SizedBox(width: 5),
                        ...[0.0, 0.3, 0.6, 1.0].map((v) {
                          final c = v == 0.0
                              ? AppTheme.surfaceLight
                              : Color.lerp(const Color(0xFF3B82F6), const Color(0xFF14B8A6), v)!;
                          return Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2)),
                          );
                        }),
                        const SizedBox(width: 5),
                        Text('More', style: TextStyle(fontSize: 10.5, color: AppTheme.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Top 10 Leaderboard (Staggered 5)
        StaggeredEntrance(
          index: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Top 10 · XP This Week'),
              Container(
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  children: [
                    ...allParticipants.take(10).toList().asMap().entries.map((entry) {
                      final rank = entry.key + 1;
                      final r = entry.value;
                      return _buildLeaderboardRow(r, rank);
                    }),
                    if (userRank > 10) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text('···', style: TextStyle(color: AppTheme.textMuted, fontSize: 18)),
                      ),
                      _buildLeaderboardRow(allParticipants[userRank - 1], userRank),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Demo leaderboard: rivals are community benchmark data.',
            style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
          ),
        ),
        const SizedBox(height: 95),
      ],
    );
  }

  Widget _buildLeaderboardRow(_Rival rival, int rank) {
    String rankBadge = '$rank';
    if (rank == 1) rankBadge = '🥇';
    if (rank == 2) rankBadge = '🥈';
    if (rank == 3) rankBadge = '🥉';

    return Container(
      margin: rival.isUser ? const EdgeInsets.symmetric(horizontal: 8, vertical: 5) : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: rival.isUser
          ? BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.45), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  blurRadius: 12,
                )
              ],
            )
          : null,
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              rankBadge,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: rank <= 3 ? 16 : 13.5,
                color: rank <= 3 ? AppTheme.primaryOrange : AppTheme.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Text(
                  rival.username,
                  style: TextStyle(
                    fontWeight: rival.isUser ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14.5,
                    color: rival.isUser ? AppTheme.primaryBlue : AppTheme.textPrimary,
                  ),
                ),
                if (rival.isUser) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'YOU',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF09090B)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${rival.xp} XP',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _Rival {
  final String username;
  final int xp;
  final bool isUser;

  _Rival(this.username, this.xp, {this.isUser = false});
}

class _RankStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _RankStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.5),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

