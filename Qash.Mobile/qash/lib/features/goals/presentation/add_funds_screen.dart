import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/input/text_input_formatters.dart';
import '../../../core/currency/currency_conversion_service.dart';
import '../../../core/currency/currency_format.dart';
import '../../../core/currency/currency_providers.dart';
import '../../../core/widgets/currency_flag.dart';
import '../domain/entities/saving_goal.dart';
import '../domain/entities/saving_goal_contribution.dart';
import '../providers/saving_goals_providers.dart';
import '../utils/saving_goal_currency.dart';

class AddFundsScreen extends ConsumerStatefulWidget {
  final SavingGoalEntity goal;

  const AddFundsScreen({super.key, required this.goal});

  @override
  ConsumerState<AddFundsScreen> createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends ConsumerState<AddFundsScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedCurrency = goalBaseCurrency;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final conversion = ref.read(currencyConversionServiceProvider);
    final remainingUsd =
        widget.goal.targetAmount - widget.goal.currentAmount;
    final amount = double.tryParse(_amountController.text.trim());

    if (remainingUsd <= 0) {
      setState(() => _errorMessage = 'This goal is already completed.');
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Enter a valid amount.');
      return;
    }

    final amountUsd = goalAmountToUsd(
      amount: amount,
      inputCurrency: _selectedCurrency,
      conversion: conversion,
    );

    if (amountUsd > remainingUsd + 0.001) {
      final maxInSelected = conversion.convertFromBase(
        remainingUsd,
        _selectedCurrency,
      );
      setState(
        () => _errorMessage =
            'Amount exceeds remaining balance (${formatMoney(maxInSelected, _selectedCurrency)}).',
      );
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final result = await ref.read(contributeToSavingGoalUseCaseProvider)(
      SavingGoalContributionData(
        savingGoalId: widget.goal.savingGoalId,
        amountUsd: amountUsd,
        inputAmount: amount,
        inputCurrency: _selectedCurrency,
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
    final conversion = ref.watch(currencyConversionServiceProvider);
    final remainingUsd =
        widget.goal.targetAmount - widget.goal.currentAmount;
    final maxInSelected = conversion.convertFromBase(
      remainingUsd,
      _selectedCurrency,
    );
    final maxHint = formatMoney(maxInSelected, _selectedCurrency);

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
          'Add Funds',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _goalSummary(widget.goal),
              const SizedBox(height: 20),
              _sectionTitle('Deposit currency'),
              const SizedBox(height: 8),
              _currencySelector(),
              const SizedBox(height: 16),
              _label('Amount (${currencySymbol(_selectedCurrency)})'),
              const SizedBox(height: 8),
              _textField(
                controller: _amountController,
                hint: 'Max $maxHint',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              if (_selectedCurrency != goalBaseCurrency) ...[
                const SizedBox(height: 8),
                _usdPreview(conversion),
              ],
              const SizedBox(height: 16),
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
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white,
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
                          'Add Funds',
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

  Widget _usdPreview(CurrencyConversionService conversion) {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      return const SizedBox.shrink();
    }
    final usd = goalAmountToUsd(
      amount: amount,
      inputCurrency: _selectedCurrency,
      conversion: conversion,
    );
    return Text(
      '≈ ${formatMoney(usd, goalBaseCurrency)} will be added to your goal',
      style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
    );
  }

  Widget _goalSummary(SavingGoalEntity goal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
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
          Text(
            goal.name,
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Saved ${formatMoney(goal.currentAmount, goalBaseCurrency)} of ${formatMoney(goal.targetAmount, goalBaseCurrency)}',
            style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF111111),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _currencySelector() {
    const currencies = ['USD', 'EGP', 'EUR', 'GBP', 'JPY'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: currencies.map((code) {
        final selected = _selectedCurrency == code;
        return GestureDetector(
          onTap: () => setState(() => _selectedCurrency = code),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? Colors.black : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CurrencyFlag(currencyCode: code, width: 22, height: 14),
                const SizedBox(width: 6),
                Text(
                  code,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF111111),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF111111),
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF111111),
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
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: (_) => setState(() {}),
        inputFormatters: amountInputFormatters,
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
    );
  }
}

