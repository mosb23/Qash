import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';

import '../domain/entities/saving_goal.dart';
import '../providers/saving_goals_providers.dart';

class DeleteGoalScreen extends ConsumerStatefulWidget {
  final SavingGoalEntity goal;

  const DeleteGoalScreen({super.key, required this.goal});

  @override
  ConsumerState<DeleteGoalScreen> createState() => _DeleteGoalScreenState();
}

class _DeleteGoalScreenState extends ConsumerState<DeleteGoalScreen> {
  bool _deleting = false;
  String? _errorMessage;

  static const _goalCardColor = Color(0xFFE5E7EB);

  Future<void> _deleteGoal() async {
    setState(() {
      _deleting = true;
      _errorMessage = null;
    });

    final result = await ref.read(deleteSavingGoalUseCaseProvider)(
      widget.goal.savingGoalId,
    );

    if (!mounted) return;

    setState(() => _deleting = false);

    if (result.isSuccess) {
      ref.invalidate(savingGoalsProvider);
      context.pop(true);
    } else {
      setState(() => _errorMessage = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;
    final color = _goalColor(widget.goal);

    return Scaffold(
      backgroundColor: qash.scaffoldBackground,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Delete Goal',
          style: TextStyle(
            color: qash.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: qash.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: qash.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.delete_outline,
                      color: Color(0xFFFB2C36),
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Delete Goal?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: qash.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to delete "${widget.goal.name}"?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: qash.textSecondary,
                    height: 1.5,
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: qash.danger,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _deleting ? null : _deleteGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: qash.danger,
                      disabledBackgroundColor: qash.danger.withValues(alpha: 0.45),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _deleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _deleting ? null : () => context.pop(false),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: qash.surfaceElevated,
                      foregroundColor: qash.textPrimary,
                      side: BorderSide(color: qash.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: qash.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _goalColor(SavingGoalEntity goal) {
    return _goalCardColor;
  }
}
