import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/theme/app_theme.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  final String projectId;
  final String projectTitle;
  final String craftsmanId;
  final String craftsmanName;
  final double amount;
  final String? milestoneId;

  const PaymentCheckoutScreen({
    super.key,
    required this.projectId,
    required this.projectTitle,
    required this.craftsmanId,
    required this.craftsmanName,
    required this.amount,
    this.milestoneId,
  });

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;
  String? _errorMessage;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    } else {
      setState(() {
        _errorMessage = 'Trebuie să fii autentificat pentru a efectua plata';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final platformFee = widget.amount * 0.05;
    final totalAmount = widget.amount + platformFee;

    return Scaffold(
      appBar: AppBar(title: const Text('Plată Proiect'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.projectTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          widget.craftsmanName,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment Summary
            const Text(
              'Sumar Plată',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      'Valoare lucrare',
                      '${widget.amount.toStringAsFixed(2)} RON',
                    ),
                    const Divider(height: 24),
                    _buildSummaryRow(
                      'Comision platformă (5%)',
                      '${platformFee.toStringAsFixed(2)} RON',
                      isSubtitle: true,
                    ),
                    const Divider(height: 24),
                    _buildSummaryRow(
                      'Total de plată',
                      '${totalAmount.toStringAsFixed(2)} RON',
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MesteriColors.primaryVeryLowOpacity,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: MesteriColors.primary.withAlpha(50)),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: MesteriColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Plata este procesată securizat prin Stripe. Banii vor fi depozitați în escrow până la finalizarea lucrării.',
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

            // Pay Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
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
                    : Text(
                        'Plătește ${totalAmount.toStringAsFixed(2)} RON',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Powered by Stripe
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Securizat de',
                    style: TextStyle(
                      fontSize: 12,
                      color: MesteriColors.onSurfaceTertiary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/b/ba/Stripe_Logo%2C_revised_2016.svg',
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    bool isSubtitle = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSubtitle ? 14 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isSubtitle ? MesteriColors.onSurfaceSecondary : null,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? MesteriColors.primary : null,
          ),
        ),
      ],
    );
  }

  Future<void> _processPayment() async {
    if (_currentUserId == null) {
      setState(() {
        _errorMessage = 'Trebuie să fii autentificat pentru a efectua plata';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Create payment intent on backend
      final paymentData = await _paymentService.createPaymentIntent(
        projectId: widget.projectId,
        clientId: _currentUserId!,
        craftsmanId: widget.craftsmanId,
        amount: widget.amount,
        milestoneId: widget.milestoneId,
      );

      // Payment intent created successfully
      if (mounted) {
        Navigator.pop(context, paymentData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Plată inițiată cu succes!'),
            backgroundColor: MesteriColors.success,
          ),
        );
      }
    } on Exception catch (e) {
      setState(() {
        _errorMessage = _parseError(e);
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'A apărut o eroare neașteptată. Te rugăm să încerci din nou.';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  String _parseError(dynamic error) {
    final errorMessage = error.toString();
    if (errorMessage.contains('network') ||
        errorMessage.contains('connection')) {
      return 'Eroare de conexiune. Verifică internetul.';
    }
    if (errorMessage.contains('timeout')) {
      return 'Cererea a expirat. Te rugăm să încerci din nou.';
    }
    if (errorMessage.contains('insufficient')) {
      return 'Fonduri insuficiente.';
    }
    return 'A apărut o eroare. Te rugăm să încerci din nou.';
  }
}
