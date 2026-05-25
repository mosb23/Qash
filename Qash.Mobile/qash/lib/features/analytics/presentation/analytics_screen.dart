import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/utils/result.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../categories/domain/entities/category.dart';
import '../../categories/providers/categories_providers.dart';
import '../../transactions/domain/entities/transaction.dart';
import '../../transactions/providers/transactions_providers.dart';
import '../domain/entities/category_breakdown.dart';
import '../domain/entities/income_vs_expense.dart';
import '../domain/entities/spending_trend.dart';
import '../providers/analytics_providers.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  static const _categoryColors = [
    Color(0xFFF97316),
    Color(0xFF8B5CF6),
    Color(0xFF3B82F6),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
    Color(0xFFEF4444),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(analyticsPeriodProvider);
    final summary = ref.watch(analyticsSummaryProvider);
    final breakdown = period == AnalyticsPeriod.month
        ? ref.watch(categoryBreakdownProvider)
        : AsyncValue.data(Result.success(<CategoryBreakdownEntity>[]));
    final categories = period == AnalyticsPeriod.month
        ? ref.watch(categoriesProvider)
        : AsyncValue.data(Result.success(<CategoryEntity>[]));
    final transactions = period == AnalyticsPeriod.month
      ? ref.watch(transactionsProvider)
      : AsyncValue.data(Result.success(<TransactionEntity>[]));
    final incomeVsExpense = ref.watch(incomeVsExpenseProvider);
    final spendingTrend = ref.watch(spendingTrendProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(monthlySummaryProvider);
                  ref.invalidate(categoryBreakdownProvider);
                  ref.invalidate(incomeVsExpenseProvider);
                  ref.invalidate(spendingTrendProvider);
                  ref.invalidate(dateRangeSummaryProvider);
                  ref.invalidate(categoriesProvider);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      const Text(
                        'Analytics',
                        style: TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _periodSelector(period, ref),
                      const SizedBox(height: 16),
                      _summaryCards(summary),
                      const SizedBox(height: 16),
                      _categoryBreakdownSection(
                        period: period,
                        breakdown: breakdown,
                        categories: categories,
                        transactions: transactions,
                      ),
                      const SizedBox(height: 16),
                      _card(
                        title: 'Cash Flow Summary',
                        height: 180,
                        child: _cashFlowSummary(summary),
                      ),
                      const SizedBox(height: 16),
                      _card(
                        title: 'Spending Trend',
                        height: 180,
                        child: _spendingTrendSection(spendingTrend),
                      ),
                      const SizedBox(height: 16),
                      if (period == AnalyticsPeriod.year)
                        _card(
                          title: 'Income vs Expense',
                          child: _incomeVsExpenseSection(incomeVsExpense),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            AppBottomNavBar(
              currentTab: AppTab.analytics,
              onSelected: (tab) => _onTabSelected(context, tab),
            ),
          ],
        ),
      ),
    );
  }

  Widget _periodSelector(AnalyticsPeriod period, WidgetRef ref) {
    final labels = ['Week', 'Month', 'Year'];
    return Container(
      padding: const EdgeInsets.all(4),
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
      child: Row(
        children: List.generate(labels.length, (i) {
          final isActive = period.index == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(analyticsPeriodProvider.notifier).state =
                    AnalyticsPeriod.values[i];
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 36,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF111111)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF8B8B8B),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _summaryCards(AsyncValue<AnalyticsSummary> summary) {
    return summary.when(
      data: (value) {
        return Row(
          children: [
            Expanded(
              child: _summaryCard(
                'Income',
                _formatCurrency(value.totalIncome),
                const Color(0xFFD9F0C8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                'Expenses',
                _formatCurrency(value.totalExpenses),
                const Color(0xFFFFE3E3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                'Net',
                _formatCurrency(value.netBalance),
                const Color(0xFFFEF3C7),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 72,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Text(
        _errorText(error),
        style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0x99111111),
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryBreakdownSection({
    required AnalyticsPeriod period,
    required AsyncValue<Result<List<CategoryBreakdownEntity>>> breakdown,
    required AsyncValue<Result<List<CategoryEntity>>> categories,
    required AsyncValue<Result<List<TransactionEntity>>> transactions,
  }) {
    if (period != AnalyticsPeriod.month) {
      return const SizedBox.shrink();
    }

    return breakdown.when(
      data: (result) {
        if (result.isFailure) {
          return Text(
            result.message,
            style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          );
        }
        final items = result.data ?? const [];
        if (items.isEmpty) {
          return const Text(
            'No category data yet.',
            style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          );
        }
        final categoryMap = _buildCategoryNameMap(categories, transactions);
        return _card(
          title: 'Spending by Category',
          height: 200,
          child: _categoryChart(items, categoryMap),
        );
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Text(
        _errorText(error),
        style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
      ),
    );
  }

  Map<String, String> _buildCategoryNameMap(
    AsyncValue<Result<List<CategoryEntity>>> categories,
    AsyncValue<Result<List<TransactionEntity>>> transactions,
  ) {
    final names = <String, String>{};

    categories.maybeWhen(
      data: (result) {
        final items = result.data ?? const [];
        for (final item in items) {
          names[item.id] = item.name;
        }
      },
      orElse: () {},
    );

    transactions.maybeWhen(
      data: (result) {
        final items = result.data ?? const [];
        for (final item in items) {
          if (item.categoryId.isNotEmpty && item.categoryName.isNotEmpty) {
            names.putIfAbsent(item.categoryId, () => item.categoryName);
          }
        }
      },
      orElse: () {},
    );

    return names;
  }

  Widget _categoryChart(
    List<CategoryBreakdownEntity> items,
    Map<String, String> categoryMap,
  ) {
    final total = items.fold<double>(0, (sum, item) => sum + item.totalAmount);
    if (total <= 0) {
      return const Center(
        child: Text(
          'No expense data yet',
          style: TextStyle(color: Color(0xFF8B8B8B)),
        ),
      );
    }

    final segments = <_DonutSegment>[];
    var colorIndex = 0;
    for (final item in items) {
      segments.add(
        _DonutSegment(
          value: item.totalAmount / total,
          color: _categoryColors[colorIndex % _categoryColors.length],
        ),
      );
      colorIndex++;
    }

    return Row(
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: CustomPaint(painter: _DonutPainter(segments: segments)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final color = _categoryColors[idx % _categoryColors.length];
                    final categoryName =
                      categoryMap[item.categoryId] ?? item.categoryId;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              categoryName,
                              style: const TextStyle(
                                color: Color(0xFF8B8B8B),
                                fontSize: 12,
                                fontFamily: 'Inter',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatCurrency(item.totalAmount),
                      style: const TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _cashFlowSummary(AsyncValue<AnalyticsSummary> summary) {
    return summary.when(
      data: (value) {
        final maxVal = math.max(
          value.totalIncome,
          math.max(value.totalExpenses, value.netBalance.abs()),
        );
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _cashFlowRow(
              'Total Income',
              value.totalIncome,
              maxVal,
              const Color(0xFF10B981),
            ),
            const SizedBox(height: 16),
            _cashFlowRow(
              'Total Expenses',
              value.totalExpenses,
              maxVal,
              const Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            _cashFlowRow(
              'Net Savings',
              value.netBalance,
              maxVal,
              const Color(0xFF3B82F6),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text(
        _errorText(error),
        style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
      ),
    );
  }

  Widget _cashFlowRow(String label, double value, double maxVal, Color color) {
    final ratio = maxVal > 0 ? (value.abs() / maxVal).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8B8B8B),
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              _formatCurrency(value),
              style: const TextStyle(
                color: Color(0xFF111111),
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  height: 6,
                  width: constraints.maxWidth * ratio,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _spendingTrendSection(
    AsyncValue<Result<List<SpendingTrendEntity>>> trend,
  ) {
    return trend.when(
      data: (result) {
        if (result.isFailure) {
          return Text(
            result.message,
            style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          );
        }
        final items = result.data ?? const [];
        if (items.isEmpty) {
          return const Center(
            child: Text(
              'No spending data yet.',
              style: TextStyle(color: Color(0xFF8B8B8B)),
            ),
          );
        }
        final slice = items.length > 7
            ? items.sublist(items.length - 7)
            : items;
        final maxValue = slice.fold<double>(
          0,
          (max, item) => math.max(max, item.totalExpenses),
        );

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: slice.map((item) {
            final ratio = maxValue > 0 ? item.totalExpenses / maxValue : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    child: Text(
                      DateFormat('MM/dd').format(item.date),
                      style: const TextStyle(
                        color: Color(0xFF8B8B8B),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: ratio,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatCurrency(item.totalExpenses),
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text(
        _errorText(error),
        style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
      ),
    );
  }

  Widget _incomeVsExpenseSection(
    AsyncValue<Result<List<IncomeVsExpenseEntity>>> data,
  ) {
    return data.when(
      data: (result) {
        if (result.isFailure) {
          return Text(
            result.message,
            style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          );
        }
        final items = result.data ?? const [];
        if (items.isEmpty) {
          return const Center(
            child: Text(
              'No yearly data yet.',
              style: TextStyle(color: Color(0xFF8B8B8B)),
            ),
          );
        }
        final maxValue = items.fold<double>(
          0,
          (max, item) => math.max(max, math.max(item.income, item.expenses)),
        );
        return Column(
          children: items.map((item) {
            final ratioIncome = maxValue > 0 ? (item.income / maxValue) : 0.0;
            final ratioExpense = maxValue > 0
                ? (item.expenses / maxValue)
                : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      item.month.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        color: Color(0xFF8B8B8B),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: ratioIncome,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: ratioExpense,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatShort(item.income)} / ${_formatShort(item.expenses)}',
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text(
        _errorText(error),
        style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
      ),
    );
  }

  Widget _card({
    required String title,
    double? height,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
            title,
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          if (height != null) SizedBox(height: height, child: child) else child,
        ],
      ),
    );
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
        return;
      case AppTab.goals:
        context.go('/goals');
        return;
      case AppTab.profile:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Coming soon.')));
    }
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(symbol: '\$').format(value);
  }

  String _formatShort(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  String _errorText(Object error) {
    if (error is AppFailure) {
      return error.message;
    }
    return 'Failed to load data.';
  }
}

class _DonutSegment {
  final double value;
  final Color color;

  const _DonutSegment({required this.value, required this.color});
}

class _DonutPainter extends CustomPainter {
  final List<_DonutSegment> segments;

  const _DonutPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 22.0;
    var startAngle = -math.pi / 2;
    for (final segment in segments) {
      final sweepAngle = segment.value * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle - 0.04,
        false,
        Paint()
          ..color = segment.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
