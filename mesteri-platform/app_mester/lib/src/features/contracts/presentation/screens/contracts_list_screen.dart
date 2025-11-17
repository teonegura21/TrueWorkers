import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';
import 'contract_viewer_screen.dart';
import '../../services/contracts_api_service.dart';

class ContractsListScreen extends StatefulWidget {
  const ContractsListScreen({super.key});

  @override
  State<ContractsListScreen> createState() => _ContractsListScreenState();
}

class _ContractsListScreenState extends State<ContractsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ContractApiService _contractService = ContractApiService();

  bool _isLoading = false;
  String? _error;
  List<ContractModel> _allContracts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadContracts();
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
        title: const Text('Contractele Mele'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.onSurfaceSecondary,
          tabs: [
            const Tab(text: 'Toate'),
            const Tab(text: 'În Așteptare'),
            const Tab(text: 'Semnate'),
            const Tab(text: 'Istoric'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContractList(),
          _buildContractList(statusFilter: 'PENDING_SIGNATURE'),
          _buildContractList(statusFilter: 'SIGNED'),
          _buildContractList(statusFilter: 'COMPLETED_HISTORY'),
        ],
      ),
    );
  }

  Widget _buildContractList({String? statusFilter}) {
    // Show loading indicator
    if (_isLoading && _allContracts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error state
    if (_error != null && _allContracts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadContracts,
              child: const Text('Încearcă din nou'),
            ),
          ],
        ),
      );
    }

    // Filter contracts based on status
    List<ContractModel> contracts = _allContracts;

    if (statusFilter != null) {
      if (statusFilter == 'COMPLETED_HISTORY') {
        contracts = contracts.where((c) =>
          c.status == 'SIGNED' || c.status == 'COMPLETED' || c.status == 'ARCHIVED'
        ).toList();
      } else {
        contracts = contracts.where((c) => c.status == statusFilter).toList();
      }
    }

    if (contracts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_drive_file_outlined,
              size: 64,
              color: AppTheme.onSurfaceSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              statusFilter == null 
                ? 'Nu ai niciun contract' 
                : _getEmptyTextForStatus(statusFilter),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Când ofertele tale sunt acceptate, contractele vor apărea aici',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.onSurfaceSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => GoRouter.of(context).pop(),
              child: const Text('Înapoi'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadContracts,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: contracts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildContractCard(contracts[index]);
        },
      ),
    );
  }

  Future<void> _loadContracts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Utilizator neautentificat');
      }

      final response = await _contractService.getUserContracts();

      if (response.statusCode == 200) {
        final data = response.data;
        List<ContractModel> contracts = [];

        // Handle different response formats
        if (data is List) {
          contracts = data.map((json) => ContractModel.fromJson(json as Map<String, dynamic>)).toList();
        } else if (data is Map) {
          final contractsList = data['contracts'] ?? data['data'] ?? [];
          if (contractsList is List) {
            contracts = contractsList.map((json) => ContractModel.fromJson(json as Map<String, dynamic>)).toList();
          }
        }

        if (mounted) {
          setState(() {
            _allContracts = contracts;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load contracts');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().contains('Exception: ')
            ? e.toString().substring(e.toString().indexOf('Exception: ') + 11)
            : e.toString();
          _isLoading = false;
          _allContracts = [];
        });
      }
    }
  }

  String _getEmptyTextForStatus(String status) {
    switch (status) {
      case 'PENDING_SIGNATURE':
        return 'Nu ai contracte în așteptare';
      case 'SIGNED':
        return 'Nu ai contracte semnate';
      case 'COMPLETED_HISTORY':
        return 'Nu ai contracte în istoric';
      default:
        return 'Nu ai niciun contract';
    }
  }

  Widget _buildContractCard(ContractModel contract) {
    return GestureDetector(
      onTap: () {
        context.push('/contracts/${contract.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.outlineColor.withValues(alpha: 0.3),
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
            // Title and status row
            Row(
              children: [
                Expanded(
                  child: Text(
                    contract.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusBackgroundColor(contract.status),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusBorderColor(contract.status)),
                  ),
                  child: Text(
                    _getStatusText(contract.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getStatusTextColor(contract.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Client name
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  contract.clientName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Amount and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${contract.amount.toStringAsFixed(0)} RON',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successColor,
                  ),
                ),
                Text(
                  _formatDate(contract.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'DRAFT':
        return 'CIORNĂ';
      case 'PENDING_SIGNATURE':
        return 'AŞT. SEMN.';
      case 'SIGNED':
        return 'SEMANT';
      case 'COMPLETED':
        return 'COMPLET';
      case 'DECLINED':
        return 'DECLINAT';
      case 'EXPIRED':
        return 'EXPIRAT';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'SIGNED':
      case 'COMPLETED':
        return AppTheme.successColor;
      case 'PENDING_SIGNATURE':
        return Colors.orange;
      case 'DECLINED':
      case 'EXPIRED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'SIGNED':
      case 'COMPLETED':
        return AppTheme.successColor.withValues(alpha: 0.1);
      case 'PENDING_SIGNATURE':
        return Colors.orange.withValues(alpha: 0.1);
      case 'DECLINED':
      case 'EXPIRED':
        return Colors.red.withValues(alpha: 0.1);
      default:
        return Colors.grey.withValues(alpha: 0.1);
    }
  }

  Color _getStatusBorderColor(String status) {
    switch (status) {
      case 'SIGNED':
      case 'COMPLETED':
        return AppTheme.successColor;
      case 'PENDING_SIGNATURE':
        return Colors.orange;
      case 'DECLINED':
      case 'EXPIRED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Astăzi';
      }
      return 'Acum ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ieri';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}z';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}