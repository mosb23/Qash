import 'package:flutter/material.dart';

class CurrencyFlag extends StatelessWidget {
  final String currencyCode;
  final double width;
  final double height;

  const CurrencyFlag({
    super.key,
    required this.currencyCode,
    this.width = 24,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = _assetPathForCurrency(currencyCode);
    if (assetPath == null) {
      return Text(
        currencyCode.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }

  String? _assetPathForCurrency(String code) {
    switch (code.trim().toUpperCase()) {
      case 'USD':
        return 'assets/icons/flags/USA_Flag.png';
      case 'EGP':
        return 'assets/icons/flags/Egypt_Flag.png';
      case 'EUR':
        return 'assets/icons/flags/Euro_Flag.png';
      case 'GBP':
        return 'assets/icons/flags/UK_Flag.png';
      case 'JPY':
        return 'assets/icons/flags/Japan_Flag.png';
      default:
        return null;
    }
  }
}
