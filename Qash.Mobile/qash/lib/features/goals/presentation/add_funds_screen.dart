import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qash/core/currency/currency_conversion_service.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';
import 'package:qash/core/utils/currency_formatter.dart';

import '../../dashboard/providers/home_preferences_provider.dart';
import '../domain/entities/saving_goal.dart';
import '../domain/entities/saving_goal_contribution.dart';
import '../providers/saving_goals_providers.dart';

class AddFundsScreen extends ConsumerStatefulWidget {
  final SavingGoalEntity goal;

  const AddFundsScreen({super.key, required this.goal});

  @override
  ConsumerState<AddFundsScreen> createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends ConsumerState<AddFundsScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.trim());
    final remaining = widget.goal.targetAmount - widget.goal.currentAmount;

    if (remaining <= 0) {
      setState(() => _errorMessage = 'This goal is already completed.');
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Enter a valid amount.');
      return;
    }
    if (amount > remaining) {
      setState(
        () => _errorMessage =
            'Amount exceeds remaining balance (${_formatCurrency(remaining, ref.read(displayCurrencyProvider))}).',
      );
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final displayCurrency = ref.read(displayCurrencyProvider);
    final amountUsd = CurrencyConversionService().convertToBase(
      amount,
      displayCurrency,
    );

    final result = await ref.read(contributeToSavingGoalUseCaseProvider)(
      SavingGoalContributionData(
        savingGoalId: widget.goal.savingGoalId,
        amountUsd: amountUsd,
        inputAmount: amount,
        inputCurrency: displayCurrency,
      ),
    );

    if (!mounted) return;

    setState(() => _submitting = false);

    if (result.isSuccess) {
      ref.invalidate(savingGoalsProvider);
      context.pop(result.data ?? widget.goal);
    } else {
      setState(() => _errorMessage = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;
    final displayCurrency = ref.watch(displayCurrencyProvider);

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
          'Add Funds',
          style: TextStyle(
            color: qash.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _goalSummary(widget.goal, displayCurrency),
              const SizedBox(height: 20),
              _label(context, 'Amount'),
              const SizedBox(height: 8),
              _textField(
                controller: _amountController,
                hint:
                    'Max ${_formatCurrency(widget.goal.targetAmount - widget.goal.currentAmount, displayCurrency)}',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
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
                    disabledForegroundColor: qash.onPrimaryButton,
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
                          'Add Funds',
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

  Widget _goalSummary(SavingGoalEntity goal, String displayCurrency) {
    final qash = context.qash;
    final progress = goal.progress;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: qash.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: qash.cardShadow, blurRadius: 2, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            goal.name,
            style: TextStyle(
              color: qash.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Saved ${_formatCurrency(goal.currentAmount, displayCurrency)} of ${_formatCurrency(goal.targetAmount, displayCurrency)}',
            style: TextStyle(color: qash.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: qash.border,
              valueColor: AlwaysStoppedAnimation<Color>(qash.primaryButton),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    final qash = context.qash;
    return Text(
      text,
      style: TextStyle(
        color: qash.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final qash = context.qash;
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: qash.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: qash.cardShadow, blurRadius: 2, offset: const Offset(0, 1)),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: qash.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: qash.textHint, fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double value, String currencyCode) {
    return CurrencyFormatter.format(value, currencyCode);
  }
}
