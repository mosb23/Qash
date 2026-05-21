import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/login/login_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/register/register_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/verify/verify_phone_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: const OnboardingScreen(),
        transitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/verify',
      builder: (context, state) {
        final phone = state.uri.queryParameters['phone'];
        return VerifyPhoneScreen(phoneNumber: phone);
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Home'))),
    ),
  ],
);
