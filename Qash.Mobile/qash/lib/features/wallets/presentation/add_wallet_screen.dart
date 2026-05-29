import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assets/qash_icons.dart';
import '../../../core/theme/qash_theme_extension.dart';
import '../../../core/widgets/qash_icon.dart';
import '../domain/entities/wallet.dart';
import '../domain/entities/wallet_create.dart';
import '../domain/entities/wallet_update.dart';
import '../providers/wallets_providers.dart';

class AddWalletScreen extends ConsumerStatefulWidget {
  final WalletEntity? wallet;
  final String? walletId;

  const AddWalletScreen({super.key, this.wallet, this.walletId});

  @override
  ConsumerState<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends ConsumerState<AddWalletScreen> {
  final TextEditingController _walletNameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  String _selectedWalletType = 'Bank Account';
  String _selectedCurrency = 'USD';

  bool _submitting = false;
  String? _errorMessage;

  WalletEntity? _resolvedWallet;
  bool _initializedFromWallet = false;

  bool get _isEdit => widget.wallet != null || widget.walletId != null;

  final List<_WalletTypeModel> _walletTypes = [
    _WalletTypeModel(
      title: 'Bank Account',
      subtitle: 'Debit or credit card',
      iconAsset: QashIcons.walletBank,
    ),
    _WalletTypeModel(
      title: 'Cash',
      subtitle: 'Physical money on hand',
      iconAsset: QashIcons.walletCash,
    ),
    _WalletTypeModel(
      title: 'Savings',
      subtitle: 'Savings & deposits',
      iconAsset: QashIcons.iconWallet,
    ),
  ];

  final List<String> _currencies = ['USD', 'EGP', 'EUR', 'GBP', 'JPY'];

  @override
  void initState() {
    super.initState();
    _resolvedWallet = widget.wallet;
    _hydrateFromWallet(_resolvedWallet);
  }

  @override
  void dispose() {
    _walletNameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _walletNameController.text.trim();
    final balance = double.tryParse(_balanceController.text.trim());

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Enter a wallet name.');
      return;
    }
    if (balance == null) {
      setState(() => _errorMessage = 'Enter a valid amount.');
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final result = _isEdit
        ? await ref.read(updateWalletUseCaseProvider)(
            WalletUpdateData(
              walletId: _resolvedWallet!.walletId,
              name: name,
              currency: _selectedCurrency,
              balance: balance,
            ),
          )
        : await ref.read(createWalletUseCaseProvider)(
            WalletCreateData(
              name: name,
              currency: _selectedCurrency,
              initialBalance: balance,
            ),
          );

    if (!mounted) return;

    setState(() => _submitting = false);

    if (result.isSuccess) {
      ref.invalidate(walletsProvider);
      context.pop(true);
    } else {
      setState(() => _errorMessage = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;

    if (!_initializedFromWallet &&
        _resolvedWallet == null &&
        widget.walletId != null) {
      final walletAsync = ref.watch(walletByIdProvider(widget.walletId!));
      if (walletAsync.value?.isSuccess == true) {
        _resolvedWallet = walletAsync.value!.data;
        _hydrateFromWallet(_resolvedWallet);
      } else if (walletAsync.isLoading) {
        return Scaffold(
          backgroundColor: qash.scaffoldBackground,
          body: Center(
            child: CircularProgressIndicator(color: qash.primaryButton),
          ),
        );
      } else if (walletAsync.hasValue && walletAsync.value!.isFailure) {
        return Scaffold(
          backgroundColor: qash.scaffoldBackground,
          appBar: AppBar(title: const Text('Edit Wallet')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    walletAsync.value!.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: qash.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => ref.invalidate(walletByIdProvider(widget.walletId!)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    return Scaffold(
      backgroundColor: qash.scaffoldBackground,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: qash.surface,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: qash.textPrimary),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        title: Text(
          _isEdit ? 'Edit Wallet' : 'New Wallet',
          style: TextStyle(
            color: qash.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Wallet Name'),
            const SizedBox(height: 8),
            _CustomInputField(
              controller: _walletNameController,
              hint: 'e.g. My Bank Account',
            ),
            const SizedBox(height: 24),
            const _SectionTitle('Wallet Type'),
            const SizedBox(height: 8),
            ..._walletTypes.map(
              (type) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _WalletTypeTile(
                  walletType: type,
                  selected: _selectedWalletType == type.title,
                  onTap: () {
                    setState(() {
                      _selectedWalletType = type.title;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            const _SectionTitle('Currency'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _currencies.map((currency) {
                final selected = _selectedCurrency == currency;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCurrency = currency;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? qash.primaryButton : qash.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? qash.primaryButton : qash.border,
                      ),
                      boxShadow: selected
                          ? null
                          : [
                              BoxShadow(
                                color: qash.cardShadow,
                                blurRadius: 6,
                              ),
                            ],
                    ),
                    child: Text(
                      currency,
                      style: TextStyle(
                        color: selected ? qash.onPrimaryButton : qash.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              height: 24,
            ), // Keep the spacing after removing the color section
            const _SectionTitle('Initial Balance'),
            const SizedBox(height: 8),
            _CustomInputField(
              controller: _balanceController,
              hint: '0.00',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: qash.danger, fontSize: 12),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: qash.primaryButton,
                  disabledBackgroundColor:
                      qash.primaryButton.withValues(alpha: 0.45),
                  foregroundColor: qash.onPrimaryButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _submitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: qash.onPrimaryButton,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isEdit ? 'Save Changes' : 'Create Wallet',
                        style: TextStyle(
                          color: qash.onPrimaryButton,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _hydrateFromWallet(WalletEntity? wallet) {
    if (wallet == null || _initializedFromWallet) return;
    _walletNameController.text = wallet.name;
    _balanceController.text = wallet.balance.toStringAsFixed(2);
    _selectedCurrency = wallet.currency;
    _initializedFromWallet = true;
  }
}

class _WalletTypeTile extends StatelessWidget {
  final _WalletTypeModel walletType;
  final bool selected;
  final VoidCallback onTap;

  const _WalletTypeTile({
    required this.walletType,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: qash.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? qash.primaryButton : qash.border,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: qash.cardShadow,
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            QashIcon(
              assetPath: walletType.iconAsset,
              fallback: Icons.account_balance_wallet_outlined,
              size: 32,
              color: qash.textPrimary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    walletType.title,
                    style: TextStyle(
                      color: qash.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    walletType.subtitle,
                    style: TextStyle(
                      color: qash.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              CircleAvatar(
                radius: 12,
                backgroundColor: qash.primaryButton,
                child: Icon(Icons.check, size: 14, color: qash.onPrimaryButton),
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  const _CustomInputField({
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: qash.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: qash.textHint),
        filled: true,
        fillColor: qash.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final qash = context.qash;

    return Text(
      title,
      style: TextStyle(
        color: qash.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _WalletTypeModel {
  final String title;
  final String subtitle;
  final String iconAsset;

  const _WalletTypeModel({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
  });
}
