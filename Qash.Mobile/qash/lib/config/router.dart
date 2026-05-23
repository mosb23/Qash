import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/forgot_reset_password_screen.dart';
import '../features/auth/presentation/forgot_verify_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/change_password_screen.dart';
import '../features/auth/presentation/password_changed_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/verify_phone_screen.dart';
import '../features/dashboard/presentation/home_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/transactions/presentation/transactions_screen.dart';

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
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/forgot-verify',
      builder: (context, state) {
        final phone = state.uri.queryParameters['phone'];
        final code = state.uri.queryParameters['code'];
        return ForgotVerifyScreen(phoneNumber: phone, demoCode: code);
      },
    ),
    GoRoute(
      path: '/forgot-reset',
      builder: (context, state) {
        final phone = state.uri.queryParameters['phone'];
        final code = state.uri.queryParameters['code'];
        return ForgotResetPasswordScreen(
          phoneNumber: phone,
          verificationCode: code,
        );
      },
    ),
    GoRoute(
      path: '/password-changed',
      builder: (context, state) => const PasswordChangedScreen(),
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
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
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/transactions',
      builder: (context, state) => const TransactionsScreen(),
    ),
  ],
);
