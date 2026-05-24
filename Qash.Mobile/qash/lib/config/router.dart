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
import '../features/analytics/presentation/analytics_screen.dart';
import '../features/dashboard/presentation/home_screen.dart';
import '../features/goals/presentation/create_goal_screen.dart';
import '../features/goals/presentation/add_funds_screen.dart';
import '../features/goals/presentation/goal_detail_screen.dart';
import '../features/goals/presentation/goals_screen.dart';
import '../features/goals/presentation/delete_goal_screen.dart';
import '../features/goals/domain/entities/saving_goal.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/transactions/presentation/transactions_screen.dart';
import '../features/transactions/presentation/add_transaction_screen.dart';

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
    GoRoute(
      path: '/transactions/add',
      builder: (context, state) {
        final typeParam = state.uri.queryParameters['type'];
        final parsed = int.tryParse(typeParam ?? '');
        final initialType = (parsed != null && parsed >= 1 && parsed <= 3)
            ? parsed
            : 2;
        return AddTransactionScreen(initialType: initialType);
      },
    ),
    GoRoute(
      path: '/analytics',
      builder: (context, state) => const AnalyticsScreen(),
    ),
    GoRoute(
      path: '/goals',
      builder: (context, state) => const GoalsScreen(),
      routes: [
        GoRoute(
          path: 'create',
          builder: (context, state) => const CreateGoalScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final goal = state.extra as SavingGoalEntity?;
            if (goal == null) {
              return const GoalsScreen();
            }
            return GoalDetailScreen(goal: goal);
          },
        ),
        GoRoute(
          path: ':id/add-funds',
          builder: (context, state) {
            final goal = state.extra as SavingGoalEntity?;
            if (goal == null) {
              return const GoalsScreen();
            }
            return AddFundsScreen(goal: goal);
          },
        ),
        GoRoute(
          path: ':id/delete',
          builder: (context, state) {
            final goal = state.extra as SavingGoalEntity?;
            if (goal == null) {
              return const GoalsScreen();
            }
            return DeleteGoalScreen(goal: goal);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/goals/:id/add-funds',
      builder: (context, state) {
        final goal = state.extra as SavingGoalEntity?;
        if (goal == null) {
          return const GoalsScreen();
        }
        return AddFundsScreen(goal: goal);
      },
    ),
  ],
);
