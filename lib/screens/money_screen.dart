import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../widgets/stat_cards.dart';
import '../widgets/custom_modals.dart';
import '../widgets/app_animations.dart';

class MoneyScreen extends StatelessWidget {
  final AppState state;

  const MoneyScreen({super.key, required this.state});

  static String formatCurrency(double amount) {
    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = daysInMonth - now.day + 1;

    final spentThisMonth = state.totalSpentForMonth(now);
    final leftToSpend = state.monthlyBudget - spentThisMonth;
    final dailyAllowance = math.max(leftToSpend, 0) / daysLeft;
    final spentToday = state.todaySpent(now);

    final currentMonthPrefix = DateFormat('yyyy-MM').format(now);
    final monthExpenses = state.expenses.where((e) => e.dateKey.startsWith(currentMonthPrefix)).toList();

    const categories = ['Groceries', 'Eating out', 'Gas', 'Shopping', 'Fun', 'Health', 'Other'];

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
                'BUDGET · ${DateFormat('MMMM yyyy').format(now).toUpperCase()}',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Money',
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

        // Monthly Budget Card (Staggered 1)
        StaggeredEntrance(
          index: 1,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              CustomModals.showEditBudget(context, state);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration(glow: leftToSpend >= 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LEFT TO SPEND',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.25)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.edit_rounded, size: 12, color: AppTheme.primaryBlue),
                            SizedBox(width: 4),
                            Text(
                              'Edit Budget',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedNumberText(
                    value: leftToSpend,
                    isCurrency: true,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: leftToSpend < 0 ? AppTheme.primaryRed : AppTheme.primaryGreen,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.bolt_rounded, size: 16, color: AppTheme.primaryOrange),
                      const SizedBox(width: 4),
                      Text(
                        '${formatCurrency(dailyAllowance)} / day · $daysLeft days remaining',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SmoothProgressBar(
                    value: (spentThisMonth / state.monthlyBudget),
                    height: 8,
                    gradientColors: leftToSpend < 0
                        ? const [Color(0xFFEF4444), Color(0xFFEF4444)]
                        : const [Color(0xFF14B8A6), Color(0xFF10B981)],
                    glow: true,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Spent ${formatCurrency(spentThisMonth)} of ${formatCurrency(state.monthlyBudget)}',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      Text(
                        'Today: ${formatCurrency(spentToday)}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // "+ Add Expense" High-Impact Button (Staggered 2)
        StaggeredEntrance(
          index: 2,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.textPrimary,
              foregroundColor: const Color(0xFF09090B),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              CustomModals.showAddExpense(context, state);
            },
            icon: const Icon(Icons.add_rounded, size: 21),
            label: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ),
        const SizedBox(height: 16),

        // Category Breakdown Section (Staggered 3)
        StaggeredEntrance(
          index: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Category Breakdown'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  children: categories.map((cat) {
                    final catSpent = monthExpenses
                        .where((e) => e.category == cat)
                        .fold(0.0, (acc, e) => acc + e.amount);
                    final proportion = spentThisMonth == 0 ? 0.0 : catSpent / spentThisMonth;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(cat, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                              Text(formatCurrency(catSpent), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          SmoothProgressBar(
                            value: proportion,
                            height: 6,
                            gradientColors: const [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Debt Payoff Trackers Section (Staggered 4)
        StaggeredEntrance(
          index: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Debt Payoff',
                actionText: '+ Add Debt',
                onAction: () => CustomModals.showAddTracker(context, state, isDebt: true),
              ),
              if (state.debts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: AppTheme.cardDecoration(),
                  child: Text('No debt trackers. Tap + Add Debt.', style: TextStyle(color: AppTheme.textMuted)),
                )
              else
                ...state.debts.asMap().entries.map((entry) {
                  return _buildVisualTrackerCard(context, entry.key, entry.value, isDebt: true);
                }),
            ],
          ),
        ),

        // Savings Trackers Section (Staggered 5)
        StaggeredEntrance(
          index: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Savings Goals',
                actionText: '+ Add Goal',
                onAction: () => CustomModals.showAddTracker(context, state, isDebt: false),
              ),
              if (state.savings.isEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: AppTheme.cardDecoration(),
                  child: Text('No savings trackers. Tap + Add Goal.', style: TextStyle(color: AppTheme.textMuted)),
                )
              else
                ...state.savings.asMap().entries.map((entry) {
                  return _buildVisualTrackerCard(context, entry.key, entry.value, isDebt: false);
                }),
            ],
          ),
        ),

        // Expenses History List (Staggered 6)
        StaggeredEntrance(
          index: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: 'Expenses · ${monthExpenses.length}'),
              Container(
                decoration: AppTheme.cardDecoration(),
                child: monthExpenses.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(18),
                        child: Text('No expenses recorded this month.', style: TextStyle(color: AppTheme.textMuted)),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: monthExpenses.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final exp = monthExpenses[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(exp.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${exp.dateKey} · ${exp.category}',
                                        style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  formatCurrency(exp.amount),
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close_rounded, size: 16, color: AppTheme.textMuted),
                                  onPressed: () => state.deleteExpense(state.expenses.indexOf(exp)),
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

  Widget _buildVisualTrackerCard(BuildContext context, int index, VisualTracker tracker, {required bool isDebt}) {
    final unit = math.max(tracker.unitValue, tracker.target / 120);
    final totalSquares = (tracker.target / unit).ceil();
    final filledSquares = (tracker.currentValue / unit).floor().clamp(0, totalSquares);
    final remaining = math.max(tracker.target - tracker.currentValue, 0.0);
    final color = isDebt ? AppTheme.primaryRed : AppTheme.primaryOrange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tracker.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              Text(
                formatCurrency(isDebt ? remaining : tracker.currentValue),
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Grid of rounded squares
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: List.generate(totalSquares, (sqIndex) {
              final isFilled = sqIndex < filledSquares;
              return Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: isFilled ? color : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(3.5),
                  boxShadow: isFilled
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 4,
                          )
                        ]
                      : null,
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            '1 square = ${formatCurrency(unit)} · $filledSquares of $totalSquares · ${isDebt ? (remaining == 0 ? "Debt free! 🎉" : "Debt-free in ~${(remaining / tracker.unitValue).ceil()} months") : "${formatCurrency(remaining)} to go"}',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  CustomModals.showLogTrackerPayment(context, tracker, (amt) {
                    state.addTrackerPayment(isDebt, index, amt);
                  });
                },
                child: Text(
                  isDebt ? '+ Log Payment' : '+ Add Savings',
                  style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.textMuted),
                onPressed: () {
                  CustomModals.confirmDelete(
                    context,
                    'Delete "${tracker.name}"?',
                    () => state.deleteTracker(isDebt, index),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

