import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../widgets/concentric_rings.dart';
import '../widgets/stat_cards.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/custom_modals.dart';
import '../widgets/app_animations.dart';

class TodayScreen extends StatelessWidget {
  final AppState state;

  const TodayScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayKey = AppState.dateKey(today);
    final scheduledHabits = state.getHabitsForDate(today);
    final completedHabitsCount = scheduledHabits.where((h) => state.isHabitDone(today, h.id)).length;
    final habitPct = scheduledHabits.isEmpty ? 0.0 : completedHabitsCount / scheduledHabits.length;

    final todayTasks = state.tasks[todayKey] ?? [];
    final big3Tasks = todayTasks.where((t) => t.isBig3).toList();
    final big3DoneCount = big3Tasks.where((t) => t.isDone).length;
    final big3Pct = big3Tasks.isEmpty ? 0.0 : big3DoneCount / big3Tasks.length;

    final regularTasks = todayTasks.where((t) => !t.isBig3).toList();
    final regularDoneCount = regularTasks.where((t) => t.isDone).length;
    final regularPct = regularTasks.isEmpty ? 0.0 : regularDoneCount / regularTasks.length;

    final energy = state.energyRatings[todayKey] ?? 5;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Screen Header (Staggered 0)
        StaggeredEntrance(
          index: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, MMMM d').format(today).toUpperCase(),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Today',
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

        // Gamification Header Card (Staggered 1)
        StaggeredEntrance(
          index: 1,
          child: LevelHeaderCard(state: state),
        ),
        const SizedBox(height: 14),

        // Activity Concentric Rings Card (Staggered 2)
        StaggeredEntrance(
          index: 2,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: AppTheme.cardDecoration(),
            child: Row(
              children: [
                ConcentricRings(
                  habitProgress: habitPct,
                  big3Progress: big3Pct,
                  taskProgress: regularPct,
                  size: 140,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MetricItem(
                        label: 'Habits',
                        value: '$completedHabitsCount / ${scheduledHabits.length}',
                        color: AppTheme.primaryBlue,
                        percentage: habitPct,
                      ),
                      const SizedBox(height: 10),
                      _MetricItem(
                        label: 'Big 3',
                        value: '$big3DoneCount / ${big3Tasks.length}',
                        color: AppTheme.primaryRed,
                        percentage: big3Pct,
                      ),
                      const SizedBox(height: 10),
                      _MetricItem(
                        label: 'Tasks',
                        value: '$regularDoneCount / ${regularTasks.length}',
                        color: AppTheme.primaryOrange,
                        percentage: regularPct,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.25)),
                        ),
                        child: Text(
                          '+${state.xpForDate(today)} XP earned today',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Section: Today's Habits (Staggered 3)
        StaggeredEntrance(
          index: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Habits · +10 XP each',
                actionText: '+ New Habit',
                onAction: () => CustomModals.showAddHabit(context, state),
              ),
              Container(
                decoration: AppTheme.cardDecoration(),
                child: scheduledHabits.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(18),
                        child: Text('No habits scheduled for today.', style: TextStyle(color: AppTheme.textMuted)),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: scheduledHabits.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final habit = scheduledHabits[index];
                          final isDone = state.isHabitDone(today, habit.id);
                          final streak = state.habitStreak(habit);

                          return Material(
                            color: isDone ? habit.color.withOpacity(0.04) : Colors.transparent,
                            borderRadius: BorderRadius.circular(index == 0 ? 20 : (index == scheduledHabits.length - 1 ? 20 : 0)),
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                final wasPerfectBefore = state.pctForDate(today) >= 1.0;
                                final nowDone = state.toggleHabit(today, habit.id);
                                if (nowDone) {
                                  final isPerfectNow = state.pctForDate(today) >= 1.0;
                                  if (!wasPerfectBefore && isPerfectNow) {
                                    ConfettiOverlay.trigger(
                                      context,
                                      toastMessage: 'Perfect Day! ⭐ Streak locked in',
                                    );
                                  } else {
                                    ConfettiOverlay.trigger(context, particleCount: 16);
                                  }
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: habit.color.withOpacity(0.16),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: habit.color.withOpacity(0.35)),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(habit.emoji, style: const TextStyle(fontSize: 20)),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            habit.name,
                                            style: TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w700,
                                              color: isDone ? AppTheme.textSecondary : AppTheme.textPrimary,
                                              decoration: isDone ? TextDecoration.lineThrough : null,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.surfaceLight,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Text('🔥', style: TextStyle(fontSize: 11)),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      '$streak d streak',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w700,
                                                        color: AppTheme.primaryOrange,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close_rounded, size: 16, color: AppTheme.textMuted),
                                      onPressed: () {
                                        CustomModals.confirmDelete(
                                          context,
                                          'Delete "${habit.name}"?',
                                          () => state.deleteHabit(habit.id),
                                        );
                                      },
                                    ),
                                    CustomCheckbox(
                                      value: isDone,
                                      activeColor: habit.color,
                                      onChanged: (val) {
                                        final wasPerfectBefore = state.pctForDate(today) >= 1.0;
                                        final nowDone = state.toggleHabit(today, habit.id);
                                        if (nowDone) {
                                          final isPerfectNow = state.pctForDate(today) >= 1.0;
                                          if (!wasPerfectBefore && isPerfectNow) {
                                            ConfettiOverlay.trigger(
                                              context,
                                              toastMessage: 'Perfect Day! ⭐ Streak locked in',
                                            );
                                          } else {
                                            ConfettiOverlay.trigger(context, particleCount: 16);
                                          }
                                        }
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
            ],
          ),
        ),

        // Section: Target Goals (Staggered 4)
        StaggeredEntrance(
          index: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Goals · ${state.goals.where((g) => g.current >= g.target).length} of ${state.goals.length} done',
                actionText: '+ New Goal',
                onAction: () => CustomModals.showAddGoal(context, state),
              ),
              Container(
                decoration: AppTheme.cardDecoration(),
                child: state.goals.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(18),
                        child: Text('No goals yet. Tap + New Goal.', style: TextStyle(color: AppTheme.textMuted)),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.goals.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final goal = state.goals[index];
                          final progressRatio = (goal.current / goal.target).clamp(0.0, 1.0);
                          final isComplete = goal.current >= goal.target;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            goal.name,
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                          ),
                                          Text(
                                            '${goal.current.toStringAsFixed(goal.current % 1 == 0 ? 0 : 1)} / ${goal.target.toStringAsFixed(goal.target % 1 == 0 ? 0 : 1)} ${goal.unit}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: isComplete ? AppTheme.primaryBlue : AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      SmoothProgressBar(
                                        value: progressRatio,
                                        height: 7,
                                        gradientColors: isComplete
                                            ? const [Color(0xFF14B8A6), Color(0xFF10B981)]
                                            : const [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                                        glow: isComplete,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_rounded, color: AppTheme.primaryBlue, size: 26),
                                  onPressed: () {
                                    CustomModals.showAddGoalProgress(context, goal, (amount) {
                                      final unlocked = state.addGoalProgress(index, amount);
                                      if (unlocked) {
                                        ConfettiOverlay.trigger(
                                          context,
                                          toastMessage: 'Goal completed! 🎯 ${goal.name}',
                                        );
                                      }
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.close_rounded, size: 16, color: AppTheme.textMuted),
                                  onPressed: () => state.deleteGoal(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),

        // Section: Today's Plan Tasks (Staggered 5)
        StaggeredEntrance(
          index: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: "Today's Plan",
                actionText: '+ Add Task',
                onAction: () => CustomModals.showAddTask(context, state, today),
              ),
              Container(
                decoration: AppTheme.cardDecoration(),
                child: todayTasks.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(18),
                        child: Text('No tasks for today. Tap + Add Task.', style: TextStyle(color: AppTheme.textMuted)),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: todayTasks.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final task = todayTasks[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                            child: Row(
                              children: [
                                Icon(
                                  task.isBig3 ? Icons.star_rounded : Icons.fiber_manual_record,
                                  size: task.isBig3 ? 20 : 10,
                                  color: task.isBig3 ? AppTheme.primaryPurple : AppTheme.textMuted,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      CustomModals.showEditTask(context, task, (newTitle) {
                                        state.editTask(today, index, newTitle);
                                      });
                                    },
                                    child: Text(
                                      task.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: task.isBig3 ? FontWeight.w600 : FontWeight.w400,
                                        color: task.isDone ? AppTheme.textSecondary : AppTheme.textPrimary,
                                        decoration: task.isDone ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close_rounded, size: 16, color: AppTheme.textMuted),
                                  onPressed: () => state.deleteTask(today, index),
                                ),
                                CustomCheckbox(
                                  value: task.isDone,
                                  activeColor: task.isBig3 ? AppTheme.primaryPurple : AppTheme.primaryOrange,
                                  onChanged: (val) {
                                    state.toggleTask(today, index);
                                    if (val) {
                                      ConfettiOverlay.trigger(context, particleCount: 14);
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),

        // Section: Rate your day (Staggered 6)
        StaggeredEntrance(
          index: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Rate your day'),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              energy >= 8 ? '🚀' : (energy >= 5 ? '⚡' : '😴'),
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            const Text('Daily Energy Level', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          ],
                        ),
                        Text(
                          '$energy / 10',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryOrange, fontSize: 17),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppTheme.primaryOrange,
                        inactiveTrackColor: AppTheme.surfaceLight,
                        thumbColor: AppTheme.primaryOrange,
                        overlayColor: AppTheme.primaryOrange.withOpacity(0.2),
                        trackHeight: 6,
                      ),
                      child: Slider(
                        min: 1,
                        max: 10,
                        divisions: 9,
                        value: energy.toDouble(),
                        onChanged: (val) => state.setEnergy(today, val.round()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 95),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double percentage;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.color,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          ],
        ),
        Text(
          value,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color),
        ),
      ],
    );
  }
}

