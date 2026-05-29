import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';
import 'package:qash/core/utils/currency_formatter.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/utils/result.dart';
import '../../../core/assets/qash_icons.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../core/widgets/qash_icon.dart';
import '../../dashboard/providers/home_preferences_provider.dart';
import '../domain/entities/saving_goal.dart';
import '../providers/saving_goals_providers.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  static const _goalCardColor = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qash = context.qash;
    final goals = ref.watch(savingGoalsProvider);
    final displayCurrency = ref.watch(displayCurrencyProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(savingGoalsProvider);
                  await ref.read(savingGoalsProvider.future);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Goals',
                            style: TextStyle(
                              color: qash.textPrimary,
                              fontSize: 24,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/goals/create'),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: qash.accent,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Icon(
                                Icons.add,
                                size: 20,
                                color: qash.onAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _summaryCard(context, goals, displayCurrency),
                      const SizedBox(height: 20),
                      goals.when(
                        data: (result) {
                          if (result.isFailure) {
                            return Text(
                              result.message,
                              style: TextStyle(
                                color: qash.textSecondary,
                                fontSize: 12,
                              ),
                            );
                          }
                          final items = result.data ?? const [];
                          if (items.isEmpty) {
                            return Text(
                              'No saving goals yet.',
                              style: TextStyle(
                                color: qash.textSecondary,
                                fontSize: 12,
                              ),
                            );
                          }
                          return Column(
                            children: [
                              for (final item in items) ...[
                                _goalCard(context, item, displayCurrency),
                                const SizedBox(height: 16),
                              ],
                            ],
                          );
                        },
                        loading: () => const SizedBox(
                          height: 180,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, stack) => Text(
                          _errorText(error),
                          style: TextStyle(
                            color: qash.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _addGoalButton(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            AppBottomNavBar(
              currentTab: AppTab.goals,
              onSelected: (tab) => _onTabSelected(context, tab),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(
    BuildContext context,
    AsyncValue<Result<List<SavingGoalEntity>>> goals,
    String displayCurrency,
  ) {
    return goals.when(
      data: (result) {
        if (result.isFailure) {
          return _summaryCardShell(
            context,
            totalSaved: 0,
            totalTarget: 0,
            completed: 0,
            totalGoals: 0,
            progress: 0,
            displayCurrency: displayCurrency,
          );
        }
        final items = result.data ?? const [];
        final totalSaved = items.fold<double>(
          0,
          (sum, item) => sum + item.currentAmount,
        );
        final totalTarget = items.fold<double>(
          0,
          (sum, item) => sum + item.targetAmount,
        );
        final completed = items
            .where(
              (item) =>
                  item.currentAmount >= item.targetAmount &&
                  item.targetAmount > 0,
            )
            .length;
        final progress = totalTarget > 0 ? (totalSaved / totalTarget) : 0.0;
          return _summaryCardShell(
            context,
            totalSaved: totalSaved,
            totalTarget: totalTarget,
            completed: completed,
            totalGoals: items.length,
            progress: progress.clamp(0.0, 1.0),
            displayCurrency: displayCurrency,
          );
        },
      loading: () => _summaryCardShell(
        context,
        totalSaved: 0,
        totalTarget: 0,
        completed: 0,
        totalGoals: 0,
        progress: 0,
        displayCurrency: displayCurrency,
      ),
      error: (_, _) => _summaryCardShell(
        context,
        totalSaved: 0,
        totalTarget: 0,
        completed: 0,
        totalGoals: 0,
        progress: 0,
        displayCurrency: displayCurrency,
      ),
    );
  }

  Widget _summaryCardShell(
    BuildContext context, {
    required double totalSaved,
    required double totalTarget,
    required int completed,
    required int totalGoals,
    required double progress,
    required String displayCurrency,
  }) {
    final qash = context.qash;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: qash.primaryButton,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Saved',
            style: TextStyle(color: qash.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(totalSaved, displayCurrency),
            style: TextStyle(
              color: qash.onPrimaryButton,
              fontSize: 24,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'of ${_formatCurrency(totalTarget, displayCurrency)} goal',
            style: TextStyle(color: qash.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: qash.onPrimaryButton.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: qash.accent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$completed/$totalGoals goals completed',
            style: TextStyle(color: qash.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _goalCard(
    BuildContext context,
    SavingGoalEntity goal,
    String displayCurrency,
  ) {
    final qash = context.qash;
    final color = _goalColor(goal);
    final percent = (goal.progress * 100).round();

    return GestureDetector(
      onTap: () => context.push('/goals/${goal.savingGoalId}'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: qash.cardShadow,
              blurRadius: 2,
              offset: const Offset(0, 1),
              spreadRadius: -1,
            ),
            BoxShadow(
              color: qash.cardShadow,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: qash.surface.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: QashIcon(
                        assetPath: QashIcons.navGoals,
                        fallback: Icons.flag_rounded,
                        size: 22,
                        color: qash.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: TextStyle(
                            color: qash.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${_daysLeft(goal.deadline)} days left',
                          style: TextStyle(
                            color: qash.textPrimary.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '$percent%',
                  style: TextStyle(
                    color: qash.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: qash.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(999),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: goal.progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: qash.primaryButton,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_formatCurrency(goal.currentAmount, displayCurrency)} saved',
                  style: TextStyle(
                    color: qash.textPrimary.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Target: ${_formatCurrency(goal.targetAmount, displayCurrency)}',
                  style: TextStyle(
                    color: qash.textPrimary.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _goalColor(SavingGoalEntity goal) {
    return _goalCardColor;
  }

  Widget _addGoalButton(BuildContext context) {
    final qash = context.qash;
    return GestureDetector(
      onTap: () => context.push('/goals/create'),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: qash.border, width: 1.4),
        ),
        child: Center(
          child: Text(
            'Add New Goal',
            style: TextStyle(
              color: qash.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _onTabSelected(BuildContext context, AppTab tab) {
    switch (tab) {
      case AppTab.home:
        context.go('/home');
        return;
      case AppTab.transactions:
        context.go('/transactions');
        return;
      case AppTab.analytics:
        context.go('/analytics');
        return;
      case AppTab.goals:
        return;
      case AppTab.profile:
        context.go('/profile');
    }
  }

  String _formatCurrency(double value, String currencyCode) {
    return CurrencyFormatter.format(value, currencyCode);
  }

  int _daysLeft(DateTime deadline) {
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);
    final target = DateTime(deadline.year, deadline.month, deadline.day);
    final diff = target.difference(dateOnly).inDays;
    return diff < 0 ? 0 : diff;
  }

  String _errorText(Object error) {
    if (error is AppFailure) {
      return error.message;
    }
    return 'Failed to load goals.';
  }
}
