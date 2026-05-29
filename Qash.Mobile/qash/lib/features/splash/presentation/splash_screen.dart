import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/providers.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/auth/onboarding_preferences.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await ref.read(appInitializationProvider.future);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final auth = ref.read(authStatusProvider);
    if (auth == AuthStatus.authenticated) {
      context.go('/home');
      return;
    }

    final onboardingDone = ref.read(onboardingCompletedProvider);
    if (!onboardingDone) {
      context.go('/onboarding');
      return;
    }

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF4D93A),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Q',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Qash',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Smart Money Management',
              style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 16),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Color(0xFFF4D93A),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
