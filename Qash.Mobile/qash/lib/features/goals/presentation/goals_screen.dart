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
    final filteredGoals = ref.watch(filteredSavingGoalsProvider);
    final filter = ref.watch(goalsFilterProvider);
    final hasExpiredGoals = ref.watch(hasExpiredGoalsProvider);

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
                      if (hasExpiredGoals) ...[
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _filterTab(
                                label: 'All',
                                isActive: filter == GoalFilter.all,
                                onTap: () => _updateFilter(
                                  ref,
                                  GoalFilter.all,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _filterTab(
                                label: 'Current',
                                isActive: filter == GoalFilter.current,
                                onTap: () => _updateFilter(
                                  ref,
                                  GoalFilter.current,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _filterTab(
                                label: 'Expired',
                                isActive: filter == GoalFilter.expired,
                                onTap: () => _updateFilter(
                                  ref,
                                  GoalFilter.expired,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      filteredGoals.when(
                        data: (items) {
                          if (items.isEmpty) {
                            return Text(
                              _emptyMessage(filter, hasExpiredGoals),
                              style: const TextStyle(
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
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: _addGoalButton(context),
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

  void _updateFilter(WidgetRef ref, GoalFilter filter) {
    ref.read(goalsFilterProvider.notifier).state = filter;
  }

  String _emptyMessage(GoalFilter filter, bool hasExpiredGoals) {
    if (!hasExpiredGoals) {
      return 'No saving goals yet.';
    }

    return switch (filter) {
      GoalFilter.current => 'No current goals.',
      GoalFilter.expired => 'No expired goals.',
      GoalFilter.all => 'No saving goals yet.',
    };
  }

  Widget _filterTab({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF111111) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isActive
              ? null
              : const [
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
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF8B8B8B),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
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
    final expired = isGoalExpired(goal);

    return GestureDetector(
      onTap: () => context.push('/goals/${goal.savingGoalId}', extra: goal),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: expired
              ? Border.all(color: const Color(0xFFFECACA), width: 1.4)
              : null,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    goal.name,
                                    style: const TextStyle(
                                      color: Color(0xFF111111),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (expired) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Expired',
                                      style: TextStyle(
                                        color: Color(0xFFEF4444),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _deadlineLabel(goal),
                              style: TextStyle(
                                color: expired
                                    ? const Color(0xFFEF4444)
                                    : const Color(0x99111111),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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
                    color: expired
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF111111),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/goals/create'),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFF4D93A),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: Color(0xFF111111), size: 22),
              SizedBox(width: 8),
              Text(
                'Add New Goal',
                style: TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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

  String _deadlineLabel(SavingGoalEntity goal) {
    if (isGoalExpired(goal)) {
      final daysOverdue = _daysOverdue(goal.deadline);
      if (daysOverdue == 0) {
        return 'Expired today';
      }
      if (daysOverdue == 1) {
        return 'Expired 1 day ago';
      }
      return 'Expired $daysOverdue days ago';
    }

    final daysLeft = _daysLeft(goal.deadline);
    if (daysLeft == 0) {
      return 'Due today';
    }
    if (daysLeft == 1) {
      return '1 day left';
    }
    return '$daysLeft days left';
  }

  int _daysLeft(DateTime deadline) {
    final today = goalLocalDate(DateTime.now());
    final target = goalLocalDate(deadline);
    final diff = target.difference(today).inDays;
    return diff < 0 ? 0 : diff;
  }

  int _daysOverdue(DateTime deadline) {
    final today = goalLocalDate(DateTime.now());
    final target = goalLocalDate(deadline);
    final diff = today.difference(target).inDays;
    return diff < 0 ? 0 : diff;
  }

  String _errorText(Object error) {
    if (error is AppFailure) {
      return error.message;
    }
    return 'Failed to load goals.';
  }
}
