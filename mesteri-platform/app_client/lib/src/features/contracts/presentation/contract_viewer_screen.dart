import 'package:flutter/material.dart';
import '../../contracts/data/contracts_models.dart';
import '../../contracts/services/contracts_api_service.dart';
import '../../../core/theme/app_theme.dart';

class ContractViewerScreen extends StatefulWidget {
  final Contract contract;
  const ContractViewerScreen({super.key, required this.contract});

  @override
  State<ContractViewerScreen> createState() => _ContractViewerScreenState();
}

class _ContractViewerScreenState extends State<ContractViewerScreen> {
  bool _signing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contract'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Previzualizare PDF: ${widget.contract.pdfUrl}\n\n(Înlocuiește cu viewer PDF real)',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.description_outlined, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contract #${widget.contract.id}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Status: ${widget.contract.status == ContractStatus.signed ? 'Semnat' : 'În așteptare semnături'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    final isSigned = widget.contract.status == ContractStatus.signed;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _signing || isSigned
                ? null
                : () async {
                    setState(() => _signing = true);
                    try {
                      final updated = await ContractsApiService.signContract(
                        contractId: widget.contract.id,
                      );
                      if (!mounted) return;
                      setState(() => _signing = false);
                      Navigator.pop(context, updated);
                    } catch (e) {
                      if (!mounted) return;
                      setState(() => _signing = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Eroare la semnarea contractului: $e'),
                          backgroundColor: AppTheme.errorColor,
                        ),
                      );
                    }
                  },
            child: _signing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Acceptă/semnează'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Închide'),
          ),
        ),
      ],
    );
  }
}
