import 'package:flutter/material.dart';

import '../theme/qash_theme_extension.dart';

/// Wraps a screen with themed scaffold and default text color.
class ThemedScreen extends StatelessWidget {
  const ThemedScreen({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.padding,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;

    return Scaffold(
      appBar: appBar,
      backgroundColor: qash.scaffoldBackground,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: DefaultTextStyle(
        style: TextStyle(
          color: qash.textPrimary,
          fontFamily: 'Inter',
        ),
        child: padding != null
            ? Padding(padding: padding!, child: body)
            : body,
      ),
    );
  }
}

/// Themed surface card used across list-based screens.
class ThemedCard extends StatelessWidget {
  const ThemedCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 24,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: qash.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: qash.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
