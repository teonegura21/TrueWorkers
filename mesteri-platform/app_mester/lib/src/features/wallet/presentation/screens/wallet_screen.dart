import 'package:flutter/material.dart';
import 'package:app_mester/src/core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/wallet_service.dart';
import '../../../wallet/presentation/screens/wallet_withdrawal_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletService _walletService = WalletService();

  Map<String, dynamic>? _walletData;
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'Trebuie să fii autentificat';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _currentUserId = user.uid;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final wallet = await _walletService.getWallet(user.uid);
      final earnings = await _walletService.getEarnings(user.uid);

      setState(() {
        _walletData = wallet;
        _transactions = earnings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Eroare la încărcarea datelor: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Portofel'),
          backgroundColor: AppTheme.surfaceColor,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Portofel'),
          backgroundColor: AppTheme.surfaceColor,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_errorMessage!),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadWalletData,
                child: const Text('Încearcă din nou'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portofel'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showWalletOptions,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadWalletData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet balance card
              _buildBalanceCard(),

              const SizedBox(height: 32),

              // Quick actions
              _buildQuickActions(),

              const SizedBox(height: 32),

              // Statistics
              _buildStatisticsSection(),

              const SizedBox(height: 32),

              // Recent transactions
              _buildTransactionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    final balance = _walletData?['balance'] as num? ?? 0;
    final pendingBalance = _walletData?['pendingBalance'] as num? ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sold Disponibil',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '${balance.toStringAsFixed(2)} RON',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'În așteptare: ${pendingBalance.toStringAsFixed(2)} RON',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acțiuni Rapide',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.account_balance,
                title: 'Retrage',
                subtitle: 'Transfer în cont',
                onTap: _withdrawFunds,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.show_chart,
                title: 'Raport',
                subtitle: 'Istoric venituri',
                onTap: _viewReport,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.settings,
                title: 'Setări',
                subtitle: 'Cont bancar',
                onTap: _manageBankAccount,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    final totalEarnings = _walletData?['totalEarnings'] as num? ?? 0;
    final thisMonth = _walletData?['thisMonth'] as num? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statisticile Tale',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              _buildStatItem(
                icon: Icons.account_balance_wallet,
                title: 'Total Câștiguri',
                value: '${totalEarnings.toStringAsFixed(2)} RON',
                color: AppTheme.successColor,
              ),
              const SizedBox(height: 16),
              _buildStatItem(
                icon: Icons.calendar_month,
                title: 'Luna Curentă',
                value: '${thisMonth.toStringAsFixed(2)} RON',
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              _buildStatItem(
                icon: Icons.trending_up,
                title: 'Rata Medie',
                value: '2.100 RON/lună',
                color: AppTheme.accentColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tranzacții Recente',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _viewAllTransactions,
              child: const Text('Vezi toate'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: _transactions.map((transaction) {
            return _buildTransactionItem(transaction);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    Color getTransactionColor(String type) {
      switch (type) {
        case 'income':
          return AppTheme.successColor;
        case 'fee':
          return AppTheme.warningColor;
        case 'withdrawal':
          return AppTheme.errorColor;
        default:
          return AppTheme.onSurfaceColor;
      }
    }

    IconData getTransactionIcon(String type) {
      switch (type) {
        case 'income':
          return Icons.arrow_downward;
        case 'fee':
          return Icons.account_balance;
        case 'withdrawal':
          return Icons.arrow_upward;
        default:
          return Icons.swap_horiz;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: getTransactionColor(
                  transaction['type'] as String,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                getTransactionIcon(transaction['type'] as String),
                color: getTransactionColor(transaction['type'] as String),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction['title'] as String,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction['client'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.onSurfaceSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction['date'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.onSurfaceSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              transaction['amount'] as String,
              style: TextStyle(
                color: getTransactionColor(transaction['type'] as String),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWalletOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Opțiuni Portofel',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildWalletOption(
                icon: Icons.account_balance,
                title: 'Gestionează cont bancar',
                onTap: _manageBankAccount,
              ),
              const SizedBox(height: 16),
              _buildWalletOption(
                icon: Icons.show_chart,
                title: 'Raport detaliat venituri',
                onTap: _viewReport,
              ),
              const SizedBox(height: 16),
              _buildWalletOption(
                icon: Icons.help_outline,
                title: 'Ajutor și suport',
                onTap: _showHelp,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWalletOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _withdrawFunds() {
    final balance = _walletData?['balance'] as num? ?? 0;
    if (balance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sold insuficient pentru retragere'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trebuie să fii autentificat'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletWithdrawalScreen(
          availableBalance: balance.toDouble(),
          craftsmanId: _currentUserId!,
        ),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh wallet data after successful withdrawal
        _loadWalletData();
      }
    });
  }

  void _viewReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deschidere raport venituri'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _manageBankAccount() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gestionare cont bancar'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _viewAllTransactions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vizualizare toate tranzacțiile'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deschidere secțiune ajutor'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}
