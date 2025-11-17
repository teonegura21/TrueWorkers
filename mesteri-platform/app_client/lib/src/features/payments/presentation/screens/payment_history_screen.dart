import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final PaymentService _paymentService = PaymentService();
  List<dynamic> _payments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPaymentHistory();
  }

  Future<void> _loadPaymentHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'Trebuie să fii autentificat';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final payments = await _paymentService.getPaymentHistory(user.uid);
      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Eroare la încărcarea istoricului: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Istoric Plăți'), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : _payments.isEmpty
          ? _buildEmptyView()
          : RefreshIndicator(
              onRefresh: _loadPaymentHistory,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _payments.length,
                itemBuilder: (context, index) {
                  final payment = _payments[index];
                  return _buildPaymentCard(payment);
                },
              ),
            ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    final amount = payment['amount'] as num? ?? 0;
    final status = payment['status'] as String? ?? 'UNKNOWN';
    final createdAt = payment['createdAt'] as String?;
    final description = payment['description'] as String? ?? 'Plată proiect';

    DateTime? date;
    if (createdAt != null) {
      date = DateTime.tryParse(createdAt);
    }

    Color statusColor = MesteriColors.onSurfaceSecondary;
    IconData statusIcon = Icons.help_outline;
    String statusText = status;

    switch (status) {
      case 'COMPLETED':
        statusColor = MesteriColors.success;
        statusIcon = Icons.check_circle;
        statusText = 'Finalizată';
        break;
      case 'PENDING':
        statusColor = MesteriColors.warning;
        statusIcon = Icons.pending;
        statusText = 'În așteptare';
        break;
      case 'PROCESSING':
        statusColor = MesteriColors.primary;
        statusIcon = Icons.sync;
        statusText = 'În procesare';
        break;
      case 'FAILED':
        statusColor = MesteriColors.error;
        statusIcon = Icons.error;
        statusText = 'Eșuată';
        break;
      case 'REFUNDED':
        statusColor = MesteriColors.onSurfaceSecondary;
        statusIcon = Icons.replay;
        statusText = 'Rambursată';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withAlpha(30),
          child: Icon(statusIcon, color: statusColor, size: 24),
        ),
        title: Text(
          description,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (date != null) ...[
              const SizedBox(height: 4),
              Text(
                DateFormat('dd MMM yyyy, HH:mm').format(date),
                style: TextStyle(
                  color: MesteriColors.onSurfaceTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        trailing: Text(
          '${amount.toStringAsFixed(2)} RON',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: status == 'REFUNDED'
                ? MesteriColors.error
                : MesteriColors.success,
          ),
        ),
        onTap: () => _showPaymentDetails(payment),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payment, size: 80, color: MesteriColors.onSurfaceTertiary),
          const SizedBox(height: 16),
          Text(
            'Nicio plată efectuată',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: MesteriColors.onSurfaceSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Plățile tale vor apărea aici',
            style: TextStyle(color: MesteriColors.onSurfaceTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: MesteriColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Eroare',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: MesteriColors.onSurfaceSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'A apărut o eroare',
              textAlign: TextAlign.center,
              style: TextStyle(color: MesteriColors.onSurfaceTertiary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPaymentHistory,
              icon: const Icon(Icons.refresh),
              label: const Text('Încearcă din nou'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDetails(Map<String, dynamic> payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Detalii Plată',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('ID', payment['id']?.toString() ?? 'N/A'),
              _buildDetailRow('Sumă', '${payment['amount']} RON'),
              _buildDetailRow('Status', payment['status']?.toString() ?? 'N/A'),
              _buildDetailRow('Metodă', payment['method']?.toString() ?? 'N/A'),
              if (payment['description'] != null)
                _buildDetailRow('Descriere', payment['description']),
              if (payment['createdAt'] != null)
                _buildDetailRow(
                  'Data',
                  DateFormat(
                    'dd MMMM yyyy, HH:mm',
                  ).format(DateTime.parse(payment['createdAt'])),
                ),
              const SizedBox(height: 24),
              if (payment['status'] == 'COMPLETED')
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _requestRefund(payment['id']),
                    icon: const Icon(Icons.replay),
                    label: const Text('Solicită rambursare'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: MesteriColors.onSurfaceSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestRefund(String paymentId) async {
    // TODO: Implement refund request
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcție în curs de implementare')),
    );
  }
}
