import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import 'app_animations.dart';

class LevelHeaderCard extends StatelessWidget {
  final AppState state;

  const LevelHeaderCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: AppTheme.cardDecoration(glow: true),
      child: Row(
        children: [
          // Shield Avatar with glowing background
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.2),
                  AppTheme.primaryPurple.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.35), width: 1.2),
            ),
            alignment: Alignment.center,
            child: const Text('🛡️', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),

          // Level and XP Progress Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'LVL ${state.level}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '${(state.levelProgress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AnimatedNumberText(
                      value: state.totalXp.toDouble(),
                      suffix: ' XP',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SmoothProgressBar(
                  value: state.levelProgress,
                  height: 7,
                  gradientColors: const [Color(0xFF14B8A6), Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                  glow: true,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Streak Badge with Animated Pulse Flame
          _StatMiniPill(
            label: 'STREAK',
            value: state.overallStreak().toDouble(),
            emoji: '🔥',
            isPulse: true,
            valueColor: AppTheme.primaryOrange,
          ),
          const SizedBox(width: 12),

          // Perfect Days Badge
          _StatMiniPill(
            label: 'PERFECT',
            value: state.perfectDateKeys.length.toDouble(),
            emoji: '⭐',
            isPulse: false,
            valueColor: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }
}

class _StatMiniPill extends StatelessWidget {
  final String label;
  final double value;
  final String emoji;
  final bool isPulse;
  final Color valueColor;

  const _StatMiniPill({
    required this.label,
    required this.value,
    required this.emoji,
    required this.isPulse,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final emojiWidget = Text(emoji, style: const TextStyle(fontSize: 13));

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: AppTheme.textMuted,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPulse) AnimatedPulseIcon(child: emojiWidget) else emojiWidget,
            const SizedBox(width: 3),
            AnimatedNumberText(
              value: value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8, left: 4, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          if (actionText != null && onAction != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onAction!();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.25)),
                ),
                child: Text(
                  actionText!,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CustomCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = AppTheme.primaryGreen,
  });

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onChanged(!widget.value);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: widget.value ? widget.activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.value ? widget.activeColor : AppTheme.borderSubtle,
              width: 1.8,
            ),
            boxShadow: widget.value
                ? [
                    BoxShadow(
                      color: widget.activeColor.withOpacity(0.45),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: widget.value
              ? const Icon(
                  Icons.check_rounded,
                  size: 19,
                  color: Color(0xFF09090B),
                )
              : null,
        ),
      ),
    );
  }
}

