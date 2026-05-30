import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';
import 'package:qash/core/utils/currency_formatter.dart';

import '../../dashboard/providers/home_preferences_provider.dart';
import '../domain/entities/saving_goal.dart';
import '../domain/entities/saving_goal_create.dart';
import '../domain/entities/saving_goal_update.dart';
import '../providers/saving_goals_providers.dart';

class CreateGoalScreen extends ConsumerStatefulWidget {
  final String? goalId;
  final SavingGoalEntity? initialGoal;

  const CreateGoalScreen({super.key, this.goalId, this.initialGoal});

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _savedController = TextEditingController();

  String _selectedEmoji = '💻';
  DateTime? _selectedDeadline;
  bool _submitting = false;
  String? _errorMessage;
  bool _initializedFromGoal = false;

  bool get _isEdit => widget.goalId != null;

  final List<String> _emojis = const [
    '💻',
    '✈️',
    '🛡️',
    '🏠',
    '🚗',
    '📚',
    '💍',
    '🎓',
    '🏋️',
    '🎵',
    '📱',
    '🌴',
  ];

  @override
  void dispose() {
    _goalNameController.dispose();
    _targetController.dispose();
    _savedController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  Future<void> _submit() async {
    final name = _goalNameController.text.trim();
    final targetAmount = double.tryParse(_targetController.text.trim());

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Enter a goal name.');
      return;
    }
    if (targetAmount == null || targetAmount <= 0) {
      setState(() => _errorMessage = 'Enter a valid target amount.');
      return;
    }
    if (_selectedDeadline == null) {
      setState(() => _errorMessage = 'Select a deadline.');
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final result = _isEdit
        ? await ref.read(updateSavingGoalUseCaseProvider)(
            SavingGoalUpdateData(
              savingGoalId: widget.goalId!,
              name: name,
              targetAmount: targetAmount,
              deadline: _selectedDeadline!,
            ),
          )
        : await ref.read(createSavingGoalUseCaseProvider)(
            SavingGoalCreateData(
              name: name,
              targetAmount: targetAmount,
              deadline: _selectedDeadline!,
            ),
          );

    if (!mounted) return;

    setState(() => _submitting = false);

    if (result.isSuccess) {
      ref.invalidate(savingGoalsProvider);
      if (_isEdit) {
        ref.invalidate(savingGoalByIdProvider(widget.goalId!));
      }
      context.pop(true);
    } else {
      setState(() => _errorMessage = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;
    final editGoalAsync = _isEdit
        ? ref.watch(savingGoalByIdProvider(widget.goalId!))
        : null;
    if (_isEdit &&
        !_initializedFromGoal &&
        widget.initialGoal != null &&
        _goalNameController.text.isEmpty) {
      _applyGoal(widget.initialGoal!);
    }
    if (_isEdit && !_initializedFromGoal && editGoalAsync?.value?.isSuccess == true) {
      _applyGoal(editGoalAsync!.value!.data!);
    }
    final displayCurrency = ref.watch(displayCurrencyProvider);
    final goalName = _goalNameController.text.isEmpty
        ? 'Goal Name'
        : _goalNameController.text;
    final target = _targetController.text.isEmpty
        ? '0'
        : _targetController.text;
    final saved = _savedController.text.isEmpty ? '0' : _savedController.text;

    return Scaffold(
      backgroundColor: qash.scaffoldBackground,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: qash.surface,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: qash.textPrimary),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        title: Text(
          _isEdit ? 'Edit Goal' : 'New Goal',
          style: TextStyle(
            color: qash.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            children: [
              GoalPreviewCard(
                emoji: _selectedEmoji,
                goalName: goalName,
                target: target,
                saved: saved,
                color: qash.surfaceElevated,
                displayCurrency: displayCurrency,
              ),
              const SizedBox(height: 24),
              _sectionTitle('Icon'),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _emojis.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final emoji = _emojis[index];
                  final selected = _selectedEmoji == emoji;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedEmoji = emoji;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: selected ? qash.primaryButton : qash.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: qash.cardShadow,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              CustomInputField(
                label: 'Goal Name',
                hint: 'e.g. New Laptop',
                controller: _goalNameController,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomInputField(
                      label: 'Target',
                      hint: '2000',
                      controller: _targetController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomInputField(
                      label: 'Saved so far',
                      hint: '0',
                      controller: _savedController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionTitle('Deadline'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: qash.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: qash.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: qash.iconMuted,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDeadline == null
                            ? 'Select Deadline'
                            : DateFormat(
                                'dd/MM/yyyy',
                              ).format(_selectedDeadline!),
                        style: TextStyle(
                          color: qash.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: qash.danger, fontSize: 12),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: qash.primaryButton,
                    disabledBackgroundColor:
                        qash.primaryButton.withValues(alpha: 0.45),
                    foregroundColor: qash.onPrimaryButton,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _submitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: qash.onPrimaryButton,
                            strokeWidth: 2,
                          ),
                        )
                    : Text(
                        _isEdit ? 'Save Goal' : 'Create Goal',
                        style: TextStyle(
                          color: qash.onPrimaryButton,
                          fontSize: 16,
                        ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyGoal(SavingGoalEntity goal) {
    _goalNameController.text = goal.name;
    _targetController.text = goal.targetAmount.toStringAsFixed(2);
    _savedController.text = goal.currentAmount.toStringAsFixed(2);
    _selectedDeadline = goal.deadline;
    _initializedFromGoal = true;
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: context.qash.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

}

class GoalPreviewCard extends StatelessWidget {
  final String emoji;
  final String goalName;
  final String target;
  final String saved;
  final Color color;
  final String displayCurrency;

  const GoalPreviewCard({
    super.key,
    required this.emoji,
    required this.goalName,
    required this.target,
    required this.saved,
    required this.color,
    required this.displayCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: qash.border),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 12),
          Text(
            goalName,
            style: TextStyle(
              color: qash.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${CurrencyFormatter.format(double.tryParse(saved) ?? 0, displayCurrency)} / ${CurrencyFormatter.format(double.tryParse(target) ?? 0, displayCurrency)}',
            style: TextStyle(
              color: qash.textPrimary.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const CustomInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.qash.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: TextStyle(color: context.qash.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.qash.textHint, fontSize: 14),
            filled: true,
            fillColor: context.qash.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: context.qash.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: context.qash.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: context.qash.primaryButton),
            ),
          ),
        ),
      ],
    );
  }
}
