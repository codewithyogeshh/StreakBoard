import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';

class CustomModals {
  static Future<T?> _showSheet<T>(BuildContext context, Widget child) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: AppTheme.border, width: 1.2),
              left: BorderSide(color: AppTheme.border, width: 1.2),
              right: BorderSide(color: AppTheme.border, width: 1.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        );
      },
    );
  }

  static void showAddHabit(BuildContext context, AppState state) {
    final controller = TextEditingController();
    final selectedDays = [1, 2, 3, 4, 5, 6, 7];
    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    _showSheet(
      context,
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New Habit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: _inputDecoration('Habit name (e.g. Read 15 mins)'),
              ),
              const SizedBox(height: 14),
              Text('Schedule Days', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              const SizedBox(height: 8),
              Row(
                children: List.generate(7, (i) {
                  final dayIndex = i + 1;
                  final isSelected = selectedDays.contains(dayIndex);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setSheetState(() {
                          if (isSelected) {
                            if (selectedDays.length > 1) selectedDays.remove(dayIndex);
                          } else {
                            selectedDays.add(dayIndex);
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryBlue : AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryBlue : AppTheme.border,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          days[i],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? const Color(0xFF09090B) : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              _actionButtons(
                context,
                onSave: () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    state.addHabit(text, selectedDays);
                    Navigator.pop(context);
                  }
                },
                buttonText: 'Add Habit',
              ),
            ],
          );
        },
      ),
    );
  }

  static void showAddTask(BuildContext context, AppState state, DateTime date) {
    final controller = TextEditingController();
    bool isBig3 = false;

    _showSheet(
      context,
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: _inputDecoration('Task title...'),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => setSheetState(() => isBig3 = !isBig3),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Checkbox(
                      value: isBig3,
                      activeColor: AppTheme.primaryPurple,
                      onChanged: (val) => setSheetState(() => isBig3 = val ?? false),
                    ),
                    const Text('Mark as Big 3 Priority', style: TextStyle(fontSize: 13.5)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _actionButtons(
                context,
                onSave: () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    state.addTask(date, text, isBig3);
                    Navigator.pop(context);
                  }
                },
                buttonText: 'Add Task',
              ),
            ],
          );
        },
      ),
    );
  }

  static void showEditTask(BuildContext context, DailyTask task, ValueChanged<String> onSave) {
    final controller = TextEditingController(text: task.title);

    _showSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Edit Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            autofocus: true,
            decoration: _inputDecoration('Task title'),
          ),
          const SizedBox(height: 20),
          _actionButtons(
            context,
            onSave: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                onSave(text);
                Navigator.pop(context);
              }
            },
            buttonText: 'Save',
          ),
        ],
      ),
    );
  }

  static void showAddGoal(BuildContext context, AppState state) {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final unitCtrl = TextEditingController();

    _showSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('New Target Goal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          TextField(controller: nameCtrl, decoration: _inputDecoration('Goal Name (e.g. Read Books)')),
          const SizedBox(height: 10),
          TextField(
            controller: targetCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration('Target Amount (e.g. 12)'),
          ),
          const SizedBox(height: 10),
          TextField(controller: unitCtrl, decoration: _inputDecoration('Unit (e.g. books, km, hrs)')),
          const SizedBox(height: 20),
          _actionButtons(
            context,
            onSave: () {
              final name = nameCtrl.text.trim();
              final target = double.tryParse(targetCtrl.text.trim()) ?? 0;
              final unit = unitCtrl.text.trim();
              if (name.isNotEmpty && target > 0) {
                state.addGoal(name, target, unit.isEmpty ? 'units' : unit);
                Navigator.pop(context);
              }
            },
            buttonText: 'Create Goal',
          ),
        ],
      ),
    );
  }

  static void showAddGoalProgress(BuildContext context, Goal goal, ValueChanged<double> onAdd) {
    final ctrl = TextEditingController();

    _showSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Log Progress for ${goal.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          TextField(
            controller: ctrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration('Amount in ${goal.unit}'),
          ),
          const SizedBox(height: 20),
          _actionButtons(
            context,
            onSave: () {
              final val = double.tryParse(ctrl.text.trim()) ?? 0;
              if (val > 0) {
                onAdd(val);
                Navigator.pop(context);
              }
            },
            buttonText: 'Add Progress',
          ),
        ],
      ),
    );
  }

  static void showBossTask(BuildContext context, AppState state, DateTime monday) {
    final k = AppState.dateKey(monday);
    final current = state.bossTasks[k];
    final ctrl = TextEditingController(text: current?.title ?? '');

    _showSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('👑', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Text('Weekly Boss Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Conquer your highest-impact mission of the week to earn +100 XP.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: ctrl,
            autofocus: true,
            decoration: _inputDecoration('Your boss task title...'),
          ),
          const SizedBox(height: 20),
          _actionButtons(
            context,
            onSave: () {
              final text = ctrl.text.trim();
              if (text.isNotEmpty) {
                state.setBossTask(monday, text);
                Navigator.pop(context);
              }
            },
            buttonText: 'Set Boss Task',
          ),
        ],
      ),
    );
  }

  static void showAddExpense(BuildContext context, AppState state) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String category = 'Groceries';
    final categories = ['Groceries', 'Eating out', 'Gas', 'Shopping', 'Fun', 'Health', 'Other'];

    _showSheet(
      context,
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Expense', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              TextField(controller: titleCtrl, decoration: _inputDecoration('What for? (e.g. Supermarket)')),
              const SizedBox(height: 10),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration('Amount (₹)'),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: category,
                    dropdownColor: AppTheme.surfaceLight,
                    isExpanded: true,
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {
                      if (val != null) setSheetState(() => category = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _actionButtons(
                context,
                onSave: () {
                  final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                  if (amount > 0) {
                    state.addExpense(titleCtrl.text.trim(), amount, category);
                    Navigator.pop(context);
                  }
                },
                buttonText: 'Add Expense',
              ),
            ],
          );
        },
      ),
    );
  }

  static void showEditBudget(BuildContext context, AppState state) {
    final ctrl = TextEditingController(text: state.monthlyBudget.toStringAsFixed(0));

    _showSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly Budget', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          TextField(
            controller: ctrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration('Total Monthly Budget (₹)'),
          ),
          const SizedBox(height: 20),
          _actionButtons(
            context,
            onSave: () {
              final val = double.tryParse(ctrl.text.trim()) ?? 0;
              if (val > 0) {
                state.setBudget(val);
                Navigator.pop(context);
              }
            },
            buttonText: 'Save Budget',
          ),
        ],
      ),
    );
  }

  static void showAddTracker(BuildContext context, AppState state, {required bool isDebt}) {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final unitCtrl = TextEditingController();
    final initialCtrl = TextEditingController();

    _showSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isDebt ? 'New Debt Payoff' : 'New Savings Goal',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          TextField(controller: nameCtrl, decoration: _inputDecoration('Name (e.g. Credit Card, Vacation)')),
          const SizedBox(height: 10),
          TextField(
            controller: targetCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration(isDebt ? 'Total Owed (₹)' : 'Target Amount (₹)'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: unitCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration(isDebt ? 'Monthly Payment (₹)' : 'Per Contribution / Square (₹)'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: initialCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration(isDebt ? 'Already Paid (Optional)' : 'Already Saved (Optional)'),
          ),
          const SizedBox(height: 20),
          _actionButtons(
            context,
            onSave: () {
              final name = nameCtrl.text.trim();
              final target = double.tryParse(targetCtrl.text.trim()) ?? 0;
              final unit = double.tryParse(unitCtrl.text.trim()) ?? 0;
              final initial = double.tryParse(initialCtrl.text.trim()) ?? 0;
              if (name.isNotEmpty && target > 0 && unit > 0) {
                state.addTracker(
                  name: name,
                  target: target,
                  unitValue: unit,
                  initialValue: initial,
                  isDebt: isDebt,
                );
                Navigator.pop(context);
              }
            },
            buttonText: 'Add Tracker',
          ),
        ],
      ),
    );
  }

  static void showLogTrackerPayment(BuildContext context, VisualTracker tracker, ValueChanged<double> onAdd) {
    final ctrl = TextEditingController();

    _showSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tracker.isDebt ? 'Log Debt Payment' : 'Add Savings',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          TextField(
            controller: ctrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration('Amount (₹)'),
          ),
          const SizedBox(height: 20),
          _actionButtons(
            context,
            onSave: () {
              final val = double.tryParse(ctrl.text.trim()) ?? 0;
              if (val > 0) {
                onAdd(val);
                Navigator.pop(context);
              }
            },
            buttonText: 'Add',
          ),
        ],
      ),
    );
  }

  static void confirmDelete(BuildContext context, String title, VoidCallback onConfirm) {
    _showSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Are you sure? This cannot be undone.',
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    foregroundColor: const Color(0xFF09090B),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    onConfirm();
                    Navigator.pop(context);
                  },
                  child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13.5),
      filled: true,
      fillColor: AppTheme.surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
      ),
    );
  }

  static Widget _actionButtons(BuildContext context, {required VoidCallback onSave, required String buttonText}) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.textPrimary,
              foregroundColor: const Color(0xFF09090B),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: onSave,
            child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ),
      ],
    );
  }
}

