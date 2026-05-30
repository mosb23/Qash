import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pops when the stack allows it; otherwise navigates to [fallbackLocation].
void popOrGo(BuildContext context, String fallbackLocation) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallbackLocation);
  }
}
