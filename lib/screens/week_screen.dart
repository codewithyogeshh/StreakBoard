import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../widgets/stat_cards.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/custom_modals.dart';
import '../widgets/app_animations.dart';

class WeekScreen extends StatefulWidget {
  final AppState state;

  const WeekScreen({super.key, required this.state});

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  late DateTime _selectedDay;
  late DateTime _monday;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _monday = AppState.mondayOfWeek(_selectedDay);
  }

  void _shiftWeek(int days) {
    HapticFeedback.selectionClick();
    setState(() {
      _monday = _monday.add(Duration(days: days));
      _selectedDay = _monday;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sunday = _monday.add(const Duration(days: 6));
    final weekDateRangeStr =
        '${DateFormat('MMM d').format(_monday)} – ${DateFormat('MMM d').format(sunday)}';

    int totalTasks = 0;
    int completedTasks = 0;
    for (int i = 0; i < 7; i++) {
      final d = _monday.add(Duration(days: i));
      final k = AppState.dateKey(d);
      final list = widget.state.tasks[k] ?? [];
      totalTasks += list.length;
      completedTasks += list.where((t) => t.isDone).length;
    }
    final weekScorePct = totalTasks == 0 ? 0 : (completedTasks * 100 ~/ totalTasks);

    final selectedKey = AppState.dateKey(_selectedDay);
    final mondayKey = AppState.dateKey(_monday);
    final boss = widget.state.bossTasks[mondayKey];

    final dayTasks = widget.state.tasks[selectedKey] ?? [];
    final dayHabits = widget.state.getHabitsForDate(_selectedDay);

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
                weekDateRangeStr.toUpperCase(),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'This Week',
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

        // Week Score Card with navigation chevrons (Staggered 1)
        StaggeredEntrance(
          index: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration(),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WEEK SCORE', style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    AnimatedNumberText(
                      value: weekScorePct.toDouble(),
                      suffix: '%',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SmoothProgressBar(
                        value: totalTasks == 0 ? 0.0 : completedTasks / totalTasks,
                        height: 7,
                        gradientColors: const [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                        glow: true,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$completedTasks / $totalTasks tasks done',
                        style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, color: AppTheme.primaryBlue),
                  onPressed: () => _shiftWeek(-7),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, color: AppTheme.primaryBlue),
                  onPressed: () => _shiftWeek(7),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Weekly Boss Task Card with Crown Wiggle (Staggered 2)
        StaggeredEntrance(
          index: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration(
              glow: boss?.isDone != true,
              glowColor: AppTheme.primaryOrange,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryOrange.withOpacity(0.2), AppTheme.primaryRed.withOpacity(0.15)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.35)),
                  ),
                  alignment: Alignment.center,
                  child: const AnimatedPulseIcon(
                    isWiggle: true,
                    child: Text('👑', style: TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: GestureDetector(
                    onTap: () => CustomModals.showBossTask(context, widget.state, _monday),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'WEEKLY BOSS TASK',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryOrange,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryOrange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '+100 XP',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          boss != null ? boss.title : 'Tap to set weekly boss task',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: boss?.isDone == true ? AppTheme.textSecondary : AppTheme.textPrimary,
                            decoration: boss?.isDone == true ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (boss != null)
                  CustomCheckbox(
                    value: boss.isDone,
                    activeColor: AppTheme.primaryOrange,
                    onChanged: (val) {
                      final defeated = widget.state.toggleBossTask(_monday);
                      if (defeated) {
                        ConfettiOverlay.trigger(
                          context,
                          toastMessage: 'Boss Defeated! +100 XP 👑',
                          particleCount: 50,
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Horizontal 7-Day Selector (Staggered 3)
        StaggeredEntrance(
          index: 3,
          child: Row(
            children: List.generate(7, (i) {
              final day = _monday.add(Duration(days: i));
              final isSelected = day.year == _selectedDay.year &&
                  day.month == _selectedDay.month &&
                  day.day == _selectedDay.day;
              const weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
              final dayPct = widget.state.pctForDate(day);

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedDay = day);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.textPrimary : AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppTheme.textPrimary : AppTheme.border,
                        width: 1.2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          weekdays[i],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? const Color(0xFF09090B) : AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? const Color(0xFF09090B) : AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Dot indicator for habit completions
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dayPct >= 1.0
                                ? AppTheme.primaryBlue
                                : (dayPct > 0 ? AppTheme.primaryOrange : Colors.transparent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 18),

        // Selected Day Title Badge (Staggered 4)
        StaggeredEntrance(
          index: 4,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                DateFormat('EEEE · MMMM d').format(_selectedDay),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Tasks for selected day (Staggered 5)
        StaggeredEntrance(
          index: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: "Tasks for this day",
                actionText: '+ Add Task',
                onAction: () => CustomModals.showAddTask(context, widget.state, _selectedDay),
              ),
              Container(
                decoration: AppTheme.cardDecoration(),
                child: dayTasks.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(18),
                        child: Text('No tasks for this day.', style: TextStyle(color: AppTheme.textMuted)),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dayTasks.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final task = dayTasks[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                Icon(
                                  task.isBig3 ? Icons.star_rounded : Icons.fiber_manual_record,
                                  size: task.isBig3 ? 19 : 10,
                                  color: task.isBig3 ? AppTheme.primaryPurple : AppTheme.textMuted,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      CustomModals.showEditTask(context, task, (newTitle) {
                                        widget.state.editTask(_selectedDay, index, newTitle);
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
                                  onPressed: () => widget.state.deleteTask(_selectedDay, index),
                                ),
                                CustomCheckbox(
                                  value: task.isDone,
                                  activeColor: task.isBig3 ? AppTheme.primaryPurple : AppTheme.primaryOrange,
                                  onChanged: (val) {
                                    widget.state.toggleTask(_selectedDay, index);
                                    if (val) ConfettiOverlay.trigger(context, particleCount: 14);
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

        // Habits scheduled on selected day (Staggered 6)
        StaggeredEntrance(
          index: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Scheduled Habits'),
              Container(
                decoration: AppTheme.cardDecoration(),
                child: dayHabits.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(18),
                        child: Text('No habits scheduled on this day.', style: TextStyle(color: AppTheme.textMuted)),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dayHabits.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final habit = dayHabits[index];
                          final isDone = widget.state.isHabitDone(_selectedDay, habit.id);

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: habit.color.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(habit.emoji, style: const TextStyle(fontSize: 19)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    habit.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isDone ? AppTheme.textSecondary : AppTheme.textPrimary,
                                      decoration: isDone ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ),
                                CustomCheckbox(
                                  value: isDone,
                                  activeColor: habit.color,
                                  onChanged: (val) {
                                    final doneNow = widget.state.toggleHabit(_selectedDay, habit.id);
                                    if (doneNow) ConfettiOverlay.trigger(context, particleCount: 14);
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
        const SizedBox(height: 95),
      ],
    );
  }
}

