import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/utils/result.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../domain/entities/saving_goal.dart';
import '../providers/saving_goals_providers.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  static const _goalCardColor = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(savingGoalsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
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
                          const Text(
                            'Goals',
                            style: TextStyle(
                              color: Color(0xFF111111),
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
                                color: const Color(0xFFF4D93A),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 20,
                                color: Color(0xFF111111),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _summaryCard(goals),
                      const SizedBox(height: 20),
                      goals.when(
                        data: (result) {
                          if (result.isFailure) {
                            return Text(
                              result.message,
                              style: const TextStyle(
                                color: Color(0xFF8B8B8B),
                                fontSize: 12,
                              ),
                            );
                          }
                          final items = result.data ?? const [];
                          if (items.isEmpty) {
                            return const Text(
                              'No saving goals yet.',
                              style: TextStyle(
                                color: Color(0xFF8B8B8B),
                                fontSize: 12,
                              ),
                            );
                          }
                          return Column(
                            children: [
                              for (final item in items) ...[
                                _goalCard(context, item),
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
                          style: const TextStyle(
                            color: Color(0xFF8B8B8B),
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

  Widget _summaryCard(AsyncValue<Result<List<SavingGoalEntity>>> goals) {
    return goals.when(
      data: (result) {
        if (result.isFailure) {
          return _summaryCardShell(
            totalSaved: 0,
            totalTarget: 0,
            completed: 0,
            totalGoals: 0,
            progress: 0,
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
          totalSaved: totalSaved,
          totalTarget: totalTarget,
          completed: completed,
          totalGoals: items.length,
          progress: progress.clamp(0.0, 1.0),
        );
      },
      loading: () => _summaryCardShell(
        totalSaved: 0,
        totalTarget: 0,
        completed: 0,
        totalGoals: 0,
        progress: 0,
      ),
      error: (_, __) => _summaryCardShell(
        totalSaved: 0,
        totalTarget: 0,
        completed: 0,
        totalGoals: 0,
        progress: 0,
      ),
    );
  }

  Widget _summaryCardShell({
    required double totalSaved,
    required double totalTarget,
    required int completed,
    required int totalGoals,
    required double progress,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Saved',
            style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(totalSaved),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'of ${_formatCurrency(totalTarget)} goal',
            style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          ),
          const SizedBox(height: 16),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4D93A),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$completed/$totalGoals goals completed',
            style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _goalCard(BuildContext context, SavingGoalEntity goal) {
    final color = _goalColor(goal);
    final percent = (goal.progress * 100).round();

    return GestureDetector(
      onTap: () => context.push('/goals/${goal.savingGoalId}', extra: goal),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 2,
              offset: Offset(0, 1),
              spreadRadius: -1,
            ),
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 3,
              offset: Offset(0, 1),
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
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.flag_rounded,
                        color: Color(0xFF111111),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: const TextStyle(
                            color: Color(0xFF111111),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${_daysLeft(goal.deadline)} days left',
                          style: const TextStyle(
                            color: Color(0x99111111),
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
                  style: const TextStyle(
                    color: Color(0xFF111111),
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
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(999),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: goal.progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
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
                  '${_formatCurrency(goal.currentAmount)} saved',
                  style: const TextStyle(
                    color: Color(0xB2111111),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Target: ${_formatCurrency(goal.targetAmount)}',
                  style: const TextStyle(
                    color: Color(0xB2111111),
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
    return GestureDetector(
      onTap: () => context.push('/goals/create'),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.4),
        ),
        child: const Center(
          child: Text(
            'Add New Goal',
            style: TextStyle(
              color: Color(0xFF8B8B8B),
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

  String _formatCurrency(double value) {
    return NumberFormat.currency(symbol: '\$').format(value);
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
