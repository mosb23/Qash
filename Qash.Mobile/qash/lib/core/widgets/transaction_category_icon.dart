import 'package:flutter/material.dart';

class TransactionCategoryIcon extends StatelessWidget {
  static const Map<String, String> _assetNames = {
    'bills': 'Bills.png',
    'education': 'Education.png',
    'entertainment': 'Entertainment.png',
    'food': 'Food.png',
    'freelance': 'Freelance.png',
    'gift': 'Gift.png',
    'health': 'Health.png',
    'other': 'Other.png',
    'salary': 'Salary.png',
    'shopping': 'Shopping.png',
    'transport': 'Transport.png',
    'exchange': 'exchange.png',
  };

  final String categoryName;
  final String? categoryIcon;
  final bool isTransfer;
  final Color backgroundColor;
  final double size;
  final double iconSize;
  final double borderRadius;

  const TransactionCategoryIcon({
    super.key,
    required this.categoryName,
    this.categoryIcon,
    required this.isTransfer,
    required this.backgroundColor,
    this.size = 40,
    this.iconSize = 22,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = _assetPath();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: assetPath != null
            ? Image.asset(
                assetPath,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
              )
            : Text(
                _fallbackLabel(),
                style: TextStyle(
                  color: const Color(0xFF111111).withOpacity(0.75),
                  fontSize: iconSize * 0.7,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  String? _assetPath() {
    if (isTransfer) {
      return 'assets/icons/Categories/${_assetNames['exchange']!}';
    }

    final candidate = (categoryIcon?.trim().isNotEmpty == true)
        ? categoryIcon!.trim()
        : categoryName.trim();
    if (candidate.isEmpty) {
      return null;
    }

    final normalized = candidate
        .split(RegExp(r'[\\/]'))
        .last
        .split('.')
        .first
        .toLowerCase();
    final fileName = _assetNames[normalized];
    if (fileName == null) {
      return null;
    }

    return 'assets/icons/Categories/$fileName';
  }

  String _fallbackLabel() {
    final text = categoryName.trim();
    if (text.isEmpty) {
      return '?';
    }
    return text.substring(0, 1).toUpperCase();
  }
}
