import 'package:flutter/material.dart';

import '../utils/currency_formatter.dart';

class CurrencyBadge extends StatelessWidget {
  final String currencyCode;
  final double size;
  final Color backgroundColor;
  final Color foregroundColor;

  const CurrencyBadge({
    super.key,
    required this.currencyCode,
    this.size = 32,
    this.backgroundColor = const Color(0xFF3B82F6),
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final label = CurrencyFormatter.badgeLabel(currencyCode);
    final fontSize = label.length > 2 ? 11.0 : 14.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: foregroundColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
