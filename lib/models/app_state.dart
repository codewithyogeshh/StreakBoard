import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class Alarm {
  final String label;
  final String time;
  final String repeat;

  Alarm({
    required this.label,
    required this.time,
    required this.repeat,
  });

  Map<String, dynamic> toJson() => {
    'l': label,
    't': time,
    'r': repeat,
  };

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      label: json['l'] as String? ?? '',
      time: json['t'] as String? ?? '',
      repeat: json['r'] as String? ?? 'Daily',
    );
  }
}

class Habit {
  final int id;
  String name;
  String colorHex;
  String emoji;
  List<int> scheduledDays; // 1 = Monday ... 7 = Sunday

  Habit({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.emoji,
    required this.scheduledDays,
  });

  Color get color {
    final hex = colorHex.replaceFirst('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    } else if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    return const Color(0xFF14B8A6);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'n': name,
    'c': colorHex,
    'e': emoji,
    'w': scheduledDays,
  };

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as int,
      name: json['n'] as String? ?? 'Habit',
      colorHex: json['c'] as String? ?? '#2EE6C5',
      emoji: json['e'] as String? ?? '⭐',
      scheduledDays: (json['w'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [1, 2, 3, 4, 5, 6, 7],
    );
  }
}

class DailyTask {
  String title;
  bool isDone;
  bool isBig3;

  DailyTask({
    required this.title,
    this.isDone = false,
    this.isBig3 = false,
  });

  Map<String, dynamic> toJson() => {
    't': title,
    'd': isDone,
    'b': isBig3,
  };

  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      title: json['t'] as String? ?? '',
      isDone: json['d'] as bool? ?? false,
      isBig3: json['b'] as bool? ?? false,
    );
  }
}

class Goal {
  String name;
  double target;
  double current;
  String unit;

  Goal({
    required this.name,
    required this.target,
    this.current = 0,
    required this.unit,
  });

  Map<String, dynamic> toJson() => {
    'n': name,
    't': target,
    'c': current,
    'u': unit,
  };

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      name: json['n'] as String? ?? '',
      target: (json['t'] as num?)?.toDouble() ?? 100,
      current: (json['c'] as num?)?.toDouble() ?? 0,
      unit: json['u'] as String? ?? '',
    );
  }
}

class Expense {
  String title;
  double amount;
  String category;
  String dateKey; // YYYY-MM-DD

  Expense({
    required this.title,
    required this.amount,
    required this.category,
    required this.dateKey,
  });

  Map<String, dynamic> toJson() => {
    't': title,
    'a': amount,
    'c': category,
    'd': dateKey,
  };

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      title: json['t'] as String? ?? '',
      amount: (json['a'] as num?)?.toDouble() ?? 0,
      category: json['c'] as String? ?? 'Other',
      dateKey: json['d'] as String? ?? '',
    );
  }
}

class VisualTracker {
  String name;
  double target;
  double unitValue;
  double currentValue;
  bool isDebt;

  VisualTracker({
    required this.name,
    required this.target,
    required this.unitValue,
    this.currentValue = 0,
    required this.isDebt,
  });

  Map<String, dynamic> toJson() => {
    'n': name,
    't': target,
    'u': unitValue,
    'v': currentValue,
    'isDebt': isDebt,
  };

  factory VisualTracker.fromJson(Map<String, dynamic> json, {bool isDebt = false}) {
    return VisualTracker(
      name: json['n'] as String? ?? '',
      target: (json['t'] as num?)?.toDouble() ?? 0,
      unitValue: (json['u'] as num?)?.toDouble() ?? 1,
      currentValue: (json['v'] as num?)?.toDouble() ?? 0,
      isDebt: json['isDebt'] as bool? ?? isDebt,
    );
  }
}

class BossTask {
  String title;
  bool isDone;

  BossTask({required this.title, this.isDone = false});

  Map<String, dynamic> toJson() => {
    't': title,
    'd': isDone,
  };

  factory BossTask.fromJson(Map<String, dynamic> json) {
    return BossTask(
      title: json['t'] as String? ?? '',
      isDone: json['d'] as bool? ?? false,
    );
  }
}

class AppState extends ChangeNotifier {
  static const String _storageKey = 'streakboard_state_v1';

  List<Habit> habits = [];
  Map<String, List<int>> done = {}; // 'YYYY-MM-DD' -> [habitId]
  Map<String, List<DailyTask>> tasks = {}; // 'YYYY-MM-DD' -> [tasks]
  List<Expense> expenses = [];
  Map<String, int> energyRatings = {}; // 'YYYY-MM-DD' -> 1..10
  double monthlyBudget = 20000;
  List<Goal> goals = [];
  List<VisualTracker> debts = [];
  List<VisualTracker> savings = [];
  Map<String, BossTask> bossTasks = {}; // monday 'YYYY-MM-DD' -> BossTask

  bool isLoaded = false;

  // Authentication state
  bool isLoggedIn = false;
  String? userName;
  String? userEmail;

  // App Settings & Preferences
  bool isDarkMode = true;
  bool notificationsEnabled = true;

  // Study timer state
  Map<String, int> studySessions = {}; // 'YYYY-MM-DD' -> session count
  int totalStudySessions = 0;
  DateTime? lastStudySession;
  List<Alarm> alarms = [];

  static String dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  static DateTime parseDate(String k) => DateTime.parse('${k}T00:00:00');
  static DateTime mondayOfWeek(DateTime d) {
    final dayOffset = (d.weekday - 1);
    return DateTime(d.year, d.month, d.day - dayOffset);
  }

  AppState() {
    loadFromStorage();
  }

  void _seedDefaultData() {
    final names = [
      'Wake up at 06:00',
      'Meditation',
      'Gym & Cardio',
      'Deep Work (2h)',
      'Read 10 pages',
      'No refined sugar',
      'Sleep before 23:00',
    ];
    final emojis = ['⏰', '🧘', '🏋️', '🎯', '📖', '🚫', '🛏️'];
    final colors = [
      '#8B6CFF',
      '#4DA3FF',
      '#2EE6C5',
      '#A3E635',
      '#FFD166',
      '#FF5FA2',
      '#8B6CFF',
    ];

    habits = List.generate(names.length, (i) {
      return Habit(
        id: i + 1,
        name: names[i],
        colorHex: colors[i],
        emoji: emojis[i],
        scheduledDays: [1, 2, 3, 4, 5, 6, 7],
      );
    });

    monthlyBudget = 25000;
    goals = [
      Goal(name: 'Read Books', target: 12, current: 4, unit: 'books'),
      Goal(name: 'Run 100km', target: 100, current: 35, unit: 'km'),
    ];
    debts = [];
    savings = [
      VisualTracker(
        name: 'Emergency Fund',
        target: 50000,
        unitValue: 5000,
        currentValue: 20000,
        isDebt: false,
      ),
    ];
    expenses = [];
    bossTasks = {};
    done = {};
    tasks = {};
    energyRatings = {};
  }

  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_storageKey);
      if (dataStr != null) {
        final Map<String, dynamic> data = jsonDecode(dataStr);
        if (data['h'] != null) {
          habits = (data['h'] as List).map((e) => Habit.fromJson(e)).toList();
        }
        if (data['done'] != null) {
          done = (data['done'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, (v as List).map((i) => i as int).toList()),
          );
        }
        if (data['tasks'] != null) {
          tasks = (data['tasks'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, (v as List).map((t) => DailyTask.fromJson(t)).toList()),
          );
        }
        if (data['exp'] != null) {
          expenses = (data['exp'] as List).map((e) => Expense.fromJson(e)).toList();
        }
        if (data['en'] != null) {
          energyRatings = (data['en'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, (v as num).toInt()),
          );
        }
        if (data['bud'] != null) {
          monthlyBudget = (data['bud'] as num).toDouble();
        }
        if (data['goals'] != null) {
          goals = (data['goals'] as List).map((e) => Goal.fromJson(e)).toList();
        }
        if (data['debts'] != null) {
          debts = (data['debts'] as List).map((e) => VisualTracker.fromJson(e, isDebt: true)).toList();
        }
        if (data['sav'] != null) {
          savings = (data['sav'] as List).map((e) => VisualTracker.fromJson(e, isDebt: false)).toList();
        }
        if (data['boss'] != null) {
          bossTasks = (data['boss'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, BossTask.fromJson(v)),
          );
        }
        if (data['isLoggedIn'] != null) {
          isLoggedIn = data['isLoggedIn'] as bool? ?? false;
        }
        if (data['userName'] != null) {
          userName = data['userName'] as String?;
        }
        if (data['userEmail'] != null) {
          userEmail = data['userEmail'] as String?;
        }
        if (data['studySessions'] != null) {
          studySessions = (data['studySessions'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, (v as num).toInt()),
          );
        }
        if (data['totalStudySessions'] != null) {
          totalStudySessions = (data['totalStudySessions'] as num).toInt();
        }
        if (data['lastStudySession'] != null) {
          lastStudySession = DateTime.tryParse(data['lastStudySession'] as String);
        }
        if (data['alarms'] != null) {
          alarms = (data['alarms'] as List).map((a) => Alarm.fromJson(a)).toList();
        }
        if (data['isDarkMode'] != null) {
          isDarkMode = data['isDarkMode'] as bool? ?? true;
          AppTheme.isDarkTheme = isDarkMode;
        }
        if (data['notificationsEnabled'] != null) {
          notificationsEnabled = data['notificationsEnabled'] as bool? ?? true;
        }
      } else {
        _seedDefaultData();
      }
    } catch (_) {
      _seedDefaultData();
    }
    isLoaded = true;
    notifyListeners();
  }

  Future<void> saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> data = {
        'h': habits.map((e) => e.toJson()).toList(),
        'done': done,
        'tasks': tasks.map((k, v) => MapEntry(k, v.map((t) => t.toJson()).toList())),
        'exp': expenses.map((e) => e.toJson()).toList(),
        'en': energyRatings,
        'bud': monthlyBudget,
        'goals': goals.map((e) => e.toJson()).toList(),
        'debts': debts.map((e) => e.toJson()).toList(),
        'sav': savings.map((e) => e.toJson()).toList(),
        'boss': bossTasks.map((k, v) => MapEntry(k, v.toJson())),
        'isLoggedIn': isLoggedIn,
        'userName': userName,
        'userEmail': userEmail,
        'studySessions': studySessions,
        'totalStudySessions': totalStudySessions,
        'lastStudySession': lastStudySession?.toIso8601String(),
        'alarms': alarms.map((a) => a.toJson()).toList(),
        'isDarkMode': isDarkMode,
        'notificationsEnabled': notificationsEnabled,
      };
      await prefs.setString(_storageKey, jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving state: $e');
    }
  }

  void login(String name, String email) {
    isLoggedIn = true;
    userName = name;
    userEmail = email;
    saveToStorage();
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    userName = null;
    userEmail = null;
    saveToStorage();
    notifyListeners();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    AppTheme.isDarkTheme = isDarkMode;
    saveToStorage();
    notifyListeners();
  }

  void setThemeMode(bool dark) {
    if (isDarkMode != dark) {
      isDarkMode = dark;
      AppTheme.isDarkTheme = isDarkMode;
      saveToStorage();
      notifyListeners();
    }
  }

  void toggleNotifications(bool val) {
    notificationsEnabled = val;
    saveToStorage();
    notifyListeners();
  }

  void updateProfile({String? name, String? email}) {
    if (name != null) userName = name;
    if (email != null) userEmail = email;
    saveToStorage();
    notifyListeners();
  }

  void resetAllHabitData() {
    done = {};
    tasks = {};
    expenses = [];
    energyRatings = {};
    bossTasks = {};
    studySessions = {};
    totalStudySessions = 0;
    saveToStorage();
    notifyListeners();
  }

  // --- Calculations ---

  List<Habit> getHabitsForDate(DateTime d) {
    return habits.where((h) => h.scheduledDays.contains(d.weekday)).toList();
  }

  bool isHabitDone(DateTime d, int habitId) {
    final list = done[dateKey(d)];
    return list?.contains(habitId) ?? false;
  }

  double pctForDate(DateTime d) {
    final scheduled = getHabitsForDate(d);
    if (scheduled.isEmpty) return 0.0;
    final completed = scheduled.where((h) => isHabitDone(d, h.id)).length;
    return completed / scheduled.length;
  }

  int habitStreak(Habit h) {
    var d = DateTime.now();
    int count = 0;
    for (int g = 0; g < 400; g++) {
      if (h.scheduledDays.contains(d.weekday)) {
        if (isHabitDone(d, h.id)) {
          count++;
        } else if (g > 0) {
          break;
        }
      }
      d = d.subtract(const Duration(days: 1));
    }
    return count;
  }

  List<String> get perfectDateKeys {
    final list = done.keys.where((k) {
      final d = parseDate(k);
      final scheduled = getHabitsForDate(d);
      if (scheduled.isEmpty) return false;
      return scheduled.every((h) => done[k]?.contains(h.id) ?? false);
    }).toList();
    list.sort();
    return list;
  }

  int overallStreak() {
    var d = DateTime.now();
    int count = 0;
    if (pctForDate(d) < 1.0) {
      d = d.subtract(const Duration(days: 1));
    }
    while (habits.isNotEmpty && pctForDate(d) >= 1.0 && count < 3650) {
      count++;
      d = d.subtract(const Duration(days: 1));
    }
    return count;
  }

  int bestStreak() {
    int maxBest = 0;
    int current = 0;
    String? prev;
    for (final k in perfectDateKeys) {
      if (prev != null) {
        final expected = dateKey(parseDate(prev).add(const Duration(days: 1)));
        current = (expected == k) ? current + 1 : 1;
      } else {
        current = 1;
      }
      if (current > maxBest) maxBest = current;
      prev = k;
    }
    return maxBest;
  }

  int tasksDoneForDate(String k) {
    return (tasks[k] ?? []).where((t) => t.isDone).length;
  }

  int xpForDate(DateTime d) {
    final k = dateKey(d);
    final hDone = (done[k] ?? []).length;
    final tDone = tasksDoneForDate(k);
    return (hDone + tDone) * 10;
  }

  int get totalXp {
    int total = 0;
    for (final list in done.values) {
      total += list.length * 10;
    }
    for (final k in tasks.keys) {
      total += tasksDoneForDate(k) * 10;
    }
    for (final boss in bossTasks.values) {
      if (boss.isDone) total += 100;
    }
    return total;
  }

  int get level => (totalXp ~/ 500) + 1;
  double get levelProgress => (totalXp % 500) / 500.0;

  int weekXp(DateTime monday) {
    int total = 0;
    for (int i = 0; i < 7; i++) {
      total += xpForDate(monday.add(Duration(days: i)));
    }
    final boss = bossTasks[dateKey(monday)];
    if (boss?.isDone == true) {
      total += 100;
    }
    return total;
  }

  double totalSpentForMonth(DateTime m) {
    final prefix = DateFormat('yyyy-MM').format(m);
    return expenses
        .where((e) => e.dateKey.startsWith(prefix))
        .fold(0.0, (acc, e) => acc + e.amount);
  }

  double todaySpent(DateTime d) {
    final k = dateKey(d);
    return expenses
        .where((e) => e.dateKey == k)
        .fold(0.0, (acc, e) => acc + e.amount);
  }

  // --- Actions ---

  bool toggleHabit(DateTime d, int habitId) {
    final k = dateKey(d);
    final list = done[k] ?? [];
    bool isCompletedNow = false;
    if (list.contains(habitId)) {
      list.remove(habitId);
      isCompletedNow = false;
    } else {
      list.add(habitId);
      isCompletedNow = true;
    }
    done[k] = list;
    saveToStorage();
    notifyListeners();
    return isCompletedNow;
  }

  void addHabit(String name, List<int> scheduledDays) {
    final newId = habits.fold<int>(0, (prev, h) => h.id > prev ? h.id : prev) + 1;
    final color = AppTheme.habitColors[newId % AppTheme.habitColors.length];
    final hex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
    habits.add(Habit(
      id: newId,
      name: name,
      colorHex: hex,
      emoji: '⭐',
      scheduledDays: scheduledDays.isEmpty ? [1, 2, 3, 4, 5, 6, 7] : scheduledDays,
    ));
    saveToStorage();
    notifyListeners();
  }

  void deleteHabit(int id) {
    habits.removeWhere((h) => h.id == id);
    for (final list in done.values) {
      list.remove(id);
    }
    saveToStorage();
    notifyListeners();
  }

  void addTask(DateTime d, String title, bool isBig3) {
    final k = dateKey(d);
    final list = tasks[k] ?? [];
    list.add(DailyTask(title: title, isBig3: isBig3));
    tasks[k] = list;
    saveToStorage();
    notifyListeners();
  }

  void toggleTask(DateTime d, int index) {
    final k = dateKey(d);
    final list = tasks[k];
    if (list != null && index < list.length) {
      list[index].isDone = !list[index].isDone;
      saveToStorage();
      notifyListeners();
    }
  }

  void editTask(DateTime d, int index, String newTitle) {
    final k = dateKey(d);
    final list = tasks[k];
    if (list != null && index < list.length) {
      list[index].title = newTitle;
      saveToStorage();
      notifyListeners();
    }
  }

  void deleteTask(DateTime d, int index) {
    final k = dateKey(d);
    final list = tasks[k];
    if (list != null && index < list.length) {
      list.removeAt(index);
      saveToStorage();
      notifyListeners();
    }
  }

  void setEnergy(DateTime d, int rating) {
    energyRatings[dateKey(d)] = rating;
    saveToStorage();
    notifyListeners();
  }

  void setBossTask(DateTime monday, String title) {
    final k = dateKey(monday);
    final current = bossTasks[k];
    bossTasks[k] = BossTask(title: title, isDone: current?.isDone ?? false);
    saveToStorage();
    notifyListeners();
  }

  bool toggleBossTask(DateTime monday) {
    final k = dateKey(monday);
    final current = bossTasks[k];
    if (current != null) {
      current.isDone = !current.isDone;
      saveToStorage();
      notifyListeners();
      return current.isDone;
    }
    return false;
  }

  void addGoal(String name, double target, String unit) {
    goals.add(Goal(name: name, target: target, unit: unit));
    saveToStorage();
    notifyListeners();
  }

  bool addGoalProgress(int index, double amount) {
    if (index < goals.length) {
      final g = goals[index];
      final wasCompleted = g.current >= g.target;
      g.current += amount;
      saveToStorage();
      notifyListeners();
      return !wasCompleted && g.current >= g.target;
    }
    return false;
  }

  void deleteGoal(int index) {
    if (index < goals.length) {
      goals.removeAt(index);
      saveToStorage();
      notifyListeners();
    }
  }

  void addExpense(String title, double amount, String category) {
    expenses.insert(0, Expense(
      title: title.isEmpty ? category : title,
      amount: amount,
      category: category,
      dateKey: dateKey(DateTime.now()),
    ));
    saveToStorage();
    notifyListeners();
  }

  void deleteExpense(int index) {
    if (index < expenses.length) {
      expenses.removeAt(index);
      saveToStorage();
      notifyListeners();
    }
  }

  void setBudget(double newBudget) {
    monthlyBudget = newBudget;
    saveToStorage();
    notifyListeners();
  }

  void addTracker({
    required String name,
    required double target,
    required double unitValue,
    required double initialValue,
    required bool isDebt,
  }) {
    final tracker = VisualTracker(
      name: name,
      target: target,
      unitValue: unitValue,
      currentValue: initialValue,
      isDebt: isDebt,
    );
    if (isDebt) {
      debts.add(tracker);
    } else {
      savings.add(tracker);
    }
    saveToStorage();
    notifyListeners();
  }

  void addTrackerPayment(bool isDebt, int index, double amount) {
    final list = isDebt ? debts : savings;
    if (index < list.length) {
      list[index].currentValue += amount;
      saveToStorage();
      notifyListeners();
    }
  }

  void deleteTracker(bool isDebt, int index) {
    final list = isDebt ? debts : savings;
    if (index < list.length) {
      list.removeAt(index);
      saveToStorage();
      notifyListeners();
    }
  }
}

