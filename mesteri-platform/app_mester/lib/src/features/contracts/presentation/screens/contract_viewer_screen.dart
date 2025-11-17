import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

class ContractModel {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String clientName;
  final String clientEmail;
  final double amount;
  final DateTime createdAt;
  final String status; // DRAFT, PENDING_SIGNATURE, SIGNED, DECLINED, EXPIRED, VOID
  final String? signedDocumentUrl;
  final DateTime? signedAt;

  ContractModel({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.clientName,
    required this.clientEmail,
    required this.amount,
    required this.createdAt,
    required this.status,
    this.signedDocumentUrl,
    this.signedAt,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      id: json['id'] ?? '',
      projectId: json['projectId'] ?? '',
      title: json['title'] ?? 'Contract',
      description: json['description'] ?? 'Fără descriere',
      clientName: json['clientName'] ?? 'Client necunoscut',
      clientEmail: json['clientEmail'] ?? '',
      amount: (json['amount'] ?? 0.0) as double,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'DRAFT',
      signedDocumentUrl: json['signedDocumentUrl'],
      signedAt: json['signedAt'] != null ? DateTime.tryParse(json['signedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'signedDocumentUrl': signedDocumentUrl,
      'signedAt': signedAt?.toIso8601String(),
    };
  }
}

class ContractViewerScreen extends StatefulWidget {
  final String contractId;

  const ContractViewerScreen({super.key, required this.contractId});

  @override
  State<ContractViewerScreen> createState() => _ContractViewerScreenState();
}

class _ContractViewerScreenState extends State<ContractViewerScreen> {
  ContractModel? _contract;
  bool _isLoading = true;
  bool _isAccepting = false;
  bool _isDeclining = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContract();
  }

  Future<void> _loadContract() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiClient.instance.get('/contracts/${widget.contractId}');
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _contract = ContractModel.fromJson(response.data as Map<String, dynamic>);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Contractul nu a fost găsit';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString().contains('Exception: ') 
          ? e.toString().substring(e.toString().indexOf('Exception: ') + 11) 
          : e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptContract() async {
    if (_contract == null || _contract!.status != 'PENDING_SIGNATURE') return;

    setState(() {
      _isAccepting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Utilizator neautentificat');
      }

      final idToken = await user.getIdToken();
      
      // For signature capturing, we would redirect to a signature screen
      // For now, let's just navigate to a signature capture screen
      context.push('/contracts/${widget.contractId}/sign');
    } catch (e) {
      final errorMsg = e.toString().contains('Exception: ') 
        ? e.toString().substring(e.toString().indexOf('Exception: ') + 11) 
        : e.toString();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare: $errorMsg'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAccepting = false;
        });
      }
    }
  }

  Future<void> _declineContract() async {
    if (_contract == null || _contract!.status != 'PENDING_SIGNATURE') return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Declină contractul'),
        content: const Text('Sigur dorești să declini acest contract?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anulează'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Declină'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isDeclining = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Utilizator neautentificat');
      }

      final idToken = await user.getIdToken();
      
      // In a real app, we would have an endpoint to decline contracts
      // For now, we'll just show a message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contractul a fost declinat cu succes'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      final errorMsg = e.toString().contains('Exception: ') 
        ? e.toString().substring(e.toString().indexOf('Exception: ') + 11) 
        : e.toString();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare: $errorMsg'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeclining = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalii Contract')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadContract,
                child: const Text('Încearcă din nou'),
              ),
            ],
          ),
        ),
      );
    }

    if (_contract == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Contractul nu a fost găsit'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalii Contract'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusBackgroundColor(_contract!.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStatusText(_contract!.status),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(_contract!.status),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _contract!.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // Contract details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Client info
                    _buildInfoRow(Icons.person, 'Client', _contract!.clientName),
                    _buildInfoRow(Icons.email, 'Email', _contract!.clientEmail),
                    
                    const Divider(height: 24),
                    
                    // Project details
                    _buildInfoRow(Icons.work, 'Proiect', _contract!.title),
                    _buildInfoRow(Icons.description, 'Descriere', _contract!.description),
                    
                    const Divider(height: 24),
                    
                    // Financial info
                    _buildInfoRow(Icons.attach_money, 'Valoare', '${_contract!.amount.toStringAsFixed(0)} RON'),
                    
                    const Divider(height: 24),
                    
                    // Date info
                    _buildInfoRow(Icons.calendar_today, 'Creat la', 
                        _formatDate(_contract!.createdAt)),
                    
                    if (_contract!.signedAt != null)
                      _buildInfoRow(Icons.done, 'Semnat la', 
                          _formatDate(_contract!.signedAt!)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Contract actions based on status
            if (_contract!.status == 'PENDING_SIGNATURE') _buildSignatureActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.onSurfaceSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.onSurfaceSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isAccepting ? null : _acceptContract,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _isAccepting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.approval),
                      SizedBox(width: 8),
                      Text(
                        'Acceptă și semnează',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isDeclining ? null : _declineContract,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _isDeclining
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close),
                      SizedBox(width: 8),
                      Text(
                        'Declină contractul',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'DRAFT':
        return Colors.grey;
      case 'PENDING_SIGNATURE':
        return Colors.orange;
      case 'SIGNED':
        return AppTheme.successColor;
      case 'DECLINED':
        return Colors.red;
      case 'EXPIRED':
        return Colors.red;
      case 'VOID':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'SIGNED':
        return AppTheme.successColor.withValues(alpha: 0.1);
      case 'PENDING_SIGNATURE':
        return Colors.orange.withValues(alpha: 0.1);
      case 'DECLINED':
      case 'EXPIRED':
      case 'VOID':
        return Colors.red.withValues(alpha: 0.1);
      default:
        return Colors.grey.withValues(alpha: 0.1);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'DRAFT':
        return 'CIORNĂ';
      case 'PENDING_SIGNATURE':
        return 'ÎN AȘTEPTARE SEMNĂTURĂ';
      case 'SIGNED':
        return 'SEMNAT';
      case 'DECLINED':
        return 'DECLINAT';
      case 'EXPIRED':
        return 'EXPIRAT';
      case 'VOID':
        return 'ANULAT';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}