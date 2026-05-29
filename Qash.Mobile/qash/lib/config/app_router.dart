import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_state.dart';
import '../features/analytics/presentation/analytics_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/forgot_reset_password_screen.dart';
import '../features/auth/presentation/forgot_verify_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/password_changed_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/verify_phone_screen.dart';
import '../features/budgets/domain/entities/budget_status.dart';
import '../features/budgets/presentation/budget_screen.dart';
import '../features/budgets/presentation/create_budget_screen.dart';
import '../features/dashboard/presentation/home_screen.dart';
import '../features/goals/domain/entities/saving_goal.dart';
import '../features/goals/presentation/add_funds_screen.dart';
import '../features/goals/presentation/create_goal_screen.dart';
import '../features/goals/presentation/delete_goal_screen.dart';
import '../features/goals/presentation/goal_detail_screen.dart';
import '../features/goals/presentation/goals_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/profile/presentation/change_password_screen.dart';
import '../features/profile/presentation/delete_account_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/profile/presentation/help_faq_screen.dart';
import '../features/profile/presentation/logout_confirm_screen.dart';
import '../features/profile/presentation/privacy_policy_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/settings_screen.dart';
import '../features/profile/presentation/terms_of_service_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/transactions/presentation/add_transaction_screen.dart';
import '../features/transactions/presentation/edit_transaction_screen.dart';
import '../features/transactions/presentation/transaction_detail_screen.dart';
import '../features/transactions/presentation/transactions_screen.dart';
import '../features/wallets/presentation/add_wallet_screen.dart';
import '../features/wallets/presentation/wallets_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

bool _isPublicRoute(String location) {
  return location == '/' ||
      location == '/onboarding' ||
      location.startsWith('/login') ||
      location.startsWith('/register') ||
      location.startsWith('/verify') ||
      location.startsWith('/forgot') ||
      location == '/password-changed';
}

bool _isProtectedRoute(String location) {
  return location.startsWith('/home') ||
      location.startsWith('/transactions') ||
      location.startsWith('/analytics') ||
      location.startsWith('/goals') ||
      location.startsWith('/profile') ||
      location.startsWith('/budgets') ||
      location.startsWith('/wallets');
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(authRefreshListenableProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final auth = ref.read(authStatusProvider);
      final location = state.matchedLocation;

      if (auth == AuthStatus.unknown && location != '/') {
        return '/';
      }

      if (auth == AuthStatus.unauthenticated && _isProtectedRoute(location)) {
        return '/login';
      }

      if (auth == AuthStatus.authenticated) {
        if (_isPublicRoute(location) &&
            location != '/verify' &&
            !location.startsWith('/forgot')) {
          return '/home';
        }
      }

      return null;
    },
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
        path: '/transactions/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return EditTransactionScreen(transactionId: id);
        },
      ),
      GoRoute(
        path: '/transactions/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return TransactionDetailScreen(transactionId: id);
        },
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(path: 'edit', builder: (context, state) => const EditProfileScreen()),
          GoRoute(path: 'settings', builder: (context, state) => const SettingsScreen()),
          GoRoute(path: 'change-password', builder: (context, state) => const ProfileChangePasswordScreen()),
          GoRoute(path: 'terms', builder: (context, state) => const TermsOfServiceScreen()),
          GoRoute(path: 'privacy', builder: (context, state) => const PrivacyPolicyScreen()),
          GoRoute(path: 'delete', builder: (context, state) => const DeleteAccountScreen()),
          GoRoute(path: 'logout', builder: (context, state) => const LogoutConfirmScreen()),
          GoRoute(path: 'help', builder: (context, state) => const HelpFaqScreen()),
        ],
      ),
      GoRoute(
        path: '/budgets',
        builder: (context, state) => const BudgetScreen(),
        routes: [
          GoRoute(path: 'create', builder: (context, state) => const CreateBudgetScreen()),
          GoRoute(
            path: ':id/edit',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              if (id.isEmpty) {
                return const _MissingDataScreen(message: 'Budget id is missing.');
              }
              final initial = state.extra as BudgetStatusEntity?;
              return CreateBudgetScreen(budgetId: id, budget: initial);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/wallets',
        builder: (context, state) => const WalletsScreen(),
        routes: [
          GoRoute(path: 'create', builder: (context, state) => const AddWalletScreen()),
          GoRoute(
            path: ':id/edit',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              if (id.isEmpty) {
                return const _MissingDataScreen(message: 'Wallet id is missing.');
              }
              return AddWalletScreen(walletId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/goals',
        builder: (context, state) => const GoalsScreen(),
        routes: [
          GoRoute(path: 'create', builder: (context, state) => const CreateGoalScreen()),
          GoRoute(
            path: ':id/edit',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              if (id.isEmpty) {
                return const _MissingDataScreen(message: 'Goal id is missing.');
              }
              return CreateGoalScreen(goalId: id);
            },
          ),
          GoRoute(
            path: ':id/add-funds',
            builder: (context, state) {
              final goal = state.extra as SavingGoalEntity?;
              if (goal == null) {
                return const _MissingDataScreen(message: 'Goal data is missing. Open it from Goals list.');
              }
              return AddFundsScreen(goal: goal);
            },
          ),
          GoRoute(
            path: ':id/delete',
            builder: (context, state) {
              final goal = state.extra as SavingGoalEntity?;
              if (goal == null) {
                return const _MissingDataScreen(message: 'Goal data is missing. Open it from Goals list.');
              }
              return DeleteGoalScreen(goal: goal);
            },
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              if (id.isEmpty) {
                return const _MissingDataScreen(message: 'Goal id is missing.');
              }
              return GoalDetailScreen(goalId: id);
            },
          ),
        ],
      ),
    ],
  );
});

class _MissingDataScreen extends StatelessWidget {
  final String message;

  const _MissingDataScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unable to open screen')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
