import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

enum EarningsView {
  overview,
  transactions,
  analytics,
  banking,
}

enum TransactionType {
  paymentReceived,
  payout,
  refund,
  withheld,
  fee,
}

class Transaction {
  final String id;
  final String description;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String? projectTitle;
  final String? clientName;
  final int? durationDays;

  const Transaction({
    required this.id,
    required this.description,
    required this.type,
    required this.amount,
    required this.date,
    this.projectTitle,
    this.clientName,
    this.durationDays,
  });

  Color getAmountColor() {
    switch (type) {
      case TransactionType.paymentReceived:
      case TransactionType.refund:
        return AppTheme.successColor;
      case TransactionType.payout:
        return AppTheme.warningColor;
      case TransactionType.withheld:
      case TransactionType.fee:
        return AppTheme.errorColor;
    }
  }

  String getTypeLabel() {
    switch (type) {
      case TransactionType.paymentReceived:
        return 'ÎNCASARE EȘECUTĂ';
      case TransactionType.payout:
        return 'PLATĂ TRANSFER';
      case TransactionType.refund:
        return 'REFUND';
      case TransactionType.withheld:
        return 'REȚINUT';
      case TransactionType.fee:
        return 'TAXĂ COMISION';
    }
  }
}

// Mock data for earnings
final List<Transaction> mockTransactions = [
  Transaction(
    id: '1',
    description: 'Plată proiect "Reparație robinet bucătărie"',
    type: TransactionType.paymentReceived,
    amount: 180.0,
    date: DateTime.now().subtract(const Duration(hours: 2)),
    projectTitle: 'Reparație robinet bucătărie',
    clientName: 'Maria Popescu',
    durationDays: 2,
  ),
  Transaction(
    id: '2',
    description: 'Plată proiect "Montaj ușă de intrare"',
    type: TransactionType.paymentReceived,
    amount: 320.0,
    date: DateTime.now().subtract(const Duration(days: 1)),
    projectTitle: 'Montaj ușă de intrare',
    clientName: 'Ion Dumitrescu',
    durationDays: 1,
  ),
  Transaction(
    id: '3',
    description: 'Comision platformă (2%)',
    type: TransactionType.fee,
    amount: -7.2,
    date: DateTime.now().subtract(const Duration(days: 1)),
    projectTitle: 'Montaj ușă de intrare',
    clientName: 'Ion Dumitrescu',
  ),
  Transaction(
    id: '4',
    description: 'Transfer către IBAN',
    type: TransactionType.payout,
    amount: -1850.00,
    date: DateTime.now().subtract(const Duration(days: 3)),
    projectTitle: 'Variuzui plăți acumulate',
  ),
  Transaction(
    id: '5',
    description: 'Refund project cancellation',
    type: TransactionType.refund,
    amount: 50.0,
    date: DateTime.now().subtract(const Duration(days: 5)),
    projectTitle: 'Outdated project',
    clientName: 'Alex Georgescu',
    durationDays: 1,
  ),
];

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen>
    with SingleTickerProviderStateMixin {
  EarningsView _selectedView = EarningsView.overview;
  late TabController _tabController;

  // Balance and stats
  final double currentBalance = 2560.80;
  final double heldAmount = 320.00; // Funds waiting for project completion
  final double totalEarned = 15320.00;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    setState(() {
      switch (_tabController.index) {
        case 0:
          _selectedView = EarningsView.overview;
          break;
        case 1:
          _selectedView = EarningsView.transactions;
          break;
        case 2:
          _selectedView = EarningsView.analytics;
          break;
        case 3:
          _selectedView = EarningsView.banking;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veniturile Mele'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => _showNotifications(),
            tooltip: 'Notificări Financiare',
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded),
            onPressed: () => _generateInvoice(),
            tooltip: 'Generează Factură',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.onSurfaceSecondary,
          tabs: const [
            Tab(text: 'Prezentare', icon: Icon(Icons.insights_rounded)),
            Tab(text: 'Tranzacții', icon: Icon(Icons.list_alt_rounded)),
            Tab(text: 'Anal tuckedize', icon: Icon(Icons.show_chart_rounded)),
            Tab(text: 'Bancare', icon: Icon(Icons.account_balance_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverview(),
          _buildTransactionsTab(),
          _buildAnalyticsTab(),
          _buildBankingTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // Overview tab with balance and key metrics
  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Card
          _buildBalanceCard(),

          const SizedBox(height: 24),

          // Quick Stats Grid
          _buildQuickStatsGrid(),

          const SizedBox(height: 24),

          // Recent Activity
          _buildRecentActivity(),

          const SizedBox(height: 24),

          // Quick Actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    final availableAmount = currentBalance - heldAmount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.successColor,
            AppTheme.successColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.successColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Portofelul Meu',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'RON',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            '${currentBalance.toStringAsFixed(2)} lei',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Text(
                '${availableAmount.toStringAsFixed(2)} lei disponibil',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const Spacer(),
              Text(
                '${heldAmount.toStringAsFixed(2)} lei reținut',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid() {
    final thisMonthEarnings = mockTransactions
        .where((t) => t.date.month == DateTime.now().month &&
                     t.amount > 0 &&
                     t.type == TransactionType.paymentReceived)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalPayments = mockTransactions
        .where((t) => t.type == TransactionType.paymentReceived)
        .length;

    final successRate = totalPayments > 0 ? (totalPayments / 8) * 100 : 0.0;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.trending_up_rounded,
            color: AppTheme.successColor,
            title: 'Luna aceasta',
            value: '${thisMonthEarnings.toStringAsFixed(0)} lei',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.verified_rounded,
            color: AppTheme.primaryColor,
            title: 'Rată succes',
            value: '${successRate.toStringAsFixed(0)}%',
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history_rounded,
              color: AppTheme.onSurfaceSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Activitate Recent',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        ...mockTransactions.take(3).map(_buildRecentTransaction),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _tabController.animateTo(1),
            child: const Text('Vezi toate tranzacțiile'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acțiuni Rapide',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.account_balance_rounded,
                label: 'Transfer',
                onPressed: () => _requestPayout(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.receipt_long_rounded,
                label: 'Factură',
                onPressed: () => _generateInvoice(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.calculate_rounded,
                label: 'Taxe',
                onPressed: () => _calculateTaxes(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionsTab() {
    return Column(
      children: [
        // Filter and search
        _buildTransactionsFilter(),

        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshTransactions,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: mockTransactions.length,
              itemBuilder: (context, index) {
                final transaction = mockTransactions[index];
                return _buildTransactionItem(transaction);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        border: Border(
          bottom: BorderSide(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Caută tranzacții...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: AppTheme.surfaceColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                // TODO: Implement search
              },
            ),
          ),

          const SizedBox(width: 12),

          PopupMenuButton<String>(
            onSelected: (value) {
              // TODO: Implement filter
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('Toate'),
              ),
              const PopupMenuItem(
                value: 'income',
                child: Text('Încasări'),
              ),
              const PopupMenuItem(
                value: 'expenses',
                child: Text('Cheltuieli'),
              ),
            ],
            icon: const Icon(Icons.filter_list_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransaction(Transaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.outlineColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: transaction.getAmountColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTransactionIcon(transaction.type),
              color: transaction.getAmountColor(),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description.length > 30
                      ? '${transaction.description.substring(0, 30)}...'
                      : transaction.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),

                if (transaction.clientName != null) ...[
                  Text(
                    transaction.clientName!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.onSurfaceSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Text(
            transaction.amount > 0
                ? '+${transaction.amount.toStringAsFixed(2)} lei'
                : '${transaction.amount.toStringAsFixed(2)} lei',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: transaction.getAmountColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.outlineColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: transaction.getAmountColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTransactionIcon(transaction.type),
                  color: transaction.getAmountColor(),
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTransactionLabel(transaction.type),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: transaction.getAmountColor(),
                      ),
                    ),

                    Text(
                      _formatDate(transaction.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                transaction.amount >= 0
                    ? '+${transaction.amount.toStringAsFixed(2)} lei'
                    : '${transaction.amount.toStringAsFixed(2)} lei',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: transaction.getAmountColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Description
          Text(
            transaction.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceColor,
            ),
          ),

          // Additional info
          if (transaction.clientName != null || transaction.projectTitle != null) ...[
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceSecondary,
                ),
                children: [
                  if (transaction.clientName != null) ...[
                    const TextSpan(text: 'Client: '),
                    TextSpan(
                      text: transaction.clientName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                  if (transaction.projectTitle != null) ...[
                    if (transaction.clientName != null) const TextSpan(text: ' • '),
                    const TextSpan(text: 'Proiect: '),
                    TextSpan(
                      text: transaction.projectTitle,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    // This would contain charts and analytics
    // For now, showing placeholder with key metrics
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analiza Veniturilor',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          // Monthly earnings chart placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('Grafic veniturilor lunare - Implementat în viitor'),
            ),
          ),

          const SizedBox(height: 24),

          // Key metrics cards
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsMetric(
                  'Medie/Zi',
                  '85 lei',
                  Icons.show_chart_rounded,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsMetric(
                  'Medie/Lună',
                  '2560 lei',
                  Icons.calendar_month_rounded,
                  AppTheme.successColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildAnalyticsMetric(
                  'Cel mai bun luna',
                  '4200 lei',
                  Icons.emoji_events_rounded,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsMetric(
                  'Număr clienți',
                  '24',
                  Icons.people_rounded,
                  AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBankingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestionează Banii',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          // Withdrawal section
          _buildWithdrawalSection(),

          const SizedBox(height: 24),

          // Bank account management
          _buildBankAccountSection(),

          const SizedBox(height: 24),

          // Tax information
          _buildTaxSection(),
        ],
      ),
    );
  }

  Widget _buildWithdrawalSection() {
    final availableToWithdraw = currentBalance - heldAmount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Transfer către bancă',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Text(
                'Disponibil pentru retragere:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Text(
                '${availableToWithdraw.toStringAsFixed(2)} lei',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: availableToWithdraw > 0 ? () => _requestPayout() : null,
              icon: const Icon(Icons.account_balance_rounded),
              label: const Text('Retragere Fonduri'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: AppTheme.primaryColor,
                disabledBackgroundColor: AppTheme.onSurfaceSecondary.withValues(alpha: 0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contul meu bancar',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Current bank account status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_rounded,
                    color: AppTheme.successColor,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cont verificat',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '•••• •••• •••• 1234',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.onSurfaceSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 14,
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Verificat',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: () => _manageBankAccounts(),
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Gestionează Conturi'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxSection() {
    final taxAmount = totalEarned * 0.100; // Approximate 10% for freelancing

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calculate_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Calcul Taxe',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Venituri totale anul acesta:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${totalEarned.toStringAsFixed(2)} lei',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimare taxe (PFA):',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${taxAmount.toStringAsFixed(2)} lei',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.warningColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showTaxCalculator(),
                  icon: const Icon(Icons.show_chart_rounded),
                  label: const Text('Calculator Taxe'),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _downloadTaxReport(),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Raport'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickTransfer(),
      icon: const Icon(Icons.add_card_rounded),
      label: const Text('Transfer Rapid'),
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
    );
  }

  // Helper methods

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.paymentReceived:
        return Icons.arrow_downward_rounded;
      case TransactionType.payout:
        return Icons.arrow_upward_rounded;
      case TransactionType.refund:
        return Icons.undo_rounded;
      case TransactionType.withheld:
        return Icons.block_rounded;
      case TransactionType.fee:
        return Icons.monetization_on_rounded;
    }
  }

  String _getTransactionLabel(TransactionType type) {
    switch (type) {
      case TransactionType.paymentReceived:
        return 'Încasare';
      case TransactionType.payout:
        return 'Transfer';
      case TransactionType.refund:
        return 'Restituire';
      case TransactionType.withheld:
        return 'Reținut';
      case TransactionType.fee:
        return 'Comision';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} l în urmă';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} z în urmă';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} ore în urmă';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} min în urmă';
    } else {
      return 'Acum';
    }
  }

  // Action handlers

  void _showNotifications() {
    // TODO: Show financial notifications
  }

  void _generateInvoice() {
    // TODO: Generate invoice for tax purposes
  }

  void _requestPayout() {
    // TODO: Show payout dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cerere transfer către bancă - implementare în curând'),
      ),
    );
  }

  void _calculateTaxes() {
    // TODO: Show tax calculator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calculator de taxe - implementare în curând'),
      ),
    );
  }

  void _showTaxCalculator() {
    // TODO: Show detailed tax calculator
  }

  void _downloadTaxReport() {
    // TODO: Download tax report
  }

  void _manageBankAccounts() {
    // TODO: Manage bank accounts
  }

  void _showQuickTransfer() {
    // TODO: Show quick transfer options
  }

  Future<void> _refreshTransactions() async {
    // TODO: Refresh transactions
    await Future.delayed(const Duration(seconds: 2));
    setState(() {});
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
        elevation: 0,
        side: BorderSide(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
