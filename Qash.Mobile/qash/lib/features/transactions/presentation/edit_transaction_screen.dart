import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';
import 'package:qash/core/utils/currency_formatter.dart';
import 'package:qash/core/widgets/async_error_view.dart';

import '../../categories/domain/entities/category.dart';
import '../../categories/providers/categories_providers.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../dashboard/providers/home_preferences_provider.dart';
import '../../wallets/domain/entities/wallet.dart';
import '../../wallets/providers/wallets_providers.dart';
import '../domain/entities/transaction.dart';
import '../domain/entities/transaction_update.dart';
import '../providers/transactions_providers.dart';

class EditTransactionScreen extends ConsumerStatefulWidget {
  final String transactionId;

  const EditTransactionScreen({super.key, required this.transactionId});

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState extends ConsumerState<EditTransactionScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionEntity? _transaction;
  List<WalletEntity> _wallets = [];
  List<CategoryEntity> _categories = [];
  String? _walletId;
  String? _categoryId;
  int _transactionType = 2;
  DateTime _date = DateTime.now();
  bool _loading = true;
  bool _submitting = false;
  String? _errorMessage;
  String? _loadError;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    final txResult = await ref.read(getTransactionByIdUseCaseProvider)(
      widget.transactionId,
    );
    final walletsResult = await ref.read(walletsProvider.future);
    final categoriesResult = await ref.read(categoriesProvider.future);

    if (!mounted) return;

    if (txResult.isFailure || txResult.data == null) {
      setState(() {
        _loading = false;
        _loadError = txResult.message.isNotEmpty
            ? txResult.message
            : 'Transaction not found.';
      });
      return;
    }

    final tx = txResult.data!;
    if (tx.isTransfer) {
      setState(() {
        _transaction = tx;
        _loading = false;
      });
      return;
    }

    final wallets = walletsResult.data ?? const <WalletEntity>[];
    final categories = (categoriesResult.data ?? const <CategoryEntity>[])
        .where(
          (c) => tx.isIncome
              ? c.type == CategoryType.income
              : c.type == CategoryType.expense,
        )
        .toList();

    _amountController.text = tx.amount.toStringAsFixed(2);
    _descriptionController.text = tx.description;
    setState(() {
      _transaction = tx;
      _wallets = wallets;
      _categories = categories;
      _walletId = tx.walletId;
      _categoryId = tx.categoryId;
      _transactionType = tx.isIncome ? 1 : 2;
      _date = tx.transactionDate;
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_transaction?.isTransfer == true) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Enter a valid amount.');
      return;
    }
    if (_walletId == null || _categoryId == null) {
      setState(() => _errorMessage = 'Select wallet and category.');
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final result = await ref.read(updateTransactionUseCaseProvider)(
      TransactionUpdateData(
        transactionId: widget.transactionId,
        userId: '',
        walletId: _walletId!,
        amount: amount,
        transactionType: _transactionType,
        categoryId: _categoryId!,
        description: _descriptionController.text.trim(),
        transactionDate: _date,
      ),
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.isSuccess) {
      ref.invalidate(transactionsProvider);
      ref.invalidate(dashboardProvider);
      ref.invalidate(walletsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction updated.')),
      );
      context.pop(true);
    } else {
      setState(() => _errorMessage = result.message);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _submitting = true);
    final result = await ref.read(deleteTransactionUseCaseProvider)(
      widget.transactionId,
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.isSuccess) {
      ref.invalidate(transactionsProvider);
      ref.invalidate(dashboardProvider);
      ref.invalidate(walletsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction deleted.')),
      );
      context.go('/transactions');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;

    return Scaffold(
      backgroundColor: qash.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back, color: qash.textPrimary),
                  ),
                  Text(
                    'Edit Transaction',
                    style: TextStyle(
                      color: qash.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _loadError != null
                  ? AsyncErrorView(message: _loadError!, onRetry: _load)
                  : _transaction?.isTransfer == true
                  ? _transferBody(context)
                  : _formBody(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _transferBody(BuildContext context) {
    final qash = context.qash;
    final tx = _transaction!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transfers cannot be edited here. Delete and create a new transfer if needed.',
            style: TextStyle(color: qash.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            CurrencyFormatter.format(
              tx.amount,
              _currencyForWallet(tx.walletId),
            ),
            style: TextStyle(
              color: qash.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${tx.walletName} → ${tx.toWalletName}',
            style: TextStyle(color: qash.textSecondary),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _submitting ? null : _delete,
              style: OutlinedButton.styleFrom(foregroundColor: qash.danger),
              child: const Text('Delete Transfer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formBody(BuildContext context) {
    final qash = context.qash;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(context, 'Amount'),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: qash.textPrimary),
            decoration: _inputDecoration(context, '0.00'),
          ),
          const SizedBox(height: 16),
          _fieldLabel(context, 'Description (optional)'),
          TextField(
            controller: _descriptionController,
            style: TextStyle(color: qash.textPrimary),
            decoration: _inputDecoration(context, 'Notes'),
          ),
          const SizedBox(height: 16),
          _fieldLabel(context, 'Wallet'),
          _dropdown(
            context,
            value: _walletId,
            items: _wallets
                .map(
                  (w) => DropdownMenuItem(
                    value: w.walletId,
                    child: Text(w.name),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _walletId = v),
          ),
          const SizedBox(height: 16),
          _fieldLabel(context, 'Category'),
          _dropdown(
            context,
            value: _categoryId,
            items: _categories
                .map(
                  (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                )
                .toList(),
            onChanged: (v) => setState(() => _categoryId = v),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(_errorMessage!, style: TextStyle(color: qash.danger)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _submitting ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: qash.accent,
                foregroundColor: qash.onAccent,
              ),
              child: _submitting
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Text('Save Changes'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: _submitting ? null : _delete,
              style: OutlinedButton.styleFrom(foregroundColor: qash.danger),
              child: const Text('Delete'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: context.qash.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    final qash = context.qash;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: qash.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _dropdown(
    BuildContext context, {
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.qash.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  String _currencyForWallet(String walletId) {
    for (final wallet in _wallets) {
      if (wallet.walletId == walletId) {
        return wallet.currency;
      }
    }
    return ref.read(displayCurrencyProvider);
  }
}
