import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../domain/entities/saving_goal_create.dart';
import '../providers/saving_goals_providers.dart';

class CreateGoalScreen extends ConsumerStatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _savedController = TextEditingController();

  String _selectedEmoji = '💻';
  DateTime? _selectedDeadline;
  Color _selectedColor = const Color(0xFFD9F0C8);
  bool _submitting = false;
  String? _errorMessage;

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

  final List<Color> _cardColors = const [
    Color(0xFFD9F0C8),
    Color(0xFFFEF3C7),
    Color(0xFFEDE9FE),
    Color(0xFFFEE2E2),
    Color(0xFFDBEAFE),
    Color(0xFFFCE7F3),
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

    final result = await ref.read(createSavingGoalUseCaseProvider)(
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
      context.pop(true);
    } else {
      setState(() => _errorMessage = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalName = _goalNameController.text.isEmpty
        ? 'Goal Name'
        : _goalNameController.text;
    final target = _targetController.text.isEmpty
        ? '0'
        : _targetController.text;
    final saved = _savedController.text.isEmpty ? '0' : _savedController.text;

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
                emoji: _selectedEmoji,
                goalName: goalName,
                target: target,
                saved: saved,
                color: _selectedColor,
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
                        color: selected ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
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
                      label: 'Target (\$)',
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDeadline == null
                            ? 'Select Deadline'
                            : DateFormat(
                                'dd/MM/yyyy',
                              ).format(_selectedDeadline!),
                        style: const TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Card Color'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _cardColors.map((color) {
                  final selected = _selectedColor == color;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
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

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF111111),
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

  const GoalPreviewCard({
    super.key,
    required this.emoji,
    required this.goalName,
    required this.target,
    required this.saved,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 12),
          Text(
            goalName,
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$$saved / \$$target',
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.6),
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
          style: const TextStyle(
            color: Color(0xFF111111),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(color: Color(0xFF111111)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
