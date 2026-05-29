/// Asset paths and lookups for Qash custom icons.
class QashIcons {
  QashIcons._();

  static const String _base = 'assets/icons';

  // Bottom navigation
  static const String navHome = '$_base/nav_home.png';
  static const String navTransactions = '$_base/nav_transactions.png';
  static const String navAnalytics = '$_base/nav_analytics.png';
  static const String navGoals = '$_base/nav_goals.png';
  static const String navProfile = '$_base/nav_profile.png';

  // Transaction categories
  static const String categoryFood = '$_base/category_food.png';
  static const String categoryShopping = '$_base/category_shopping.png';
  static const String categoryBills = '$_base/category_bills.png';
  static const String categoryTransport = '$_base/category_transport.png';
  static const String categoryHealth = '$_base/category_health.png';
  static const String categorySalary = '$_base/category_salary.png';
  static const String categoryFreelance = '$_base/category_freelance.png';
  static const String categoryTransfer = '$_base/category_transfer.png';

  // Wallets
  static const String walletBank = '$_base/wallet_bank.png';
  static const String walletCash = '$_base/wallet_cash.png';
  static const String iconWallet = '$_base/icon_wallet.png';

  // Currency flags
  static const String flagUsd = '$_base/flag_usd.png';
  static const String flagGbp = '$_base/flag_gbp.png';
  static const String flagEur = '$_base/flag_eur.png';
  static const String flagAud = '$_base/flag_aud.png';
  static const String flagSgd = '$_base/flag_sgd.png';
  static const String flagEgp = '$_base/flag_egp.png';

  // Profile / actions
  static const String profileLogout = '$_base/profile_logout.png';
  static const String profileDelete = '$_base/profile_delete.png';
  static const String actionSuccess = '$_base/action_success.png';
  static const String actionEmail = '$_base/action_email.png';
  static const String actionTrophy = '$_base/action_trophy.png';

  /// Maps backend category name to an icon asset (case-insensitive).
  static String? categoryFor(String name) {
    switch (name.trim().toLowerCase()) {
      case 'food':
        return categoryFood;
      case 'shopping':
        return categoryShopping;
      case 'bills':
        return categoryBills;
      case 'transport':
        return categoryTransport;
      case 'health':
      case 'healthcare':
        return categoryHealth;
      case 'salary':
        return categorySalary;
      case 'freelance':
        return categoryFreelance;
      case 'transfer':
        return categoryTransfer;
      case 'entertainment':
      case 'education':
      case 'gift':
      case 'other':
        return categoryTransfer;
      default:
        return null;
    }
  }

  /// ISO currency code → flag asset when available.
  static String? currencyFlag(String code) {
    switch (code.trim().toUpperCase()) {
      case 'USD':
        return flagUsd;
      case 'GBP':
        return flagGbp;
      case 'EUR':
        return flagEur;
      case 'AUD':
        return flagAud;
      case 'SGD':
        return flagSgd;
      case 'EGP':
        return flagEgp;
      default:
        return null;
    }
  }

  /// Wallet type label (Add Wallet screen) → icon asset.
  static String? walletTypeFor(String title) {
    switch (title.trim().toLowerCase()) {
      case 'bank account':
        return walletBank;
      case 'cash':
        return walletCash;
      case 'savings':
        return iconWallet;
      default:
        return iconWallet;
    }
  }
}
