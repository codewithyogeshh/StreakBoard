import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import 'today_screen.dart';
import 'month_screen.dart';
import 'week_screen.dart';
import 'money_screen.dart';
import 'ranks_screen.dart';
import 'study_timer_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final AppState state;

  const MainNavigationScreen({super.key, required this.state});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  PageController? _pageController;

  PageController get pageController =>
      _pageController ??= PageController(initialPage: _currentIndex);

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      HapticFeedback.selectionClick();
      setState(() => _currentIndex = index);
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      TodayScreen(state: widget.state),
      MonthScreen(state: widget.state),
      WeekScreen(state: widget.state),
      MoneyScreen(state: widget.state),
      RanksScreen(state: widget.state),
      StudyTimerScreen(state: widget.state),
    ];

    final isDark = widget.state.isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.bg : AppTheme.lightBg,
      body: AppTheme.ambientBackground(
        isDark: isDark,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top Header with User Profile
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    // User Avatar (tappable to open settings)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(state: widget.state),
                          ),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryPurple, AppTheme.primaryRed],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryPurple.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.state.userName?.isNotEmpty == true
                                ? widget.state.userName![0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // User Name (tappable to open settings)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SettingsScreen(state: widget.state),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.state.userName?.isNotEmpty == true
                                  ? 'Welcome back, ${widget.state.userName}'
                                  : 'Welcome',
                              style: TextStyle(
                                color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.state.userEmail?.isNotEmpty == true
                                  ? widget.state.userEmail!
                                  : 'streakboard@user.com',
                              style: TextStyle(
                                color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Settings/Profile Icon
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(state: widget.state),
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.surfaceLight : AppTheme.lightSurfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppTheme.border : AppTheme.lightBorder,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.settings_rounded,
                          color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // PageView Content
              Expanded(
                child: Stack(
                  children: [
                    // GPU-Accelerated Smooth PageView Transitions
                    PageView(
                      controller: pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: screens,
                    ),

                    // Floating Frosted Glass Bottom Navigation Bar with Liquid Sliding Pill
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: MediaQuery.of(context).padding.bottom + 12,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                height: 64,
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF141418).withOpacity(0.88)
                                      : Colors.white.withOpacity(0.92),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.14)
                                        : const Color(0xFFCBD5E1),
                                    width: 1.1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.black.withOpacity(0.65)
                                          : Colors.black.withOpacity(0.08),
                                      blurRadius: 28,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Smooth Sliding Pill Active Indicator (7 items)
                                    AnimatedAlign(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeOutCubic,
                                      alignment: Alignment(-1.0 + (_currentIndex * (2.0 / 6.0)), 0.0),
                                      child: FractionallySizedBox(
                                        widthFactor: 1.0 / 7.0,
                                        heightFactor: 1.0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0xFF26262E)
                                                : const Color(0xFFE2E8F0),
                                            borderRadius: BorderRadius.circular(18),
                                            border: Border.all(
                                              color: isDark
                                                  ? Colors.white.withOpacity(0.12)
                                                  : AppTheme.primaryBlue.withOpacity(0.35),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppTheme.primaryBlue.withOpacity(isDark ? 0.12 : 0.08),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Interactive Navigation Buttons
                                    Row(
                                      children: [
                                        _buildNavItem(0, Icons.adjust_rounded, 'Today'),
                                        _buildNavItem(1, Icons.calendar_month_rounded, 'Month'),
                                        _buildNavItem(2, Icons.view_week_rounded, 'Week'),
                                        _buildNavItem(3, Icons.account_balance_wallet_rounded, 'Money'),
                                        _buildNavItem(4, Icons.emoji_events_rounded, 'Ranks'),
                                        _buildNavItem(5, Icons.timer_rounded, 'Study'),
                                        _buildLogoutNavItem(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
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
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.12 : 0.95,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? AppTheme.primaryBlue : AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
                letterSpacing: isSelected ? 0.2 : 0,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutNavItem() {
    return Expanded(
      child: GestureDetector(
        onTap: _logout,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              size: 20,
              color: AppTheme.primaryRed,
            ),
            const SizedBox(height: 3),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Logout',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.state.logout();
            },
            child: Text(
              'Logout',
              style: TextStyle(color: AppTheme.primaryRed),
            ),
          ),
        ],
      ),
    );
  }
}

