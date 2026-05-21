import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;

  final List<Map<String, dynamic>> onboardingData = [
    {
      'emoji': '💳',
      'title': 'Track All Your Wallets',
      'description':
          'Manage cash, bank accounts, and savings in one beautiful place. Know your money, grow your money.',
      'color': const Color(0xFFD9F0C8),
    },
    {
      'emoji': '📊',
      'title': 'Smart Budget Insights',
      'description':
          'Set spending limits by category and get notified before you overspend. Stay in control effortlessly.',
      'color': const Color(0xFFFEF3C7),
    },
    {
      'emoji': '🎯',
      'title': 'Achieve Your Financial Goals',
      'description':
          'Whether it’s a vacation or an emergency fund, Qash helps you save smarter and reach your goals faster.',
      'color': const Color(0xFFEDE9FE),
    },
  ];

  void nextPage() {
    if (currentPage < 2) {
      setState(() {
        currentPage += 1;
      });
    } else {
      context.go('/login');
    }
  }

  void skip() {
    setState(() {
      currentPage = 2;
    });
  }

  Widget buildIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: currentPage == index
            ? const Color(0xFF111111)
            : const Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: skip,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Color(0xFF8B8B8B),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: _OnboardingPage(
                  key: ValueKey<int>(currentPage),
                  item: onboardingData[currentPage],
                  currentPage: currentPage,
                  onContinue: nextPage,
                  buildIndicator: buildIndicator,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final Map<String, dynamic> item;
  final int currentPage;
  final VoidCallback onContinue;
  final Widget Function(int) buildIndicator;

  const _OnboardingPage({
    super.key,
    required this.item,
    required this.currentPage,
    required this.onContinue,
    required this.buildIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 380,
            decoration: BoxDecoration(
              color: item['color'],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(item['emoji'], style: const TextStyle(fontSize: 100)),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) => buildIndicator(index)),
          ),
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item['title'],
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111111),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item['description'],
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF8B8B8B),
                height: 1.6,
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111111),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                currentPage == 2 ? 'Get Started' : 'Continue',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account? ',
                style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 14),
              ),
              GestureDetector(
                onTap: () {
                  context.go('/login');
                },
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
