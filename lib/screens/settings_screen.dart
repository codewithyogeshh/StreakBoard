import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';

class SettingsScreen extends StatefulWidget {
  final AppState state;

  const SettingsScreen({super.key, required this.state});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;
    final surfaceColor = isDark ? AppTheme.surface : AppTheme.lightSurface;
    final surfaceLightColor = isDark ? AppTheme.surfaceLight : AppTheme.lightSurfaceLight;
    final borderColor = isDark ? AppTheme.border : AppTheme.lightBorder;
    final textPrimaryColor = isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary;
    final textSecondaryColor = isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary;
    final textMutedColor = isDark ? AppTheme.textMuted : AppTheme.lightTextMuted;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bg : AppTheme.lightBg,
      body: AppTheme.ambientBackground(
        isDark: isDark,
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: surfaceLightColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: 1),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: textPrimaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Settings',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: textPrimaryColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Preferences & Account',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Settings Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  children: [
                    // 1. Profile Summary Card
                    _buildProfileCard(
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      textPrimary: textPrimaryColor,
                      textSecondary: textSecondaryColor,
                    ),

                    const SizedBox(height: 20),

                    // 2. Appearance & Theme Section
                    _buildSectionHeader('APPEARANCE & THEME', textMutedColor),
                    const SizedBox(height: 10),
                    _buildThemeSelector(
                      isDark: isDark,
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      textPrimary: textPrimaryColor,
                      textSecondary: textSecondaryColor,
                    ),

                    const SizedBox(height: 20),

                    // 3. Notifications & Habits Section
                    _buildSectionHeader('PREFERENCES', textMutedColor),
                    const SizedBox(height: 10),
                    _buildPreferencesCard(
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      textPrimary: textPrimaryColor,
                      textSecondary: textSecondaryColor,
                    ),

                    const SizedBox(height: 20),

                    // 4. Data Management Section
                    _buildSectionHeader('DATA & PRIVACY', textMutedColor),
                    const SizedBox(height: 10),
                    _buildDataManagementCard(
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      textPrimary: textPrimaryColor,
                      textSecondary: textSecondaryColor,
                    ),

                    const SizedBox(height: 24),

                    // 5. Logout Card Button
                    _buildLogoutCard(
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                    ),

                    const SizedBox(height: 24),

                    // App Version Footer
                    Center(
                      child: Text(
                        'StreakBoard v2.1 • Built for Focus & Productivity',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: textMutedColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Profile Card ---
  Widget _buildProfileCard({
    required Color surfaceColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final userName = widget.state.userName?.isNotEmpty == true
        ? widget.state.userName!
        : 'StreakBoard User';
    final userEmail = widget.state.userEmail?.isNotEmpty == true
        ? widget.state.userEmail!
        : 'user@streakboard.com';
    final initial = userName[0].toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // User Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.inter(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userEmail,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Edit Profile Button
              IconButton(
                onPressed: _showEditProfileDialog,
                icon: const Icon(Icons.edit_rounded, size: 20),
                color: AppTheme.primaryBlue,
                tooltip: 'Edit Profile',
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('Habits', '${widget.state.habits.length}', Icons.check_circle_rounded, AppTheme.primaryBlue, textSecondary),
              _buildMiniStat('Streak', '${widget.state.overallStreak()}d', Icons.local_fire_department_rounded, AppTheme.primaryOrange, textSecondary),
              _buildMiniStat('Total XP', '${widget.state.totalXp}', Icons.stars_rounded, AppTheme.primaryPurple, textSecondary),
              _buildMiniStat('Study', '${widget.state.totalStudySessions}', Icons.timer_rounded, AppTheme.primaryGreen, textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color, Color textSecondary) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // --- Theme Selector ---
  Widget _buildThemeSelector({
    required bool isDark,
    required Color surfaceColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Column(
      children: [
        // Dual Visual Cards for Dark & Light
        Row(
          children: [
            // Dark Mode Card
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.state.setThemeMode(true);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppTheme.primaryBlue : AppTheme.border,
                      width: isDark ? 2 : 1,
                    ),
                    boxShadow: isDark
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.dark_mode_rounded,
                              color: Color(0xFF38BDF8),
                              size: 20,
                            ),
                          ),
                          if (isDark)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppTheme.primaryBlue,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Dark Mode',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Sleek & Deep OLED',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Light Mode Card
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.state.setThemeMode(false);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: !isDark ? AppTheme.primaryBlue : const Color(0xFFCBD5E1),
                      width: !isDark ? 2 : 1,
                    ),
                    boxShadow: !isDark
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.light_mode_rounded,
                              color: Color(0xFFF59E0B),
                              size: 20,
                            ),
                          ),
                          if (!isDark)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppTheme.primaryBlue,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Light Mode',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Crisp & Clean',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Preferences Card ---
  Widget _buildPreferencesCard({
    required Color surfaceColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Material(
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Push Notifications
          SwitchListTile(
            value: widget.state.notificationsEnabled,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              widget.state.toggleNotifications(val);
            },
            activeThumbColor: AppTheme.primaryBlue,
            title: Text(
              'Habit Reminders & Alerts',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            subtitle: Text(
              'Notify before study sessions and habit deadlines',
              style: GoogleFonts.inter(fontSize: 11.5, color: textSecondary),
            ),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.notifications_active_rounded, color: AppTheme.primaryBlue, size: 20),
            ),
          ),
          const Divider(height: 1),
          // Haptic Feedback Indicator
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.vibration_rounded, color: AppTheme.primaryPurple, size: 20),
            ),
            title: Text(
              'Tactile Haptics',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            subtitle: Text(
              'Subtle vibration on checking off habits and completions',
              style: GoogleFonts.inter(fontSize: 11.5, color: textSecondary),
            ),
            trailing: Text(
              'Active',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Data Management Card ---
  Widget _buildDataManagementCard({
    required Color surfaceColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Material(
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Reset Habit Progress
          ListTile(
            onTap: _showResetConfirmDialog,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.restart_alt_rounded, color: AppTheme.primaryOrange, size: 20),
            ),
            title: Text(
              'Reset Habit Progress',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            subtitle: Text(
              'Clear completions, logs, and energy ratings',
              style: GoogleFonts.inter(fontSize: 11.5, color: textSecondary),
            ),
            trailing: const Icon(Icons.chevron_right_rounded, size: 20),
          ),
        ],
      ),
    );
  }

  // --- Logout Card Button ---
  Widget _buildLogoutCard({
    required Color surfaceColor,
    required Color borderColor,
  }) {
    return GestureDetector(
      onTap: _confirmLogout,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.primaryRed.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryRed.withOpacity(0.35),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppTheme.primaryRed,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Log Out',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sign out of your account on this device',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: AppTheme.primaryRed.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.primaryRed,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // --- Section Header Helper ---
  Widget _buildSectionHeader(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // --- Edit Profile Dialog ---
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: widget.state.userName ?? '');
    final emailController = TextEditingController(text: widget.state.userEmail ?? '');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: widget.state.isDarkMode ? AppTheme.surface : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: widget.state.isDarkMode ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.state.updateProfile(
                name: nameController.text.trim(),
                email: emailController.text.trim(),
              );
              Navigator.pop(dialogCtx);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- Reset Confirm Dialog ---
  void _showResetConfirmDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: widget.state.isDarkMode ? AppTheme.surface : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.primaryOrange),
            const SizedBox(width: 8),
            Text(
              'Reset Progress',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: widget.state.isDarkMode ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to reset all habit check-ins, tasks, and study records? This cannot be undone.',
          style: GoogleFonts.inter(
            fontSize: 13.5,
            color: widget.state.isDarkMode ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.state.resetAllHabitData();
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Progress has been reset'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Reset Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- Logout Action ---
  void _confirmLogout() {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: widget.state.isDarkMode ? AppTheme.surface : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded, color: AppTheme.primaryRed, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'Log Out',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: widget.state.isDarkMode ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: GoogleFonts.inter(
            fontSize: 13.5,
            color: widget.state.isDarkMode ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx); // pop dialog
              Navigator.of(context).popUntil((route) => route.isFirst); // pop settings screen
              widget.state.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
