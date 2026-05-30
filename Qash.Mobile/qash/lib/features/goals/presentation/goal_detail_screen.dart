import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';
import 'package:qash/core/utils/currency_formatter.dart';

import '../../../core/widgets/bottom_nav_bar.dart';
import '../../dashboard/providers/home_preferences_provider.dart';
import '../providers/saving_goals_providers.dart';

class GoalDetailScreen extends ConsumerWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGoal = ref.watch(savingGoalByIdProvider(goalId));
    final displayCurrency = ref.watch(displayCurrencyProvider);
    final qash = context.qash;

    return Scaffold(
      appBar: AppBar(title: const Text('Goal Details')),
      body: asyncGoal.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _FailureState(
          message: 'Unable to load goal.',
          onRetry: () => ref.invalidate(savingGoalByIdProvider(goalId)),
        ),
        data: (result) {
          if (result.isFailure) {
            return _FailureState(
              message: result.message,
              onRetry: () => ref.invalidate(savingGoalByIdProvider(goalId)),
            );
          }
          final goal = result.data;
          if (goal == null) {
            return _FailureState(
              message: 'Goal not found.',
              onRetry: () => ref.invalidate(savingGoalByIdProvider(goalId)),
            );
          }
          final remaining = math.max(goal.targetAmount - goal.currentAmount, 0);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                goal.name,
                style: TextStyle(fontSize: 24, color: qash.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                '${CurrencyFormatter.format(goal.currentAmount, displayCurrency)} / ${CurrencyFormatter.format(goal.targetAmount, displayCurrency)}',
                style: TextStyle(color: qash.textSecondary),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: goal.progress, minHeight: 10),
              const SizedBox(height: 20),
              _StatTile(
                label: 'Remaining',
                value: CurrencyFormatter.format(
                  remaining.toDouble(),
                  displayCurrency,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  final updated = await context.push('/goals/$goalId/edit');
                  if (updated == true) {
                    ref.invalidate(savingGoalByIdProvider(goalId));
                    ref.invalidate(savingGoalsProvider);
                  }
                },
                child: const Text('Edit Goal'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () async {
                  final deleted = await context.push('/goals/$goalId/delete', extra: goal);
                  if (deleted == true && context.mounted) {
                    context.go('/goals');
                  }
                },
                child: const Text('Delete Goal'),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentTab: AppTab.goals,
        onSelected: (tab) => _onTabSelected(context, tab),
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
}

class _FailureState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FailureState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.qash.textPrimary),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: qash.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: qash.textSecondary)),
          Text(value, style: TextStyle(color: qash.textPrimary)),
        ],
      ),
    );
  }
}
