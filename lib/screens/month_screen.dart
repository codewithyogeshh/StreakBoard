import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../widgets/stat_cards.dart';
import '../widgets/app_animations.dart';

class MonthScreen extends StatefulWidget {
  final AppState state;

  const MonthScreen({super.key, required this.state});

  @override
  State<MonthScreen> createState() => _MonthScreenState();
}

class _MonthScreenState extends State<MonthScreen> {
  int _monthOffset = 0;
  bool _isBoardView = false;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetMonth = DateTime(now.year, now.month + _monthOffset, 1);
    final daysInMonth = DateTime(targetMonth.year, targetMonth.month + 1, 0).day;

    final List<DateTime> elapsedDaysInMonth = [];
    for (int i = 1; i <= daysInMonth; i++) {
      final d = DateTime(targetMonth.year, targetMonth.month, i);
      if (d.isBefore(today.add(const Duration(days: 1)))) {
        elapsedDaysInMonth.add(d);
      }
    }

    int totalScheduled = 0;
    int totalCompleted = 0;
    for (final d in elapsedDaysInMonth) {
      final scheduled = widget.state.getHabitsForDate(d);
      totalScheduled += scheduled.length;
      totalCompleted += scheduled.where((h) => widget.state.isHabitDone(d, h.id)).length;
    }

    final overallMonthlyPct = totalScheduled == 0 ? 0 : (totalCompleted * 100 ~/ totalScheduled);
    final perfectDaysCount = elapsedDaysInMonth.where((d) => widget.state.pctForDate(d) >= 1.0).length;

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
                'HABIT TRACKER · ${targetMonth.year}',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('MMMM').format(targetMonth),
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
          child: LevelHeaderCard(state: widget.state),
        ),
        const SizedBox(height: 14),

        // 3 Metric Stat Cards (Staggered 2)
        StaggeredEntrance(
          index: 2,
          child: Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: 'Completed',
                  value: '$overallMonthlyPct%',
                  color: AppTheme.primaryBlue,
                  icon: Icons.check_circle_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatBox(
                  label: 'Perfect',
                  value: '$perfectDaysCount d',
                  color: AppTheme.primaryPurple,
                  icon: Icons.stars_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatBox(
                  label: 'Best run',
                  value: '${widget.state.bestStreak()} d',
                  color: AppTheme.primaryOrange,
                  icon: Icons.local_fire_department_rounded,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Segmented Control (Staggered 3)
        StaggeredEntrance(
          index: 3,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SegmentButton(
                    title: 'Calendar',
                    isSelected: !_isBoardView,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _isBoardView = false);
                    },
                  ),
                  _SegmentButton(
                    title: 'Board Matrix',
                    isSelected: _isBoardView,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _isBoardView = true);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Month Selector Bar (Staggered 4)
        StaggeredEntrance(
          index: 4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _monthOffset--);
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.chevron_left_rounded, size: 18, color: AppTheme.primaryBlue),
                      SizedBox(width: 2),
                      Text('Prev', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w700, fontSize: 12.5)),
                    ],
                  ),
                ),
              ),
              Text(
                DateFormat('MMMM yyyy').format(targetMonth),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16.5, letterSpacing: -0.3),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _monthOffset++);
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Row(
                    children: [
                      Text('Next', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w700, fontSize: 12.5)),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.primaryBlue),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Calendar or Board Matrix view (Staggered 5)
        StaggeredEntrance(
          index: 5,
          child: _isBoardView
              ? _buildBoardView(targetMonth, daysInMonth, today)
              : _buildCalendarView(targetMonth, daysInMonth, today),
        ),
        const SizedBox(height: 16),

        // Per-Habit Analysis Section (Staggered 6)
        StaggeredEntrance(
          index: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Habit Monthly Analysis'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecoration(),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.state.habits.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final habit = widget.state.habits[index];
                    final scheduledDays = elapsedDaysInMonth.where((d) => habit.scheduledDays.contains(d.weekday)).toList();
                    final doneCount = scheduledDays.where((d) => widget.state.isHabitDone(d, habit.id)).length;
                    final habitPct = scheduledDays.isEmpty ? 0.0 : doneCount / scheduledDays.length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(habit.emoji, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(habit.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                              ],
                            ),
                            Text(
                              '${(habitPct * 100).round()}% ($doneCount/${scheduledDays.length})',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        SmoothProgressBar(
                          value: habitPct,
                          height: 6,
                          gradientColors: [habit.color, habit.color.withOpacity(0.7)],
                          glow: habitPct >= 1.0,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 95),
      ],
    );
  }

  Widget _buildCalendarView(DateTime month, int daysCount, DateTime today) {
    const weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    final firstWeekday = month.weekday;
    final leadingBlanks = firstWeekday - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          Row(
            children: weekdays.map((w) {
              return Expanded(
                child: Center(
                  child: Text(
                    w,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingBlanks + daysCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              if (index < leadingBlanks) {
                return const SizedBox.shrink();
              }
              final dayNumber = index - leadingBlanks + 1;
              final dayDate = DateTime(month.year, month.month, dayNumber);
              final pct = widget.state.pctForDate(dayDate);
              final isToday = dayDate.year == today.year &&
                  dayDate.month == today.month &&
                  dayDate.day == today.day;
              final isFuture = dayDate.isAfter(today);

              Color bgColor = AppTheme.surfaceLight;
              Color textColor = AppTheme.textPrimary;

              if (!isFuture && pct > 0) {
                bgColor = Color.lerp(
                  const Color(0xFF8B5CF6),
                  const Color(0xFF14B8A6),
                  pct,
                )!;
                textColor = const Color(0xFF09090B);
              } else if (isFuture) {
                textColor = AppTheme.textMuted.withOpacity(0.5);
              }

              return Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(9),
                  border: isToday
                      ? Border.all(color: AppTheme.primaryBlue, width: 2)
                      : Border.all(color: AppTheme.borderSubtle),
                  boxShadow: isToday
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withOpacity(0.4),
                            blurRadius: 8,
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$dayNumber',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBoardView(DateTime month, int daysCount, DateTime today) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Days header row
            Row(
              children: [
                const SizedBox(width: 125),
                ...List.generate(daysCount, (i) {
                  return SizedBox(
                    width: 26,
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w700),
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 10),
            // Habits rows
            ...widget.state.habits.map((habit) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 125,
                      child: Row(
                        children: [
                          Text(habit.emoji, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              habit.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...List.generate(daysCount, (i) {
                      final dayDate = DateTime(month.year, month.month, i + 1);
                      final isScheduled = habit.scheduledDays.contains(dayDate.weekday);
                      final isDone = widget.state.isHabitDone(dayDate, habit.id);
                      final isFuture = dayDate.isAfter(today);

                      return GestureDetector(
                        onTap: (!isFuture && isScheduled)
                            ? () {
                                HapticFeedback.selectionClick();
                                widget.state.toggleHabit(dayDate, habit.id);
                              }
                            : null,
                        child: Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: isDone
                                  ? habit.color
                                  : isScheduled
                                      ? AppTheme.surfaceLight
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: isScheduled
                                  ? Border.all(
                                      color: isDone ? habit.color : AppTheme.border,
                                      width: 1.2,
                                    )
                                  : null,
                              boxShadow: isDone
                                  ? [
                                      BoxShadow(
                                        color: habit.color.withOpacity(0.4),
                                        blurRadius: 6,
                                      )
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
              Icon(icon, size: 14, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.border : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 1))]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
}

