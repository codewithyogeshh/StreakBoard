import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import 'main_navigation_screen.dart';

class StudyTimerScreen extends StatefulWidget {
  final AppState state;

  const StudyTimerScreen({super.key, required this.state});

  @override
  State<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends State<StudyTimerScreen>
    with SingleTickerProviderStateMixin {
  // Timer state
  int _focusDuration = 25; // minutes
  int _breakDuration = 5; // minutes
  int _longBreakDuration = 15; // minutes
  int _cycles = 3; // number of focus cycles
  
  // Current timer state
  Timer? _timer;
  int _currentTime = 0; // in seconds
  bool _isRunning = false;
  bool _isBreak = false;
  int _currentCycle = 0;
  int _completedCycles = 0;
  
  // Session state
  int _totalSessions = 0;
  int _todaySessions = 0;
  DateTime? _lastSessionDate;
  
  // Alarm state
  List<Alarm> _alarms = [];
  bool _notificationsEnabled = true;
  
  // UI state
  bool _showSettings = false;
  String _motivationalMessage = 'Ready to focus?';
  double _progressValue = 0.0;
  
  // Animation controller
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _loadTimerState();
    _loadAlarms();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }
  
  void _loadTimerState() {
    final today = DateTime.now();
    final todayKey = AppState.dateKey(today);
    
    // Load today's sessions
    if (_lastSessionDate?.day == today.day && 
        _lastSessionDate?.month == today.month && 
        _lastSessionDate?.year == today.year) {
      _todaySessions = widget.state.studySessions[todayKey] ?? 0;
    }
    
    _totalSessions = widget.state.totalStudySessions;
    _lastSessionDate = widget.state.lastStudySession;
  }
  
  void _loadAlarms() {
    _alarms = widget.state.alarms;
  }
  
  void _saveTimerState() {
    final today = DateTime.now();
    final todayKey = AppState.dateKey(today);
    
    widget.state.studySessions[todayKey] = _todaySessions;
    widget.state.totalStudySessions = _totalSessions;
    widget.state.lastStudySession = _lastSessionDate;
    widget.state.alarms = _alarms;
    widget.state.saveToStorage();
  }
  
  void _startTimer() {
    if (_isRunning) return;
    
    setState(() {
      _isRunning = true;
      _currentTime = _isBreak ? _breakDuration * 60 : _focusDuration * 60;
      _progressValue = 0.0;
    });
    
    _updateMotivationalMessage();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentTime > 0) {
          _currentTime--;
          _progressValue = (_currentTime / (_isBreak ? _breakDuration * 60 : _focusDuration * 60));
        } else {
          _onTimerComplete();
        }
      });
    });
  }
  
  void _pauseTimer() {
    if (!_isRunning) return;
    
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }
  
  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _currentTime = _isBreak ? _breakDuration * 60 : _focusDuration * 60;
      _progressValue = 0.0;
      _updateMotivationalMessage();
    });
  }
  
  void _onTimerComplete() {
    _timer?.cancel();
    
    setState(() {
      _isRunning = false;
      _isBreak = !_isBreak;
      
      if (_isBreak) {
        // If it's a long break (after all cycles)
        if (_currentCycle >= _cycles - 1) {
          _currentTime = _longBreakDuration * 60;
        } else {
          _currentTime = _breakDuration * 60;
        }
        _updateMotivationalMessage();
      } else {
        // Focus period completed
        _completedCycles++;
        _currentCycle++;
        
        if (_currentCycle < _cycles) {
          _currentTime = _focusDuration * 60;
          _updateMotivationalMessage();
        } else {
          // All cycles completed
          _currentTime = _longBreakDuration * 60;
          _updateMotivationalMessage();
          _completeSession();
        }
      }
      
      _progressValue = 0.0;
    });
    
    _playCompletionSound();
    _scheduleAlarm();
  }
  
  void _updateMotivationalMessage() {
    final messages = [
      'Ready to focus?',
      'Time to dive in!',
      'Let\'s make progress!',
      'Stay focused!',
      'You can do this!',
      'Keep going strong!',
      'Almost there!',
      'Great job!',
    ];
    
    if (_isBreak) {
      if (_currentCycle >= _cycles - 1) {
        _motivationalMessage = 'Long break time!';
      } else {
        _motivationalMessage = 'Break time!';
      }
    } else {
      _motivationalMessage = messages[Random().nextInt(messages.length)];
    }
  }
  
  void _completeSession() {
    final today = DateTime.now();
    final todayKey = AppState.dateKey(today);
    
    setState(() {
      _todaySessions++;
      _totalSessions++;
      _lastSessionDate = today;
    });
    
    _saveTimerState();
    _showSessionCompleteDialog();
  }
  
  void _playCompletionSound() {
    // Play completion sound
    // In a real app, you would use audio player to play a sound
  }
  
  void _scheduleAlarm() {
    if (!_notificationsEnabled) return;
    
    // Schedule notification for timer completion
    // In a real app, you would use notification services
  }
  
  void _showSessionCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Session Complete!',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'You completed ${_completedCycles} focus cycles! Great job!',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: AppTheme.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }
  
  void _addAlarm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Add Study Alarm',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Label',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      hintText: 'HH:MM',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Repeat',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Daily', 'Weekdays', 'Weekends', 'Once'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {},
                  ),
                ),
              ],
            ),
          ],
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
              _saveTimerState();
            },
            child: Text(
              'Add',
              style: TextStyle(color: AppTheme.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }
  
  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  String _getSessionLabel() {
    if (_isBreak) {
      if (_currentCycle >= _cycles - 1) {
        return 'Long Break';
      } else {
        return 'Break';
      }
    } else {
      return 'Focus';
    }
  }
  
  Color _getSessionColor() {
    if (_isBreak) {
      if (_currentCycle >= _cycles - 1) {
        return AppTheme.primaryPurple;
      } else {
        return AppTheme.primaryRed;
      }
    } else {
      return AppTheme.primaryBlue;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: AppTheme.ambientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
                    ),
                    Text(
                      'Study Timer',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showSettings = !_showSettings;
                        });
                      },
                      icon: Icon(Icons.settings, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
              
              // Timer Display
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated container for the timer
                      AnimatedScale(
                        scale: _pulseAnimation.value,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            color: _getSessionColor().withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _getSessionColor().withOpacity(0.3),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _getSessionColor().withOpacity(0.2),
                                blurRadius: 30,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _getSessionLabel(),
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _getSessionColor(),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatTime(_currentTime),
                                  style: GoogleFonts.inter(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${(_progressValue * 100).toInt()}%',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Motivational message
                      Text(
                        _motivationalMessage,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Progress bar
                      Container(
                        width: 280,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: LinearProgressIndicator(
                          value: _progressValue,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(_getSessionColor()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Controls
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Reset button
                    _buildControlButton(
                      icon: Icons.replay,
                      label: 'Reset',
                      color: AppTheme.textSecondary,
                      onTap: _resetTimer,
                    ),
                    
                    // Pause/Play button
                    _buildControlButton(
                      icon: _isRunning ? Icons.pause : Icons.play_arrow,
                      label: _isRunning ? 'Pause' : 'Start',
                      color: _getSessionColor(),
                      onTap: _isRunning ? _pauseTimer : _startTimer,
                    ),
                    
                    // Skip button
                    _buildControlButton(
                      icon: Icons.skip_next,
                      label: 'Skip',
                      color: AppTheme.textSecondary,
                      onTap: () {
                        _timer?.cancel();
                        setState(() {
                          _isRunning = false;
                          if (_isBreak) {
                            _currentCycle++;
                            if (_currentCycle < _cycles) {
                              _currentTime = _focusDuration * 60;
                            } else {
                              _currentTime = _longBreakDuration * 60;
                            }
                          } else {
                            _currentCycle++;
                            if (_currentCycle < _cycles) {
                              _currentTime = _focusDuration * 60;
                            } else {
                              _currentTime = _longBreakDuration * 60;
                            }
                          }
                          _isBreak = !_isBreak;
                          _updateMotivationalMessage();
                          _progressValue = 0.0;
                        });
                      },
                    ),
                  ],
                ),
              ),
              
              // Session stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Today Sessions',
                      '$_todaySessions',
                      Icons.today,
                      AppTheme.primaryBlue,
                    ),
                    _buildStatItem(
                      'Total Sessions',
                      '$_totalSessions',
                      Icons.fitness_center,
                      AppTheme.primaryPurple,
                    ),
                    _buildStatItem(
                      'Current Cycle',
                      '${_completedCycles}/${_cycles}',
                      Icons.repeat,
                      AppTheme.primaryRed,
                    ),
                  ],
                ),
              ),
              
              // Alarm section
              if (!_showSettings) ...[
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Study Alarms',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          IconButton(
                            onPressed: _addAlarm,
                            icon: Icon(Icons.add, color: AppTheme.primaryBlue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.border, width: 1),
                        ),
                        child: _alarms.isEmpty
                            ? Center(
                                child: Text(
                                  'No alarms set',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.all(12),
                                itemCount: _alarms.length,
                                itemBuilder: (context, index) {
                                  final alarm = _alarms[index];
                                  return Container(
                                    width: 80,
                                    margin: const EdgeInsets.symmetric(horizontal: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceLight,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppTheme.border, width: 1),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.alarm,
                                          color: AppTheme.primaryBlue,
                                          size: 24,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          alarm.label,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textPrimary,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          alarm.time,
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            color: AppTheme.textSecondary,
                                          ),
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
              ],
              
              // Settings section
              if (_showSettings) ...[
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Timer Settings',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSettingsRow('Focus Duration', '${_focusDuration} min'),
                      _buildSettingsRow('Break Duration', '${_breakDuration} min'),
                      _buildSettingsRow('Long Break', '${_longBreakDuration} min'),
                      _buildSettingsRow('Cycles', '$_cycles'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.notifications, color: AppTheme.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            'Enable Notifications',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: _notificationsEnabled,
                            onChanged: _toggleNotifications,
                            activeColor: AppTheme.primaryBlue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSettingsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
