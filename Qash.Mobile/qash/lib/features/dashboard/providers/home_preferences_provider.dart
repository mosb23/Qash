import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../wallets/domain/entities/wallet.dart';

const _displayCurrencyKey = 'default_display_currency';
const _balanceHiddenKey = 'balance_hidden';

final balanceHiddenProvider =
    StateNotifierProvider<BalanceHiddenNotifier, bool>((ref) {
  return BalanceHiddenNotifier();
});

class BalanceHiddenNotifier extends StateNotifier<bool> {
  BalanceHiddenNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_balanceHiddenKey) ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_balanceHiddenKey, state);
  }
}

final displayCurrencyProvider =
    StateNotifierProvider<DisplayCurrencyNotifier, String>((ref) {
  return DisplayCurrencyNotifier();
});

class DisplayCurrencyNotifier extends StateNotifier<String> {
  DisplayCurrencyNotifier() : super('USD') {
    _load();
  }

  bool _initializedFromWallets = false;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_displayCurrencyKey);
    if (saved != null && saved.isNotEmpty) {
      state = saved.toUpperCase();
      _initializedFromWallets = true;
    }
  }

  Future<void> setCurrency(String currencyCode) async {
    final code = currencyCode.toUpperCase();
    state = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_displayCurrencyKey, code);
    _initializedFromWallets = true;
  }

  /// Uses the first wallet's currency once if the user has not chosen a display currency.
  void applyDefaultFromWallets(List<WalletEntity> wallets) {
    if (_initializedFromWallets || wallets.isEmpty) {
      return;
    }
    final first = wallets.first.currency.trim();
    if (first.isNotEmpty) {
      state = first.toUpperCase();
      _initializedFromWallets = true;
    }
  }
}
