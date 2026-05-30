import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/currency/currency_format.dart';
import '../../../core/input/text_input_formatters.dart';
import '../../../core/widgets/goal_logo.dart';
import '../domain/entities/saving_goal_create.dart';
import '../providers/saving_goals_providers.dart';
import '../utils/saving_goal_currency.dart';

class CreateGoalScreen extends ConsumerStatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();

  DateTime? _selectedDeadline;
  bool _submitting = false;
  String? _errorMessage;

  static const Color _goalCardColor = Color(0xFFE5E7EB);

  @override
  void dispose() {
    _goalNameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
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
      setState(() => _errorMessage = 'Select a target date.');
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final deadline = DateTime(
      _selectedDeadline!.year,
      _selectedDeadline!.month,
      _selectedDeadline!.day,
      23,
      59,
      59,
    );

    final result = await ref.read(createSavingGoalUseCaseProvider)(
      SavingGoalCreateData(
        name: name,
        targetAmount: targetAmount,
        deadline: deadline,
        colorHex: _toHexColor(_goalCardColor),
        currency: goalBaseCurrency,
      ),
    );

    if (!mounted) return;

    setState(() => _submitting = false);

    if (result.isSuccess) {
      ref.invalidate(savingGoalsProvider);
      if (!mounted) return;
      context.pop(true);
    } else {
      final message = result.errors.isNotEmpty
          ? result.errors.join('\n')
          : (result.message.isNotEmpty
                ? result.message
                : 'Failed to create goal.');
      setState(() => _errorMessage = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalName = _goalNameController.text.isEmpty
        ? 'Goal Name'
        : _goalNameController.text;
    final targetAmount =
        double.tryParse(_targetController.text.trim()) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6F3),
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
          'New Goal',
          style: TextStyle(
            color: Colors.black,
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
                goalName: goalName,
                targetAmount: targetAmount,
                color: _goalCardColor,
              ),
              const SizedBox(height: 24),
              CustomInputField(
                label: 'Goal Name',
                hint: 'e.g. New Laptop',
                controller: _goalNameController,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              CustomInputField(
                label: 'Target (${currencySymbol(goalBaseCurrency)})',
                hint: '2000',
                controller: _targetController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: amountInputFormatters,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              _DatePickerField(
                label: 'Target Date',
                value: _selectedDeadline,
                onTap: _pickDate,
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    disabledBackgroundColor: const Color(0xFF111111),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Create Goal',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _toHexColor(Color color) {
    final value = color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
    return '#${value.substring(2)}';
  }
}

class GoalPreviewCard extends StatelessWidget {
  final String goalName;
  final double targetAmount;
  final Color color;

  const GoalPreviewCard({
    super.key,
    required this.goalName,
    required this.targetAmount,
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
          const GoalLogo(size: 48, padding: 8),
          const SizedBox(height: 12),
          Text(
            goalName,
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Target ${formatMoney(targetAmount, goalBaseCurrency)}',
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.55),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasDate = value != null;
    final dateText =
        hasDate ? DateFormat('dd/MM/yyyy').format(value!) : 'Select Target Date';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF111111),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 56,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: hasDate
                        ? const Color(0xFF111111)
                        : const Color(0xFFC4C4C4),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dateText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasDate
                            ? const Color(0xFF111111)
                            : const Color(0xFFC4C4C4),
                        fontSize: 16,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const CustomInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF111111),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            inputFormatters: inputFormatters,
            style: const TextStyle(color: Color(0xFF111111), fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFC4C4C4), fontSize: 16),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
