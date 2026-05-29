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
import '../features/budgets/presentation/budget_screen.dart';
import '../features/budgets/presentation/create_budget_screen.dart';
import '../features/budgets/presentation/budget_detail_screen.dart';
import '../features/budgets/domain/entities/budget_status.dart';
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
import '../features/transactions/presentation/transaction_detail_screen.dart';
import '../features/transactions/presentation/delete_transaction_screen.dart';
import '../features/wallets/presentation/add_wallet_screen.dart';
import '../features/wallets/presentation/wallet_detail_screen.dart';
import '../features/wallets/presentation/wallets_screen.dart';
import '../features/wallets/domain/entities/wallet.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/profile/presentation/settings_screen.dart';
import '../features/profile/presentation/change_password_screen.dart';
import '../features/profile/presentation/privacy_policy_screen.dart';
import '../features/profile/presentation/terms_of_service_screen.dart';
import '../features/profile/presentation/delete_account_screen.dart';
import '../features/profile/presentation/logout_confirm_screen.dart';
import '../features/profile/presentation/help_faq_screen.dart';
import '../features/profile/presentation/change_verify_screen.dart';
import '../features/profile/presentation/change_reset_password_screen.dart';
import '../features/profile/presentation/change_password_success_screen.dart';

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
      path: '/transactions/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return TransactionDetailScreen(transactionId: id);
      },
      routes: [
        GoRoute(
          path: 'delete',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return DeleteTransactionScreen(transactionId: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/analytics',
      builder: (context, state) => const AnalyticsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: 'change-password',
          builder: (context, state) => const ProfileChangePasswordScreen(),
        ),
        GoRoute(
          path: 'change-verify',
          builder: (context, state) {
            final phone = state.uri.queryParameters['phone'];
            final code = state.uri.queryParameters['code'];
            return ProfileChangeVerifyScreen(
              phoneNumber: phone,
              demoCode: code,
            );
          },
        ),
        GoRoute(
          path: 'change-reset',
          builder: (context, state) {
            final phone = state.uri.queryParameters['phone'];
            final code = state.uri.queryParameters['code'];
            return ProfileChangeResetPasswordScreen(
              phoneNumber: phone,
              verificationCode: code,
            );
          },
        ),
        GoRoute(
          path: 'change-success',
          builder: (context, state) =>
              const ProfileChangePasswordSuccessScreen(),
        ),
        GoRoute(
          path: 'terms',
          builder: (context, state) => const TermsOfServiceScreen(),
        ),
        GoRoute(
          path: 'privacy',
          builder: (context, state) => const PrivacyPolicyScreen(),
        ),
        GoRoute(
          path: 'delete',
          builder: (context, state) => const DeleteAccountScreen(),
        ),
        GoRoute(
          path: 'logout',
          builder: (context, state) => const LogoutConfirmScreen(),
        ),
        GoRoute(
          path: 'help',
          builder: (context, state) => const HelpFaqScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/budgets',
      builder: (context, state) => const BudgetScreen(),
      routes: [
        GoRoute(
          path: 'create',
          builder: (context, state) => const CreateBudgetScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final budget = state.extra as BudgetStatusEntity?;
            if (budget == null) {
              return const BudgetScreen();
            }
            return BudgetDetailScreen(budget: budget);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/wallets',
      builder: (context, state) => const WalletsScreen(),
      routes: [
        GoRoute(
          path: 'create',
          builder: (context, state) => const AddWalletScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final wallet = state.extra as WalletEntity?;
            if (wallet == null) {
              return const WalletsScreen();
            }
            return WalletDetailScreen(wallet: wallet);
          },
        ),
      ],
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
