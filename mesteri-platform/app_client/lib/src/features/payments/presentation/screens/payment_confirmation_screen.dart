import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/app_config.dart';
import 'package:intl/intl.dart';

// Contract and Payment Status
enum ContractStatus {
  draft,
  pendingSignature,
  signed,
  paymentProcessing,
  completed,
  disputed,
}

extension ContractStatusExtension on ContractStatus {
  String get label {
    switch (this) {
      case ContractStatus.draft:
        return 'CiornÄƒ';
      case ContractStatus.pendingSignature:
        return 'ÃŽn AÈ™teptare SemnÄƒturÄƒ';
      case ContractStatus.signed:
        return 'Semnat';
      case ContractStatus.paymentProcessing:
        return 'Procesare PlatÄƒ';
      case ContractStatus.completed:
        return 'Finalizat';
      case ContractStatus.disputed:
        return 'Contestat';
    }
  }

  Color get color {
    switch (this) {
      case ContractStatus.draft:
        return Colors.grey;
      case ContractStatus.pendingSignature:
        return Colors.orange;
      case ContractStatus.signed:
        return Colors.green;
      case ContractStatus.paymentProcessing:
        return Colors.blue;
      case ContractStatus.completed:
        return Colors.green;
      case ContractStatus.disputed:
        return Colors.red;
    }
  }
}

enum PaymentType {
  upfront50, // 50% upfront
  milestone, // Per milestone
  finalPayment, // Final payment
  subscription, // Regular payments
}

class DigitalContract {
  final String id;
  final String clientId;
  final String clientName;
  final String craftsmanId;
  final String craftsmanName;
  final String projectId;
  final String projectTitle;
  final String projectDescription;
  final List<ContractTerm> terms;
  final List<PaymentMilestone> paymentMilestones;
  final DateTime creationDate;
  final DateTime? signedDate;
  final ContractStatus status;
  final double totalValue;
  final String contractNumber;
  final List<String> attachments;

  const DigitalContract({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.craftsmanId,
    required this.craftsmanName,
    required this.projectId,
    required this.projectTitle,
    required this.projectDescription,
    required this.terms,
    required this.paymentMilestones,
    required this.creationDate,
    this.signedDate,
    this.status = ContractStatus.pendingSignature,
    required this.totalValue,
    required this.contractNumber,
    this.attachments = const [],
  });

  bool get isFullySigned => status == ContractStatus.signed;
  bool get isPendingClientSignature =>
      status == ContractStatus.pendingSignature;
}

class ContractTerm {
  final String id;
  final String title;
  final String content;
  final bool isAccepted;
  final bool isRequired;

  const ContractTerm({
    required this.id,
    required this.title,
    required this.content,
    this.isAccepted = false,
    this.isRequired = true,
  });
}

class PaymentMilestone {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final String status;

  const PaymentMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
    required this.status,
  });
}

class SignatureData {
  final String contractId;
  final String signerId;
  final String signerName;
  final String signerEmail;
  final DateTime signedDate;
  final String ipAddress;
  final String deviceInfo;
  final String legalText;

  const SignatureData({
    required this.contractId,
    required this.signerId,
    required this.signerName,
    required this.signerEmail,
    required this.signedDate,
    required this.ipAddress,
    required this.deviceInfo,
    required this.legalText,
  });
}

// Mock contract data
final mockContract = DigitalContract(
  id: 'contract_001',
  clientId: 'client_001',
  clientName: 'Maria Elena Popescu',
  craftsmanId: 'craftsman_001',
  craftsmanName: 'Ion Dumitrescu',
  projectId: 'proj_001',
  projectTitle: 'ReparaÈ›ie È™i montaj robinet bucÄƒtÄƒrie',
  projectDescription:
      'Se efectueazÄƒ reparaÈ›ia completÄƒ a sistemului de robinet È™i conducta, inclusiv teste de presiune È™i verificare conform normativelor ANRE.',
  creationDate: DateTime.now().subtract(const Duration(days: 1)),
  status: ContractStatus.pendingSignature,
  totalValue: 850.0,
  contractNumber: 'CONT-2024-001234',
  terms: [
    ContractTerm(
      id: 'term1',
      title: 'Drepturile È™i ObligaÈ›iile ParteÈ›i',
      content:
          'MeÈ™terul se obligÄƒ sÄƒ execute lucrÄƒrile cu materiale de calitate È™i conform specificaÈ›iilor, iar Clientul se obligÄƒ sÄƒ plÄƒteascÄƒ conform termenilor.',
      isAccepted: false,
      isRequired: true,
    ),
    ContractTerm(
      id: 'term2',
      title: 'Perioada È™i Termenele de Executare',
      content:
          'LucrÄƒrile vor fi executate Ã®n perioada 10 octombrie - 20 octombrie 2024, cu posibilitatea prelungirii Ã®n cazul obiectivelor neprevÄƒzute.',
      isAccepted: false,
      isRequired: true,
    ),
    ContractTerm(
      id: 'term3',
      title: 'GaranÈ›ia LucrÄƒrilor',
      content:
          'MeÈ™terul acordÄƒ garanÈ›ie de 12 luni pentru toate lucrÄƒrile executate, conform prevederilor legale Ã®n vigoare.',
      isAccepted: false,
      isRequired: true,
    ),
    ContractTerm(
      id: 'term4',
      title: 'Responsabilitate È™i ÃŽnvoire',
      content:
          'Prin semnarea acestui contract, pÄƒrÈ›ile declarÄƒ cÄƒ sunt Ã®n posesia tuturor autorizaÈ›iilor È™i avizelor necesare.',
      isAccepted: false,
      isRequired: true,
    ),
  ],
  paymentMilestones: [
    PaymentMilestone(
      id: 'milestone1',
      title: 'Avans 50% - Etapa 1',
      description:
          'PlatÄƒ avans pentru achiziÈ›ionarea materialelor È™i demontare',
      amount: 425.0,
      dueDate: DateTime.now().add(const Duration(days: 1)),
      status: 'pending',
    ),
    PaymentMilestone(
      id: 'milestone2',
      title: 'PlatÄƒ FinalÄƒ - Etapa 2',
      description: 'Plata restului dupÄƒ finalizarea lucrÄƒrii È™i verificare',
      amount: 425.0,
      dueDate: DateTime.now().add(const Duration(days: 10)),
      status: 'future',
    ),
  ],
);

final mockSignedContract = DigitalContract(
  id: mockContract.id,
  clientId: mockContract.clientId,
  clientName: mockContract.clientName,
  craftsmanId: mockContract.craftsmanId,
  craftsmanName: mockContract.craftsmanName,
  projectId: mockContract.projectId,
  projectTitle: mockContract.projectTitle,
  projectDescription: mockContract.projectDescription,
  terms: mockContract.terms,
  paymentMilestones: mockContract.paymentMilestones,
  creationDate: mockContract.creationDate,
  signedDate: DateTime.now(),
  status: ContractStatus.signed,
  totalValue: mockContract.totalValue,
  contractNumber: mockContract.contractNumber,
  attachments: mockContract.attachments,
);

class PaymentConfirmationScreen extends StatefulWidget {
  final String contractId;
  final bool isReviewMode;

  const PaymentConfirmationScreen({
    super.key,
    required this.contractId,
    this.isReviewMode = false,
  });

  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, bool> _acceptedTerms = {};
  bool _isSigning = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize terms acceptance
    for (var term in mockContract.terms) {
      _acceptedTerms[term.id] = false;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contract = widget.isReviewMode ? mockSignedContract : mockContract;
    final isAllTermsAccepted = _acceptedTerms.values.every(
      (accepted) => accepted,
    );
    final canSignContract =
        isAllTermsAccepted && !widget.isReviewMode && !_isSigning;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmare Contract'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () => _downloadContract(contract),
            tooltip: 'DescarcÄƒ Contract',
          ),
          if (!widget.isReviewMode) ...[
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () => _shareContract(),
              tooltip: 'ÃŽmpÄƒrtÄƒÈ™eaÈ™te Contract',
            ),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.onSurfaceSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.description_rounded), text: 'Contract'),
            Tab(icon: Icon(Icons.assignment_rounded), text: 'Termeni'),
            Tab(icon: Icon(Icons.payment_rounded), text: 'PlatÄƒ'),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContractTab(contract),
          _buildTermsTab(contract),
          _buildPaymentTab(contract),
        ],
      ),

      bottomNavigationBar: widget.isReviewMode
          ? null
          : Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 12 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                border: Border(
                  top: BorderSide(
                    color: AppTheme.outlineColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _rejectContract(),
                      icon: const Icon(Icons.close_rounded, color: Colors.red),
                      label: const Text(
                        'Respinge',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: canSignContract ? _signContract : null,
                      icon: _isSigning
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.draw_rounded),
                      label: Text(
                        _isSigning ? 'Se semneazÄƒ...' : 'SemneazÄƒ Contractul',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canSignContract
                            ? AppTheme.primaryColor
                            : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildContractTab(DigitalContract contract) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contract Header
          _buildContractHeader(contract),

          const SizedBox(height: 24),

          // Project Summary
          _buildProjectSummary(contract),

          const SizedBox(height: 24),

          // Contract Details
          _buildContractDetails(contract),

          const SizedBox(height: 24),

          // Parties Information
          _buildPartiesInfo(contract),

          const SizedBox(height: 24),

          // Contract Signature Status
          if (widget.isReviewMode) _buildSignatureStatus(contract),
        ],
      ),
    );
  }

  Widget _buildContractHeader(DigitalContract contract) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contract Digital',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  contract.contractNumber,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  DateFormat(
                    "d MMM yyyy",
                    "ro_RO",
                  ).format(contract.creationDate),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ContractStatus.pendingSignature.color.withValues(
                alpha: 0.2,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              ContractStatus.pendingSignature.label,
              style: TextStyle(
                color: ContractStatus.pendingSignature.color,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSummary(DigitalContract contract) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalii Proiect',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Text(
            contract.projectTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          Text(
            contract.projectDescription,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.4),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Valoarea TotalÄƒ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.onSurfaceSecondary,
                    ),
                  ),
                  Text(
                    '${contract.totalValue.toStringAsFixed(2)} ${AppConfig.currencySymbol}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'PÄƒrÈ›i implicate',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Client â€¢ MeÈ™ter',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
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

  Widget _buildContractDetails(DigitalContract contract) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Articole Contractuale',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          ...contract.terms.map(
            (term) => Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          term.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          term.content,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.onSurfaceSecondary),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: term.isRequired
                          ? AppTheme.primaryColor.withValues(alpha: 0.1)
                          : AppTheme.successColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      term.isRequired
                          ? Icons.gavel_rounded
                          : Icons.info_outline_rounded,
                      color: term.isRequired
                          ? AppTheme.primaryColor
                          : AppTheme.successColor,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartiesInfo(DigitalContract contract) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PÄƒrÈ›ile Contractuale',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // Client Info
          _buildPartyRow(
            'Client',
            contract.clientName,
            Icons.person_outline_rounded,
            AppTheme.primaryColor,
          ),

          const SizedBox(height: 12),

          // Craftsman Info
          _buildPartyRow(
            'MeseriaÈ™',
            contract.craftsmanName,
            Icons.engineering_rounded,
            AppTheme.successColor,
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: AppTheme.successColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ambele pÄƒrÈ›i sunt Ã®nregistrate È™i verificate Ã®n platforma Mesteri.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.successColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartyRow(String role, String name, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
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
                role,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceSecondary,
                  fontSize: 11,
                ),
              ),
              Text(
                name,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignatureStatus(DigitalContract contract) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.draw_rounded, color: AppTheme.successColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'Contract Semnat Digital',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),

          if (contract.signedDate != null) ...[
            const SizedBox(height: 8),
            Text(
              'Semnat la: ${DateFormat("HH:mm, d MMM yyyy", "ro_RO").format(contract.signedDate!)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.successColor),
            ),
          ],

          const SizedBox(height: 12),

          Row(
            children: [
              _buildSignatureVerification('Client', 'Maria Elena Popescu'),
              const SizedBox(width: 12),
              _buildSignatureVerification('MeseriaÈ™', 'Ion Dumitrescu'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureVerification(String role, String name) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, color: Colors.green, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                  color: AppTheme.successColor,
                ),
              ),
              Text(
                name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTermsTab(DigitalContract contract) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AcceptaÈ›i Termenii Contractuali',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            'Citirea cu atenÈ›ie È™i acceptarea termenilor este necesarÄƒ pentru semnarea digitalÄƒ.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceSecondary,
            ),
          ),

          const SizedBox(height: 24),

          // Terms Checklist
          ...contract.terms.map(
            (term) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: CheckboxListTile(
                title: Text(
                  term.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  term.content,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceSecondary,
                  ),
                ),
                value: _acceptedTerms[term.id] ?? false,
                onChanged: (value) {
                  if (!widget.isReviewMode) {
                    setState(() {
                      _acceptedTerms[term.id] = value ?? false;
                    });
                  }
                },
                activeColor: AppTheme.primaryColor,
                secondary: term.isRequired
                    ? Icon(
                        Icons.gavel_rounded,
                        color: AppTheme.warningColor,
                        size: 20,
                      )
                    : Icon(
                        Icons.info_outline_rounded,
                        color: AppTheme.successColor,
                        size: 20,
                      ),
              ),
            ),
          ),

          // Legal Disclaimer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.warningColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.gavel_rounded,
                      color: AppTheme.warningColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Informare LegalÄƒ',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  'Prin semnarea acestui contract electronic, sunteÈ›i de acord cÄƒ semnÄƒtura dvs. digitalÄƒ are aceeaÈ™i valoare legalÄƒ ca È™i una scrisÄƒ de mÃ¢na proprie, conform Legii 509/2006 privind semnÄƒtura electronicÄƒ.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTab(DigitalContract contract) {
    // This would integrate with the payment system
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Milestones
          ...contract.paymentMilestones.map(_buildPaymentMilestone),

          const SizedBox(height: 24),

          // Payment Security Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.successColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.security_rounded,
                      color: AppTheme.successColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Securitatea PlÄƒÈ›ii',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  'PlÄƒÈ›ile sunt pÄƒstrate Ã®n sistem de escrow pÃ¢nÄƒ la finalizarea lucrÄƒrilor conform contractului.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.successColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Contract action methods
  void _downloadContract(DigitalContract contract) {
    // TODO: Implement contract download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('FuncÈ›ionalitatea de descÄƒrcare va fi implementatÄƒ'),
      ),
    );
  }

  void _shareContract() {
    // TODO: Implement contract sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('FuncÈ›ionalitatea de Ã®mpÄƒrÈ›ire va fi implementatÄƒ'),
      ),
    );
  }

  void _rejectContract() {
    // TODO: Implement contract rejection functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Respinge Contract'),
        content: const Text('Sigur doriÈ›i sÄƒ respingeÈ›i acest contract?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('AnuleazÄƒ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate back to contracts screen
            },
            child: const Text('Respinge'),
          ),
        ],
      ),
    );
  }

  void _signContract() async {
    setState(() => _isSigning = true);

    // Simulate signing process
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isSigning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contract semnÄƒmÃ¢nt cu succes!')),
      );
      // TODO: Navigate to signed contract screen
    }
  }

  Widget _buildPaymentMilestone(PaymentMilestone milestone) {
    final isPending = milestone.status == 'pending';
    final isCompleted = milestone.status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPending
              ? AppTheme.warningColor.withValues(alpha: 0.3)
              : isCompleted
              ? AppTheme.successColor.withValues(alpha: 0.3)
              : AppTheme.outlineColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  milestone.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isPending
                        ? AppTheme.warningColor
                        : isCompleted
                        ? AppTheme.successColor
                        : AppTheme.onSurfaceColor,
                  ),
                ),
              ),
              Text(
                '${milestone.amount.toStringAsFixed(2)} ${AppConfig.currencySymbol}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCompleted
                      ? AppTheme.successColor
                      : AppTheme.primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            milestone.description,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceSecondary),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPending
                  ? AppTheme.warningColor.withValues(alpha: 0.1)
                  : isCompleted
                  ? AppTheme.successColor.withValues(alpha: 0.1)
                  : AppTheme.outlineColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              milestone.status == 'pending'
                  ? 'ÃŽn AÈ™teptare'
                  : milestone.status == 'completed'
                  ? 'Completat'
                  : 'Viitor',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isPending
                    ? AppTheme.warningColor
                    : isCompleted
                    ? AppTheme.successColor
                    : AppTheme.onSurfaceSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
