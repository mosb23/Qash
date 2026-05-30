import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/currency/currency_format.dart';
import '../utils/analytics_chart_data.dart';

class AnalyticsVerticalBarChart extends StatelessWidget {
  final List<AnalyticsChartBar> bars;
  final Color barColor;
  final double chartHeight;
  final String Function(double value)? formatValue;

  const AnalyticsVerticalBarChart({
    super.key,
    required this.bars,
    this.barColor = const Color(0xFF3B82F6),
    this.chartHeight = 180,
    this.formatValue,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = bars.fold<double>(
      0,
      (max, bar) => math.max(max, bar.value),
    );
    final plotHeight = chartHeight - 48;

    return SizedBox(
      height: chartHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: bars.map((bar) {
          final ratio = maxValue > 0 ? (bar.value / maxValue).clamp(0.0, 1.0) : 0.0;
          final columnHeight = bar.value > 0
              ? math.max(6.0, plotHeight * ratio)
              : 0.0;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (bar.value > 0)
                    Text(
                      _format(bar.value),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                  if (bar.value > 0) const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                    height: columnHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    bar.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF8B8B8B),
                      fontSize: 11,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _format(double value) {
    if (formatValue != null) {
      return formatValue!(value);
    }
    return formatMoney(value, 'USD');
  }
}

class AnalyticsVerticalGroupedBarChart extends StatelessWidget {
  final List<AnalyticsComparisonBar> bars;
  final double chartHeight;
  final String displayCurrency;

  const AnalyticsVerticalGroupedBarChart({
    super.key,
    required this.bars,
    this.chartHeight = 200,
    this.displayCurrency = 'USD',
  });

  static const _incomeColor = Color(0xFF10B981);
  static const _expenseColor = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final maxValue = bars.fold<double>(
      0,
      (max, bar) => math.max(max, math.max(bar.income, bar.expenses)),
    );
    final plotHeight = chartHeight - 56;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _LegendChip(color: _incomeColor, label: 'Income'),
            SizedBox(width: 16),
            _LegendChip(color: _expenseColor, label: 'Expense'),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: chartHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: bars.map((bar) {
              final incomeHeight = _barHeight(bar.income, maxValue, plotHeight);
              final expenseHeight = _barHeight(bar.expenses, maxValue, plotHeight);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: _GroupedBar(
                              height: incomeHeight,
                              color: _incomeColor,
                              value: bar.income,
                              displayCurrency: displayCurrency,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _GroupedBar(
                              height: expenseHeight,
                              color: _expenseColor,
                              value: bar.expenses,
                              displayCurrency: displayCurrency,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        bar.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8B8B8B),
                          fontSize: 11,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  double _barHeight(double value, double maxValue, double plotHeight) {
    if (value <= 0 || maxValue <= 0) {
      return 0;
    }
    return math.max(6.0, plotHeight * (value / maxValue));
  }
}

class _GroupedBar extends StatelessWidget {
  final double height;
  final Color color;
  final double value;
  final String displayCurrency;

  const _GroupedBar({
    required this.height,
    required this.color,
    required this.value,
    required this.displayCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (value > 0)
          Text(
            _shortValue(value),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 9,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        if (value > 0) const SizedBox(height: 2),
        AnimatedContainer(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ),
      ],
    );
  }

  String _shortValue(double value) {
    final symbol = currencySymbol(displayCurrency);
    if (value >= 1000) {
      return NumberFormat.compactCurrency(symbol: symbol).format(value);
    }
    return NumberFormat.currency(symbol: symbol, decimalDigits: 0).format(value);
  }
}

class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8B8B8B),
            fontSize: 11,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
