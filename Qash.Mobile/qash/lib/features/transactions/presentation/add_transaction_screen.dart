import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/input/text_input_formatters.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/currency/currency_conversion_service.dart';
import '../../../core/currency/currency_format.dart';
import '../../../core/currency/currency_providers.dart';
import '../../../core/providers/user_session_invalidation.dart';
import '../../../core/widgets/transaction_category_icon.dart';
import '../../categories/domain/entities/category.dart';
import '../../categories/providers/categories_providers.dart';
import '../../wallets/domain/entities/wallet.dart';
import '../../wallets/providers/wallets_providers.dart';
import '../domain/entities/transaction_create.dart';
import '../providers/transactions_providers.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  /// 1 = Income, 2 = Expense, 3 = Transfer
  final int initialType;

  const AddTransactionScreen({super.key, this.initialType = 2});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _transactionType = 2;
  DateTime _date = DateTime.now();
  List<WalletEntity> _wallets = [];
  List<CategoryEntity> _allCategories = [];
  String? _walletId;
  String? _toWalletId;
  String? _categoryId;
  bool _loadingData = true;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _transactionType = widget.initialType;
    _amountController.addListener(_onAmountChanged);
    _loadFormData();
  }

  void _onAmountChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadFormData() async {
    setState(() {
      _loadingData = true;
      _errorMessage = null;
    });

    final walletsResult = await ref.read(walletsProvider.future);
    final categoriesResult = await ref.read(categoriesProvider.future);

    final wallets = walletsResult.data ?? const <WalletEntity>[];
    final categories = categoriesResult.data ?? const <CategoryEntity>[];
    final filteredCategories = _filterCategories(categories);

    if (!mounted) return;

    final resolvedWalletId =
        _walletId ?? (wallets.isNotEmpty ? wallets.first.walletId : null);
    final resolvedToWalletId = _transactionType == 3
        ? (_toWalletId ?? _defaultToWalletId(wallets, resolvedWalletId))
        : null;

    setState(() {
      _wallets = wallets;
      _allCategories = categories;
      _walletId = resolvedWalletId;
      _toWalletId = resolvedToWalletId;
      _categoryId = filteredCategories.isNotEmpty
          ? filteredCategories.first.id
          : null;
      _loadingData = false;
      _errorMessage = _errorMessageFromResults(walletsResult, categoriesResult);
    });
  }

  String? _errorMessageFromResults(
    dynamic walletsResult,
    dynamic categoriesResult,
  ) {
    if (walletsResult.isFailure) {
      return walletsResult.failure?.message ?? 'Failed to load wallets.';
    }
    if (categoriesResult.isFailure) {
      return categoriesResult.failure?.message ?? 'Failed to load categories.';
    }
    return null;
  }

  List<CategoryEntity> _filterCategories(List<CategoryEntity> categories) {
    bool isTransferCategory(CategoryEntity category) {
      return category.type == CategoryType.transfer ||
          category.name.trim().toLowerCase() == 'transfer';
    }

    if (_transactionType == 1) {
      return categories
          .where((c) => c.type == CategoryType.income && !isTransferCategory(c))
          .toList();
    }
    if (_transactionType == 2) {
      return categories
          .where((c) => c.type == CategoryType.expense && !isTransferCategory(c))
          .toList();
    }
    return const [];
  }

  void _applyCategoryFilter() {
    final filtered = _filterCategories(_allCategories);
    setState(() {
      _categoryId = filtered.isNotEmpty ? filtered.first.id : null;
      if (_transactionType == 3) {
        _toWalletId = _defaultToWalletId(_wallets, _walletId);
      }
    });
  }

  String? _defaultToWalletId(List<WalletEntity> wallets, String? fromWalletId) {
    for (final wallet in wallets) {
      if (wallet.walletId != fromWalletId) {
        return wallet.walletId;
      }
    }
    return null;
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (picked != null) {
      setState(() {
        _date = DateTime(
          _date.year,
          _date.month,
          _date.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  String _formatDateDisplay(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour < 12 ? 'AM' : 'PM';
    return '${months[date.month - 1]} ${date.day}, ${date.year}   $hour:$minute $ampm';
  }

  WalletEntity? _walletById(String? id) {
    if (id == null) {
      return null;
    }
    for (final wallet in _wallets) {
      if (wallet.walletId == id) {
        return wallet;
      }
    }
    return null;
  }

  String? _transferConversionPreview(CurrencyConversionService conversion) {
    if (_transactionType != 3) {
      return null;
    }

    final source = _walletById(_walletId);
    final target = _walletById(_toWalletId);
    if (source == null || target == null) {
      return null;
    }

    final fromCurrency = source.currency.trim().toUpperCase();
    final toCurrency = target.currency.trim().toUpperCase();
    if (fromCurrency == toCurrency) {
      return null;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      return 'Enter an amount to preview conversion to $toCurrency.';
    }

    try {
      final converted = conversion.transferCreditAmount(
        sourceAmount: amount,
        sourceCurrency: fromCurrency,
        targetCurrency: toCurrency,
      );
      return 'Destination receives ${formatMoney(converted, toCurrency)}';
    } catch (_) {
      return 'Exchange rate unavailable for $fromCurrency → $toCurrency.';
    }
  }

  String _amountFieldLabel() {
    final wallet = _walletById(_walletId);
    final currency = wallet?.currency.trim().toUpperCase();
    if (currency == null || currency.isEmpty) {
      return 'Amount';
    }
    return 'Amount ($currency)';
  }

  String? _selectedWalletCurrency() {
    final wallet = _walletById(_walletId);
    final currency = wallet?.currency.trim().toUpperCase();
    if (currency == null || currency.isEmpty) {
      return null;
    }
    return currency;
  }

  String _typeLabel(int type) {
    switch (type) {
      case 1:
        return 'Income';
      case 2:
        return 'Expense';
      case 3:
        return 'Transfer';
      default:
        return 'Transaction';
    }
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Enter a valid amount.');
      return;
    }
    // Description is optional now.
    if (_walletId == null) {
      setState(
        () => _errorMessage = 'Create a wallet first to add transactions.',
      );
      return;
    }
    if (_transactionType == 3 && _toWalletId == null) {
      setState(() => _errorMessage = 'Select a target wallet for transfers.');
      return;
    }
    if (_transactionType == 3 && _toWalletId == _walletId) {
      setState(
        () => _errorMessage = 'Source and target wallets must be different.',
      );
      return;
    }
    if (_transactionType != 3 && _categoryId == null) {
      setState(() => _errorMessage = 'Select a category.');
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    CategoryEntity? transferCategory;
    for (final category in _allCategories) {
      if (category.type == CategoryType.transfer) {
        transferCategory = category;
        break;
      }
    }
    final resolvedCategoryId = _transactionType == 3
        ? (transferCategory?.id ?? _categoryId ?? '')
        : _categoryId!;

    if (_transactionType == 3 && resolvedCategoryId.isEmpty) {
      setState(() {
        _submitting = false;
        _errorMessage = 'Unable to resolve transfer category.';
      });
      return;
    }

    final result = await ref.read(createTransactionUseCaseProvider)(
      TransactionCreateData(
        userId: '',
        walletId: _walletId!,
        toWalletId: _transactionType == 3 ? _toWalletId : null,
        amount: amount,
        transactionType: _transactionType,
        categoryId: resolvedCategoryId,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        transactionDate: _date,
      ),
    );

    if (!mounted) return;

    setState(() => _submitting = false);

    if (result.isSuccess) {
      invalidateTransactionRelatedData(ref);
      Navigator.pop(context, true);
    } else {
      setState(() => _errorMessage = result.message);
    }
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
    String? prefixText,
    List<TextInputFormatter>? inputFormatters,
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
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Color(0xFF111111), fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFC4C4C4), fontSize: 16),
          prefixText: prefixText,
          prefixStyle: const TextStyle(
            color: Color(0xFF111111),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: Colors.white,
              iconEnabledColor: const Color(0xFF111111),
              style: const TextStyle(color: Color(0xFF111111), fontSize: 15),
              hint: Text(
                'Select $label',
                style: const TextStyle(color: Color(0xFFC4C4C4)),
              ),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  List<CategoryEntity> _currentCategories() {
    return _filterCategories(_allCategories);
  }

  @override
  Widget build(BuildContext context) {
    final conversion = ref.watch(currencyConversionServiceProvider);
    final conversionPreview = _transferConversionPreview(conversion);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                            spreadRadius: -1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Add Transaction',
                    style: TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loadingData
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF111111),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Type'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _typeChip(1, 'Income'),
                              const SizedBox(width: 8),
                              _typeChip(2, 'Expense'),
                              const SizedBox(width: 8),
                              _typeChip(3, 'Transfer'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (_wallets.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: Text(
                                'No wallets found. Create a wallet on the home screen first.',
                                style: TextStyle(
                                  color: Color(0xFF8B8B8B),
                                  fontSize: 14,
                                ),
                              ),
                            )
                          else
                            _dropdown<String>(
                              label: 'Wallet',
                              value: _walletId,
                              items: _wallets.map((wallet) {
                                return DropdownMenuItem<String>(
                                  value: wallet.walletId,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          wallet.name,
                                          style: const TextStyle(
                                            color: Color(0xFF111111),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        wallet.currency.trim().toUpperCase(),
                                        style: const TextStyle(
                                          color: Color(0xFF8B8B8B),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _walletId = value;
                                  if (_transactionType == 3 &&
                                      _toWalletId == value) {
                                    _toWalletId = _defaultToWalletId(
                                      _wallets,
                                      value,
                                    );
                                  }
                                });
                              },
                            ),
                          const SizedBox(height: 16),
                          _label(_amountFieldLabel()),
                          const SizedBox(height: 8),
                          _textField(
                            controller: _amountController,
                            hint: '0.00',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: amountInputFormatters,
                            prefixText: _selectedWalletCurrency() == null
                                ? null
                                : '${currencySymbol(_selectedWalletCurrency()!)} ',
                          ),
                          if (conversionPreview != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE1EBFF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.currency_exchange,
                                    size: 18,
                                    color: Color(0xFF2B7FFF),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      conversionPreview,
                                      style: const TextStyle(
                                        color: Color(0xFF1D4ED8),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          _label('Description'),
                          const SizedBox(height: 8),
                          _textField(
                            controller: _descriptionController,
                            hint: 'What was this for?',
                          ),
                          const SizedBox(height: 16),
                          if (_transactionType != 3) ...[
                            if (_currentCategories().isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 16),
                                child: Text(
                                  'No categories found for this transaction type.',
                                  style: TextStyle(
                                    color: Color(0xFF8B8B8B),
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            else
                              _dropdown<String>(
                                label: 'Category',
                                value: _categoryId,
                                items: _currentCategories().map((category) {
                                  return DropdownMenuItem<String>(
                                    value: category.id,
                                    child: Row(
                                      children: [
                                        TransactionCategoryIcon(
                                          categoryName: category.name,
                                          categoryIcon: category.name,
                                          isTransfer:
                                              category.type ==
                                              CategoryType.transfer,
                                          size: 28,
                                          iconSize: 14,
                                          backgroundColor: const Color(
                                            0xFFF3F4F6,
                                          ),
                                          borderRadius: 8,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            category.name,
                                            style: const TextStyle(
                                              color: Color(0xFF111111),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) => setState(() {
                                  _categoryId = value;
                                }),
                              ),
                            const SizedBox(height: 16),
                          ],
                          if (_transactionType == 3) ...[
                            const SizedBox(height: 16),
                            if (_wallets.length < 2)
                              const Text(
                                'Create another wallet to make transfers.',
                                style: TextStyle(
                                  color: Color(0xFF8B8B8B),
                                  fontSize: 14,
                                ),
                              )
                            else
                              _dropdown<String>(
                                label: 'To Wallet',
                                value: _toWalletId,
                                items: _wallets
                                    .where(
                                      (wallet) => wallet.walletId != _walletId,
                                    )
                                    .map((wallet) {
                                      return DropdownMenuItem<String>(
                                        value: wallet.walletId,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                wallet.name,
                                                style: const TextStyle(
                                                  color: Color(0xFF111111),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              wallet.currency
                                                  .trim()
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                color: Color(0xFF8B8B8B),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    })
                                    .toList(),
                                onChanged: (value) => setState(() {
                                  _toWalletId = value;
                                }),
                              ),
                          ],
                          const SizedBox(height: 16),
                          const SizedBox(height: 16),
                          _label('Date & Time'),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _pickTime,
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDateDisplay(_date),
                                    style: const TextStyle(
                                      color: Color(0xFF111111),
                                      fontSize: 15,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.access_time_outlined,
                                    size: 20,
                                    color: Color(0xFF8B8B8B),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          GestureDetector(
                            onTap: _submitting ? null : _submit,
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4D93A),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: _submitting
                                    ? const CircularProgressIndicator(
                                        color: Color(0xFF111111),
                                      )
                                    : Text(
                                        'Save ${_typeLabel(_transactionType)}',
                                        style: const TextStyle(
                                          color: Color(0xFF111111),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(int type, String label) {
    final selected = _transactionType == type;
    final selectedColor = type == 1
        ? const Color(0xFF00A63E)
        : type == 2
        ? const Color(0xFFEF4444)
        : const Color(0xFF2B7FFF);

    return Expanded(
      child: GestureDetector(
        onTap: _submitting
            ? null
            : () {
                setState(() => _transactionType = type);
                _applyCategoryFilter();
              },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? selectedColor : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: selected
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                      spreadRadius: -1,
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF8B8B8B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
