import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/utils/result.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../categories/domain/entities/category.dart';
import '../../categories/providers/categories_providers.dart';
import '../../transactions/domain/entities/transaction.dart';
import '../../transactions/providers/transactions_providers.dart';
import '../domain/entities/category_breakdown.dart';
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
    final qash = context.qash;
    final period = ref.watch(analyticsPeriodProvider);
    final summary = ref.watch(analyticsSummaryProvider);
    final breakdown = ref.watch(periodCategoryBreakdownProvider);
    final categories = ref.watch(categoriesProvider);
    final transactions = ref.watch(transactionsProvider);
    final periodComparison = ref.watch(periodComparisonProvider);
    final spendingTrend = ref.watch(spendingTrendProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(monthlySummaryProvider);
                  ref.invalidate(categoryBreakdownProvider);
                  ref.invalidate(periodCategoryBreakdownProvider);
                  ref.invalidate(incomeVsExpenseProvider);
                  ref.invalidate(periodComparisonProvider);
                  ref.invalidate(spendingTrendProvider);
                  ref.invalidate(dateRangeSummaryProvider);
                  ref.invalidate(categoriesProvider);
                  ref.invalidate(transactionsProvider);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'Analytics',
                        style: TextStyle(
                          color: qash.textPrimary,
                          fontSize: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _periodSelector(context, period, ref),
                      const SizedBox(height: 16),
                      _summaryCards(context, summary),
                      const SizedBox(height: 16),
                      _categoryBreakdownSection(
                        context,
                        period: period,
                        breakdown: breakdown,
                        categories: categories,
                        transactions: transactions,
                      ),
                      const SizedBox(height: 16),
                      _card(
                        context,
                        title: 'Cash Flow Summary',
                        height: 180,
                        child: _cashFlowSummary(context, summary),
                      ),
                      const SizedBox(height: 16),
                      _card(
                        context,
                        title: _spendingTrendTitle(period),
                        height: _spendingTrendHeight(period),
                        child: _spendingTrendSection(
                          context,
                          period: period,
                          trend: spendingTrend,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (period == AnalyticsPeriod.week ||
                          period == AnalyticsPeriod.year)
                        _card(
                          context,
                          title: period == AnalyticsPeriod.year
                              ? 'Income vs Expense (Yearly)'
                              : 'Income vs Expense (Weekly)',
                          height: _comparisonChartHeight(period),
                          child: _periodComparisonSection(
                            context,
                            periodComparison,
                          ),
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

  Widget _periodSelector(
    BuildContext context,
    AnalyticsPeriod period,
    WidgetRef ref,
  ) {
    final qash = context.qash;
    final labels = ['Week', 'Month', 'Year'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: qash.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: qash.cardShadow,
            blurRadius: 2,
            offset: const Offset(0, 1),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: qash.cardShadow,
            blurRadius: 3,
            offset: const Offset(0, 1),
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
                  color: isActive ? qash.primaryButton : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: isActive ? qash.onPrimaryButton : qash.textSecondary,
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

  Widget _summaryCards(
    BuildContext context,
    AsyncValue<AnalyticsSummary> summary,
  ) {
    return summary.when(
      data: (value) {
        return Row(
          children: [
            Expanded(
              child: _summaryCard(
                context,
                'Income',
                _formatCurrency(value.totalIncome),
                const Color(0xFFD9F0C8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                context,
                'Expenses',
                _formatCurrency(value.totalExpenses),
                const Color(0xFFFFE3E3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                context,
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
        style: TextStyle(color: context.qash.textSecondary, fontSize: 12),
      ),
    );
  }

  Widget _summaryCard(BuildContext context, String label, String value, Color bg) {
    final qash = context.qash;
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
            style: TextStyle(
              color: qash.textPrimary.withValues(alpha: 0.6),
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: qash.textPrimary,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _spendingTrendTitle(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.week:
        return 'Weekly Spending';
      case AnalyticsPeriod.month:
        return 'Spending Trend';
      case AnalyticsPeriod.year:
        return 'Yearly Spending';
    }
  }

  double? _spendingTrendHeight(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.week:
        return 200;
      case AnalyticsPeriod.month:
        return 240;
      case AnalyticsPeriod.year:
        return 260;
    }
  }

  double? _comparisonChartHeight(AnalyticsPeriod period) {
    if (period == AnalyticsPeriod.year) return 280;
    if (period == AnalyticsPeriod.week) return 200;
    return null;
  }

  String _categorySectionTitle(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.week:
        return 'Weekly Spending by Category';
      case AnalyticsPeriod.month:
        return 'Spending by Category';
      case AnalyticsPeriod.year:
        return 'Yearly Spending by Category';
    }
  }

  Widget _categoryBreakdownSection(
    BuildContext context, {
    required AnalyticsPeriod period,
    required AsyncValue<Result<List<CategoryBreakdownEntity>>> breakdown,
    required AsyncValue<Result<List<CategoryEntity>>> categories,
    required AsyncValue<Result<List<TransactionEntity>>> transactions,
  }) {
    final qash = context.qash;
    return breakdown.when(
      data: (result) {
        if (result.isFailure) {
          return Text(
            result.message,
            style: TextStyle(color: qash.textSecondary, fontSize: 12),
          );
        }
        final items = result.data ?? const [];
        if (items.isEmpty) {
          return Text(
            'No category data yet.',
            style: TextStyle(color: qash.textSecondary, fontSize: 12),
          );
        }
        final categoryMap = _buildCategoryNameMap(categories, transactions);
        return _card(
          context,
          title: _categorySectionTitle(period),
          height: 200,
          child: _categoryChart(context, items, categoryMap),
        );
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Text(
        _errorText(error),
        style: TextStyle(color: qash.textSecondary, fontSize: 12),
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
    BuildContext context,
    List<CategoryBreakdownEntity> items,
    Map<String, String> categoryMap,
  ) {
    final qash = context.qash;
    final total = items.fold<double>(0, (sum, item) => sum + item.totalAmount);
    if (total <= 0) {
      return Center(
        child: Text(
          'No expense data yet',
          style: TextStyle(color: qash.textSecondary),
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
                              style: TextStyle(
                                color: qash.textSecondary,
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
                      style: TextStyle(
                        color: qash.textPrimary,
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

  Widget _cashFlowSummary(
    BuildContext context,
    AsyncValue<AnalyticsSummary> summary,
  ) {
    final qash = context.qash;
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
              context,
              'Total Income',
              value.totalIncome,
              maxVal,
              const Color(0xFF10B981),
            ),
            const SizedBox(height: 16),
            _cashFlowRow(
              context,
              'Total Expenses',
              value.totalExpenses,
              maxVal,
              const Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            _cashFlowRow(
              context,
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
        style: TextStyle(color: qash.textSecondary, fontSize: 12),
      ),
    );
  }

  Widget _cashFlowRow(
    BuildContext context,
    String label,
    double value,
    double maxVal,
    Color color,
  ) {
    final qash = context.qash;
    final ratio = maxVal > 0 ? (value.abs() / maxVal).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: qash.textSecondary,
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              _formatCurrency(value),
              style: TextStyle(
                color: qash.textPrimary,
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
                color: qash.border,
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
    BuildContext context, {
    required AnalyticsPeriod period,
    required AsyncValue<Result<List<SpendingTrendEntity>>> trend,
  }) {
    final qash = context.qash;
    return trend.when(
      data: (result) {
        if (result.isFailure) {
          return Text(
            result.message,
            style: TextStyle(color: qash.textSecondary, fontSize: 12),
          );
        }
        final raw = result.data ?? const [];
        if (raw.isEmpty) {
          return Center(
            child: Text(
              'No spending data yet.',
              style: TextStyle(color: qash.textSecondary),
            ),
          );
        }

        final items = period == AnalyticsPeriod.year
            ? _aggregateSpendingByMonth(raw, DateTime.now().year)
            : raw;

        final maxValue = items.fold<double>(
          0,
          (max, item) => math.max(max, item.totalExpenses),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: items.map((item) {
            final ratio = maxValue > 0 ? item.totalExpenses / maxValue : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: period == AnalyticsPeriod.year ? 40 : 48,
                    child: Text(
                      _spendingTrendLabel(item.date, period),
                      style: TextStyle(
                        color: qash.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: qash.border,
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
                    style: TextStyle(
                      color: qash.textPrimary,
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
        style: TextStyle(color: qash.textSecondary, fontSize: 12),
      ),
    );
  }

  List<SpendingTrendEntity> _aggregateSpendingByMonth(
    List<SpendingTrendEntity> daily,
    int year,
  ) {
    final totals = List<double>.filled(12, 0);
    for (final item in daily) {
      if (item.date.year == year) {
        totals[item.date.month - 1] += item.totalExpenses;
      }
    }

    return List.generate(
      12,
      (index) => SpendingTrendEntity(
        date: DateTime(year, index + 1, 1),
        totalExpenses: totals[index],
      ),
    );
  }

  String _spendingTrendLabel(DateTime date, AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.week:
        return DateFormat('EEE').format(date);
      case AnalyticsPeriod.month:
        return DateFormat('d MMM').format(date);
      case AnalyticsPeriod.year:
        return DateFormat('MMM').format(date);
    }
  }

  Widget _periodComparisonSection(
    BuildContext context,
    AsyncValue<Result<List<PeriodComparisonPoint>>> data,
  ) {
    final qash = context.qash;
    return data.when(
      data: (result) {
        if (result.isFailure) {
          return Text(
            result.message,
            style: TextStyle(color: qash.textSecondary, fontSize: 12),
          );
        }
        final items = result.data ?? const [];
        if (items.isEmpty) {
          return Center(
            child: Text(
              'No comparison data yet.',
              style: TextStyle(color: qash.textSecondary),
            ),
          );
        }
        final maxValue = items.fold<double>(
          0,
          (max, item) => math.max(max, math.max(item.income, item.expenses)),
        );
        return Column(
          children: [
            Row(
              children: [
                _legendDot(const Color(0xFF10B981), 'Income'),
                const SizedBox(width: 16),
                _legendDot(const Color(0xFFEF4444), 'Expense'),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) {
              final ratioIncome = maxValue > 0 ? item.income / maxValue : 0.0;
              final ratioExpense =
                  maxValue > 0 ? item.expenses / maxValue : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: qash.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _comparisonBar(
                              context,
                              ratio: ratioIncome,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _comparisonBar(
                              context,
                              ratio: ratioExpense,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatShort(item.income)}/${_formatShort(item.expenses)}',
                      style: TextStyle(
                        color: qash.textPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text(
        _errorText(error),
        style: TextStyle(color: qash.textSecondary, fontSize: 12),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _comparisonBar(
    BuildContext context, {
    required double ratio,
    required Color color,
  }) {
    final qash = context.qash;
    return Container(
      height: 5,
      width: double.infinity,
      decoration: BoxDecoration(
        color: qash.border,
        borderRadius: BorderRadius.circular(999),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: ratio.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required String title,
    double? height,
    required Widget child,
  }) {
    final qash = context.qash;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: qash.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: qash.cardShadow,
            blurRadius: 2,
            offset: const Offset(0, 1),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: qash.cardShadow,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: qash.textPrimary,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          if (height != null)
            SizedBox(
              height: height,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: child,
              ),
            )
          else
            child,
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
        context.go('/profile');
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
