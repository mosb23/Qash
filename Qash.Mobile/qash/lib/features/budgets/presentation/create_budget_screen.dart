import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';
import 'package:qash/core/utils/currency_formatter.dart';

import '../../categories/domain/entities/category.dart';
import '../../dashboard/providers/home_preferences_provider.dart';
import '../../categories/providers/categories_providers.dart';
import '../domain/entities/budget_create.dart';
import '../domain/entities/budget_status.dart';
import '../domain/entities/budget_update.dart';
import '../providers/budgets_providers.dart';

class CreateBudgetScreen extends ConsumerStatefulWidget {
  final BudgetStatusEntity? budget;
  final String? budgetId;

  const CreateBudgetScreen({super.key, this.budget, this.budgetId});

  @override
  ConsumerState<CreateBudgetScreen> createState() =>
      _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends ConsumerState<CreateBudgetScreen> {
  final TextEditingController limitController = TextEditingController();

  String? selectedCategoryId;
  bool _submitting = false;
  BudgetStatusEntity? _resolvedBudget;
  bool _initializedFromBudget = false;

  bool get _isEdit => widget.budget != null || widget.budgetId != null;

  BudgetStatusEntity? get _editBudget => _resolvedBudget ?? widget.budget;

  @override
  void initState() {
    super.initState();
    _resolvedBudget = widget.budget;
    _hydrateFromBudget(_resolvedBudget);
  }

  void _hydrateFromBudget(BudgetStatusEntity? budget) {
    if (budget == null || _initializedFromBudget) {
      return;
    }
    selectedCategoryId = budget.categoryId;
    limitController.text = budget.budgetAmount.toStringAsFixed(2);
    _initializedFromBudget = true;
  }

  @override
  void dispose() {
    limitController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(limitController.text.trim());
    final categoryId = selectedCategoryId;

    if (categoryId == null || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }

    final period = ref.read(budgetPeriodProvider);
    final editBudget = _editBudget;
    final year = editBudget?.year ?? period.year;
    final month = editBudget?.month ?? period.month;

    setState(() {
      _submitting = true;
    });

    final result = _isEdit
        ? await ref.read(updateBudgetUseCaseProvider)(
            BudgetUpdateData(
              budgetId: editBudget!.budgetId,
              userId: '',
              categoryId: categoryId,
              amount: amount,
              year: year,
              month: month,
            ),
          )
        : await ref.read(createBudgetUseCaseProvider)(
            BudgetCreateData(
              userId: '',
              categoryId: categoryId,
              amount: amount,
              year: year,
              month: month,
            ),
          );

    if (!mounted) return;

    setState(() {
      _submitting = false;
    });

    if (result.isSuccess) {
      ref.invalidate(budgetStatusesProvider);
      Navigator.pop(context);
      return;
    }

    final message = result.message.isNotEmpty
        ? result.message
        : 'Failed to create budget.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;

    if (!_initializedFromBudget &&
        _resolvedBudget == null &&
        widget.budgetId != null) {
      final budgetAsync = ref.watch(budgetByIdProvider(widget.budgetId!));
      if (budgetAsync.value?.isSuccess == true) {
        _resolvedBudget = budgetAsync.value!.data;
        _hydrateFromBudget(_resolvedBudget);
      } else if (budgetAsync.isLoading) {
        return Scaffold(
          backgroundColor: qash.scaffoldBackground,
          body: const Center(child: CircularProgressIndicator()),
        );
      } else if (budgetAsync.hasValue && budgetAsync.value!.isFailure) {
        final message = budgetAsync.value!.message.isNotEmpty
            ? budgetAsync.value!.message
            : 'Budget was not found.';
        return Scaffold(
          backgroundColor: qash.scaffoldBackground,
          appBar: AppBar(
            title: Text('Edit Budget', style: TextStyle(color: qash.textPrimary)),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message, textAlign: TextAlign.center, style: TextStyle(color: qash.textSecondary)),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () =>
                        ref.invalidate(budgetByIdProvider(widget.budgetId!)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    final categoriesAsync = ref.watch(categoriesProvider);
    final period = ref.watch(budgetPeriodProvider);
    final displayCurrency = ref.watch(displayCurrencyProvider);
    final editPeriod = _editBudget != null
        ? BudgetPeriod(year: _editBudget!.year, month: _editBudget!.month)
        : period;

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
              boxShadow: [
                BoxShadow(
                  color: qash.cardShadow,
                  blurRadius: 6,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: qash.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          _isEdit ? 'Edit Budget' : 'Set Budget',
          style: TextStyle(
            color: qash.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: qash.accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Setting budget for',
                    style: TextStyle(
                      color: qash.onAccent.withValues(alpha: 0.65),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _periodLabel(editPeriod),
                    style: TextStyle(
                      color: qash.onAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Category',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: qash.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            categoriesAsync.when(
              data: (result) {
                if (result.isFailure) {
                  return Text(
                    result.message,
                    style: TextStyle(
                      color: qash.textSecondary,
                      fontSize: 12,
                    ),
                  );
                }

                final items = (result.data ?? const <CategoryEntity>[])
                    .where((category) => category.type == CategoryType.expense)
                    .toList();

                if (items.isNotEmpty &&
                    selectedCategoryId == null &&
                    !_isEdit) {
                  selectedCategoryId = items.first.id;
                }

                return Column(
                  children: [
                    for (final category in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CategorySelectionTile(
                          category: category,
                          selected: selectedCategoryId == category.id,
                          onTap: () {
                            setState(() {
                              selectedCategoryId = category.id;
                            });
                          },
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Text(
                'Failed to load categories.',
                style: TextStyle(color: qash.textSecondary, fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Monthly Limit ($displayCurrency)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: qash.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: limitController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: qash.textPrimary),
              decoration: InputDecoration(
                prefixText: '${CurrencyFormatter.symbolFor(displayCurrency)} ',
                hintText: '0.00',
                filled: true,
                fillColor: qash.surface,
                hintStyle: TextStyle(color: qash.textHint),
                prefixStyle: TextStyle(color: qash.textPrimary, fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: qash.border),
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: qash.primaryButton,
                  disabledBackgroundColor: qash.primaryButton.withValues(alpha: 0.4),
                  foregroundColor: qash.onPrimaryButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _submitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: qash.onPrimaryButton,
                        ),
                      )
                    : Text(
                        _isEdit ? 'Save Changes' : 'Set Budget',
                        style: TextStyle(
                          color: qash.onPrimaryButton,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            if (_isEdit) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _submitting ? null : _deleteBudget,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: qash.danger,
                    side: BorderSide(color: qash.danger),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Delete Budget',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _deleteBudget() async {
    final budget = _editBudget;
    if (budget == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete budget?'),
        content: Text(
          'Remove the ${budget.categoryName} budget for this month?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: context.qash.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _submitting = true);
    final result = await ref.read(deleteBudgetUseCaseProvider)(budget.budgetId);
    if (!mounted) return;

    setState(() => _submitting = false);

    if (result.isSuccess) {
      ref.invalidate(budgetStatusesProvider);
      Navigator.pop(context);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.message.isNotEmpty
              ? result.message
              : 'Failed to delete budget.',
        ),
      ),
    );
  }
}

class CategorySelectionTile extends StatelessWidget {
  final CategoryEntity category;
  final bool selected;
  final VoidCallback onTap;

  const CategorySelectionTile({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: qash.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? qash.textPrimary : qash.border,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(color: qash.cardShadow, blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: qash.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  category.name.isNotEmpty
                      ? category.name.substring(0, 1).toUpperCase()
                      : '?',
                  style: TextStyle(color: qash.textPrimary, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  color: qash.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (selected)
              CircleAvatar(
                radius: 12,
                backgroundColor: qash.primaryButton,
                child: Icon(Icons.check, size: 14, color: qash.onPrimaryButton),
              ),
          ],
        ),
      ),
    );
  }
}

String _periodLabel(BudgetPeriod period) {
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
  final index = period.month - 1;
  final monthName = index >= 0 && index < months.length
      ? months[index]
      : period.month.toString();
  return '$monthName ${period.year}';
}
