import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/wallet_service.dart';

class WalletWithdrawalScreen extends StatefulWidget {
  final double availableBalance;
  final String craftsmanId;

  const WalletWithdrawalScreen({
    super.key,
    required this.availableBalance,
    required this.craftsmanId,
  });

  @override
  State<WalletWithdrawalScreen> createState() => _WalletWithdrawalScreenState();
}

class _WalletWithdrawalScreenState extends State<WalletWithdrawalScreen> {
  final WalletService _walletService = WalletService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();

  String _selectedMethod = 'bank'; // bank, card, revolut
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    _ibanController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Retragere Fonduri'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Available Balance Card
            Card(
              color: MesteriColors.primaryLowOpacity,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sold disponibil',
                      style: TextStyle(
                        fontSize: 14,
                        color: MesteriColors.onSurfaceSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.availableBalance.toStringAsFixed(2)} RON',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: MesteriColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Amount to Withdraw
            const Text(
              'Sumă de retras',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Introduceți suma',
                suffixText: 'RON',
                prefixIcon: const Icon(Icons.money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildQuickAmountChip(50),
                const SizedBox(width: 8),
                _buildQuickAmountChip(100),
                const SizedBox(width: 8),
                _buildQuickAmountChip(widget.availableBalance, label: 'Tot'),
              ],
            ),
            const SizedBox(height: 24),

            // Withdrawal Method
            const Text(
              'Metodă de retragere',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildMethodOption(
              'bank',
              'Transfer Bancar',
              'IBAN',
              Icons.account_balance,
            ),
            _buildMethodOption(
              'card',
              'Card Bancar',
              'Debit/Credit Card',
              Icons.credit_card,
            ),
            _buildMethodOption(
              'revolut',
              'Revolut',
              'Cont Revolut',
              Icons.phone_android,
            ),
            const SizedBox(height: 24),

            // Account Details
            if (_selectedMethod == 'bank') ...[
              const Text(
                'Detalii cont bancar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ibanController,
                decoration: InputDecoration(
                  hintText: 'RO49 AAAA 1B31 0075 9384 0000',
                  labelText: 'IBAN',
                  prefixIcon: const Icon(Icons.account_balance),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _accountNameController,
                decoration: InputDecoration(
                  hintText: 'Numele complet',
                  labelText: 'Titular cont',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MesteriColors.warningVeryLowOpacity,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: MesteriColors.warning.withAlpha(50)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: MesteriColors.warning, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Fondurile vor fi transferate în 1-3 zile lucrătoare. Nu se percep comisioane suplimentare.',
                      style: TextStyle(
                        fontSize: 12,
                        color: MesteriColors.onSurfaceSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Error Message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: MesteriColors.errorLowOpacity,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: MesteriColors.error),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: MesteriColors.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: MesteriColors.error),
                      ),
                    ),
                  ],
                ),
              ),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _requestWithdrawal,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: MesteriColors.primary,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Solicită retragere',
                        style: TextStyle(
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

  Widget _buildQuickAmountChip(double amount, {String? label}) {
    return InkWell(
      onTap: () {
        _amountController.text = amount.toStringAsFixed(0);
      },
      child: Chip(
        label: Text(label ?? '${amount.toInt()} RON'),
        backgroundColor: MesteriColors.primaryVeryLowOpacity,
      ),
    );
  }

  Widget _buildMethodOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedMethod == value;
    return Card(
      color: isSelected ? MesteriColors.primaryVeryLowOpacity : null,
      child: ListTile(
        leading: Icon(icon, color: isSelected ? MesteriColors.primary : null),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? MesteriColors.primary : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Radio<String>(
          value: value,
          groupValue: _selectedMethod,
          onChanged: (val) {
            setState(() {
              _selectedMethod = val!;
            });
          },
        ),
        onTap: () {
          setState(() {
            _selectedMethod = value;
          });
        },
      ),
    );
  }

  Future<void> _requestWithdrawal() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final amount = double.tryParse(_amountController.text);

      if (amount == null || amount <= 0) {
        throw Exception('Introduceți o sumă validă');
      }

      if (amount > widget.availableBalance) {
        throw Exception('Fond insuficient');
      }

      if (_selectedMethod == 'bank' && _ibanController.text.isEmpty) {
        throw Exception('Introduceți IBAN-ul');
      }

      // Prepare account details
      final accountDetails = <String, String>{};
      if (_selectedMethod == 'bank') {
        accountDetails['iban'] = _ibanController.text;
        accountDetails['accountName'] = _accountNameController.text;
      }

      // Call backend API to create withdrawal request
      await _walletService.requestWithdrawal(
        userId: widget.craftsmanId,
        amount: amount,
        method: _selectedMethod.toUpperCase(),
        accountDetails: accountDetails,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Cerere de retragere trimisă cu succes!'),
            backgroundColor: MesteriColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}
