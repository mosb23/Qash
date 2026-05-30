import 'package:flutter/material.dart';

class GoalLogo extends StatelessWidget {
  final double size;
  final double padding;

  const GoalLogo({super.key, this.size = 56, this.padding = 10});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        shape: BoxShape.circle,
      ),
      child: Image.asset('assets/icons/Goals/Goals.png', fit: BoxFit.contain),
    );
  }
}
