import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/payment_service.dart';

// Enhanced Payment System Models
class PaymentProfile {
  final String id;
  final String avatar;
  final String name;
  final String rating;
  final String specialization;
  final String accountType;

  const PaymentProfile({
    required this.id,
    required this.avatar,
    required this.name,
    required this.rating,
    required this.specialization,
    required this.accountType,
  });
}

class PaymentCard {
  final String id;
  final String cardNumber;
  final String expiryDate;
  final String cardHolder;
  final String cardType;
  final bool isDefault;

  const PaymentCard({
    required this.id,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolder,
    required this.cardType,
    this.isDefault = false,
  });

  String get maskedNumber =>
      'â€¢â€¢â€¢â€¢ â€¢â€¢â€¢â€¢ â€¢â€¢â€¢â€¢ ${cardNumber.substring(cardNumber.length - 4)}';
}

class PaymentTransaction {
  final String id;
  final String description;
  final String craftsmanName;
  final double amount;
  final DateTime date;
  final PaymentStatus status;
  final String projectTitle;
  final String transactionId;

  const PaymentTransaction({
    required this.id,
    required this.description,
    required this.craftsmanName,
    required this.amount,
    required this.date,
    required this.status,
    required this.projectTitle,
    required this.transactionId,
  });
}

enum PaymentStatus { pending, processing, completed, failed, cancelled }

class PaymentProject {
  final String id;
  final String projectTitle;
  final String craftsmanName;
  final double totalAmount;
  final double paidAmount;
  final PaymentStatus status;
  final List<PaymentTransaction> transactions;

  const PaymentProject({
    required this.id,
    required this.projectTitle,
    required this.craftsmanName,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
    required this.transactions,
  });

  double get remainingAmount => totalAmount - paidAmount;
  bool get isFullyPaid => paidAmount >= totalAmount;
}

class EnhancedPaymentsScreen extends StatefulWidget {
  const EnhancedPaymentsScreen({super.key});

  @override
  State<EnhancedPaymentsScreen> createState() => _EnhancedPaymentsScreenState();
}

class _EnhancedPaymentsScreenState extends State<EnhancedPaymentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PaymentService _paymentService = PaymentService();

  PaymentCard? _selectedCard;
  List<dynamic> _payments = [];
  List<PaymentCard> _paymentCards = []; // Empty for now - backend doesn't support payment methods yet
  bool _isLoadingPayments = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPaymentHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PlÄƒÈ›i È™i Metode'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => _showHelp(),
            tooltip: 'Ajutor',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.onSurfaceSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.payment_rounded), text: 'PlatÄƒ'),
            Tab(icon: Icon(Icons.history_rounded), text: 'Istoric'),
            Tab(icon: Icon(Icons.credit_card_rounded), text: 'Carduri'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildPaymentTab(), _buildHistoryTab(), _buildCardsTab()],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildPaymentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Escrow safety and fee info
          _buildEscrowInfoBanner(),
          const SizedBox(height: 12),

          // Project Payment Summary
          _buildPaymentProjectCard(),

          const SizedBox(height: 24),

          // Quick Payment Actions
          Text(
            'AcÈ›iuni Rapide',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildQuickPaymentButton(
                  icon: Icons.electric_bolt_rounded,
                  title: 'PlatÄƒ Instant',
                  subtitle: '100%',
                  onPressed: () => _makeInstantPayment(),
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickPaymentButton(
                  icon: Icons.electric_bolt_rounded,
                  title: 'PlatÄƒ Instant',
                  subtitle: '100%',
                  onPressed: () => _makeInstantPayment(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildQuickPaymentButton(
                  icon: Icons.security_rounded,
                  title: 'SecurizatÄƒ',
                  subtitle: 'SSL Certified',
                  onPressed: () => _showSecurityInfo(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickPaymentButton(
                  icon: Icons.verified_rounded,
                  title: 'GaranÈ›ie',
                  subtitle: 'RISC ZERO',
                  onPressed: () => _showGuarantee(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Payment Security Info
          _buildSecurityInfo(),
        ],
      ),
    );
  }

  Widget _buildEscrowInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_user, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fonduri securizate',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PlÄƒÈ›ile sunt reÈ›inute Ã®n escrow pÃ¢nÄƒ la confirmarea lucrÄƒrii. Plata se elibereazÄƒ doar dupÄƒ accept.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppTheme.onSurfaceSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Comision platformÄƒ: 1.5% / tranzacÈ›ie',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentProjectCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outlineColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with project and craftsman
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: Text(
                  'I',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ReparaÈ›ie robinet bucÄƒtÄƒrie',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Ion Popescu',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Chip(
                avatar: const Icon(
                  Icons.verified_user,
                  size: 16,
                  color: Colors.white,
                ),
                label: const Text('Escrow activ'),
                labelStyle: const TextStyle(color: Colors.white),
                backgroundColor: AppTheme.primaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Payment breakdown
          _buildPaymentBreakdown(),

          const SizedBox(height: 20),

          // Payment action
          _buildPaymentAction(),
        ],
      ),
    );
  }

  Widget _buildPaymentBreakdown() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cost total',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            Text(
              '850 ${AppConfig.currencySymbol}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PlÄƒtit deja',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceSecondary,
              ),
            ),
            Text(
              '650 ${AppConfig.currencySymbol}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.successColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sold de plÄƒtit',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.warningColor,
              ),
            ),
            Text(
              '200 ${AppConfig.currencySymbol}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.warningColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Progress bar
        LinearProgressIndicator(
          value: 650 / 850, // 76.5% paid
          backgroundColor: AppTheme.surfaceVariant.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.successColor),
        ),

        const SizedBox(height: 4),

        Text(
          '76% plÄƒtit',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.onSurfaceSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentAction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MetodÄƒ de platÄƒ selectatÄƒ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                      ),
                    ),
                    Text(
                      '${_selectedCard?.cardType} ${_selectedCard?.maskedNumber}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () => _changePaymentMethod(),
                icon: const Icon(Icons.edit_rounded, size: 20),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _makePayment(),
              icon: const Icon(Icons.payment_rounded),
              label: const Text('PlÄƒteÈ™te acum 200 lei'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_rounded,
                color: AppTheme.successColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Securitatea plÄƒÈ›ii garantatÄƒ',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            'Toate plÄƒÈ›ile sunt securizate prin SSL È™i procesate de bÄƒnci autorizate. Administrarea plÄƒÈ›ilor este blocatÄƒ pÃ¢nÄƒ cÃ¢nd lucrÄƒrile sunt finalizate cu succes.',
            style: TextStyle(fontSize: 12, height: 1.4),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              _buildSecurityBadge(text: 'SSL Protected'),
              const SizedBox(width: 8),
              _buildSecurityBadge(text: 'RISC ZERO'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoadingPayments) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPaymentHistory,
              child: const Text('Încearcă din nou'),
            ),
          ],
        ),
      );
    }

    if (_payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Nu există plăți încă',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshPaymentHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _payments.length,
        itemBuilder: (context, index) {
          final payment = _payments[index];
          // Convert API payment data to PaymentTransaction for display
          return _buildPaymentHistoryItemFromData(payment);
        },
      ),
    );
  }

  Widget _buildPaymentHistoryItemFromData(Map<String, dynamic> payment) {
    // Parse payment data from API
    final description = payment['description'] ?? 'Plată';
    final amount = (payment['amount'] ?? 0.0).toDouble();
    final status = _parsePaymentStatus(payment['status']);
    final date = payment['createdAt'] != null
      ? DateTime.tryParse(payment['createdAt'].toString()) ?? DateTime.now()
      : DateTime.now();
    final transactionId = payment['id'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPaymentStatusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getPaymentStatusText(status),
                  style: TextStyle(
                    fontSize: 11,
                    color: _getPaymentStatusColor(status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                transactionId,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceSecondary,
                ),
              ),
              Text(
                '${amount.toStringAsFixed(2)} RON',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(date),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PaymentStatus _parsePaymentStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'processing':
        return PaymentStatus.processing;
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'cancelled':
        return PaymentStatus.cancelled;
      default:
        return PaymentStatus.pending;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildPaymentHistoryItem(PaymentTransaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.craftsmanName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPaymentStatusColor(
                    transaction.status,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getPaymentStatusText(transaction.status),
                  style: TextStyle(
                    fontSize: 11,
                    color: _getPaymentStatusColor(transaction.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                transaction.transactionId,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceSecondary,
                  fontSize: 11,
                ),
              ),

              Text(
                '${transaction.amount} ${AppConfig.currencySymbol}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              '${transaction.date.day.toString().padLeft(2, '0')}/${transaction.date.month.toString().padLeft(2, '0')} ${transaction.date.year}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceSecondary,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Carduri salvate',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),

              IconButton(
                onPressed: () => _addNewCard(),
                icon: const Icon(Icons.add_rounded),
                tooltip: 'AdaugÄƒ card nou',
              ),
            ],
          ),
        ),

        Expanded(
          child: _paymentCards.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.credit_card_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Nu ai carduri salvate',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Adaugă un card pentru plăți rapide',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _paymentCards.length,
                itemBuilder: (context, index) =>
                    _buildCardItem(_paymentCards[index]),
              ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: () => _managePaymentMethods(),
            icon: const Icon(Icons.account_balance_wallet_rounded),
            label: const Text('Gestionare metode de platÄƒ'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardItem(PaymentCard card) {
    final isSelected = _selectedCard?.id == card.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppTheme.primaryColor
              : AppTheme.outlineColor.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                card.cardType == 'VISA' ? 'V' : 'M',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      card.maskedNumber,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (card.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Implicit',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: AppTheme.onSurfaceSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      card.cardHolder,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppTheme.onSurfaceSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Expiră ${card.expiryDate}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Switch(
                value: isSelected,
                onChanged: (_) => _toggleCardSelection(card),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _editCard(card);
                      break;
                    case 'delete':
                      _deleteCard(card);
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('ModificÄƒ')),
                  PopupMenuItem(value: 'delete', child: Text('È˜terge')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _makeQuickPayment(),
      icon: const Icon(Icons.payment_rounded),
      label: const Text('PlatÄƒ RapidÄƒ'),
      backgroundColor: AppTheme.primaryColor,
    );
  }

  // Helper widgets
  Widget _buildQuickPaymentButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary
                ? AppTheme.primaryColor
                : AppTheme.outlineColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isPrimary ? Colors.white : null,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.8)
                    : AppTheme.onSurfaceSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityBadge({required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: AppTheme.successColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Helper methods
  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return AppTheme.successColor;
      case PaymentStatus.processing:
        return AppTheme.warningColor;
      case PaymentStatus.pending:
        return AppTheme.primaryColor;
      case PaymentStatus.failed:
        return AppTheme.errorColor;
      case PaymentStatus.cancelled:
        return AppTheme.onSurfaceSecondary;
    }
  }

  String _getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return 'Finalizat';
      case PaymentStatus.processing:
        return 'ÃŽn procesare';
      case PaymentStatus.pending:
        return 'ÃŽn aÈ™teptare';
      case PaymentStatus.failed:
        return 'EÈ™uat';
      case PaymentStatus.cancelled:
        return 'Anulat';
    }
  }

  // Action handlers
  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajutor PlÄƒÈ›i'),
        content: const Text(
          'â— plÄƒÈ›i sunt 100% securizate\n'
          'â— bani sunt reÈ›inuÈ›i pÃ¢nÄƒ la finalizare\n'
          'â— garanÈ›ia este de 30 zile\n'
          'â— poÈ›i anula pÃ¢nÄƒ cÃ¢nd Ã®ncepe lucrul',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ÃŽnÈ›eleg'),
          ),
        ],
      ),
    );
  }

  void _makeInstantPayment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Initiere platÄƒ instantanee...')),
    );
  }

  void _showSecurityInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Toate plÄƒÈ›ile sunt SSL securizate')),
    );
  }

  void _showGuarantee() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Garantie 30 zile pe lucrÄƒri')),
    );
  }

  void _makePayment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PlatÄƒ procesatÄƒ cu succes!')),
    );
  }

  void _changePaymentMethod() {
    _tabController.animateTo(2); // Switch to cards tab
  }

  void _addNewCard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Adaugare card nou Ã®n curÃ¢nd')),
    );
  }

  void _managePaymentMethods() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gestionare metode de platÄƒ Ã®n curÃ¢nd')),
    );
  }

  void _editCard(PaymentCard card) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editare card "${card.maskedNumber}" Ã®n curÃ¢nd'),
      ),
    );
  }

  void _deleteCard(PaymentCard card) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('È˜tergere card "${card.maskedNumber}" Ã®n curÃ¢nd'),
      ),
    );
  }

  void _toggleCardSelection(PaymentCard card) {
    setState(() {
      _selectedCard = _selectedCard?.id == card.id ? null : card;
    });
  }

  void _makeQuickPayment() {
    setState(() {
      _tabController.animateTo(0); // Switch to payment tab
    });
  }

  Future<void> _loadPaymentHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _error = 'Utilizator neautentificat';
        _isLoadingPayments = false;
      });
      return;
    }

    setState(() {
      _isLoadingPayments = true;
      _error = null;
    });

    try {
      final payments = await _paymentService.getPaymentHistory(user.uid);
      if (mounted) {
        setState(() {
          _payments = payments;
          _isLoadingPayments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoadingPayments = false;
        });
      }
    }
  }

  Future<void> _refreshPaymentHistory() async {
    await _loadPaymentHistory();
  }
}

// Quick Payment Button
