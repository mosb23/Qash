import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _onboardingCompletedKey = 'onboarding_completed';

final onboardingCompletedProvider =
    StateNotifierProvider<OnboardingCompletedNotifier, bool>((ref) {
  return OnboardingCompletedNotifier();
});

class OnboardingCompletedNotifier extends StateNotifier<bool> {
  OnboardingCompletedNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> markCompleted() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
  }
}
