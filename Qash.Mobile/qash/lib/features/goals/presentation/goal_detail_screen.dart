import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/bottom_nav_bar.dart';
import '../domain/entities/saving_goal.dart';

class GoalDetailScreen extends StatefulWidget {
  final SavingGoalEntity goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  late SavingGoalEntity _goal;

  static const _goalCardColor = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _goal = widget.goal;
  }

  @override
  Widget build(BuildContext context) {
    final progress = _goal.progress;
    final savedAmount = _goal.currentAmount;
    final targetAmount = _goal.targetAmount;
    final remaining = math.max(targetAmount - savedAmount, 0).toDouble();
    final daysLeft = _daysLeft(_goal.deadline);
    final monthsLeft = math.max(1, (daysLeft / 30).ceil());
    final needPerMonth = remaining / monthsLeft;
    final cardColor = _goalColor(_goal);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        title: const Text(
          'Goal Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GoalSummaryCard(
                color: cardColor,
                title: _goal.name,
                deadline: DateFormat('MMMM d, yyyy').format(_goal.deadline),
                savedAmount: savedAmount,
                targetAmount: targetAmount,
                progress: progress,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Remaining',
                      value: _formatCurrency(remaining),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Days Left',
                      value: daysLeft.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Need/Month',
                      value: _formatCurrency(needPerMonth),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_goal.currentAmount < _goal.targetAmount)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await context.push(
                        '/goals/${_goal.savingGoalId}/add-funds',
                        extra: _goal,
                      );
                      if (result is SavingGoalEntity) {
                        setState(() => _goal = result);
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Add Funds',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 28),
              _sectionTitle('Progress Milestones'),
              const SizedBox(height: 12),
              for (final milestone in _milestones(targetAmount, progress)) ...[
                MilestoneTile(
                  title: milestone.title,
                  amount: _formatCurrency(milestone.amount),
                  completed: milestone.completed,
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await context.push(
                      '/goals/${_goal.savingGoalId}/delete',
                      extra: _goal,
                    );
                    if (result == true && context.mounted) {
                      context.go('/goals');
                    }
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFFB2C36),
                  ),
                  label: const Text(
                    'Delete Goal',
                    style: TextStyle(
                      color: Color(0xFFFB2C36),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFFC9C9)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentTab: AppTab.goals,
        onSelected: (tab) => _onTabSelected(context, tab),
      ),
    );
  }

  Color _goalColor(SavingGoalEntity goal) {
    return _goalCardColor;
  }

  int _daysLeft(DateTime deadline) {
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);
    final target = DateTime(deadline.year, deadline.month, deadline.day);
    final diff = target.difference(dateOnly).inDays;
    return diff < 0 ? 0 : diff;
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(symbol: '\$').format(value);
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

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF111111),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<_Milestone> _milestones(double target, double progress) {
    final percent = progress * 100;
    return [
      _Milestone('25% milestone', target * 0.25, percent >= 25),
      _Milestone('50% milestone', target * 0.5, percent >= 50),
      _Milestone('75% milestone', target * 0.75, percent >= 75),
      _Milestone('100% milestone', target, percent >= 100),
    ];
  }
}

class GoalSummaryCard extends StatelessWidget {
  final String title;
  final String deadline;
  final double savedAmount;
  final double targetAmount;
  final double progress;
  final Color color;

  const GoalSummaryCard({
    super.key,
    required this.title,
    required this.deadline,
    required this.savedAmount,
    required this.targetAmount,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                title.isNotEmpty ? title[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Deadline: $deadline',
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.55),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _formatCurrency(savedAmount),
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 36,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'of ${_formatCurrency(targetAmount)}',
            style: TextStyle(color: Colors.black.withValues(alpha: 0.55)),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha: 0.5),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(progress * 100).toInt()}% completed',
            style: TextStyle(color: Colors.black.withValues(alpha: 0.55)),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(symbol: '\$').format(value);
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;

  const StatCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111111),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class MilestoneTile extends StatelessWidget {
  final String title;
  final String amount;
  final bool completed;

  const MilestoneTile({
    super.key,
    required this.title,
    required this.amount,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: completed
                  ? const Color(0xFFD9F0C8)
                  : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              completed ? Icons.check : Icons.lock_outline,
              size: 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: const TextStyle(
                    color: Color(0xFF8B8B8B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (completed)
            const Text(
              'Reached!',
              style: TextStyle(
                color: Color(0xFF00A63E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _Milestone {
  final String title;
  final double amount;
  final bool completed;

  const _Milestone(this.title, this.amount, this.completed);
}
